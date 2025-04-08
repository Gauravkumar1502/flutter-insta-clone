import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_insta_clone/bloc/post/post_bloc.dart';
import 'package:flutter_insta_clone/bloc/post/post_events.dart';
import 'package:flutter_insta_clone/bloc/post/post_states.dart';
import 'package:flutter_insta_clone/models/media_model.dart';
import 'package:flutter_insta_clone/models/post_model.dart';
import 'package:flutter_insta_clone/screen/new_post.dart';
import 'package:flutter_insta_clone/widgets/post_widget.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<Uint8List> getRandomImageBytes() async {
    final response = await http.get(
      Uri.parse('https://picsum.photos/300/300'),
    );
    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      throw Exception('Failed to load image');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Home',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: BlocBuilder<PostBloc, PostState>(
          builder: (context, state) {
            if (state is PostInitial) {
              return Center(child: Text('No posts yet'));
            }
            if (state is PostsLoaded) {
              return ListView.builder(
                itemCount: state.posts.length,
                itemBuilder: (context, index) {
                  final post = state.posts[index];
                  return PostWidget(post: post);
                },
              );
            }

            return Center(child: CircularProgressIndicator());
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => NewPost()),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
