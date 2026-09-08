#include "include/stream_thumbnail/stream_thumbnail_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "stream_thumbnail_plugin.h"

void StreamThumbnailPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  stream_thumbnail::StreamThumbnailPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
