import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

class MediaThumbnail extends StatelessWidget {
  final AssetEntity asset;
  final bool isSelected;
  final VoidCallback onTap;

  const MediaThumbnail({
    super.key,
    required this.asset,
    this.isSelected = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        fit: StackFit.expand,
        children: [
          FutureBuilder<Uint8List?>(
            future: asset.thumbnailDataWithSize(
              const ThumbnailSize(300, 300),
            ),
            builder: (context, snapshot) {
              if (snapshot.connectionState ==
                  ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(strokeWidth: 1),
                );
              }

              if (!snapshot.hasData) {
                return Container(
                  color: Theme.of(context).primaryColor,
                  child: const Center(
                    child: Icon(Icons.broken_image),
                  ),
                );
              }

              return Container(
                decoration: BoxDecoration(
                  border:
                      isSelected
                          ? Border.all(
                            color: Theme.of(context).primaryColor,
                            width: 2,
                          )
                          : null,
                ),
                child: Padding(
                  padding:
                      isSelected
                          ? const EdgeInsets.all(4)
                          : EdgeInsets.zero,
                  child: Image.memory(
                    snapshot.data!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Theme.of(context).primaryColor,
                        child: const Center(
                          child: Icon(Icons.broken_image),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),

          if (asset.type == AssetType.video)
            Positioned(
              bottom: 8,
              right: 8,
              child: Icon(
                Icons.videocam,
                size: 20,
                color: Theme.of(context).primaryColor,
              ),
            ),

          if (isSelected)
            Center(
              child: Icon(
                Icons.check_circle,
                color: Theme.of(context).primaryColor,
                size: 30,
              ),
            ),
        ],
      ),
    );
  }
}
