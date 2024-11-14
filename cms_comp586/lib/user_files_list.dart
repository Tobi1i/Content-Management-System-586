import 'dart:io';
import 'package:cms_comp586/file_provider.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html; // Only used in web environment
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

class FilesList extends StatefulWidget {
  const FilesList({super.key});

  @override
  FilesListState createState() => FilesListState();
}

class FilesListState extends State<FilesList> {
  @override
  void initState() {
    super.initState();

    // Fetch files when the widget is first created
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<FileProvider>(context, listen: false).fetchUserFiles();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FileProvider>(
      builder: (context, fileProvider, child) {
        if (fileProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (fileProvider.files.isEmpty) {
          return const Center(child: Text('No files found.'));
        }

        return Expanded(
          child: ListView.builder(
            itemCount: fileProvider.files.length,
            itemBuilder: (context, index) {
              Map<String, dynamic> fileData = fileProvider.files[index];
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
                downloadURL: downloadURL,
                userId: fileProvider.auth.currentUser!.uid,
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
}

class FileCardWidget extends StatefulWidget {
  final String fileName;
  final String fileSize;
  final IconData fileTypeIcon;
  final String downloadURL;
  final String userId;

  const FileCardWidget({
    super.key,
    required this.fileName,
    required this.fileSize,
    required this.fileTypeIcon,
    required this.downloadURL,
    required this.userId,
  });

  @override
  State<FileCardWidget> createState() => _FileCardWidgetState();
}

class _FileCardWidgetState extends State<FileCardWidget> {
  Future<void> downloadFile() async {
    try {
      if (kIsWeb) {
        // Web platform download implementation
        html.AnchorElement anchorElement =
            html.AnchorElement(href: widget.downloadURL);
        anchorElement.download = widget.downloadURL;
        anchorElement.click();
        // Will download through browser
      } else {
        // Mobile platform download implementation
        final response = await http.get(Uri.parse(widget.downloadURL));

        // Get the directory to save the file
        final directory =
            await getExternalStorageDirectory(); // For Android/iOS

        // Create the file path
        final file = File('${directory!.path}/$widget.fileName');

        // Save the file
        await file.writeAsBytes(response.bodyBytes);

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('File downloaded.')),
        );
      }
    } catch (e) {
      throw Exception('Failed to download file: $e');
    }
  }

  Future<void> deleteItem({
    required String userId,
    required String fileName,
    required String storagePath,
  }) async {
    try {
      final firestore = FirebaseFirestore.instance;
      final storage = FirebaseStorage.instance;

      // Delete from Firestore
      await firestore
          .collection('uploads')
          .doc(userId)
          .collection('userCreated')
          .doc(fileName)
          .delete();

      // Delete from Storage
      await storage.refFromURL(storagePath).delete();

      if (!mounted) return;
      Provider.of<FileProvider>(context, listen: false).deleteFile(fileName);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('File deleted successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('File deletion failed!')),
      );
    }
  }

  Future<void> handleDelete() async {
    try {
      await deleteItem(
        userId: widget.userId,
        fileName: widget.fileName, // The Firestore document ID
        storagePath: widget.downloadURL, // The Storage file path
      );
    } catch (e) {
      //print(e);
    }
  }

  PopupMenuItem<String> _buildMenuItem(
    String value,
    IconData icon,
    String text,
  ) {
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.black87),
          const SizedBox(width: 8),
          Text(text),
        ],
      ),
    );
  }

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
            widget.fileTypeIcon,
            color: Colors.teal,
            size: 40,
          ),
          title: Text(
            widget.fileName,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(widget.fileSize),
          trailing: PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (String value) {
              switch (value) {
                case 'download':
                  downloadFile();
                  break;
                case 'delete':
                  handleDelete();
                  break;
                case 'share':
                  // Implement share functionality
                  break;
              }
            },
            itemBuilder: (BuildContext context) => [
              _buildMenuItem('download', Icons.download, 'Download'),
              _buildMenuItem('delete', Icons.delete, 'Delete'),
              _buildMenuItem('share', Icons.share, 'Share'),
            ],
          ),
          onTap: () {
            // (preview or download) TODO
          },
        ),
      ),
    );
  }
}
