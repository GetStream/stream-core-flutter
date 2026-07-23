#include "stream_thumbnail_plugin.h"

// This must be included before many other Windows headers.
#include <windows.h>

#include <mfapi.h>
#include <mferror.h>
#include <mfidl.h>
#include <mfreadwrite.h>
#include <propvarutil.h>
#include <shlwapi.h>
#include <wincodec.h>
#include <wrl/client.h>

#include <flutter/plugin_registrar_windows.h>

#include <cctype>
#include <stdexcept>
#include <string>
#include <thread>
#include <vector>

using Microsoft::WRL::ComPtr;
using stream_thumbnail_windows::ErrorOr;
using stream_thumbnail_windows::FlutterError;
using stream_thumbnail_windows::ThumbnailFormat;
using stream_thumbnail_windows::ThumbnailRequest;

namespace stream_thumbnail {

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

std::wstring Utf8ToWide(const std::string &utf8) {
  if (utf8.empty()) return std::wstring();
  const int size = MultiByteToWideChar(CP_UTF8, 0, utf8.data(), static_cast<int>(utf8.size()), nullptr, 0);
  std::wstring wide(size, 0);
  MultiByteToWideChar(CP_UTF8, 0, utf8.data(), static_cast<int>(utf8.size()), wide.data(), size);
  return wide;
}

std::string WideToUtf8(const std::wstring &wide) {
  if (wide.empty()) return std::string();
  const int size =
      WideCharToMultiByte(CP_UTF8, 0, wide.data(), static_cast<int>(wide.size()), nullptr, 0, nullptr, nullptr);
  std::string utf8(size, 0);
  WideCharToMultiByte(CP_UTF8, 0, wide.data(), static_cast<int>(wide.size()), utf8.data(), size, nullptr, nullptr);
  return utf8;
}

bool IsLocalPath(const std::string &video) {
  if (video.size() >= 2 && std::isalpha(static_cast<unsigned char>(video[0])) && video[1] == ':') return true;
  if (video.rfind("\\\\", 0) == 0) return true;
  if (video.rfind("/", 0) == 0) return true;
  if (video.rfind("file://", 0) == 0) return true;
  return false;
}

// Strips a leading "file://" prefix, if present.
std::string VideoPath(const std::string &video) {
  if (video.rfind("file://", 0) == 0) return video.substr(7);
  return video;
}

std::string FileExtension(ThumbnailFormat format) {
  switch (format) {
    case ThumbnailFormat::kJpeg:
      return "jpg";
    case ThumbnailFormat::kPng:
      return "png";
    case ThumbnailFormat::kWebp:
      return "webp";
  }
  return "jpg";
}

// A single decoded video frame as a flat, contiguous BGRX (32bpp) buffer.
struct DecodedFrame {
  std::vector<uint8_t> pixels;
  UINT32 width = 0;
  UINT32 height = 0;
  LONG stride = 0;
};

// Decodes a single frame from `video` at `time_ms` via Media Foundation.
//
// NOTE: unlike AVFoundation (iOS/macOS) and MediaMetadataRetriever (Android),
// IMFSourceReader has no simple way to attach custom HTTP headers to a remote
// URL, so `request.headers()` is not applied on Windows.
DecodedFrame DecodeFrame(const std::string &video, int64_t time_ms) {
  ComPtr<IMFAttributes> attributes;
  ComPtr<IMFSourceReader> reader;
  ComPtr<IMFMediaType> type;
  ComPtr<IMFMediaType> current_type;
  ComPtr<IMFSample> sample;
  ComPtr<IMFMediaBuffer> buffer;

  HRESULT hr = MFCreateAttributes(&attributes, 1);
  if (SUCCEEDED(hr)) {
    hr = attributes->SetUINT32(MF_SOURCE_READER_ENABLE_VIDEO_PROCESSING, TRUE);
  }

  const std::wstring wide_path = Utf8ToWide(VideoPath(video));
  if (SUCCEEDED(hr)) {
    hr = MFCreateSourceReaderFromURL(wide_path.c_str(), attributes.Get(), &reader);
  }
  if (FAILED(hr)) {
    throw ThumbnailException("THUMBNAIL_ERROR", "Failed to open the video.");
  }

  // Ask the source reader to hand back progressive RGB32 frames; its
  // internal video processor performs any necessary YUV -> RGB conversion.
  hr = MFCreateMediaType(&type);
  if (SUCCEEDED(hr)) hr = type->SetGUID(MF_MT_MAJOR_TYPE, MFMediaType_Video);
  if (SUCCEEDED(hr)) hr = type->SetGUID(MF_MT_SUBTYPE, MFVideoFormat_RGB32);
  if (SUCCEEDED(hr)) {
    hr = reader->SetCurrentMediaType(static_cast<DWORD>(MF_SOURCE_READER_FIRST_VIDEO_STREAM), nullptr, type.Get());
  }
  if (SUCCEEDED(hr)) {
    hr = reader->SetStreamSelection(static_cast<DWORD>(MF_SOURCE_READER_FIRST_VIDEO_STREAM), TRUE);
  }
  if (FAILED(hr)) {
    throw ThumbnailException("THUMBNAIL_ERROR", "Failed to configure the video decoder.");
  }

  UINT32 width = 0, height = 0;
  hr = reader->GetCurrentMediaType(static_cast<DWORD>(MF_SOURCE_READER_FIRST_VIDEO_STREAM), &current_type);
  if (SUCCEEDED(hr)) hr = MFGetAttributeSize(current_type.Get(), MF_MT_FRAME_SIZE, &width, &height);
  if (FAILED(hr) || width == 0 || height == 0) {
    throw ThumbnailException("THUMBNAIL_ERROR", "Failed to read the video's frame size.");
  }

  // Seek, if possible; `time_ms` is already platform-normalized (never
  // negative) on the Dart side. Seek failures are non-fatal — fall back to
  // whatever frame ReadSample returns first.
  if (time_ms > 0) {
    PROPVARIANT position;
    PropVariantInit(&position);
    position.vt = VT_I8;
    position.hVal.QuadPart = time_ms * 10000LL;  // milliseconds -> 100ns units.
    reader->SetCurrentPosition(GUID_NULL, position);
    PropVariantClear(&position);
  }

  DWORD flags = 0;
  hr = reader->ReadSample(static_cast<DWORD>(MF_SOURCE_READER_FIRST_VIDEO_STREAM), 0, nullptr, &flags, nullptr,
                           &sample);
  if (FAILED(hr) || !sample) {
    throw ThumbnailException("THUMBNAIL_ERROR", "Failed to read a video frame.");
  }

  hr = sample->ConvertToContiguousBuffer(&buffer);
  if (FAILED(hr)) {
    throw ThumbnailException("THUMBNAIL_ERROR", "Failed to read the decoded frame buffer.");
  }

  BYTE *data = nullptr;
  DWORD data_length = 0;
  hr = buffer->Lock(&data, nullptr, &data_length);
  if (FAILED(hr)) {
    throw ThumbnailException("THUMBNAIL_ERROR", "Failed to lock the decoded frame buffer.");
  }

  DecodedFrame frame;
  frame.width = width;
  frame.height = height;
  frame.stride = static_cast<LONG>(width) * 4;  // RGB32 is a tightly-packed 32bpp format.
  frame.pixels.assign(data, data + data_length);
  buffer->Unlock();

  return frame;
}

// Computes the output size for `frame`, honoring `max_width`/`max_height`
// (<= 0 keeps the source resolution), preserving aspect ratio.
void ScaledSize(const DecodedFrame &frame, int64_t max_width, int64_t max_height, UINT *out_width,
                 UINT *out_height) {
  if (max_width <= 0 && max_height <= 0) {
    *out_width = frame.width;
    *out_height = frame.height;
    return;
  }
  const double aspect = static_cast<double>(frame.width) / static_cast<double>(frame.height);
  double width = max_width > 0 ? static_cast<double>(max_width) : max_height * aspect;
  double height = max_height > 0 ? static_cast<double>(max_height) : max_width / aspect;
  if (max_width > 0 && max_height > 0 && width / aspect > height) {
    width = height * aspect;
  } else if (max_width > 0 && max_height > 0) {
    height = width / aspect;
  }
  *out_width = static_cast<UINT>(width);
  *out_height = static_cast<UINT>(height);
}

// Encodes `frame` as jpeg/png into `stream` via WIC. `quality` (0-100) only
// applies to jpeg.
void EncodeToStream(const DecodedFrame &frame, ThumbnailFormat format, int64_t max_width, int64_t max_height,
                     int64_t quality, IStream *stream) {
  ComPtr<IWICImagingFactory> factory;
  HRESULT hr = CoCreateInstance(CLSID_WICImagingFactory, nullptr, CLSCTX_INPROC_SERVER, IID_PPV_ARGS(&factory));
  if (FAILED(hr)) {
    throw ThumbnailException("THUMBNAIL_ERROR", "Failed to create the imaging factory.");
  }

  ComPtr<IWICBitmap> bitmap;
  // Media Foundation's RGB32 is a 32bpp BGR format with an unused byte (no
  // meaningful alpha channel) — WICPixelFormat32bppBGR matches it exactly.
  hr = factory->CreateBitmapFromMemory(frame.width, frame.height, GUID_WICPixelFormat32bppBGR, frame.stride,
                                        static_cast<UINT>(frame.pixels.size()),
                                        const_cast<BYTE *>(frame.pixels.data()), &bitmap);
  if (FAILED(hr)) {
    throw ThumbnailException("THUMBNAIL_ERROR", "Failed to wrap the decoded frame.");
  }

  ComPtr<IWICBitmapSource> source = bitmap;
  UINT target_width = 0, target_height = 0;
  ScaledSize(frame, max_width, max_height, &target_width, &target_height);
  if (target_width != frame.width || target_height != frame.height) {
    ComPtr<IWICBitmapScaler> scaler;
    hr = factory->CreateBitmapScaler(&scaler);
    if (SUCCEEDED(hr)) {
      hr = scaler->Initialize(bitmap.Get(), target_width, target_height, WICBitmapInterpolationModeFant);
    }
    if (FAILED(hr)) {
      throw ThumbnailException("THUMBNAIL_ERROR", "Failed to scale the decoded frame.");
    }
    source = scaler;
  }

  const GUID container_format = format == ThumbnailFormat::kPng ? GUID_ContainerFormatPng : GUID_ContainerFormatJpeg;

  ComPtr<IWICBitmapEncoder> encoder;
  hr = factory->CreateEncoder(container_format, nullptr, &encoder);
  if (SUCCEEDED(hr)) hr = encoder->Initialize(stream, WICBitmapEncoderNoCache);

  ComPtr<IWICBitmapFrameEncode> frame_encode;
  ComPtr<IPropertyBag2> properties;
  if (SUCCEEDED(hr)) hr = encoder->CreateNewFrame(&frame_encode, &properties);

  if (SUCCEEDED(hr) && format == ThumbnailFormat::kJpeg) {
    PROPBAG2 option = {};
    option.pstrName = const_cast<LPOLESTR>(L"ImageQuality");
    VARIANT value;
    VariantInit(&value);
    value.vt = VT_R4;
    value.fltVal = static_cast<FLOAT>(quality) / 100.0f;
    properties->Write(1, &option, &value);
  }

  if (SUCCEEDED(hr)) hr = frame_encode->Initialize(properties.Get());
  if (SUCCEEDED(hr)) hr = frame_encode->SetSize(target_width, target_height);

  WICPixelFormatGUID pixel_format = GUID_WICPixelFormat24bppBGR;
  if (SUCCEEDED(hr)) hr = frame_encode->SetPixelFormat(&pixel_format);

  ComPtr<IWICFormatConverter> converter;
  if (SUCCEEDED(hr)) hr = factory->CreateFormatConverter(&converter);
  if (SUCCEEDED(hr)) {
    hr = converter->Initialize(source.Get(), pixel_format, WICBitmapDitherTypeNone, nullptr, 0.0,
                                WICBitmapPaletteTypeCustom);
  }
  if (SUCCEEDED(hr)) hr = frame_encode->WriteSource(converter.Get(), nullptr);
  if (SUCCEEDED(hr)) hr = frame_encode->Commit();
  if (SUCCEEDED(hr)) hr = encoder->Commit();

  if (FAILED(hr)) {
    throw ThumbnailException("THUMBNAIL_ERROR", "Failed to encode the thumbnail image.");
  }
}

std::vector<uint8_t> GenerateThumbnailData(const ThumbnailRequest &request) {
  if (request.format() == ThumbnailFormat::kWebp) {
    throw ThumbnailException("UNSUPPORTED_FORMAT", "WebP is not yet supported on Windows.");
  }

  const DecodedFrame frame = DecodeFrame(request.video(), request.time_ms());

  ComPtr<IStream> stream;
  HRESULT hr = CreateStreamOnHGlobal(nullptr, TRUE, &stream);
  if (FAILED(hr)) {
    throw ThumbnailException("THUMBNAIL_ERROR", "Failed to allocate an output buffer.");
  }

  EncodeToStream(frame, request.format(), request.max_width(), request.max_height(), request.quality(),
                  stream.Get());

  STATSTG stats = {};
  stream->Stat(&stats, STATFLAG_NONAME);
  const ULONG size = static_cast<ULONG>(stats.cbSize.QuadPart);

  LARGE_INTEGER zero = {};
  stream->Seek(zero, STREAM_SEEK_SET, nullptr);

  std::vector<uint8_t> bytes(size);
  ULONG read = 0;
  stream->Read(bytes.data(), size, &read);
  bytes.resize(read);
  return bytes;
}

std::string WriteThumbnailFile(const ThumbnailRequest &request) {
  const std::vector<uint8_t> data = GenerateThumbnailData(request);
  const std::string ext = FileExtension(request.format());
  const std::string video_path = VideoPath(request.video());

  std::string save_path = request.thumbnail_path() != nullptr ? *request.thumbnail_path() : std::string();
  if (save_path.empty() && !IsLocalPath(request.video())) {
    wchar_t temp_path[MAX_PATH];
    GetTempPathW(MAX_PATH, temp_path);
    save_path = WideToUtf8(temp_path);
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
      const size_t slash = base.find_last_of("/\\");
      const std::string file_name = (slash == std::string::npos ? base : base.substr(slash + 1)) + "." + ext;
      const bool trailing_slash = save_path.back() == '/' || save_path.back() == '\\';
      full_path = trailing_slash ? save_path + file_name : save_path + "\\" + file_name;
    }
  } else {
    full_path = base + "." + ext;
  }

