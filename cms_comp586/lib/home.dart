import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';

import 'upload_file.dart';
import 'user_files_list.dart';
import 'search_func.dart';
import 'comment_section.dart'; // Import CommentSection widget

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute<ProfileScreen>(
                  builder: (context) => ProfileScreen(
                    appBar: AppBar(
                      title: const Text('User Profile'),
                    ),
                    actions: [
                      SignedOutAction((context) {
                        Navigator.of(context).pop();
                      })
                    ],
                    children: [
                      const Divider(),
                      Padding(
                        padding: const EdgeInsets.all(2),
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: Image.asset('assets/android-chrome-192x192.png'), // Fixed typo in assets path
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          )
        ],
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Welcome!',
              style: Theme.of(context).textTheme.displaySmall,
            ),
            const SizedBox(height: 20), // Space between widgets

            // Display the UploadFileScreen and pass fileId to CommentSection
            // Here, I assume fileId is passed from the file selection or upload process.
            const UploadFileScreen(fileId: 'exampleFileId'), // This should be dynamically passed based on file

            // Display FilesList - This may also involve selecting a file
            const FilesList(),

            // SignOutButton - Provide a sign-out option for users
            const SignOutButton(),
            
            // ElevatedButton to navigate to the SearchScreen
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SearchScreen()),
                );
              },
              child: const Text('Go to Search'),
            ),
          ],
        ),
      ),
    );
  }
}

class UploadFileScreen extends StatelessWidget {
  final String fileId; // This is the fileId used for identifying the file in Firestore

  const UploadFileScreen({super.key, required this.fileId});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // File upload UI or file-related actions
        Text('Upload or select file: $fileId'), // Placeholder text for fileId
        // Pass fileId to the CommentSection
        CommentSection(fileId: fileId), // Display the CommentSection for the selected file
      ],
    );
  }
}
