import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String searchQuery = "";

  void updateSearchQuery(String newQuery) {
    setState(() {
      searchQuery = newQuery;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Documents'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              onChanged: updateSearchQuery,
              decoration: InputDecoration(
                labelText: 'Search by title or tag',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    updateSearchQuery("");
                  },
                ),
              ),
            ),
          ),
          Expanded(
            child: SearchResultsList(query: searchQuery),
          ),
        ],
      ),
    );
  }
}

class SearchResultsList extends StatelessWidget {
  final String query;

  SearchResultsList({required this.query});

  @override
  Widget build(BuildContext context) {
    // Get the current user's ID
    User? user = FirebaseAuth.instance.currentUser;
    String? userId = user?.uid;

    // Check if user is authenticated
    if (userId == null) {
      return Center(child: Text('Please log in to search for files.'));
    }

    return StreamBuilder(
      stream: (query.isNotEmpty)
          ? FirebaseFirestore.instance
              .collection('uploads')
              .doc(userId) // Navigate to the user’s document
              .collection('userCreated') // Access the user’s uploads
              .where('fileName', isEqualTo: query) // Search by 'fileName'
              .snapshots()
          : FirebaseFirestore.instance
              .collection('uploads')
              .doc(userId)
              .collection('userCreated')
              .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No results found'));
        }

        final results = snapshot.data!.docs;

        return ListView.builder(
          itemCount: results.length,
          itemBuilder: (context, index) {
            final doc = results[index];
            return ListTile(
              title: Text(doc['fileName']),
              subtitle: Text(doc['contentType'] ?? ''),
              onTap: () {
                // Handle tap to open document details
              },
            );
          },
        );
      },
    );
  }
}