  const std::wstring wide_path = Utf8ToWide(full_path);
  ComPtr<IStream> file_stream;
  HRESULT hr = SHCreateStreamOnFileEx(wide_path.c_str(), STGM_CREATE | STGM_WRITE | STGM_SHARE_EXCLUSIVE, 0, TRUE,
                                       nullptr, &file_stream);
  ULONG written = 0;
  if (SUCCEEDED(hr)) hr = file_stream->Write(data.data(), static_cast<ULONG>(data.size()), &written);
  if (FAILED(hr) || written != data.size()) {
    throw ThumbnailException("WRITE_ERROR", "Failed to write the thumbnail to disk.");
  }

  return full_path;
}

}  // namespace

// static
void StreamThumbnailPlugin::RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar) {
  auto plugin = std::make_unique<StreamThumbnailPlugin>();
  stream_thumbnail_windows::StreamThumbnailHostApi::SetUp(registrar->messenger(), plugin.get());
  registrar->AddPlugin(std::move(plugin));
}

StreamThumbnailPlugin::StreamThumbnailPlugin() { MFStartup(MF_VERSION); }

StreamThumbnailPlugin::~StreamThumbnailPlugin() { MFShutdown(); }

void StreamThumbnailPlugin::ThumbnailData(const ThumbnailRequest &request,
                                           std::function<void(ErrorOr<std::vector<uint8_t>> reply)> result) {
  std::thread([request, result]() {
    const bool co_initialized = SUCCEEDED(CoInitializeEx(nullptr, COINIT_MULTITHREADED));
    try {
      result(ErrorOr<std::vector<uint8_t>>(GenerateThumbnailData(request)));
    } catch (const ThumbnailException &e) {
      result(ErrorOr<std::vector<uint8_t>>(FlutterError(e.code(), e.what())));
    }
    if (co_initialized) CoUninitialize();
  }).detach();
}

void StreamThumbnailPlugin::ThumbnailFile(const ThumbnailRequest &request,
                                           std::function<void(ErrorOr<std::string> reply)> result) {
  std::thread([request, result]() {
    const bool co_initialized = SUCCEEDED(CoInitializeEx(nullptr, COINIT_MULTITHREADED));
    try {
      result(ErrorOr<std::string>(WriteThumbnailFile(request)));
    } catch (const ThumbnailException &e) {
      result(ErrorOr<std::string>(FlutterError(e.code(), e.what())));
    }
    if (co_initialized) CoUninitialize();
  }).detach();
}

}  // namespace stream_thumbnail
