import 'package:flutter/widgets.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:flutter_insta_clone/models/media_model.dart';

class MediaPickerService {
  Future<List<Media>> pickMedia() async {
    final permission = await PhotoManager.requestPermissionExtend();

    if (!permission.isAuth) {
      throw Exception('Permission denied');
    }

    // Get all albums (images + videos)
    final List<AssetPathEntity> albums =
        await PhotoManager.getAssetPathList(type: RequestType.all);

    if (albums.isEmpty) return [];

    debugPrint('Albums: $albums');

    // Fetch media from first album (Recent)
    final List<AssetEntity> assets = await albums[0]
        .getAssetListPaged(page: 0, size: 100);

    List<Media> mediaList = [];

    for (final asset in assets) {
      final bytes = await asset.originBytes;
      final ext = asset.title?.split('.').last ?? 'jpg';

      if (bytes != null) {
        mediaList.add(
          Media(
            id: asset.id,
            extension: ext,
            file: bytes,
            type:
                asset.type == AssetType.image
                    ? MediaType.image
                    : MediaType.video,
          ),
        );
      }
    }

    return mediaList;
  }
}
