import 'package:cached_network_image_ce/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../cache/internal/stream_bounded_image.dart';
import '../../cache/internal/stream_image_cache.dart';
import '../../factory/stream_component_factory.dart';
import '../../theme/stream_theme_extensions.dart';
import '../badge/stream_retry_badge.dart';
import 'stream_loading_spinner.dart';
import 'stream_skeleton_loading.dart';

/// Signature for a function that builds a placeholder widget while a
/// [StreamNetworkImage] is loading.
typedef StreamNetworkImagePlaceholderBuilder = WidgetBuilder;

/// Signature for a function that builds an error widget when a
/// [StreamNetworkImage] fails to load.
///
/// When [retry] is non-null, it can be invoked to retry loading the image
/// (e.g. to show a tap-to-reload button).
typedef StreamNetworkImageErrorBuilder = Widget Function(BuildContext context, Object error, VoidCallback? retry);

/// A network image component with automatic caching, error handling,
/// and tap-to-reload support.
///
/// [StreamNetworkImage] loads and displays an image from a URL with built-in
/// caching. If the image fails to load, it shows an error widget that can be
/// tapped to retry the request. Except on web, an image with more pixels than
/// 8192 by 8192 fails to load.
///
/// {@tool snippet}
///
/// Basic usage:
///
/// ```dart
/// StreamNetworkImage('https://example.com/photo.jpg')
/// ```
/// {@end-tool}
///
/// {@tool snippet}
///
/// With custom placeholder and error handling:
///
/// ```dart
/// StreamNetworkImage(
///   'https://example.com/photo.jpg',
///   width: 200,
///   height: 200,
///   fit: BoxFit.cover,
///   placeholderBuilder: (context) => const CircularProgressIndicator(),
///   errorBuilder: (context, error, retry) => TextButton(
///     onPressed: retry, // nullable -- null when retry is not available
///     child: const Text('Retry'),
///   ),
/// )
/// ```
/// {@end-tool}
///
/// {@tool snippet}
///
/// Auto-retry on external events (e.g. network reconnection):
///
/// ```dart
/// StreamNetworkImage(
///   'https://example.com/photo.jpg',
///   retryListenable: myConnectivityNotifier,
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamNetworkImagePlaceholderBuilder], the placeholder builder typedef.
///  * [StreamNetworkImageErrorBuilder], the error builder typedef.
///  * [StreamImageLoadingPlaceholder], the default loading placeholder.
///  * [StreamImageErrorPlaceholder], the default error surface with retry.
class StreamNetworkImage extends StatelessWidget {
  /// Creates a network image with automatic caching and error handling.
  ///
  /// The [url] is the network location of the image to load.
  StreamNetworkImage(
    String url, {
    super.key,
    Map<String, String>? httpHeaders,
    double? width,
    double? height,
    int? cacheWidth,
    int? cacheHeight,
    BoxFit? fit,
    Alignment alignment = Alignment.center,
    Color? color,
    Animation<double>? opacity,
    BlendMode? colorBlendMode,
    FilterQuality filterQuality = FilterQuality.low,
    String? cacheKey,
    String? semanticLabel,
    bool excludeFromSemantics = false,
    StreamNetworkImagePlaceholderBuilder? placeholderBuilder,
    StreamNetworkImageErrorBuilder? errorBuilder,
    Listenable? retryListenable,
  }) : props = .new(
         url: url,
         httpHeaders: httpHeaders,
         width: width,
         height: height,
         cacheWidth: cacheWidth,
         cacheHeight: cacheHeight,
         fit: fit,
         alignment: alignment,
         color: color,
         opacity: opacity,
         colorBlendMode: colorBlendMode,
         filterQuality: filterQuality,
         cacheKey: cacheKey,
         semanticLabel: semanticLabel,
         excludeFromSemantics: excludeFromSemantics,
         placeholderBuilder: placeholderBuilder,
         errorBuilder: errorBuilder,
         retryListenable: retryListenable,
       );

  /// The properties that configure this network image.
  final StreamNetworkImageProps props;

