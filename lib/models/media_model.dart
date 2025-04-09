import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';

class Media {
  final String id;
  final MediaType type;
  final Uint8List file;
  final String extension;

  Media({
    required this.id,
    required this.type,
    required this.file,
    required this.extension,
  });

  bool get isImage => [
    'jpg',
    'jpeg',
    'png',
    'webp',
    'gif',
  ].contains(extension.toLowerCase());

  bool get isVideo =>
      ['mp4', 'mov', 'avi', 'mkv'].contains(extension.toLowerCase());

  Future<File> toFile({String? fileName}) async {
    final tempDir = await getTemporaryDirectory();
    final path = '${tempDir.path}/${fileName ?? '$id.$extension'}';

    final mediaFile = File(path);
    await mediaFile.writeAsBytes(file);
    return mediaFile;
  }
}

enum MediaType { image, video }
