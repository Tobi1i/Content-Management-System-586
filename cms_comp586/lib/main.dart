import 'package:cms_comp586/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'app.dart';
import 'comment_section.dart'; // Import the CommentSection widget
import 'search_func.dart'; // Import SearchScreen
import 'profile_screen.dart';  // Import ProfileScreen


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomeScreen(),
    );
  }
}

class FileCardWidget extends StatelessWidget {
  final String fileName;
  final String fileSize;
  final IconData fileTypeIcon;
  final String fileId; // fileId to be passed to CommentSection

  const FileCardWidget({
    super.key,
    required this.fileName,
    required this.fileSize,
    required this.fileTypeIcon,
    required this.fileId,
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
              // Implement options if necessary
            },
          ),
          onTap: () {
            // Navigate to CommentSection with fileId for commenting
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CommentSection(fileId: fileId),
              ),
            );
          },
        ),
      ),
    );
  }
}

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
                MaterialPageRoute(
                  builder: (context) => const ProfileScreen(),
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

            // Display files from Firestore
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('files').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  var files = snapshot.data!.docs;
                  return ListView.builder(
                    itemCount: files.length,
                    itemBuilder: (context, index) {
                      var file = files[index];
                      return FileCardWidget(
                        fileName: file['name'],
                        fileSize: file['size'].toString(),
                        fileTypeIcon: Icons.folder, // Icon based on file type
                        fileId: file.id, // Pass the fileId for navigation
                      );
                    },
                  );
                },
              ),
            ),

            // Button to go to search screen
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SearchScreen()),
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

// Define SignedOutAction Widget
class SignedOutAction extends StatelessWidget {
  final Function(BuildContext) onPressed;

  const SignedOutAction(this.onPressed, {super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.exit_to_app),
      onPressed: () => onPressed(context),
    );
  }
}
