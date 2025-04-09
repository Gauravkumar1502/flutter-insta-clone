import 'dart:io';
import 'dart:typed_data';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_insta_clone/bloc/post/post_bloc.dart';
import 'package:flutter_insta_clone/bloc/post/post_events.dart';
import 'package:flutter_insta_clone/models/media_model.dart';
import 'package:flutter_insta_clone/models/post_model.dart';
import 'package:flutter_insta_clone/screen/post_preview.dart';
import 'package:flutter_insta_clone/services/permission_service.dart';
import 'package:flutter_insta_clone/widgets/photo_manager_widget.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_manager/photo_manager.dart';

class NewPost extends StatefulWidget {
  const NewPost({super.key});

  @override
  State<NewPost> createState() => _NewPostState();
}

class _NewPostState extends State<NewPost> {
  bool isPermissionGranted = false;
  List<AssetEntity> selectedAssets = [];

  @override
  void initState() {
    super.initState();
    getPermissions();
  }

  void handleSelectionChanged(List<AssetEntity> assets) {
    setState(() {
      selectedAssets = assets;
    });
  }

  Future<void> getPermissions() async {
    bool photoPermissionGranted = false;
    bool videoPermissionGranted = false;
    bool storagePermissionGranted = false;
    bool cameraPermissionGranted = false;
    if (Platform.isAndroid) {
      var androidInfo = await DeviceInfoPlugin().androidInfo;
      if (androidInfo.version.sdkInt >= 33) {
        // Request permissions for Android 13 and above
        photoPermissionGranted =
            await PermissionService.requestPermission(
              Permission.photos,
            );
        videoPermissionGranted =
            await PermissionService.requestPermission(
              Permission.videos,
            );
        cameraPermissionGranted =
            await PermissionService.requestPermission(
              Permission.camera,
            );
        setState(() {
          isPermissionGranted =
              photoPermissionGranted &&
              videoPermissionGranted &&
              cameraPermissionGranted;
        });
      } else {
        // Request permissions for Android 12 and below
        storagePermissionGranted =
            await PermissionService.requestPermission(
              Permission.storage,
            );
        cameraPermissionGranted =
            await PermissionService.requestPermission(
              Permission.camera,
            );
        setState(() {
          isPermissionGranted =
              storagePermissionGranted && cameraPermissionGranted;
        });
      }
    } else if (Platform.isIOS) {
      photoPermissionGranted =
          await PermissionService.requestPermission(
            Permission.photos,
          );
      setState(() {
        isPermissionGranted = photoPermissionGranted;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 8,
        title: Text('New Post'),
        actions: [
          TextButton(
            child: Text('Next'),
            onPressed: () async {
              final List<Media> mediaList = await Future.wait(
                selectedAssets.map((asset) async {
                  final Uint8List? bytes = await asset.originBytes;

                  return Media(
                    id: asset.id,
                    type:
                        asset.type == AssetType.image
                            ? MediaType.image
                            : MediaType.video,
                    file: bytes!,
                    extension:
                        asset.title?.split('.').last.toLowerCase() ??
                        'jpg',
                  );
                }).toList(),
              );

              if (mounted) {
                // Navigate to edit screen instead of immediately creating post
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) =>
                            MediaEditScreen(selectedMedia: mediaList),
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox.expand(
                  child: InteractiveViewer(
                    minScale: 0.5,
                    maxScale: 5,
                    child: Image.network(
                      'https://picsum.photos/300/300',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(
                          child: Text(
                            'Error loading image',
                            style: TextStyle(color: Colors.red),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child:
                  isPermissionGranted
                      ? PhotoManagerWidget(
                        onSelectionChanged: handleSelectionChanged,
                      )
                      : Text("Permissions not granted"),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.white,
                ),
                child: Row(
                  spacing: 10,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FilledButton.tonal(
                      onPressed: () {},
                      child: Text('Post'),
                    ),
                    FilledButton.tonal(
                      onPressed: () {},
                      child: Text('Reel'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
