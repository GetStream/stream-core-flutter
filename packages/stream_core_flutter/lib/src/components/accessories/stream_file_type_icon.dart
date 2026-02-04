import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../factory/stream_component_factory.dart' show StreamComponentBuilder;
import '../../theme.dart';

/// Predefined sizes for the file type icon.
///
/// Each size corresponds to a specific width and height in logical pixels.
/// The dimensions are designed to match the SVG asset sizes available.
///
/// See also:
///
///  * [StreamFileTypeIcon], which uses these size variants.
enum StreamFileTypeIconSize {
  /// Large icon (40×48 pixels).
  s48(width: 40, height: 48),

  /// Small icon (32×40 pixels).
  s40(width: 32, height: 40)
  ;

  /// Constructs a [StreamFileTypeIconSize] with the given dimensions.
  const StreamFileTypeIconSize({
    required this.width,
    required this.height,
  });

  /// The width of the icon in logical pixels.
  final double width;

  /// The height of the icon in logical pixels.
  final double height;
}

/// Supported file types for the file type icon.
///
/// Each type corresponds to a distinct visual icon representation.
/// Use [StreamFileTypeIcon.fromMimeType] to automatically determine the
/// file type from a MIME type string.
///
/// See also:
///
///  * [StreamFileTypeIcon], which uses these file types.
enum StreamFileType {
  /// PDF document files (.pdf).
  pdf,

  /// Text and word processing files (.doc, .docx, .txt, .rtf, etc.).
  text,

  /// Presentation files (.ppt, .pptx, .key, .odp).
  presentation,

  /// Spreadsheet files (.xls, .xlsx, .ods).
  spreadsheet,

  /// Code and markup files (.html, .csv, .xml, .md).
  code,

  /// Video files (.mp4, .mov, .avi, .webm, etc.).
  video,

  /// Audio files (.mp3, .wav, .aac, .flac, etc.).
  audio,

  /// Compressed archive files (.zip, .rar, .7z, etc.).
  compression,

  /// Other or unrecognized file types.
  other,
}

/// An icon widget displaying file type with optional extension label.
///
/// [StreamFileTypeIcon] displays a visual representation of a file based on
/// its type (e.g., PDF, audio, video). It includes an optional file extension
/// label rendered on the icon.
///
/// This widget delegates rendering to the [StreamComponentFactory], allowing
/// customization of the default appearance through theming.
///
/// The icon automatically handles:
/// - Multiple size variants
/// - File type detection from MIME types
/// - Extension label positioning based on icon size
/// - Text scaling (disabled to prevent overflow)
///
/// {@tool snippet}
///
/// Basic usage with a specific file type:
///
/// ```dart
/// StreamFileTypeIcon(type: StreamFileType.pdf)
/// ```
/// {@end-tool}
///
/// {@tool snippet}
///
/// Create from MIME type (automatically detects type and extension):
///
/// ```dart
/// StreamFileTypeIcon.fromMimeType(mimeType: 'application/pdf')
/// ```
/// {@end-tool}
///
/// {@tool snippet}
///
/// Custom size with explicit extension:
///
/// ```dart
/// StreamFileTypeIcon(
///   type: StreamFileType.audio,
///   size: StreamFileTypeIconSize.s48,
///   extension: 'mp3',
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamFileType], which defines the available file type variants.
///  * [StreamFileTypeIconSize], which defines the available size variants.
///  * [StreamFileTypeIconProps], which holds the configuration for this widget.
///  * [DefaultStreamFileTypeIcon], the default implementation.
class StreamFileTypeIcon extends StatelessWidget {
  /// Creates a file type icon.
  ///
  /// The [type] parameter is required and determines which icon is displayed.
  /// Optionally specify [size] and [extension] to customize the appearance.
  StreamFileTypeIcon({
    super.key,
    required StreamFileType type,
    StreamFileTypeIconSize size = .s40,
    String? extension,
  }) : props = .new(type: type, size: size, extension: extension);

