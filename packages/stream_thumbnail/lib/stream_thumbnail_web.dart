// The web implementation is browser/DOM glue that requires a real browser to
// exercise, so it is validated via the example app rather than unit tests.
// coverage:ignore-file
import 'dart:async';
import 'dart:js_interop';
import 'dart:math' as math;

import 'package:cross_file/cross_file.dart';
import 'package:flutter/services.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:web/web.dart' as web;

import 'src/stream_thumbnail_format.dart';
import 'src/stream_thumbnail_platform.dart';

// An error code value to error name Map.
// See: https://developer.mozilla.org/en-US/docs/Web/API/MediaError/code
const _kErrorValueToErrorName = <int, String>{
  1: 'MEDIA_ERR_ABORTED',
  2: 'MEDIA_ERR_NETWORK',
  3: 'MEDIA_ERR_DECODE',
  4: 'MEDIA_ERR_SRC_NOT_SUPPORTED',
};

// An error code value to description Map.
// See: https://developer.mozilla.org/en-US/docs/Web/API/MediaError/code
const _kErrorValueToErrorDescription = <int, String>{
  1: 'The user canceled the fetching of the video.',
  2: 'A network error occurred while fetching the video, despite having previously been available.',
  3: 'An error occurred while trying to decode the video, despite having previously been determined to be usable.',
  4: 'The video has been found to be unsuitable (missing or in a format not supported by your browser).',
};

// The default error message, when the error is an empty string
// See: https://developer.mozilla.org/en-US/docs/Web/API/MediaError/message
const _kDefaultErrorMessage = 'No further diagnostic information can be determined or provided.';

/// A web implementation of the [StreamThumbnailPlatform].
class StreamThumbnailWeb extends StreamThumbnailPlatform {
  /// Constructs a [StreamThumbnailWeb].
  StreamThumbnailWeb();

  /// Registers this class as the default [StreamThumbnailPlatform] on web.
  static void registerWith(Registrar registrar) {
    StreamThumbnailPlatform.instance = StreamThumbnailWeb();
  }

  @override
  Future<List<XFile>> thumbnailFiles({
    required List<String> videos,
    required Map<String, String>? headers,
    required String? thumbnailPath,
    required StreamThumbnailFormat imageFormat,
    required int maxHeight,
    required int maxWidth,
    int? timeMs,
    required int quality,
  }) async {
    final blobs = <web.Blob>[];

    for (final video in videos) {
      blobs.add(
        await _createThumbnail(
          videoSrc: video,
          headers: headers,
          imageFormat: imageFormat,
          maxHeight: maxHeight,
          maxWidth: maxWidth,
          timeMs: timeMs ?? 0,
          quality: quality,
        ),
      );
    }

    return blobs
        .map(
          (blob) => XFile(web.URL.createObjectURL(blob), mimeType: blob.type),
        )
        .toList();
  }

  @override
  Future<XFile> thumbnailFile({
    required String video,
    required Map<String, String>? headers,
    required String? thumbnailPath,
    required StreamThumbnailFormat imageFormat,
    required int maxHeight,
    required int maxWidth,
    int? timeMs,
    required int quality,
  }) async {
    final blob = await _createThumbnail(
      videoSrc: video,
      headers: headers,
      imageFormat: imageFormat,
      maxHeight: maxHeight,
      maxWidth: maxWidth,
      timeMs: timeMs ?? 0,
      quality: quality,
    );

    return XFile(web.URL.createObjectURL(blob), mimeType: blob.type);
  }

  @override
  Future<Uint8List> thumbnailData({
    required String video,
    required Map<String, String>? headers,
    required StreamThumbnailFormat imageFormat,
    required int maxHeight,
    required int maxWidth,
    int? timeMs,
    required int quality,
  }) async {
    final blob = await _createThumbnail(
      videoSrc: video,
      headers: headers,
      imageFormat: imageFormat,
      maxHeight: maxHeight,
      maxWidth: maxWidth,
      timeMs: timeMs ?? 0,
      quality: quality,
    );
    final path = web.URL.createObjectURL(blob);
    final file = XFile(path, mimeType: blob.type);
    final bytes = await file.readAsBytes();
    web.URL.revokeObjectURL(path);

    return bytes;
  }

