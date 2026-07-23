#include "include/stream_thumbnail/stream_thumbnail_plugin.h"

extern "C" {
#include <libavcodec/avcodec.h>
#include <libavformat/avformat.h>
#include <libavutil/dict.h>
#include <libavutil/imgutils.h>
#include <libswscale/swscale.h>
}
#include <webp/encode.h>

#include <flutter_linux/flutter_linux.h>

#include <map>
#include <memory>
#include <stdexcept>
#include <string>
#include <vector>

#include "pigeon/messages.g.h"

#define STREAM_THUMBNAIL_PLUGIN(obj) \
  (G_TYPE_CHECK_INSTANCE_CAST((obj), stream_thumbnail_plugin_get_type(), StreamThumbnailPlugin))

struct _StreamThumbnailPlugin {
  GObject parent_instance;
};

G_DEFINE_TYPE(StreamThumbnailPlugin, stream_thumbnail_plugin, g_object_get_type())

namespace {

// A generation failure that couldn't produce a frame/encode, or a failure
// writing the encoded thumbnail to disk.
class ThumbnailException : public std::runtime_error {
 public:
  ThumbnailException(std::string code, const std::string &message)
      : std::runtime_error(message), code_(std::move(code)) {}
  const std::string &code() const { return code_; }

 private:
  std::string code_;
};

struct FormatContextDeleter {
  void operator()(AVFormatContext *ctx) const { avformat_close_input(&ctx); }
};
struct CodecContextDeleter {
  void operator()(AVCodecContext *ctx) const { avcodec_free_context(&ctx); }
};
struct FrameDeleter {
  void operator()(AVFrame *frame) const { av_frame_free(&frame); }
};
struct PacketDeleter {
  void operator()(AVPacket *packet) const { av_packet_free(&packet); }
};
struct SwsContextDeleter {
  void operator()(SwsContext *ctx) const { sws_freeContext(ctx); }
};

using FormatContextPtr = std::unique_ptr<AVFormatContext, FormatContextDeleter>;
using CodecContextPtr = std::unique_ptr<AVCodecContext, CodecContextDeleter>;
using FramePtr = std::unique_ptr<AVFrame, FrameDeleter>;
using PacketPtr = std::unique_ptr<AVPacket, PacketDeleter>;
using SwsContextPtr = std::unique_ptr<SwsContext, SwsContextDeleter>;

bool IsLocalPath(const std::string &video) {
  return video.rfind("/", 0) == 0 || video.rfind("file://", 0) == 0;
}

// Strips a leading "file://" prefix, if present.
std::string VideoPath(const std::string &video) {
  if (video.rfind("file://", 0) == 0) return video.substr(7);
  return video;
}

std::string FileExtension(ThumbnailFormat format) {
  switch (format) {
    case STREAM_THUMBNAIL_THUMBNAIL_FORMAT_JPEG:
      return "jpg";
    case STREAM_THUMBNAIL_THUMBNAIL_FORMAT_PNG:
      return "png";
    case STREAM_THUMBNAIL_THUMBNAIL_FORMAT_WEBP:
      return "webp";
  }
  return "jpg";
}

// Decodes a single frame from `video` at `time_ms`, at its native resolution
// and pixel format. Unlike Media Foundation (Windows), FFmpeg's http(s)
// protocol handler has a simple, direct way to attach custom headers.
FramePtr DecodeFrame(const std::string &video, const std::map<std::string, std::string> *headers, int64_t time_ms) {
  AVDictionary *options = nullptr;
  if (headers != nullptr && !headers->empty()) {
    std::string header_lines;
    for (const auto &[key, value] : *headers) {
      header_lines += key + ": " + value + "\r\n";
    }
    av_dict_set(&options, "headers", header_lines.c_str(), 0);
  }

  AVFormatContext *raw_format_ctx = nullptr;
  const int open_result = avformat_open_input(&raw_format_ctx, video.c_str(), nullptr, &options);
  av_dict_free(&options);
  if (open_result < 0) {
    throw ThumbnailException("THUMBNAIL_ERROR", "Failed to open the video.");
  }
  FormatContextPtr format_ctx(raw_format_ctx);

  if (avformat_find_stream_info(format_ctx.get(), nullptr) < 0) {
    throw ThumbnailException("THUMBNAIL_ERROR", "Failed to read the video's stream info.");
  }

  const AVCodec *decoder = nullptr;
  const int stream_index = av_find_best_stream(format_ctx.get(), AVMEDIA_TYPE_VIDEO, -1, -1, &decoder, 0);
  if (stream_index < 0 || decoder == nullptr) {
    throw ThumbnailException("THUMBNAIL_ERROR", "Failed to find a video stream.");
  }

  AVStream *stream = format_ctx->streams[stream_index];
  CodecContextPtr codec_ctx(avcodec_alloc_context3(decoder));
  if (!codec_ctx || avcodec_parameters_to_context(codec_ctx.get(), stream->codecpar) < 0) {
    throw ThumbnailException("THUMBNAIL_ERROR", "Failed to configure the video decoder.");
  }
  if (avcodec_open2(codec_ctx.get(), decoder, nullptr) < 0) {
    throw ThumbnailException("THUMBNAIL_ERROR", "Failed to open the video decoder.");
  }

  if (time_ms > 0) {
    const int64_t timestamp = av_rescale_q(time_ms, AVRational{1, 1000}, stream->time_base);
    av_seek_frame(format_ctx.get(), stream_index, timestamp, AVSEEK_FLAG_BACKWARD);
  }

  PacketPtr packet(av_packet_alloc());
  FramePtr frame(av_frame_alloc());
  bool have_frame = false;

  while (!have_frame && av_read_frame(format_ctx.get(), packet.get()) >= 0) {
    if (packet->stream_index == stream_index && avcodec_send_packet(codec_ctx.get(), packet.get()) == 0) {
      if (avcodec_receive_frame(codec_ctx.get(), frame.get()) == 0) {
        have_frame = true;
      }
    }
    av_packet_unref(packet.get());
  }
  if (!have_frame) {
    // Flush: the last packet(s) may not have produced a frame until the
    // decoder is told there's no more input.
    avcodec_send_packet(codec_ctx.get(), nullptr);
    have_frame = avcodec_receive_frame(codec_ctx.get(), frame.get()) == 0;
  }
  if (!have_frame) {
    throw ThumbnailException("THUMBNAIL_ERROR", "Failed to read a video frame.");
  }

  return frame;
}

// Computes the output size, honoring max_width/max_height (<= 0 keeps the
// source resolution), preserving aspect ratio.
void ScaledSize(int src_width, int src_height, int64_t max_width, int64_t max_height, int *out_width,
                 int *out_height) {
  if (max_width <= 0 && max_height <= 0) {
    *out_width = src_width;
    *out_height = src_height;
    return;
  }
  const double aspect = static_cast<double>(src_width) / static_cast<double>(src_height);
  double width = max_width > 0 ? static_cast<double>(max_width) : max_height * aspect;
  double height = max_height > 0 ? static_cast<double>(max_height) : max_width / aspect;
  if (max_width > 0 && max_height > 0) {
    if (width / aspect > height) {
      width = height * aspect;
    } else {
      height = width / aspect;
    }
  }
  *out_width = static_cast<int>(width);
  *out_height = static_cast<int>(height);
}

// Scales `src` into a newly-allocated frame in `dst_format` at
// `width`x`height`.
FramePtr ScaleFrame(const AVFrame *src, AVPixelFormat dst_format, int width, int height) {
  SwsContextPtr sws(sws_getContext(src->width, src->height, static_cast<AVPixelFormat>(src->format), width, height,
                                    dst_format, SWS_BILINEAR, nullptr, nullptr, nullptr));
  if (!sws) {
    throw ThumbnailException("THUMBNAIL_ERROR", "Failed to scale the decoded frame.");
  }

  FramePtr dst(av_frame_alloc());
  dst->width = width;
  dst->height = height;
  dst->format = dst_format;
  dst->color_range = AVCOL_RANGE_JPEG;
  if (av_frame_get_buffer(dst.get(), 0) < 0) {
    throw ThumbnailException("THUMBNAIL_ERROR", "Failed to allocate the scaled frame.");
  }
  sws_scale(sws.get(), src->data, src->linesize, 0, src->height, dst->data, dst->linesize);
  return dst;
}

// Encodes an already-scaled `frame` via a libavcodec image encoder (mjpeg or
// png). `quality` (0-100) only applies to jpeg.
std::vector<uint8_t> EncodeWithCodec(AVCodecID codec_id, const AVFrame *frame, int64_t quality) {
  const AVCodec *encoder = avcodec_find_encoder(codec_id);
  if (!encoder) {
    throw ThumbnailException("THUMBNAIL_ERROR", "No encoder available for the requested format.");
  }

  CodecContextPtr codec_ctx(avcodec_alloc_context3(encoder));
  codec_ctx->width = frame->width;
  codec_ctx->height = frame->height;
  codec_ctx->pix_fmt = static_cast<AVPixelFormat>(frame->format);
  codec_ctx->time_base = AVRational{1, 1};
  codec_ctx->color_range = frame->color_range;
  if (codec_id == AV_CODEC_ID_MJPEG) {
    codec_ctx->flags |= AV_CODEC_FLAG_QSCALE;
    // FFmpeg's qscale is inverted (lower is better); map 0-100 quality onto
    // its ~2-31 usable range.
    codec_ctx->global_quality = FF_QP2LAMBDA * (2 + (31 - 2) * (100 - quality) / 100);
  }
  if (avcodec_open2(codec_ctx.get(), encoder, nullptr) < 0) {
    throw ThumbnailException("THUMBNAIL_ERROR", "Failed to open the image encoder.");
  }

  PacketPtr packet(av_packet_alloc());
  if (avcodec_send_frame(codec_ctx.get(), frame) < 0) {
    throw ThumbnailException("THUMBNAIL_ERROR", "Failed to encode the thumbnail image.");
  }
  avcodec_send_frame(codec_ctx.get(), nullptr);  // Flush.
  if (avcodec_receive_packet(codec_ctx.get(), packet.get()) < 0) {
    throw ThumbnailException("THUMBNAIL_ERROR", "Failed to encode the thumbnail image.");
  }

  return std::vector<uint8_t>(packet->data, packet->data + packet->size);
}

// Encodes an already-scaled RGB24 `frame` as WebP.
std::vector<uint8_t> EncodeWebP(const AVFrame *frame, int64_t quality) {
  uint8_t *output = nullptr;
  size_t size;
  if (quality >= 100) {
    size = WebPEncodeLosslessRGB(frame->data[0], frame->width, frame->height, frame->linesize[0], &output);
  } else {
    size = WebPEncodeRGB(frame->data[0], frame->width, frame->height, frame->linesize[0],
                          static_cast<float>(quality), &output);
  }
  if (size == 0 || output == nullptr) {
    throw ThumbnailException("THUMBNAIL_ERROR", "Failed to encode the thumbnail as WebP.");
  }
  std::vector<uint8_t> result(output, output + size);
  WebPFree(output);
  return result;
}

std::vector<uint8_t> GenerateThumbnailData(const std::string &video, const std::map<std::string, std::string> *headers,
                                            ThumbnailFormat format, int64_t max_width, int64_t max_height,
                                            int64_t time_ms, int64_t quality) {
  const FramePtr native = DecodeFrame(VideoPath(video), headers, time_ms);

  int width, height;
  ScaledSize(native->width, native->height, max_width, max_height, &width, &height);

  switch (format) {
    case STREAM_THUMBNAIL_THUMBNAIL_FORMAT_JPEG: {
      const FramePtr scaled = ScaleFrame(native.get(), AV_PIX_FMT_YUV420P, width, height);
      return EncodeWithCodec(AV_CODEC_ID_MJPEG, scaled.get(), quality);
    }
    case STREAM_THUMBNAIL_THUMBNAIL_FORMAT_PNG: {
      const FramePtr scaled = ScaleFrame(native.get(), AV_PIX_FMT_RGB24, width, height);
      return EncodeWithCodec(AV_CODEC_ID_PNG, scaled.get(), quality);
    }
    case STREAM_THUMBNAIL_THUMBNAIL_FORMAT_WEBP: {
      const FramePtr scaled = ScaleFrame(native.get(), AV_PIX_FMT_RGB24, width, height);
      return EncodeWebP(scaled.get(), quality);
    }
  }
  throw ThumbnailException("THUMBNAIL_ERROR", "Unknown image format.");
}

std::string WriteThumbnailFile(const std::string &video, const std::map<std::string, std::string> *headers,
                                const std::string *thumbnail_path, ThumbnailFormat format, int64_t max_width,
                                int64_t max_height, int64_t time_ms, int64_t quality) {
  const std::vector<uint8_t> data = GenerateThumbnailData(video, headers, format, max_width, max_height, time_ms, quality);
  const std::string ext = FileExtension(format);
  const std::string video_path = VideoPath(video);

  std::string save_path = thumbnail_path != nullptr ? *thumbnail_path : std::string();
  if (save_path.empty() && !IsLocalPath(video)) {
    save_path = g_get_tmp_dir();
  }

  const size_t dot = video_path.find_last_of('.');
  const std::string base = dot == std::string::npos ? video_path : video_path.substr(0, dot);

  std::string full_path;
  if (!save_path.empty()) {
    const bool ends_with_ext =
        save_path.size() >= ext.size() && save_path.compare(save_path.size() - ext.size(), ext.size(), ext) == 0;
    if (ends_with_ext) {
      full_path = save_path;
    } else {
      const size_t slash = base.find_last_of('/');
      const std::string file_name = (slash == std::string::npos ? base : base.substr(slash + 1)) + "." + ext;
      full_path = save_path.back() == '/' ? save_path + file_name : save_path + "/" + file_name;
    }
  } else {
    full_path = base + "." + ext;
  }

  GError *error = nullptr;
  if (!g_file_set_contents(full_path.c_str(), reinterpret_cast<const gchar *>(data.data()), data.size(), &error)) {
    const std::string message = error != nullptr ? error->message : "Failed to write the thumbnail to disk.";
    if (error != nullptr) g_error_free(error);
    throw ThumbnailException("WRITE_ERROR", message);
  }

  return full_path;
}

// Extracts a std::map<string,string> from a nullable FlValue map, or nullptr
// if `headers` is null.
std::unique_ptr<std::map<std::string, std::string>> ExtractHeaders(FlValue *headers) {
  if (headers == nullptr || fl_value_get_type(headers) != FL_VALUE_TYPE_MAP) return nullptr;
  auto result = std::make_unique<std::map<std::string, std::string>>();
  const size_t count = fl_value_get_length(headers);
  for (size_t i = 0; i < count; i++) {
    FlValue *key = fl_value_get_map_key(headers, i);
    FlValue *value = fl_value_get_map_value(headers, i);
    if (fl_value_get_type(key) == FL_VALUE_TYPE_STRING && fl_value_get_type(value) == FL_VALUE_TYPE_STRING) {
      (*result)[fl_value_get_string(key)] = fl_value_get_string(value);
    }
  }
  return result;
}

// Task data + result plumbing shared by both async methods. A background
// GTask (run via g_task_run_in_thread) does the decode/encode work, then its
// completion callback — invoked back on the thread that owns this
// GMainContext, per GTask's documented contract — replies to Flutter. This
// avoids calling into the generated FlBasicMessageChannel-backed respond
// functions from a non-main thread.
struct ThumbnailDataTaskData {
  std::string video;
  std::unique_ptr<std::map<std::string, std::string>> headers;
  ThumbnailFormat format;
  int64_t max_width;
  int64_t max_height;
  int64_t time_ms;
  int64_t quality;
};

struct ThumbnailDataResult {
  bool ok = false;
  std::vector<uint8_t> bytes;
  std::string error_code;
  std::string error_message;
};

struct ThumbnailFileTaskData {
  std::string video;
  std::unique_ptr<std::map<std::string, std::string>> headers;
  std::string thumbnail_path;
  bool has_thumbnail_path;
  ThumbnailFormat format;
  int64_t max_width;
  int64_t max_height;
  int64_t time_ms;
  int64_t quality;
};

struct ThumbnailFileResult {
  bool ok = false;
  std::string path;
  std::string error_code;
  std::string error_message;
};

void ThumbnailDataThread(GTask *task, gpointer, gpointer task_data, GCancellable *) {
  auto *data = static_cast<ThumbnailDataTaskData *>(task_data);
  auto *result = new ThumbnailDataResult();
  try {
    result->bytes =
        GenerateThumbnailData(data->video, data->headers.get(), data->format, data->max_width, data->max_height,
                               data->time_ms, data->quality);
    result->ok = true;
  } catch (const ThumbnailException &e) {
    result->error_code = e.code();
    result->error_message = e.what();
  }
  g_task_return_pointer(task, result, [](gpointer p) { delete static_cast<ThumbnailDataResult *>(p); });
}

void OnThumbnailDataDone(GObject *, GAsyncResult *res, gpointer user_data) {
  // Not g_autoptr: the generated header doesn't declare a
  // G_DEFINE_AUTOPTR_CLEANUP_FUNC for StreamThumbnailHostApiResponseHandle.
  StreamThumbnailHostApiResponseHandle *handle = STREAM_THUMBNAIL_HOST_API_RESPONSE_HANDLE(user_data);
  std::unique_ptr<ThumbnailDataResult> result(
      static_cast<ThumbnailDataResult *>(g_task_propagate_pointer(G_TASK(res), nullptr)));
  if (result->ok) {
    stream_thumbnail_host_api_respond_thumbnail_data(handle, result->bytes.data(), result->bytes.size());
  } else {
    stream_thumbnail_host_api_respond_error_thumbnail_data(handle, result->error_code.c_str(),
                                                            result->error_message.c_str(), nullptr);
  }
  g_object_unref(handle);
}

void ThumbnailFileThread(GTask *task, gpointer, gpointer task_data, GCancellable *) {
  auto *data = static_cast<ThumbnailFileTaskData *>(task_data);
  auto *result = new ThumbnailFileResult();
  try {
    result->path = WriteThumbnailFile(data->video, data->headers.get(),
                                       data->has_thumbnail_path ? &data->thumbnail_path : nullptr, data->format,
                                       data->max_width, data->max_height, data->time_ms, data->quality);
    result->ok = true;
  } catch (const ThumbnailException &e) {
    result->error_code = e.code();
    result->error_message = e.what();
  }
  g_task_return_pointer(task, result, [](gpointer p) { delete static_cast<ThumbnailFileResult *>(p); });
}

void OnThumbnailFileDone(GObject *, GAsyncResult *res, gpointer user_data) {
  StreamThumbnailHostApiResponseHandle *handle = STREAM_THUMBNAIL_HOST_API_RESPONSE_HANDLE(user_data);
  std::unique_ptr<ThumbnailFileResult> result(
      static_cast<ThumbnailFileResult *>(g_task_propagate_pointer(G_TASK(res), nullptr)));
  if (result->ok) {
    stream_thumbnail_host_api_respond_thumbnail_file(handle, result->path.c_str());
  } else {
    stream_thumbnail_host_api_respond_error_thumbnail_file(handle, result->error_code.c_str(),
                                                            result->error_message.c_str(), nullptr);
  }
  g_object_unref(handle);
}

void HandleThumbnailData(ThumbnailRequest *request, StreamThumbnailHostApiResponseHandle *response_handle,
                          gpointer) {
  auto *data = new ThumbnailDataTaskData{
      thumbnail_request_get_video(request),
      ExtractHeaders(thumbnail_request_get_headers(request)),
      thumbnail_request_get_format(request),
      thumbnail_request_get_max_width(request),
      thumbnail_request_get_max_height(request),
      thumbnail_request_get_time_ms(request),
      thumbnail_request_get_quality(request),
  };

  GTask *task = g_task_new(nullptr, nullptr, OnThumbnailDataDone, g_object_ref(response_handle));
  g_task_set_task_data(task, data, [](gpointer p) { delete static_cast<ThumbnailDataTaskData *>(p); });
  g_task_run_in_thread(task, ThumbnailDataThread);
  g_object_unref(task);
}

void HandleThumbnailFile(ThumbnailRequest *request, StreamThumbnailHostApiResponseHandle *response_handle,
                          gpointer) {
  const gchar *thumbnail_path = thumbnail_request_get_thumbnail_path(request);
  auto *data = new ThumbnailFileTaskData{
      thumbnail_request_get_video(request),
      ExtractHeaders(thumbnail_request_get_headers(request)),
      thumbnail_path != nullptr ? std::string(thumbnail_path) : std::string(),
      thumbnail_path != nullptr,
      thumbnail_request_get_format(request),
      thumbnail_request_get_max_width(request),
      thumbnail_request_get_max_height(request),
      thumbnail_request_get_time_ms(request),
      thumbnail_request_get_quality(request),
  };

  GTask *task = g_task_new(nullptr, nullptr, OnThumbnailFileDone, g_object_ref(response_handle));
  g_task_set_task_data(task, data, [](gpointer p) { delete static_cast<ThumbnailFileTaskData *>(p); });
  g_task_run_in_thread(task, ThumbnailFileThread);
  g_object_unref(task);
}

constexpr StreamThumbnailHostApiVTable kVTable = {
    HandleThumbnailData,
    HandleThumbnailFile,
};

}  // namespace

static void stream_thumbnail_plugin_dispose(GObject *object) {
  G_OBJECT_CLASS(stream_thumbnail_plugin_parent_class)->dispose(object);
}

static void stream_thumbnail_plugin_class_init(StreamThumbnailPluginClass *klass) {
  G_OBJECT_CLASS(klass)->dispose = stream_thumbnail_plugin_dispose;
}

static void stream_thumbnail_plugin_init(StreamThumbnailPlugin *) {}

void stream_thumbnail_plugin_register_with_registrar(FlPluginRegistrar *registrar) {
  StreamThumbnailPlugin *plugin =
      STREAM_THUMBNAIL_PLUGIN(g_object_new(stream_thumbnail_plugin_get_type(), nullptr));

  stream_thumbnail_host_api_set_method_handlers(fl_plugin_registrar_get_messenger(registrar), nullptr, &kVTable,
                                                 g_object_ref(plugin), g_object_unref);

  g_object_unref(plugin);
}
