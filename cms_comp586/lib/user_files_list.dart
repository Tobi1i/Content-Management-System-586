import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FilesList extends StatefulWidget {
  const FilesList({super.key});

  @override
  FilesListState createState() => FilesListState();
}

class FilesListState extends State<FilesList> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> _getUserFiles() async {
    User? user = _auth.currentUser;
    if (user == null) {
      throw Exception("User not logged in");
    }

    String userId = user.uid;

    // Fetch files from Firestore
    // pagination TODO
    QuerySnapshot<Map<String, dynamic>> querySnapshot = await _firestore
        .collection('uploads')
        .doc(userId)
        .collection('userCreated')
        .get();

    // Convert documents to a list of file metadata
    List<Map<String, dynamic>> files =
        querySnapshot.docs.map((doc) => doc.data()).toList();

    return files;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _getUserFiles(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Center(child: Text('Error loading files'));
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No files found.'));
        }

        List<Map<String, dynamic>> files = snapshot.data!;

        return Expanded(
          child: ListView.builder(
            itemCount: files.length,
            itemBuilder: (context, index) {
              Map<String, dynamic> fileData = files[index];
              String fileName = fileData['fileName'] ?? 'Unknown File';
              String fileSize = _getFileSize(fileData['size'] ?? 0);
              String contentType = fileData['contentType'] ?? 'unknown';
              String downloadURL = fileData['downloadURL'] ?? '';

              // Determine icon based on file type (contentType)
              IconData fileTypeIcon = _getFileIcon(contentType);

              return FileCardWidget(
                fileName: fileName,
                fileSize: fileSize,
                fileTypeIcon: fileTypeIcon,
              );
            },
          ),
        );
      },
    );
  }

  // Utility function to handle file size formatting
  String _getFileSize(int bytes) {
    if (bytes < 1024) {
      return "$bytes B";
    }
    if (bytes < 1024 * 1024) {
      return "${(bytes / 1024).toStringAsFixed(2)} KB";
    }
    if (bytes < 1024 * 1024 * 1024) {
      return "${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB";
    }
    return "${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB";
  }

  // Utility function to return appropriate icon based on file type
  IconData _getFileIcon(String contentType) {
    if (contentType.startsWith('image/')) {
      return Icons.image;
    } else if (contentType.startsWith('video/')) {
      return Icons.video_library;
    } else if (contentType == 'application/pdf') {
      return Icons.picture_as_pdf;
    } else if (contentType.startsWith('audio/')) {
      return Icons.audiotrack;
    } else {
      return Icons.insert_drive_file; // unknown file types
    }
  }

  // Function to handle downloading the file
  void _downloadFile(String downloadURL) {
    // Find package to work on web and mobile TODO
    //print('Download URL: $downloadURL'); //Download link is direct
  }
}

class FileCardWidget extends StatelessWidget {
  final String fileName;
  final String fileSize;
  final IconData fileTypeIcon;

  const FileCardWidget({
    super.key,
    required this.fileName,
    required this.fileSize,
    required this.fileTypeIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: ListTile(
          leading: Icon(
            fileTypeIcon,
            color: Colors.teal,
            size: 40,
          ),
          title: Text(
            fileName,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(fileSize),
          trailing: IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              // (open menu, file options) TODO
            },
          ),
          onTap: () {
            // (preview or download) TODO
          },
        ),
      ),
    );
  }
}
