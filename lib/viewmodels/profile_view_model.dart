import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfileViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? name;
  String? email;
  String? profilePicture; // Can be a network URL or asset path
  bool notificationsEnabled = false;
  List<Map<String, dynamic>> createdEvents = [];

  // Fetch user data from Firestore
  Future<void> fetchUserData() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        DocumentSnapshot userDoc =
        await _firestore.collection("users").doc(user.uid).get();
        if (userDoc.exists) {
          name = userDoc['username'];
          email = userDoc['email'];
          profilePicture = userDoc['profilePicture']; // You can store a URL here
          createdEvents = List<Map<String, dynamic>>.from(userDoc['events']);
          notifyListeners(); // Notifies the UI of the data change
        }
      }
    } catch (e) {
      print("Error fetching user data: $e");
    }
  }

  void toggleNotifications(bool value) {
    notificationsEnabled = value;
    notifyListeners();
  }

  Future<void> updatePersonalInfo(String updatedName, String updatedProfilePicture) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        // Update Firestore data
        await _firestore.collection("users").doc(user.uid).update({
          'username': updatedName,
          'profilePicture': updatedProfilePicture,
        });

        // Update local variables
        name = updatedName;
        profilePicture = updatedProfilePicture;

        notifyListeners(); // Notify UI of changes
      }
    } catch (e) {
      print("Error updating personal information: $e");
    }
  }
}
