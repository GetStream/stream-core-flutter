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
      ],
    );
  }
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
