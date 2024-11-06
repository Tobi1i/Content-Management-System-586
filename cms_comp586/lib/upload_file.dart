import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';

class UploadFileScreen extends StatefulWidget {
  const UploadFileScreen({super.key});

  @override
  UploadFileScreenState createState() => UploadFileScreenState();
}

class UploadFileScreenState extends State<UploadFileScreen> {
  String? _downloadURL;
  String? _fileName;
  String _visibility = 'private'; // Default visibility

  Future<void> _uploadFile() async {
    try {
      // Pick a file using file_picker package
      FilePickerResult? result = await FilePicker.platform.pickFiles();
      if (result == null) return;

      // Get the file and its name
      PlatformFile file = result.files.first;
      String fileName = file.name;
      _fileName = fileName;

      // Get current user ID
      User? user = FirebaseAuth.instance.currentUser;
      String userId = user!.uid;

      // Reference to Firebase Storage
      FirebaseStorage storage = FirebaseStorage.instance;
      Reference storageRef = storage.ref('uploads/$userId/$fileName');

      // Platform-specific file upload
      if (kIsWeb) {
        // For web, use the bytes property
        await storageRef.putData(file.bytes!); // Use putData for web
      } else {
        // For mobile, use the path property
        await storageRef.putFile(File(file.path!)); // Use putFile for mobile
      }
      // Get the download URL
      _downloadURL = await storageRef.getDownloadURL();
      // Save file metadata to Firestore
      await FirebaseFirestore.instance
          .collection('uploads')
          .doc(userId)
          .collection('userCreated')
          .doc(fileName)
          .set({
        'fileName': fileName,
        'contentType': file.extension, // Store the file type (e.g., jpg, pdf)
        'downloadURL': _downloadURL,
        'visibility': _visibility,
        'sharedWith': [], // Empty sharedWith array initially
      });

      setState(() {
        // Update the UI with the new file's metadata
        _fileName = fileName;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('File uploaded successfully!')),
      );
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to upload file')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          ElevatedButton(
            onPressed: _uploadFile,
            child: const Text('Pick & Upload File'),
          ),
          const SizedBox(height: 20),
          if (_fileName != null) ...[
            Text('File: $_fileName'),
            Text('Visibility: $_visibility'),
            TextButton(
              onPressed: () {
                // Optionally toggle visibility
                setState(() {
                  _visibility = _visibility == 'private' ? 'public' : 'private';
                });
              },
              child: const Text('Generate Share Link'),
            ),
          ],
        ],
      ),
    );
  }
}