  /// Evicts a single image from both disk and in-memory caches.
  ///
  /// This is intended for development and testing purposes only.
  @visibleForTesting
  static Future<bool> evictFromCache(String url, {String? cacheKey}) {
    StreamBoundedImage.evictAll(CachedNetworkImageProvider(url, cacheKey: cacheKey));
    return CachedNetworkImage.evictFromCache(url, cacheKey: cacheKey, cacheManager: StreamImageCache.manager);
  }

  @override
  Widget build(BuildContext context) {
    final builder = StreamComponentFactory.of(context).networkImage;
    if (builder != null) return builder(context, props);
    return DefaultStreamNetworkImage(props: props);
  }
}

/// Properties for configuring a [StreamNetworkImage].
///
/// This class holds all the configuration options for a network image,
/// allowing them to be passed through the [StreamComponentFactory].
///
/// See also:
///
///  * [StreamNetworkImage], which uses these properties.
///  * [DefaultStreamNetworkImage], the default implementation.
class StreamNetworkImageProps {
  /// Creates properties for a network image.
  const StreamNetworkImageProps({
    required this.url,
    this.httpHeaders,
    this.width,
    this.height,
    this.cacheWidth,
    this.cacheHeight,
    this.fit,
    this.alignment = Alignment.center,
    this.color,
    this.opacity,
    this.colorBlendMode,
    this.filterQuality = FilterQuality.low,
    this.cacheKey,
    this.semanticLabel,
    this.excludeFromSemantics = false,
    this.placeholderBuilder,
    this.errorBuilder,
    this.retryListenable,
  });

  /// The URL of the image to load.
  final String url;

  /// Optional HTTP headers to send with the image request.
  ///
  /// Useful for authenticated image URLs that require authorization headers.
  final Map<String, String>? httpHeaders;

  /// The width to use for layout.
  ///
  /// If null, the image's intrinsic width is used.
  final double? width;

  /// The height to use for layout.
  ///
  /// If null, the image's intrinsic height is used.
  final double? height;

  /// The largest width, in physical pixels, to decode the image to.
  ///
  /// The image is fitted within [cacheWidth] and [cacheHeight], keeping its
  /// aspect ratio, and is never enlarged. If both are null, it is decoded for
  /// [width] and [height] times the device pixel ratio. It is never decoded
  /// wider than 4096 pixels.
  final int? cacheWidth;

  /// The largest height, in physical pixels, to decode the image to.
  ///
  /// The image is fitted within [cacheWidth] and [cacheHeight], keeping its
  /// aspect ratio, and is never enlarged. If both are null, it is decoded for
  /// [width] and [height] times the device pixel ratio. It is never decoded
  /// taller than 4096 pixels.
  final int? cacheHeight;

  /// How the image should be inscribed into the space allocated for it.
  ///
  /// If null, uses [BoxFit.contain] (the Flutter default).
  final BoxFit? fit;

  /// How to align the image within its bounds.
  ///
  /// Defaults to [Alignment.center].
  final Alignment alignment;

  /// A color to blend with the image.
  ///
  /// If non-null, the color is applied using [colorBlendMode].
  final Color? color;

  /// An opacity animation to apply to the image.
  final Animation<double>? opacity;

  /// The blend mode used to apply [color] to the image.
  ///
  /// If null, defaults to [BlendMode.srcIn] when [color] is set.
  final BlendMode? colorBlendMode;

  /// The quality with which to filter the image.
  ///
  /// Defaults to [FilterQuality.low].
  final FilterQuality filterQuality;

  /// An alternate key to use for caching.
  ///
  /// Useful when the same URL serves different images (e.g. when query
  /// parameters change the response).
  final String? cacheKey;

  /// A semantic description of the image for accessibility.
  final String? semanticLabel;

  /// Whether to exclude this image from the semantics tree.
  ///
  /// Defaults to false.
  final bool excludeFromSemantics;

  /// A builder for the placeholder widget shown while loading.
  ///
  /// If null, [StreamImageLoadingPlaceholder] is used.
  final StreamNetworkImagePlaceholderBuilder? placeholderBuilder;

  /// A builder for the error widget shown when loading fails.
  ///
  /// The builder receives the error and an optional [retry] callback that
  /// can be invoked to retry loading the image. If null,
  /// [StreamImageErrorPlaceholder] is used.
  final StreamNetworkImageErrorBuilder? errorBuilder;

