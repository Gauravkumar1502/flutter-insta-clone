import 'package:flutter_insta_clone/models/post_model.dart';

abstract class PostState {}

class PostInitial extends PostState {}

class PostsLoaded extends PostState {
  final List<Post> posts;

  PostsLoaded({required this.posts});
}
