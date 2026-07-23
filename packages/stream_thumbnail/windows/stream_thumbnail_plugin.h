#ifndef FLUTTER_PLUGIN_STREAM_THUMBNAIL_PLUGIN_H_
#define FLUTTER_PLUGIN_STREAM_THUMBNAIL_PLUGIN_H_

#include <flutter/plugin_registrar_windows.h>

#include <memory>

#include "pigeon/messages.g.h"

namespace stream_thumbnail {

class StreamThumbnailPlugin : public flutter::Plugin,
                               public stream_thumbnail_windows::StreamThumbnailHostApi {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  StreamThumbnailPlugin();
  virtual ~StreamThumbnailPlugin();

  // Disallow copy and assign.
  StreamThumbnailPlugin(const StreamThumbnailPlugin &) = delete;
  StreamThumbnailPlugin &operator=(const StreamThumbnailPlugin &) = delete;

  // stream_thumbnail_windows::StreamThumbnailHostApi
  void ThumbnailData(
      const stream_thumbnail_windows::ThumbnailRequest &request,
      std::function<void(stream_thumbnail_windows::ErrorOr<std::vector<uint8_t>> reply)> result) override;
  void ThumbnailFile(
      const stream_thumbnail_windows::ThumbnailRequest &request,
      std::function<void(stream_thumbnail_windows::ErrorOr<std::string> reply)> result) override;
};

}  // namespace stream_thumbnail

#endif  // FLUTTER_PLUGIN_STREAM_THUMBNAIL_PLUGIN_H_
