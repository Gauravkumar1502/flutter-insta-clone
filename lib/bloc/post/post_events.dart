import 'package:flutter_insta_clone/models/post_model.dart';

abstract class PostEvent {}

class AddPostEvent extends PostEvent {
  final Post post;

  AddPostEvent({required this.post});
}

class RemovePostEvent extends PostEvent {
  final String postId;

  RemovePostEvent({required this.postId});
}
