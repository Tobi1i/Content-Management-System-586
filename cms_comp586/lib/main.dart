import 'package:cms_comp586/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'app.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
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
              // void
            },
          ),
          onTap: () => {
            // void
          },
        ),
      ),
    );
  }
}
