import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

/// Thrown when an image has more pixels than [StreamBoundedImage.maxSourcePixels].
class StreamImageTooLargeException implements Exception {
  /// Creates an exception for an image of [width] by [height] pixels.
  const StreamImageTooLargeException(this.width, this.height);

  /// The width of the image.
  final int width;

  /// The height of the image.
  final int height;

  @override
  String toString() => 'StreamImageTooLargeException: a ${width}x$height image is too large to display.';
}

/// An image provider that decodes [provider] to fit [maxWidth] by [maxHeight].
///
/// The image keeps its aspect ratio, is never enlarged, and is at most
/// [maxDecodeSize] pixels on a side. With a [fit] that fills the box, such as
/// [BoxFit.cover], it is decoded large enough to fill it, and with [BoxFit.none]
/// it is decoded at its own size. An image with more
/// pixels than [maxSourcePixels] fails with an [StreamImageTooLargeException].
///
/// See also:
///
///  * [ResizeImage], which resizes an image without limiting its source size.
@immutable
class StreamBoundedImage extends ImageProvider<StreamBoundedImageKey> {
  /// Creates a provider that bounds the decoded size of [provider].
  const StreamBoundedImage(
    this.provider, {
    required this.maxWidth,
    required this.maxHeight,
    this.fit = BoxFit.contain,
  });

  /// The image to decode.
  final ImageProvider<Object> provider;

  /// The width of the box to decode the image for.
  final int maxWidth;

  /// The height of the box to decode the image for.
  final int maxHeight;

  /// How the decoded image is placed in the box.
  final BoxFit fit;

  /// The largest number of pixels an image can have and still be decoded.
  static const maxSourcePixels = 8192 * 8192;

  /// The largest width or height an image is decoded to.
  static const maxDecodeSize = 4096;

  @override
  Future<StreamBoundedImageKey> obtainKey(ImageConfiguration configuration) {
    Completer<StreamBoundedImageKey>? completer;
    SynchronousFuture<StreamBoundedImageKey>? result;
    provider.obtainKey(configuration).then((providerKey) {
      final key = StreamBoundedImageKey._(providerKey, maxWidth, maxHeight, fit);
      if (completer == null) {
        result = SynchronousFuture(key);
      } else {
        completer.complete(key);
      }
    });
    if (result case final result?) return result;

    completer = Completer<StreamBoundedImageKey>();
    return completer.future;
  }

  @override
  ImageStreamCompleter loadImage(StreamBoundedImageKey key, ImageDecoderCallback decode) {
    Future<ui.Codec> decodeBounded(ui.ImmutableBuffer buffer, {ui.TargetImageSizeCallback? getTargetSize}) {
      return decode(buffer, getTargetSize: (width, height) => _targetSize(width, height, key));
    }

    return provider.loadImage(key.providerKey, decodeBounded)..addEphemeralErrorListener(
      (_, _) => scheduleMicrotask(() => PaintingBinding.instance.imageCache.evict(key)),
    );
  }

  static ui.TargetImageSize _targetSize(int width, int height, StreamBoundedImageKey key) {
    if (width * height > maxSourcePixels) throw StreamImageTooLargeException(width, height);

    final widthScale = key.maxWidth / width;
    final heightScale = key.maxHeight / height;
    final boxScale = switch (key.fit) {
      BoxFit.cover || BoxFit.fill => math.max(widthScale, heightScale),
      BoxFit.fitWidth => widthScale,
      BoxFit.fitHeight => heightScale,
      BoxFit.none => 1.0,
      BoxFit.contain || BoxFit.scaleDown => math.min(widthScale, heightScale),
    };
    final scale = [1.0, boxScale, maxDecodeSize / width, maxDecodeSize / height].reduce(math.min);
    if (scale >= 1) return ui.TargetImageSize(width: width, height: height);

    return ui.TargetImageSize(
      width: math.max(1, (width * scale).round()),
      height: math.max(1, (height * scale).round()),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is StreamBoundedImage &&
        other.provider == provider &&
        other.maxWidth == maxWidth &&
        other.maxHeight == maxHeight &&
        other.fit == fit;
  }

  @override
  int get hashCode => Object.hash(provider, maxWidth, maxHeight, fit);

  @override
  String toString() => '${objectRuntimeType(this, 'StreamBoundedImage')}($provider, $maxWidth x $maxHeight, $fit)';
}

/// The cache key of a [StreamBoundedImage], distinct for each decoded size.
@immutable
class StreamBoundedImageKey {
  const StreamBoundedImageKey._(this.providerKey, this.maxWidth, this.maxHeight, this.fit);

  /// The key of the image that is decoded.
  final Object providerKey;

  /// The width of the box the image is decoded for.
  final int maxWidth;

  /// The height of the box the image is decoded for.
  final int maxHeight;

  /// How the decoded image is placed in the box.
  final BoxFit fit;

  @override
  bool operator ==(Object other) {
    return other is StreamBoundedImageKey &&
        other.providerKey == providerKey &&
        other.maxWidth == maxWidth &&
        other.maxHeight == maxHeight &&
        other.fit == fit;
  }

  @override
  int get hashCode => Object.hash(providerKey, maxWidth, maxHeight, fit);
}
