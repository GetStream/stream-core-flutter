//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <stream_thumbnail/stream_thumbnail_plugin.h>

void fl_register_plugins(FlPluginRegistry* registry) {
  g_autoptr(FlPluginRegistrar) stream_thumbnail_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "StreamThumbnailPlugin");
  stream_thumbnail_plugin_register_with_registrar(stream_thumbnail_registrar);
}
