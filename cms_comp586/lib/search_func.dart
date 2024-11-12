import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

  const SearchResultsList({super.key, required this.query});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: (query.isNotEmpty)
          ? FirebaseFirestore.instance
              .collection('documents')
              .where('tags', arrayContains: query)
              .snapshots()
          : FirebaseFirestore.instance.collection('documents').snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No results found'));
        }

        final results = snapshot.data!.docs;

        return ListView.builder(
          itemCount: results.length,
          itemBuilder: (context, index) {
            final doc = results[index];
            return ListTile(
              title: Text(doc['title']),
              subtitle: Text(doc['description'] ?? ''),
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
