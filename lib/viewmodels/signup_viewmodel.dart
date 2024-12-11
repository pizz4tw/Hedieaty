import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final FirebaseFirestore _firestore = FirebaseFirestore.instance;

class SignUpViewModel extends ChangeNotifier {
  final formKey = GlobalKey<FormState>();
  late String username;
  late String email;
  DateTime? dob; // Store as DateTime
  late String password;
  String? gender;
  late String phoneNumber;

  final RegExp emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  final RegExp egyptianPhoneRegex = RegExp(r'^\+20\d{10}$');

  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool validateForm() {
    return formKey.currentState?.validate() ?? false;
  }

  Future<void> selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null && pickedDate != dob) {
      dob = pickedDate;
      notifyListeners();
    }
  }

  // Sign-up logic with Firebase Authentication and Firestore save
  Future<String?> signUp(BuildContext context) async {
    try {
      print("Starting sign-up process...");

      // Check for existing email
      QuerySnapshot emailSnapshot = await _firestore
          .collection("users")
          .where("email", isEqualTo: email)
          .get();
      if (emailSnapshot.docs.isNotEmpty) {
        return "Email is already registered. Please use a different email.";
      }

      // Check for existing username
      // QuerySnapshot usernameSnapshot = await _firestore
      //     .collection("users")
      //     .where("username", isEqualTo: username)
      //     .get();
      // if (usernameSnapshot.docs.isNotEmpty) {
      //   return "Username is already taken. Please choose a different username.";
      // }

      // Check for existing phone number
      QuerySnapshot phoneSnapshot = await _firestore
          .collection("users")
          .where("phoneNumber", isEqualTo: phoneNumber)
          .get();
      if (phoneSnapshot.docs.isNotEmpty) {
        return "Phone number is already registered. Please use a different number.";
      }

      // Firebase Authentication
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Prepare user data
      Map<String, dynamic> userData = {
        'username': username,
        'email': email,
        'dob': dob?.toIso8601String(),
        'gender': gender,
        'phoneNumber': phoneNumber,
        'profilePicture': null,
        // Ensure no profile image is set on first sign-up
      };

      // Save to Firestore under the users collection
      await _firestore.collection("users").doc(userCredential.user!.uid).set(
          userData)
          .then((_) {
        print("User data saved to Firestore");
      });

      return null; // Sign-up successful
    } catch (e) {
      print("Error during sign-up: $e");
      return 'Sign-up failed. Please try again.';
    }
  }
}
