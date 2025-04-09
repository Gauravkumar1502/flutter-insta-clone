import 'package:flutter/material.dart';
import 'package:flutter_insta_clone/widgets/media_thumbnail_widget.dart';
import 'package:photo_manager/photo_manager.dart';

class PhotoManagerWidget extends StatefulWidget {
  final Function(List<AssetEntity>) onSelectionChanged;
  const PhotoManagerWidget({
    super.key,
    required this.onSelectionChanged,
  });

  @override
  State<PhotoManagerWidget> createState() =>
      _PhotoManagerWidgetState();
}

class _PhotoManagerWidgetState extends State<PhotoManagerWidget> {
  late List<AssetPathEntity> paths;
  Map<String, List<AssetEntity>> mediaMap = {
    'recent': [],
    'images': [],
    'videos': [],
  };
  Map<String, int> pageCount = {
    'recent': 0,
    'images': 0,
    'videos': 0,
  };
  String selectedTab = 'recent';
  List<AssetEntity> selectedAssets = [];

  bool isLoading = false;
  bool isError = false;

  @override
  void initState() {
    super.initState();
    fetchMedia(type: RequestType.all, key: 'recent');
  }

  Future<void> fetchMedia({
    required RequestType type,
    required String key, // recent, images, videos
    bool loadMore = false,
    int pageSize = 100,
  }) async {
    if (isLoading) return;
    setState(() {
      isLoading = true;
    });

    try {
      if (!loadMore && mediaMap[key]!.isNotEmpty) {
        debugPrint('Already Loaded $key Media');
        return;
      }
      final List<AssetPathEntity> paths =
          await PhotoManager.getAssetPathList(type: type);
      debugPrint('Fetched Paths Successfully. $paths');
      debugPrint(
        'Fetched Paths Successfully. Count: ${paths.length}',
      );
      if (paths.isEmpty) {
        debugPrint('No Albums found');
        return;
      }
      final int currentPage = pageCount[key] ?? 0;
      final List<AssetEntity> media = await paths[0]
          .getAssetListPaged(page: currentPage, size: pageSize);
      debugPrint('Media: $media');
      debugPrint(
        'Album: ${paths[0].name} | Media Count: ${media.length}',
      );
      if (media.isEmpty) {
        debugPrint('No Media found');
        return;
      }
      if (loadMore) {
        mediaMap[key]!.addAll(media);
        pageCount[key] = currentPage + 1;
      } else {
        mediaMap[key] = media;
        pageCount[key] = 1;
      }
      debugPrint('Media Count: ${mediaMap[key]!.length}');
      debugPrint('Page Count: ${pageCount[key]}');
      debugPrint('Media Map: $mediaMap');
      debugPrint('Selected Tab: $selectedTab');
      debugPrint(
        'Fetched $key → Page: ${pageCount[key]} → Total: ${mediaMap[key]!.length}',
      );
      setState(() {
        isLoading = false;
      });
    } catch (e, s) {
      debugPrint('EXCEPTION OCCURRED -> $e');
      debugPrint('STACKTRACE -> $s');
      setState(() {
        isLoading = false;
        isError = true;
      });
      debugPrint('Error occurred while fetching media: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
      debugPrint('Loading completed');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 10,
      children: [
        Row(
          spacing: 10,
          children: [
            TextButton(
              onPressed: () {
                setState(() {
                  selectedTab = 'recent';
                  fetchMedia(type: RequestType.all, key: 'recent');
                });
              },
              child: Column(
                children: [
                  const Icon(Icons.access_time),
                  Text('Recent'),
                ],
              ),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  selectedTab = 'images';
                  fetchMedia(type: RequestType.image, key: 'images');
                });
              },
              child: Column(
                children: [const Icon(Icons.image), Text('Images')],
              ),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  selectedTab = 'videos';
                  fetchMedia(type: RequestType.video, key: 'videos');
                });
              },
              child: Column(
                children: [
                  const Icon(Icons.video_collection),
                  Text('Videos'),
                ],
              ),
            ),
          ],
        ),
        Expanded(
          child: Center(
            child: GridView.builder(
              padding: const EdgeInsets.all(8),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
              ),
              itemCount: mediaMap[selectedTab]!.length,
              itemBuilder: (context, index) {
                final AssetEntity asset =
                    mediaMap[selectedTab]![index];
                return MediaThumbnail(
                  asset: asset,
                  isSelected: selectedAssets.contains(asset),
                  onTap: () {
                    debugPrint('Selected Asset ID: ${asset.id}');
                    setState(() {
                      if (selectedAssets.contains(asset)) {
                        selectedAssets.remove(asset);
                      } else {
                        selectedAssets.add(asset);
                      }
                      widget.onSelectionChanged(selectedAssets);
                    });
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
