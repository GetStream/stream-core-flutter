import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

/// The largest image, in pixels, that is decoded at all.
///
/// Formats such as PNG are decoded at full size before being scaled, so this
/// bounds the memory a single image can take while it decodes.
const maxImageSourcePixels = 8192 * 8192;

/// The largest width or height an image is decoded to.
const maxImageDecodeSize = 4096;

/// Thrown when an image is larger than [maxImageSourcePixels].
class ImageTooLargeException implements Exception {
  /// Creates an exception for an image of [width] by [height] pixels.
  const ImageTooLargeException(this.width, this.height);

  /// The width the image declares.
  final int width;

  /// The height the image declares.
  final int height;

  @override
  String toString() => 'ImageTooLargeException: a ${width}x$height image is too large to display.';
}

/// Decodes the image of [provider] no larger than [maxWidth] by [maxHeight],
/// keeping its aspect ratio and never enlarging it.
///
/// Images larger than [maxImageSourcePixels] fail with an
/// [ImageTooLargeException] before any pixels are decoded.
@immutable
class BoundedImage extends ImageProvider<BoundedImageKey> {
  /// Creates a provider that bounds the decoded size of [provider].
  const BoundedImage(this.provider, {required this.maxWidth, required this.maxHeight});

  /// The image to decode.
  final ImageProvider<Object> provider;

  /// The largest width to decode the image to.
  final int maxWidth;

  /// The largest height to decode the image to.
  final int maxHeight;

  @override
  Future<BoundedImageKey> obtainKey(ImageConfiguration configuration) {
    Completer<BoundedImageKey>? completer;
    SynchronousFuture<BoundedImageKey>? result;
    provider.obtainKey(configuration).then((providerKey) {
      final key = BoundedImageKey._(providerKey, maxWidth, maxHeight);
      if (completer == null) {
        result = SynchronousFuture(key);
      } else {
        completer.complete(key);
      }
    });
    if (result case final result?) return result;

    completer = Completer<BoundedImageKey>();
    return completer.future;
  }

  @override
  ImageStreamCompleter loadImage(BoundedImageKey key, ImageDecoderCallback decode) {
    Future<ui.Codec> decodeBounded(ui.ImmutableBuffer buffer, {ui.TargetImageSizeCallback? getTargetSize}) async {
      final descriptor = await ui.ImageDescriptor.encoded(buffer);
      final (width, height) = (descriptor.width, descriptor.height);
      descriptor.dispose();

      if (width * height > maxImageSourcePixels) {
        buffer.dispose();
        throw ImageTooLargeException(width, height);
      }

      return decode(buffer, getTargetSize: (width, height) => _fit(width, height, key.maxWidth, key.maxHeight));
    }

    return provider.loadImage(key.providerKey, decodeBounded);
  }

  static ui.TargetImageSize _fit(int width, int height, int maxWidth, int maxHeight) {
    final scale = math.min(1, math.min(maxWidth / width, maxHeight / height));
    if (scale >= 1) return ui.TargetImageSize(width: width, height: height);

    return ui.TargetImageSize(
      width: math.max(1, (width * scale).round()),
      height: math.max(1, (height * scale).round()),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is BoundedImage &&
        other.provider == provider &&
        other.maxWidth == maxWidth &&
        other.maxHeight == maxHeight;
  }

  @override
  int get hashCode => Object.hash(provider, maxWidth, maxHeight);

  @override
  String toString() => '${objectRuntimeType(this, 'BoundedImage')}($provider, $maxWidth x $maxHeight)';
}

/// The key of a [BoundedImage], so that each decoded size is cached apart.
@immutable
class BoundedImageKey {
  const BoundedImageKey._(this.providerKey, this.maxWidth, this.maxHeight);

  /// The key of the image that is decoded.
  final Object providerKey;

  /// The largest width the image is decoded to.
  final int maxWidth;

  /// The largest height the image is decoded to.
  final int maxHeight;

  @override
  bool operator ==(Object other) {
    return other is BoundedImageKey &&
        other.providerKey == providerKey &&
        other.maxWidth == maxWidth &&
        other.maxHeight == maxHeight;
  }

  @override
  int get hashCode => Object.hash(providerKey, maxWidth, maxHeight);
}
