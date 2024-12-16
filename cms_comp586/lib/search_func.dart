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
          // Comment Button Section
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton.icon(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  builder: (context) => Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Add a Comment',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          decoration: const InputDecoration(
                            labelText: 'Type your comment here',
                            border: OutlineInputBorder(),
                          ),
                          onSubmitted: (value) {
                            // Logic to handle the typed comment (optional)
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.comment),
              label: const Text('Add Comment'),
            ),
          ),

          // Search Bar Section
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

          // Search Results Section
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
    User? user = FirebaseAuth.instance.currentUser;
    String? userId = user?.uid;

    if (userId == null) {
      return Center(child: Text('Please log in to search for files.'));
    }

    return StreamBuilder(
      stream: (query.isNotEmpty)
          ? FirebaseFirestore.instance
              .collection('uploads')
              .doc(userId)
              .collection('userCreated')
              .where('fileName', isEqualTo: query)
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
