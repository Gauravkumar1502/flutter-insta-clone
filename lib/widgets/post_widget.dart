import 'package:flutter/material.dart';
import 'package:flutter_insta_clone/models/media_model.dart';
import 'package:flutter_insta_clone/models/post_model.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:video_player/video_player.dart';

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
  int _currentPage = 0;
  Map<String, VideoPlayerController> _videoControllers = {};

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _pageController.addListener(_onPageChanged);
    _initializeControllers();
  }

  void _onPageChanged() {
    final page = _pageController.page?.round() ?? 0;
    if (_currentPage != page) {
      setState(() {
        _currentPage = page;
      });

      _pauseAllVideos();
    }
  }

  Future<void> _initializeControllers() async {
    // Create controllers for each video
    for (final media in widget.post.media) {
      if (media.type == MediaType.video) {
        try {
          final mediaFile = await media.toFile();
          final controller = VideoPlayerController.file(mediaFile);
          await controller.initialize();

          // Only mount if widget is still in the tree
          if (mounted) {
            setState(() {
              _videoControllers[media.id] = controller;
            });
          }
        } catch (e) {
          debugPrint('Error initializing video ${media.id}: $e');
        }
      }
    }
  }

  void _pauseAllVideos() {
    for (var controller in _videoControllers.values) {
      controller.pause();
    }
  }

  @override
  void dispose() {
    _pageController.removeListener(_onPageChanged);
    _pageController.dispose();
    for (final controller in _videoControllers.values) {
      controller.dispose();
    }
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
          AspectRatio(
            aspectRatio: .8,
            child: PageView.builder(
              itemCount: widget.post.media.length,
              controller: _pageController,
              physics: const BouncingScrollPhysics(),
              itemBuilder: (context, index) {
                final media = widget.post.media[index];
                if (media.type == MediaType.image) {
                  return Image.memory(
                    media.file,
                    fit: BoxFit.contain,
                  );
                } else if (media.type == MediaType.video) {
                  final controller = _videoControllers[media.id];

                  if (controller == null ||
                      !controller.value.isInitialized) {
                    return Center(child: CircularProgressIndicator());
                  }
                  return AspectRatio(
                    aspectRatio: controller.value.aspectRatio,
                    child: Stack(
                      children: [
                        VideoPlayer(controller),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              if (controller.value.isPlaying) {
                                controller.pause();
                              } else {
                                controller.play();
                              }
                            });
                          },
                          child: Center(
                            child: Icon(
                              controller.value.isPlaying
                                  ? Icons.pause
                                  : Icons.play_arrow,
                              color: Theme.of(context).primaryColor,
                              size: 64,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return Center(child: Text('Unsupported media type'));
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