  /// An optional [Listenable] that triggers a retry when notified.
  ///
  /// When this listenable fires and the image is in an error state, the
  /// image will automatically retry loading. This is useful for reacting
  /// to external events like network reconnection without adding a network
  /// dependency to the component.
  ///
  /// Example: pass a [ChangeNotifier] that is notified when connectivity
  /// is restored.
  final Listenable? retryListenable;
}

/// The default implementation of [StreamNetworkImage].
///
/// This widget handles image loading, caching, error states, and
/// tap-to-reload behavior. It is used as the default factory
/// implementation in [StreamComponentFactory].
///
/// See also:
///
///  * [StreamNetworkImage], the public API widget.
///  * [StreamNetworkImageProps], which configures this widget.
class DefaultStreamNetworkImage extends StatefulWidget {
  /// Creates a default network image with the given [props].
  const DefaultStreamNetworkImage({super.key, required this.props});

  /// The properties that configure this network image.
  final StreamNetworkImageProps props;

  @override
  State<DefaultStreamNetworkImage> createState() => _DefaultStreamNetworkImageState();
}

enum _LoadState { checkingCache, loading, loaded, failed }

class _DefaultStreamNetworkImageState extends State<DefaultStreamNetworkImage> {
  var _state = _LoadState.checkingCache;
  var _generation = 0;
  ImageStream? _imageStream;
  late final _imageStreamListener = ImageStreamListener(
    (_, _) => _moveTo(_LoadState.loaded),
    onError: (_, _) => _moveTo(_LoadState.failed),
  );

  @override
  void initState() {
    super.initState();
    widget.props.retryListenable?.addListener(_onRetryListenableNotified);
    _checkCache(_generation);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _listenToImage();
  }

  @override
  void didUpdateWidget(DefaultStreamNetworkImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.props.retryListenable != widget.props.retryListenable) {
      oldWidget.props.retryListenable?.removeListener(_onRetryListenableNotified);
      widget.props.retryListenable?.addListener(_onRetryListenableNotified);
    }
    if (_imageFor(oldWidget.props) != _imageFor(widget.props)) {
      _generation++;
      _state = _LoadState.checkingCache;
      _listenToImage();
      _checkCache(_generation);
    }
  }

  @override
  void dispose() {
    widget.props.retryListenable?.removeListener(_onRetryListenableNotified);
    _imageStream?.removeListener(_imageStreamListener);
    super.dispose();
  }

  void _moveTo(_LoadState next, {int? generation}) {
    if (!mounted || (generation != null && generation != _generation)) return;

    final allowed = switch ((_state, next)) {
      (_LoadState.checkingCache, _LoadState.loading) => true,
      (_LoadState.failed, _LoadState.loading) => true,
      (_, _LoadState.loaded || _LoadState.failed) => true,
      _ => false,
    };
    if (allowed && next != _state) setState(() => _state = next);
  }

  Future<void> _checkCache(int generation) async {
    final props = widget.props;
    try {
      final cached = await StreamImageCache.manager.getFileFromCache(props.cacheKey ?? props.url);
      if (cached != null) return;
    } on Object catch (_) {}

    _moveTo(_LoadState.loading, generation: generation);
  }

  ImageProvider<Object> _imageFor(StreamNetworkImageProps props) {
    final hasCacheSize = props.cacheWidth != null || props.cacheHeight != null;
    int? logicalExtent(double? extent) => extent != null && extent.isFinite ? extent.ceil() : null;

    return StreamBoundedImage(
      CachedNetworkImageProvider(
        props.url,
        headers: props.httpHeaders,
        cacheKey: props.cacheKey,
        cacheManager: StreamImageCache.manager,
      ),
      width: hasCacheSize ? props.cacheWidth : logicalExtent(props.width),
      height: hasCacheSize ? props.cacheHeight : logicalExtent(props.height),
      fit: hasCacheSize ? BoxFit.contain : props.fit ?? BoxFit.contain,
      useLogicalSize: !hasCacheSize,
    );
  }

  void _listenToImage() {
    final stream = _imageFor(widget.props).resolve(createLocalImageConfiguration(context));
    if (stream.key == _imageStream?.key) return;

    _imageStream?.removeListener(_imageStreamListener);
    _imageStream = stream..addListener(_imageStreamListener);
  }

  void _onRetryListenableNotified() => _retry();

  void _retry() {
    if (_state != _LoadState.failed) return;

    final props = widget.props;
    StreamNetworkImage.evictFromCache(props.url, cacheKey: props.cacheKey);
    _generation++;
    _moveTo(_LoadState.loading);
    _listenToImage();
  }

  @override
  Widget build(BuildContext context) {
    final props = widget.props;

    return Image(
      key: ValueKey(_generation),
      image: _imageFor(props),
      width: props.width,
      height: props.height,
      fit: props.fit,
      alignment: props.alignment,
      color: props.color,
      colorBlendMode: props.colorBlendMode,
      filterQuality: props.filterQuality,
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (frame != null || wasSynchronouslyLoaded || _state != _LoadState.loading) return child;
        if (props.placeholderBuilder case final builder?) return builder(context);
        return StreamImageLoadingPlaceholder(width: props.width, height: props.height);
      },
      errorBuilder: (context, error, _) {
        if (props.errorBuilder case final builder?) return builder(context, error, _retry);
        return StreamImageErrorPlaceholder(width: props.width, height: props.height, onRetry: _retry);
      },
    );
  }
}

