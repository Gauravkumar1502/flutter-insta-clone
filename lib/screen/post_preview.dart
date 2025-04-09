import 'package:flutter/material.dart';
import 'package:flutter_insta_clone/bloc/post/post_bloc.dart';
import 'package:flutter_insta_clone/bloc/post/post_events.dart';
import 'package:flutter_insta_clone/models/media_model.dart';
import 'package:flutter_insta_clone/models/post_model.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MediaEditScreen extends StatefulWidget {
  final List<Media> selectedMedia;

  const MediaEditScreen({super.key, required this.selectedMedia});

  @override
  State<MediaEditScreen> createState() => _MediaEditScreenState();
}

class _MediaEditScreenState extends State<MediaEditScreen> {
  late PageController _pageController;
  int _currentPage = 0;
  Map<String, VideoPlayerController> _videoControllers = {};

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _pageController.addListener(_onPageChanged);
    _initializeControllers();
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

  void _onPageChanged() {
    final page = _pageController.page?.round() ?? 0;
    if (_currentPage != page) {
      setState(() {
        _currentPage = page;
      });

      // Pause all videos
      for (final controller in _videoControllers.values) {
        controller.pause();
      }
    }
  }

  Future<void> _initializeControllers() async {
    // Create controllers for each video
    for (final media in widget.selectedMedia) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(elevation: 8, title: Text('New Post')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              // Media preview takes most of the screen
              Expanded(
                flex: 3,
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: widget.selectedMedia.length,
                  itemBuilder: (context, index) {
                    final media = widget.selectedMedia[index];
                    if (media.type == MediaType.image) {
                      return Image.memory(
                        media.file,
                        fit: BoxFit.contain,
                      );
                    } else if (media.type == MediaType.video) {
                      final controller = _videoControllers[media.id];

                      if (controller == null ||
                          !controller.value.isInitialized) {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
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
                                  color:
                                      Theme.of(context).primaryColor,
                                  size: 64,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    return Center(
                      child: Text('Unsupported media type'),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  height: 80,
                  child: ListView.builder(
                    itemCount: 5,
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    itemBuilder: (context, index) {
                      return TextButton(
                        onPressed: () {},
                        child: Column(
                          children: [
                            CircleAvatar(
                              child: Icon(Icons.filter, size: 24),
                            ),
                            Text('Filter ${index + 1}'),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButtonTheme(
                    data: ElevatedButtonThemeData(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Theme.of(context).colorScheme.primary,
                        foregroundColor:
                            Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        if (mounted) {
                          context.read<PostBloc>().add(
                            AddPostEvent(
                              post: Post(
                                id:
                                    DateTime.now()
                                        .millisecondsSinceEpoch
                                        .toString(),
                                media: widget.selectedMedia,
                                createdAt: DateTime.now(),
                              ),
                            ),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Post added successfully',
                              ),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                          Navigator.pop(context);
                          Navigator.pop(context);
                        }
                      },
                      child: Text('Share'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
