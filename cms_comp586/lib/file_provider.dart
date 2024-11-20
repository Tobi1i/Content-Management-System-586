import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FileProvider with ChangeNotifier {
  List<Map<String, dynamic>> _files = [];

  List<Map<String, dynamic>> get files => _files;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  FirebaseAuth get auth => _auth;

  Future<void> fetchUserFiles() async {
    User? user = _auth.currentUser;
    if (user == null) {
      return;
    }

    String userId = user.uid;

    _isLoading = true;
    notifyListeners();

    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await _firestore
          .collection('uploads')
          .doc(userId)
          .collection('userCreated')
          .get();

      _files = querySnapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      // Handle any errors here
      //print('Error: $e');
    }
    _isLoading = false;
    notifyListeners();
  }

  void addFile(Map<String, dynamic> file) {
    _files.add(file);
    notifyListeners(); // Notify listeners about changes
  }

  void deleteFile(String fileName) {
    _files.removeWhere((file) => file['fileName'] == fileName);
    notifyListeners();
  }
}
