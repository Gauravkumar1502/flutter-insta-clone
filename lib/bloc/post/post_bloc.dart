import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_insta_clone/bloc/post/post_events.dart';
import 'package:flutter_insta_clone/bloc/post/post_states.dart';
import 'package:flutter_insta_clone/models/post_model.dart';

class PostBloc extends Bloc<PostEvent, PostState> {
  PostBloc() : super(PostInitial()) {
    on<AddPostEvent>(_onAddPost);
    on<RemovePostEvent>(_onRemovePost);
  }

  void _onAddPost(AddPostEvent event, Emitter<PostState> emit) {
    if (state is PostInitial) {
      emit(PostsLoaded(posts: [event.post]));
    } else if (state is PostsLoaded) {
      final currentState = state as PostsLoaded;
      final updatedPosts = List<Post>.from(currentState.posts)
        ..add(event.post);
      emit(PostsLoaded(posts: updatedPosts));
    }
  }

  void _onRemovePost(RemovePostEvent event, Emitter<PostState> emit) {
    if (state is PostsLoaded) {
      final currentState = state as PostsLoaded;
      final updatedPosts =
          currentState.posts
              .where((post) => post.id != event.postId)
              .toList();

      emit(PostsLoaded(posts: updatedPosts));
    }
  }
}