/// A loading placeholder for image-sized areas.
///
/// [StreamImageLoadingPlaceholder] is used as the default loading state for
/// image slots to indicate that content is being fetched.
///
/// {@tool snippet}
///
/// Basic usage:
///
/// ```dart
/// StreamImageLoadingPlaceholder(width: 200, height: 150)
/// ```
/// {@end-tool}
class StreamImageLoadingPlaceholder extends StatelessWidget {
  /// Creates a [StreamImageLoadingPlaceholder].
  const StreamImageLoadingPlaceholder({super.key, this.width, this.height});

  /// The width of the placeholder area.
  ///
  /// If null, the widget sizes itself to the parent's constraints.
  final double? width;

  /// The height of the placeholder area.
  ///
  /// If null, the widget sizes itself to the parent's constraints.
  final double? height;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: .center,
      children: [
        StreamSkeletonLoading(
          child: StreamSkeletonBox(
            width: width,
            height: height,
          ),
        ),
        StreamLoadingSpinner(size: .md),
      ],
    );
  }
}

/// An error placeholder for image-sized areas.
///
/// [StreamImageErrorPlaceholder] is used as the default error state for image
/// slots. When [onRetry] is provided, the surface becomes tappable so the
/// user can retry the failed operation.
///
/// {@tool snippet}
///
/// Basic usage with retry:
///
/// ```dart
/// StreamImageErrorPlaceholder(
///   width: 200,
///   height: 150,
///   onRetry: () => reloadImage(),
/// )
/// ```
/// {@end-tool}
class StreamImageErrorPlaceholder extends StatelessWidget {
  /// Creates a [StreamImageErrorPlaceholder].
  const StreamImageErrorPlaceholder({
    super.key,
    this.width,
    this.height,
    this.onRetry,
  });

  /// The width of the placeholder area.
  ///
  /// If null, the widget sizes itself to the parent's constraints.
  final double? width;

  /// The height of the placeholder area.
  ///
  /// If null, the widget sizes itself to the parent's constraints.
  final double? height;

  /// Called when the user taps the error surface to retry.
  ///
  /// If null, the surface is not interactive.
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final icons = context.streamIcons;
    final colorScheme = context.streamColorScheme;

    if (onRetry case final onRetry?) {
      return GestureDetector(
        onTap: onRetry,
        child: Container(
          width: width,
          height: height,
          color: colorScheme.backgroundOverlayLight,
          child: Center(child: StreamRetryBadge(size: .lg)),
        ),
      );
    }

    return Container(
      width: width,
      height: height,
      color: colorScheme.backgroundOverlayLight,
      child: Center(
        child: Icon(
          size: 32,
          icons.imageLarge,
          color: colorScheme.accentNeutral,
        ),
      ),
    );
  }
}
