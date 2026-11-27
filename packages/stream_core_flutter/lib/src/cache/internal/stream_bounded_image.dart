import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

// Thrown when an image has more pixels than [StreamBoundedImage.maxSourcePixels].
class _ImageTooLargeException implements Exception {
  const _ImageTooLargeException(this.width, this.height);

  final int width;
  final int height;

  @override
  String toString() => 'A ${width}x$height image is too large to display.';
}

/// An image provider that decodes [imageProvider] for a box of [width] by
/// [height], at most [maxDecodeSize] pixels on a side.
///
/// Like [ResizeImage] with [ResizeImagePolicy.fit], the image keeps its aspect
/// ratio and is never enlarged. A null [width] or [height] leaves that side
/// unbounded. With a [fit] that fills the box, such as [BoxFit.cover], the image
/// is decoded large enough to fill it, and with [BoxFit.none] it is decoded at
/// its own size.
///
/// An image with more pixels than [maxSourcePixels] fails to load.
///
/// See also:
///
///  * [ResizeImage], which resizes an image without limiting its size.
@immutable
class StreamBoundedImage extends ImageProvider<StreamBoundedImageKey> {
  /// Creates a provider that decodes [imageProvider] for a box of [width] by
  /// [height].
  const StreamBoundedImage(
    this.imageProvider, {
    this.width,
    this.height,
    this.fit = .contain,
    this.useLogicalSize = false,
  });

  /// The image to decode.
  final ImageProvider<Object> imageProvider;

  /// The width of the box the image is decoded for, or null for no limit.
  final int? width;

  /// The height of the box the image is decoded for, or null for no limit.
  final int? height;

  /// How the image is placed in the box.
  final BoxFit fit;

  /// Whether [width] and [height] are in logical pixels, to be multiplied by
  /// the device pixel ratio, rather than in physical pixels.
  final bool useLogicalSize;

  /// The largest number of pixels an image can have and still be decoded.
  static const maxSourcePixels = 8192 * 8192;

  /// The largest width or height an image is decoded to.
  static const maxDecodeSize = 4096;

  static final _keysByProviderKey = <Object, Set<StreamBoundedImageKey>>{};
  static var _pruneAt = 0;

  /// The number of images whose decoded sizes are being tracked for [evictAll].
  @visibleForTesting
  static int get debugTrackedImageCount => _keysByProviderKey.length;

  // Remembers [key] for [evictAll], forgetting keys the image cache no longer
  // holds or shows once more are tracked than it can hold.
  static void _track(Object providerKey, StreamBoundedImageKey key) {
    if (_keysByProviderKey.length > _pruneAt) {
      final cache = PaintingBinding.instance.imageCache;
      for (final keys in _keysByProviderKey.values) {
        keys.removeWhere((it) => !cache.statusForKey(it).tracked);
      }
      _keysByProviderKey.removeWhere((_, keys) => keys.isEmpty);
      _pruneAt = math.max(2 * _keysByProviderKey.length, cache.maximumSize);
    }
    (_keysByProviderKey[providerKey] ??= {}).add(key);
  }

  /// Evicts every decoded size of the image with [providerKey], the key of
  /// its [imageProvider], from the image cache.
  static void evictAll(Object providerKey) {
    final keys = _keysByProviderKey.remove(providerKey) ?? const <StreamBoundedImageKey>{};
    keys.forEach(PaintingBinding.instance.imageCache.evict);
  }

  @override
  Future<StreamBoundedImageKey> obtainKey(ImageConfiguration configuration) {
    final devicePixelRatio = useLogicalSize ? (configuration.devicePixelRatio ?? 1.0) : 1.0;
    final effectiveWidth = width != null ? (width! * devicePixelRatio).ceil() : null;
    final effectiveHeight = height != null ? (height! * devicePixelRatio).ceil() : null;

    Completer<StreamBoundedImageKey>? completer;
    SynchronousFuture<StreamBoundedImageKey>? result;
    imageProvider.obtainKey(configuration).then((providerKey) {
      final key = StreamBoundedImageKey._(providerKey, effectiveWidth, effectiveHeight, fit);
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
    _track(key._providerKey, key);
    Future<ui.Codec> decodeBounded(ui.ImmutableBuffer buffer, {ui.TargetImageSizeCallback? getTargetSize}) {
      assert(
        getTargetSize == null,
        'StreamBoundedImage cannot be composed with another ImageProvider that applies getTargetSize.',
      );
      return decode(buffer, getTargetSize: (width, height) => _targetSize(width, height, key));
    }

    return imageProvider.loadImage(key._providerKey, decodeBounded)..addEphemeralErrorListener(
      (_, _) => scheduleMicrotask(() => PaintingBinding.instance.imageCache.evict(key)),
    );
  }

  static ui.TargetImageSize _targetSize(int width, int height, StreamBoundedImageKey key) {
    if (width * height > maxSourcePixels) throw _ImageTooLargeException(width, height);

    final scales = [
      if (key._width case final boxWidth?) boxWidth / width,
      if (key._height case final boxHeight?) boxHeight / height,
    ];
    final boxScale = switch (key._fit) {
      _ when scales.isEmpty => 1.0,
      .none => 1.0,
      .contain || .scaleDown => scales.reduce(math.min),
      .cover || .fill || .fitWidth || .fitHeight => scales.reduce(math.max),
    };
    final scale = [1.0, boxScale, maxDecodeSize / width, maxDecodeSize / height].reduce(math.min);
    if (scale >= 1) return ui.TargetImageSize(width: width, height: height);

    return ui.TargetImageSize(
      width: math.max(1, (width * scale).floor()),
      height: math.max(1, (height * scale).floor()),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is StreamBoundedImage &&
        other.imageProvider == imageProvider &&
        other.width == width &&
        other.height == height &&
        other.fit == fit &&
        other.useLogicalSize == useLogicalSize;
  }

  @override
  int get hashCode => Object.hash(imageProvider, width, height, fit, useLogicalSize);

  @override
  String toString() {
    return '${objectRuntimeType(this, 'StreamBoundedImage')}('
        '$imageProvider, width: $width, height: $height, fit: $fit, useLogicalSize: $useLogicalSize)';
  }
}

/// The cache key of a [StreamBoundedImage], distinct for each decoded size.
@immutable
class StreamBoundedImageKey {
  const StreamBoundedImageKey._(this._providerKey, this._width, this._height, this._fit);

  final Object _providerKey;
  final int? _width;
  final int? _height;
  final BoxFit _fit;

  @override
  bool operator ==(Object other) {
    return other is StreamBoundedImageKey &&
        other._providerKey == _providerKey &&
        other._width == _width &&
        other._height == _height &&
        other._fit == _fit;
  }

  @override
  int get hashCode => Object.hash(_providerKey, _width, _height, _fit);
}