  Future<web.Blob> _createThumbnail({
    required String videoSrc,
    required Map<String, String>? headers,
    required StreamThumbnailFormat imageFormat,
    required int maxHeight,
    required int maxWidth,
    required int quality,
    int timeMs = 0,
  }) async {
    final completer = Completer<web.Blob>();

    final video = web.document.createElement('video') as web.HTMLVideoElement;
    final timeSec = math.max(timeMs / 1000, 0);
    final fetchVideo = headers != null && headers.isNotEmpty;

    video.addEventListener(
      'loadedmetadata',
      (web.Event event) {
        video.currentTime = timeSec;

        if (fetchVideo) {
          web.URL.revokeObjectURL(video.src);
        }
      }.toJS,
    );

    video.addEventListener(
      'seeked',
      (web.Event e) {
        if (!completer.isCompleted) {
          final canvas = web.document.createElement('canvas') as web.HTMLCanvasElement;
          final ctx = canvas.getContext('2d')! as web.CanvasRenderingContext2D;

          if (maxWidth == 0 && maxHeight == 0) {
            canvas
              ..width = video.videoWidth
              ..height = video.videoHeight;
            ctx.drawImage(video, 0, 0);
          } else {
            var width = maxWidth;
            var height = maxHeight;
            final aspectRatio = video.videoWidth / video.videoHeight;
            if (width == 0) {
              width = (height * aspectRatio).round();
            } else if (height == 0) {
              height = (width / aspectRatio).round();
            }

            final inputAspectRatio = width / height;
            if (aspectRatio > inputAspectRatio) {
              height = (width / aspectRatio).round();
            } else {
              width = (height * aspectRatio).round();
            }

            canvas
              ..width = width
              ..height = height;
            ctx.drawImage(video, 0, 0, width, height);
          }

          try {
            canvas.toBlob(
              (web.Blob? blob) {
                if (completer.isCompleted) return;
                if (blob == null) {
                  completer.completeError(
                    PlatformException(
                      code: 'CANVAS_EXPORT_ERROR',
                      message: 'Canvas could not be exported to a blob.',
                    ),
                  );
                } else {
                  completer.complete(blob);
                }
              }.toJS,
              _imageFormatToCanvasFormat(imageFormat),
              (quality / 100).toJS,
            );
          } catch (e, s) {
            completer.completeError(
              PlatformException(
                code: 'CANVAS_EXPORT_ERROR',
                details: e,
                stacktrace: s.toString(),
              ),
              s,
            );
          }
        }
      }.toJS,
    );

    video.addEventListener(
      'error',
      (web.Event e) {
        // The Event itself (e) doesn't contain info about the actual error.
        // We need to look at the HTMLMediaElement.error.
        // See: https://developer.mozilla.org/en-US/docs/Web/API/HTMLMediaElement/error
        if (!completer.isCompleted) {
          final error = video.error!;
          completer.completeError(
            PlatformException(
              code: _kErrorValueToErrorName[error.code]!,
              message: error.message != '' ? error.message : _kDefaultErrorMessage,
              details: _kErrorValueToErrorDescription[error.code],
            ),
          );
        }
      }.toJS,
    );

    if (fetchVideo) {
      try {
        final blob = await _fetchVideoByHeaders(
          videoSrc: videoSrc,
          headers: headers,
        );

        video.src = web.URL.createObjectURL(blob);
      } catch (e, s) {
        completer.completeError(e, s);
      }
    } else {
      video
        ..crossOrigin = 'Anonymous'
        ..src = videoSrc;
    }

    return completer.future;
  }

  // Fetches the video using the given headers.
  //
  // To avoid reading the video's bytes into memory, the XMLHttpRequest
  // responseType is set to 'blob'. This allows the blob to be stored in the
  // browser's disk or memory cache.
  Future<web.Blob> _fetchVideoByHeaders({
    required String videoSrc,
    required Map<String, String> headers,
  }) {
    final completer = Completer<web.Blob>();

    final xhr = web.XMLHttpRequest()
      ..open('GET', videoSrc, true)
      ..responseType = 'blob';
    for (final entry in headers.entries) {
      xhr.setRequestHeader(entry.key, entry.value);
    }

    xhr.addEventListener(
      'load',
      (web.Event event) {
        if (!completer.isCompleted) {
          completer.complete(xhr.response! as web.Blob);
        }
      }.toJS,
    );

    xhr.addEventListener(
      'error',
      (web.Event event) {
        if (!completer.isCompleted) {
          completer.completeError(
            PlatformException(
              code: 'VIDEO_FETCH_ERROR',
              message: 'Status: ${xhr.statusText}',
            ),
          );
        }
      }.toJS,
    );

    xhr.send();

    return completer.future;
  }

  String _imageFormatToCanvasFormat(StreamThumbnailFormat imageFormat) {
    switch (imageFormat) {
      case StreamThumbnailFormat.jpeg:
        return 'image/jpeg';
      case StreamThumbnailFormat.png:
        return 'image/png';
      case StreamThumbnailFormat.webp:
        return 'image/webp';
    }
  }
}
