import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../views/home_page.dart';
import '../models/PigeonUserDetails.dart';

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

      // Firebase Authentication
      print("Creating user with email: $email");
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      print("User created successfully with UID: ${userCredential.user!.uid}");

      // Store additional user details in Firestore
      print("Saving additional user details to Firestore...");

      // Prepare user data
      Map<String, dynamic> userData = {
        'username': username,
        'email': email,
        'dob': dob?.toIso8601String(),
        'gender': gender,
        'phoneNumber': phoneNumber,
      };

      // Log data before attempting to save
      print("User data to save in Firestore: $userData");

      // Save to Firestore under the users collection
      await _firestore.collection("users").doc(userCredential.user!.uid).set(userData)
          .then((_) {
        print("User details saved successfully in Firestore.");
      }).catchError((error) {
        print("Error saving user details in Firestore: $error");
        return error.toString(); // Return Firestore error
      });

      // **Do not attempt to cast the data as a custom object** here, just print the data directly.
      try {
        final snapshot = await _firestore.collection("users").doc(userCredential.user!.uid).get();
        if (snapshot.exists) {
          var data = snapshot.data();
          print('Fetched data from Firestore: $data');
          // Debugging: Print the type of data to ensure it's correct
          print('Fetched data type: ${data?.runtimeType}');

          // Attempt to map Firestore data to your custom model
          var userDetails = PigeonUserDetails.fromMap(data);  // Map to custom model
          print('Mapped user details: $userDetails');
        } else {
          print("No user details found in Firestore.");
        }
      } catch (e) {
        print("Error fetching user details from Firestore: $e");
      }

      // Navigate to HomePage() after successful sign-up
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );

      return null; // Sign-up successful
    } catch (e) {
      print("Sign up failed with error: $e");
      return e.toString(); // Return the error message
    }
  }
}
