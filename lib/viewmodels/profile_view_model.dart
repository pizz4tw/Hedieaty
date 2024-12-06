import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfileViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? name;
  String? email;
  String? profilePicture;
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
          profilePicture = userDoc['profilePicture'];
          createdEvents = List<Map<String, dynamic>>.from(userDoc['events']);
          notifyListeners();
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

  // Check if the username is unique
  Future<bool> isUsernameUnique(String newUsername) async {
    try {
      // Query the Firestore collection to check if any document has the same username
      QuerySnapshot querySnapshot = await _firestore
          .collection('users')
          .where('username', isEqualTo: newUsername)
          .get();

      // If the query returns any results, the username is not unique
      return querySnapshot.docs.isEmpty;
    } catch (e) {
      print("Error checking username uniqueness: $e");
      return false; // Return false if an error occurs
    }
  }

  // Update user information
  Future<void> updatePersonalInfo(String updatedName, String updatedProfilePicture, BuildContext context) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        // Fetch current username to compare with the updated name
        DocumentSnapshot userDoc = await _firestore.collection("users").doc(user.uid).get();
        String currentUsername = userDoc['username'];

        // Skip uniqueness check if the name is unchanged
        if (updatedName != currentUsername) {
          // Check if the username is unique
          bool isUnique = await isUsernameUnique(updatedName);

          if (!isUnique) {
            // Show an error message if the username is not unique
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Username is already taken. Please choose another one.")),
            );
            return; // Exit the method if the username is not unique
          }
        }

        // Update Firestore with new username and profile picture
        await _firestore.collection("users").doc(user.uid).update({
          'username': updatedName,
          'profilePicture': updatedProfilePicture,
        });

        // Update local variables
        name = updatedName;
        profilePicture = updatedProfilePicture;

        notifyListeners(); // Notify listeners to update UI
      }
    } catch (e) {
      print("Error updating personal information: $e");
    }
  }


  Future<void> deleteAccount() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        // Delete data from Firestore
        await _firestore.collection("users").doc(user.uid).delete();

        // Delete authentication data (i.e., the user)
        await user.delete();
      }
    } catch (e) {
      print("Error deleting account: $e");
    }
  }
}
