import 'package:flutter/material.dart';
import 'package:flutter_insta_clone/bloc/post/post_bloc.dart';
import 'package:flutter_insta_clone/bloc/post/post_events.dart';
import 'package:flutter_insta_clone/models/media_model.dart';
import 'package:flutter_insta_clone/models/post_model.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image/image.dart' as img;

class MediaEditScreen extends StatefulWidget {
  final List<Media> selectedMedia;
  const MediaEditScreen({super.key, required this.selectedMedia});

  @override
  State<MediaEditScreen> createState() => _MediaEditScreenState();
}

class _MediaEditScreenState extends State<MediaEditScreen> {
  List<Media> modifiedMedia = [];
  late PageController _pageController;
  int _currentPage = 0;
  Map<String, VideoPlayerController> _videoControllers = {};

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _pageController.addListener(_onPageChanged);
    _initializeControllers();
    modifiedMedia =
        widget.selectedMedia
            .map(
              (media) => Media(
                id: media.id,
                type: media.type,
                file: media.file, // working copy
                extension: media.extension,
              ),
            )
            .toList();
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

  void _applyFilter(int filterIndex) {
    debugPrint(
      'Applying filter $filterIndex to image at index $_currentPage',
    );
    img.Image? image = img.decodeImage(
      widget.selectedMedia[_currentPage].file,
    );

    if (image == null) return;

    if (filterIndex == 1) {
      image = img.grayscale(image);
    } else if (filterIndex == 2) {
      image = img.sepia(image);
    } else if (filterIndex == 3) {
      image = img.billboard(image);
    } else if (filterIndex == 4) {
      image = img.bleachBypass(image);
    } else if (filterIndex == 5) {
      image = img.chromaticAberration(image);
    }
    final filteredBytes = img.encodeJpg(image);
    setState(() {
      modifiedMedia[_currentPage] = Media(
        id: widget.selectedMedia[_currentPage].id,
        type: widget.selectedMedia[_currentPage].type,
        file:
            filterIndex == 0
                ? widget.selectedMedia[_currentPage].file
                : filteredBytes,
        extension: widget.selectedMedia[_currentPage].extension,
      );
    });
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
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged:
                      (value) => setState(() {
                        _currentPage = value;
                      }),
                  itemCount: modifiedMedia.length,
                  itemBuilder: (context, index) {
                    final media = modifiedMedia[index];
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
                    itemCount: 6,
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    itemBuilder: (context, index) {
                      return TextButton(
                        onPressed: () => _applyFilter(index),
                        child: Column(
                          children: [
                            CircleAvatar(
                              child: Icon(Icons.filter, size: 24),
                            ),
                            Text(
                              index == 0
                                  ? 'No Filter'
                                  : 'Filter $index',
                            ),
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
                                media: modifiedMedia,
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
