import 'dart:typed_data';

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
}

enum MediaType { image, video }
