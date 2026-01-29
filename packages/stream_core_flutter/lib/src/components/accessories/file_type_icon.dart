import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';

import '../../../stream_core_flutter.dart';

class FileTypeIcon extends StatelessWidget {
  const FileTypeIcon({
    super.key,
    required this.category,
    this.extension,
    this.size = .s40,
  });

  factory FileTypeIcon.fromMimeType({
    Key? key,
    required String mimeType,
    FileTypeIconSize size = .s40,
  }) {
    final (category, extension) = getExtension(mimeType);

    return FileTypeIcon(
      key: key,
      category: category,
      extension: extension,
      size: size,
    );
  }

  final FileTypeCategory category;
  final String? extension;
  final FileTypeIconSize size;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SvgPicture.asset(
          package: 'stream_core_flutter',
          category.getIconAssetName(size),
          width: size.width,
          height: size.height,
        ),
        Positioned(
          bottom: switch (size) {
            FileTypeIconSize.s48 => 5,
            FileTypeIconSize.s40 => 4,
          },
          right: 0,
          left: 0,
          // We never want the text on the icon to be scaled, so we clamp the text scale factor to 1.
          child: StreamTextScaleFactorClamper(
            minTextScaleFactor: 1,
            maxTextScaleFactor: 1,
            child: Text(
              extension ?? '',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: StreamColors.white,
                fontWeight: .bold,
                fontSize: 8,
              ),
            ),
          ),
        ),
      ],
    );
  }

  static (FileTypeCategory category, String? fileExtension) getExtension(String? mimeType) => switch (mimeType) {
    'audio/mpeg' => (FileTypeCategory.audio, 'mp3'),
    'audio/aac' => (FileTypeCategory.audio, 'aac'),
    'audio/wav' || 'audio/x-wav' => (FileTypeCategory.audio, 'wav'),
    'audio/flac' => (FileTypeCategory.audio, 'flac'),
    'audio/mp4' => (FileTypeCategory.audio, 'm4a'),
    'audio/ogg' => (FileTypeCategory.audio, 'ogg'),
    'audio/aiff' => (FileTypeCategory.audio, 'aiff'),
    'audio/alac' => (FileTypeCategory.audio, 'alac'),
    'application/zip' => (FileTypeCategory.compression, 'zip'),
    'application/x-7z-compressed' => (FileTypeCategory.compression, '7z'),
    'application/x-arj' => (FileTypeCategory.compression, 'arj'),
    'application/vnd.debian.binary-package' => (FileTypeCategory.compression, 'deb'),
    'application/x-apple-diskimage' => (FileTypeCategory.compression, 'pkg'),
    'application/x-rar-compressed' => (FileTypeCategory.compression, 'rar'),
    'application/x-rpm' => (FileTypeCategory.compression, 'rpm'),
    'application/x-tar' => (FileTypeCategory.code, 'tar'),
    'application/x-compress' => (FileTypeCategory.compression, 'z'),
    'application/vnd.ms-powerpoint' => (FileTypeCategory.presentation, 'ppt'),
    'application/vnd.openxmlformats-officedocument.presentationml.presentation' => (
      FileTypeCategory.presentation,
      'pptx',
    ),
    'application/vnd.apple.keynote' => (FileTypeCategory.presentation, 'key'),
    'application/vnd.oasis.opendocument.presentation' => (FileTypeCategory.presentation, 'odp'),
    'application/vnd.ms-excel' => (FileTypeCategory.spreadsheet, 'xls'),
    'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' => (FileTypeCategory.spreadsheet, 'xlsx'),
    'application/vnd.ms-excel.sheet.macroEnabled.12' => (FileTypeCategory.spreadsheet, 'xlsm'),
    'application/vnd.oasis.opendocument.spreadsheet' => (FileTypeCategory.spreadsheet, 'ods'),
    'application/msword' => (FileTypeCategory.text, 'doc'),
    'application/vnd.openxmlformats-officedocument.wordprocessingml.document' => (FileTypeCategory.text, 'docx'),
    'application/vnd.oasis.opendocument.text' => (FileTypeCategory.text, 'odt'),
    'text/plain' => (FileTypeCategory.text, 'txt'),
    'application/rtf' => (FileTypeCategory.text, 'rtf'),
    'application/x-tex' => (FileTypeCategory.text, 'tex'),
    'application/vnd.wordperfect' => (FileTypeCategory.text, 'wdp'),
    'video/mp4' => (FileTypeCategory.video, 'mp4'),
    'video/mpeg' => (FileTypeCategory.video, 'mpeg'),
    'video/x-msvideo' => (FileTypeCategory.video, 'avi'),
    'video/webm' => (FileTypeCategory.video, 'webm'),
    'video/ogg' => (FileTypeCategory.video, 'ogv'),
    'video/quicktime' => (FileTypeCategory.video, 'mov'),
    'video/3gpp' => (FileTypeCategory.video, '3gp'),
    'video/3gpp2' => (FileTypeCategory.video, '3g2'),
    'video/mp2t' => (FileTypeCategory.video, 'ts'),
    'text/html' => (FileTypeCategory.code, 'html'),
    'text/csv' => (FileTypeCategory.code, 'csv'),
    'application/xml' => (FileTypeCategory.code, 'xml'),
    'text/markdown' => (FileTypeCategory.code, 'md'),
    'application/octet-stream' => (FileTypeCategory.other, null),
    'application/pdf' => (FileTypeCategory.pdf, 'pdf'),
    'application/x-wiki' => (FileTypeCategory.other, 'wkq'),
    _ => (FileTypeCategory.other, null),
  };
}

enum FileTypeIconSize {
  s48,
  s40,
}

enum FileTypeCategory {
  pdf,
  text,
  presentation,
  spreadsheet,
  code,
  video,
  audio,
  compression,
  other,
}

extension on FileTypeCategory {
  String getIconAssetName(FileTypeIconSize size) => switch (this) {
    FileTypeCategory.pdf => 'assets/file_type/filetype-pdf-${size.sizeIndicator}.svg',
    FileTypeCategory.text => 'assets/file_type/filetype-text-${size.sizeIndicator}.svg',
    FileTypeCategory.presentation => 'assets/file_type/filetype-presentation-${size.sizeIndicator}.svg',
    FileTypeCategory.spreadsheet => 'assets/file_type/filetype-spreadsheet-${size.sizeIndicator}.svg',
    FileTypeCategory.code => 'assets/file_type/filetype-code-${size.sizeIndicator}.svg',
    FileTypeCategory.video => 'assets/file_type/filetype-video-${size.sizeIndicator}.svg',
    FileTypeCategory.audio => 'assets/file_type/filetype-audio-${size.sizeIndicator}.svg',
    FileTypeCategory.compression => 'assets/file_type/filetype-compression-${size.sizeIndicator}.svg',
    FileTypeCategory.other => 'assets/file_type/filetype-other-${size.sizeIndicator}.svg',
  };
}

extension on FileTypeIconSize {
  String get sizeIndicator => switch (this) {
    FileTypeIconSize.s48 => '48',
    FileTypeIconSize.s40 => '40',
  };

  double get height => switch (this) {
    FileTypeIconSize.s48 => 48,
    FileTypeIconSize.s40 => 40,
  };

  double get width => switch (this) {
    FileTypeIconSize.s48 => 40,
    FileTypeIconSize.s40 => 32,
  };
}
