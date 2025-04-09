import 'package:flutter/material.dart';
import 'package:flutter_insta_clone/services/permission_service.dart';
import 'package:flutter_insta_clone/widgets/photo_manager_widget.dart';
import 'package:permission_handler/permission_handler.dart';

class NewPost extends StatefulWidget {
  const NewPost({super.key});

  @override
  State<NewPost> createState() => _NewPostState();
}

class _NewPostState extends State<NewPost> {
  bool isPermissionGranted = false;
  @override
  void initState() {
    super.initState();
    getPermissions();
  }

  Future<void> getPermissions() async {
    final bool photoPermissionGranted =
        await PermissionService.requestPermission(Permission.photos);
    final bool videoPermissionGranted =
        await PermissionService.requestPermission(Permission.videos);
    final bool cameraPermissionGranted =
        await PermissionService.requestPermission(Permission.camera);
    if (photoPermissionGranted &&
        videoPermissionGranted &&
        cameraPermissionGranted) {
      // All permissions granted
      print('All permissions granted');
      setState(() {
        isPermissionGranted = true;
      });
    } else {
      setState(() {
        isPermissionGranted = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 8,
        title: Text('New Post'),
        actions: [TextButton(child: Text('Next'), onPressed: () {})],
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
                      ? PhotoManagerWidget()
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
