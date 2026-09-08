#ifndef FLUTTER_PLUGIN_STREAM_THUMBNAIL_PLUGIN_H_
#define FLUTTER_PLUGIN_STREAM_THUMBNAIL_PLUGIN_H_

#include <flutter/plugin_registrar_windows.h>

#include <atomic>
#include <functional>
#include <memory>
#include <mutex>
#include <thread>
#include <vector>

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

 private:
  // One in-flight request. `done` is set by the worker as its very last action,
  // so finished workers can be spotted and joined without blocking.
  struct Worker {
    std::thread thread;
    std::atomic<bool> done{false};
  };

  // Runs `work` on a tracked worker thread, with COM initialized for it.
  void RunOnWorker(std::function<void()> work);

  // Joins and drops every worker that has finished. Caller must hold `mutex_`.
  void ReapFinishedWorkers();

  std::mutex mutex_;
  std::vector<std::unique_ptr<Worker>> workers_;
};

}  // namespace stream_thumbnail

#endif  // FLUTTER_PLUGIN_STREAM_THUMBNAIL_PLUGIN_H_
