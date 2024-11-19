import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CommentSection extends StatefulWidget {
  final String fileId; // File ID to identify the document

  CommentSection({required this.fileId});

  @override
  _CommentSectionState createState() => _CommentSectionState();
}

class _CommentSectionState extends State<CommentSection> {
  TextEditingController _controller = TextEditingController();
  late CollectionReference comments;

  @override
  void initState() {
    super.initState();
    // Initialize Firestore collection
    comments = FirebaseFirestore.instance
        .collection('files')
        .doc(widget.fileId)
        .collection('comments');
  }

  // Function to add a comment
  void _addComment() async {
    if (_controller.text.isNotEmpty) {
      await comments.add({
        'text': _controller.text,
        'timestamp': FieldValue.serverTimestamp(),
      });
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Comments for File ID: ${widget.fileId}'),
        TextField(
          controller: _controller,
          decoration: InputDecoration(hintText: 'Add a comment'),
        ),
        ElevatedButton(
          onPressed: _addComment,
          child: Text('Submit Comment'),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: comments.orderBy('timestamp').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('Something went wrong!'));
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(child: Text('No comments yet.'));
              }

              var commentDocs = snapshot.data!.docs;
              return ListView.builder(
                itemCount: commentDocs.length,
                itemBuilder: (context, index) {
                  var commentData = commentDocs[index];
                  return ListTile(
                    title: Text(commentData['text']),
                    subtitle: Text(commentData['timestamp'].toDate().toString()),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
