import 'package:flutter_insta_clone/models/media_model.dart';

class Post {
  final String id;
  final List<Media> media;
  final DateTime createdAt;

  Post({required this.id, required this.media, DateTime? createdAt})
    : createdAt = createdAt ?? DateTime.now();
}