  /// Creates a file type icon from a MIME type string.
  ///
  /// This factory constructor automatically determines the appropriate
  /// [StreamFileType] and file extension from the provided [mimeType].
  ///
  /// For example, `'application/pdf'` maps to [StreamFileType.pdf] with
  /// extension `'pdf'`, while `'audio/mpeg'` maps to [StreamFileType.audio]
  /// with extension `'mp3'`.
  ///
  /// Unrecognized MIME types default to [StreamFileType.other] with no
  /// extension.
  factory StreamFileTypeIcon.fromMimeType({
    Key? key,
    required String mimeType,
    StreamFileTypeIconSize size = .s40,
  }) {
    final (type, extension) = _getFileTypeFromMimeType(mimeType);
    return .new(key: key, type: type, size: size, extension: extension);
  }

  /// The properties that configure this file type icon.
  final StreamFileTypeIconProps props;

  // Maps a MIME type string to its corresponding file type and extension.
  //
  // Returns a record containing the [StreamFileType] and optional extension
  // string. Unrecognized MIME types return [StreamFileType.other] with null
  // extension.
  static (StreamFileType type, String? extension) _getFileTypeFromMimeType(
    String? mimeType,
  ) => switch (mimeType) {
    // Audio formats
    'audio/mpeg' => (.audio, 'mp3'),
    'audio/aac' => (.audio, 'aac'),
    'audio/wav' || 'audio/x-wav' => (.audio, 'wav'),
    'audio/flac' => (.audio, 'flac'),
    'audio/mp4' => (.audio, 'm4a'),
    'audio/ogg' => (.audio, 'ogg'),
    'audio/aiff' => (.audio, 'aiff'),
    'audio/alac' => (.audio, 'alac'),

    // Compression formats
    'application/zip' => (.compression, 'zip'),
    'application/x-7z-compressed' => (.compression, '7z'),
    'application/x-arj' => (.compression, 'arj'),
    'application/vnd.debian.binary-package' => (.compression, 'deb'),
    'application/x-apple-diskimage' => (.compression, 'pkg'),
    'application/x-rar-compressed' => (.compression, 'rar'),
    'application/x-rpm' => (.compression, 'rpm'),
    'application/x-tar' => (.code, 'tar'),
    'application/x-compress' => (.compression, 'z'),

    // Presentation formats
    'application/vnd.ms-powerpoint' => (.presentation, 'ppt'),
    'application/vnd.openxmlformats-officedocument.presentationml.presentation' => (.presentation, 'pptx'),
    'application/vnd.apple.keynote' => (.presentation, 'key'),
    'application/vnd.oasis.opendocument.presentation' => (.presentation, 'odp'),

    // Spreadsheet formats
    'application/vnd.ms-excel' => (.spreadsheet, 'xls'),
    'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' => (.spreadsheet, 'xlsx'),
    'application/vnd.ms-excel.sheet.macroEnabled.12' => (.spreadsheet, 'xlsm'),
    'application/vnd.oasis.opendocument.spreadsheet' => (.spreadsheet, 'ods'),

    // Text/document formats
    'application/msword' => (.text, 'doc'),
    'application/vnd.openxmlformats-officedocument.wordprocessingml.document' => (.text, 'docx'),
    'application/vnd.oasis.opendocument.text' => (.text, 'odt'),
    'text/plain' => (.text, 'txt'),
    'application/rtf' => (.text, 'rtf'),
    'application/x-tex' => (.text, 'tex'),
    'application/vnd.wordperfect' => (.text, 'wdp'),

    // Video formats
    'video/mp4' => (.video, 'mp4'),
    'video/mpeg' => (.video, 'mpeg'),
    'video/x-msvideo' => (.video, 'avi'),
    'video/webm' => (.video, 'webm'),
    'video/ogg' => (.video, 'ogv'),
    'video/quicktime' => (.video, 'mov'),
    'video/3gpp' => (.video, '3gp'),
    'video/3gpp2' => (.video, '3g2'),
    'video/mp2t' => (.video, 'ts'),

    // Code/markup formats
    'text/html' => (.code, 'html'),
    'text/csv' => (.code, 'csv'),
    'application/xml' => (.code, 'xml'),
    'text/markdown' => (.code, 'md'),

    // PDF
    'application/pdf' => (.pdf, 'pdf'),

    // Other/unknown formats
    'application/octet-stream' => (.other, null),
    'application/x-wiki' => (.other, 'wkq'),
    _ => (.other, null),
  };

  @override
  Widget build(BuildContext context) {
    final componentFactory = StreamTheme.of(context).componentFactory;
    return componentFactory.fileTypeIconFactory.call(context, props);
  }
}

