import 'package:flutter/material.dart';
import 'package:flutter_insta_clone/models/media_model.dart';
import 'package:flutter_insta_clone/models/post_model.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class PostWidget extends StatefulWidget {
  final Post post;

  const PostWidget({super.key, required this.post});

  @override
  State<PostWidget> createState() => _PostWidgetState();
}

class _PostWidgetState extends State<PostWidget> {
  final String username = "Gaurav Kumar";

  final String userProfile =
      "https://avatar.iran.liara.run/public/46";

  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: LinearBorder(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              spacing: 10,
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: NetworkImage(userProfile),
                ),
                Text(
                  username,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 300,
            child: PageView.builder(
              itemCount: widget.post.media.length,
              controller: _pageController,
              physics: const BouncingScrollPhysics(),
              itemBuilder: (context, index) {
                final media = widget.post.media[index];

                return switch (media.type) {
                  MediaType.image => Image.memory(
                    media.file,
                    fit: BoxFit.cover,
                  ),
                  MediaType.video => Container(
                    color: Colors.black,
                    child: Center(child: Text('Video Player here')),
                  ),
                };
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              spacing: 20,
              children: [
                Text(
                  "${DateTime.now().difference(widget.post.createdAt).inHours.toString()} hours ago",
                  style: TextStyle(fontSize: 12),
                ),
                SmoothPageIndicator(
                  controller: _pageController,
                  onDotClicked: (index) {
                    _pageController.animateToPage(
                      index,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeIn,
                    );
                  },
                  count: widget.post.media.length,
                  effect: ExpandingDotsEffect(
                    activeDotColor: Theme.of(context).primaryColor,
                    dotHeight: 8,
                    dotWidth: 8,
                    spacing: 4,
                  ),
                ),
                const SizedBox(width: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
