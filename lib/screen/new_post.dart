import 'package:flutter/material.dart';
import 'package:flutter_insta_clone/services/permission_service.dart';
import 'package:permission_handler/permission_handler.dart';

class NewPost extends StatefulWidget {
  const NewPost({super.key});

  @override
  State<NewPost> createState() => _NewPostState();
}

class _NewPostState extends State<NewPost> {
  @override
  void initState() async {
    super.initState();
    final bool photoPermission =
        await PermissionService.requestPermission(Permission.photos);
    final bool cameraPermission =
        await PermissionService.requestPermission(Permission.camera);
    final bool videoPermission =
        await PermissionService.requestPermission(Permission.videos);
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
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                'Create a new post',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                ),
              ),
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