/// Properties for configuring a [StreamFileTypeIcon].
///
/// This class holds all the configuration options for a file type icon,
/// allowing them to be passed through the [StreamComponentFactory].
///
/// See also:
///
///  * [StreamFileTypeIcon], which uses these properties.
///  * [DefaultStreamFileTypeIcon], the default implementation.
class StreamFileTypeIconProps {
  /// Creates properties for a file type icon.
  const StreamFileTypeIconProps({
    required this.type,
    required this.size,
    this.extension,
  });

  /// The file type to display.
  ///
  /// Determines which icon asset is used for the visual representation.
  final StreamFileType type;

  /// The size of the icon.
  ///
  /// Defaults to [StreamFileTypeIconSize.s40].
  final StreamFileTypeIconSize size;

  /// The file extension to display on the icon.
  ///
  /// When provided, this text is rendered on the icon (e.g., 'pdf', 'mp3').
  /// If null, no extension label is shown.
  final String? extension;
}

/// The default implementation of [StreamFileTypeIcon].
///
/// This widget renders an SVG icon with an optional file extension label
/// positioned at the bottom. It's used as the default factory implementation
/// in [StreamComponentFactory].
///
/// See also:
///
///  * [StreamFileTypeIcon], the public API widget.
///  * [StreamFileTypeIconProps], which configures this widget.
class DefaultStreamFileTypeIcon extends StatelessWidget {
  /// Creates a default file type icon with the given [props].
  const DefaultStreamFileTypeIcon({super.key, required this.props});

  /// The properties that configure this file type icon.
  final StreamFileTypeIconProps props;

  /// The factory method for creating [DefaultStreamFileTypeIcon] instances.
  ///
  /// This is used by [StreamComponentFactory] to create file type icons.
  static StreamComponentBuilder<StreamFileTypeIconProps> get factory {
    return (context, props) => DefaultStreamFileTypeIcon(props: props);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = context.streamTextTheme;

    return Stack(
      clipBehavior: .none,
      children: [
        SvgPicture.asset(
          _iconAssetForTypeAndSize(props.type, props.size),
          package: 'stream_core_flutter',
          width: props.size.width,
          height: props.size.height,
          clipBehavior: .none,
        ),
        if (props.extension case final extension?) ...[
          Positioned(
            left: 4,
            right: 4,
            bottom: _bottomPositionForSize(props.size),
            // Need to disable text scaling here so that the text doesn't
            // escape the icon when the textScaleFactor is large.
            child: MediaQuery.withNoTextScaling(
              child: Text(
                extension,
                maxLines: 1,
                textAlign: .center,
                overflow: .ellipsis,
                style: textTheme.numericSm.copyWith(color: StreamColors.white),
              ),
            ),
          ),
        ],
      ],
    );
  }

  // Returns the appropriate bottom position for the given icon size.
  //
  // The position determines where the extension label is placed vertically
  // on the icon. Larger icons require slightly more offset.
  double _bottomPositionForSize(
    StreamFileTypeIconSize size,
  ) => switch (size) {
    .s48 => 5,
    .s40 => 4,
  };

  // Returns the appropriate icon asset path for the given file type and size.
  //
  // Maps each [StreamFileType] to its corresponding SVG asset, using the
  // icon height from [size] to select the correct asset variant.
  String _iconAssetForTypeAndSize(
    StreamFileType type,
    StreamFileTypeIconSize size,
  ) => switch (type) {
    .pdf => 'assets/file_type/filetype-pdf-${size.height.toInt()}.svg',
    .text => 'assets/file_type/filetype-text-${size.height.toInt()}.svg',
    .presentation => 'assets/file_type/filetype-presentation-${size.height.toInt()}.svg',
    .spreadsheet => 'assets/file_type/filetype-spreadsheet-${size.height.toInt()}.svg',
    .code => 'assets/file_type/filetype-code-${size.height.toInt()}.svg',
    .video => 'assets/file_type/filetype-video-${size.height.toInt()}.svg',
    .audio => 'assets/file_type/filetype-audio-${size.height.toInt()}.svg',
    .compression => 'assets/file_type/filetype-compression-${size.height.toInt()}.svg',
    .other => 'assets/file_type/filetype-other-${size.height.toInt()}.svg',
  };
}
