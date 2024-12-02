import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginViewModel extends ChangeNotifier {
  final formKey = GlobalKey<FormState>();
  String email = '';
  String password = '';
  final RegExp emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
  bool isLoading = false;
  String errorMessage = '';

  // Validate form before login attempt
  bool validateForm() {
    if (formKey.currentState?.validate() ?? false) {
      return true;
    }
    return false;
  }

  // Handle login logic
  Future<void> loginUser() async {
    isLoading = true;
    notifyListeners();

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      isLoading = false;
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      errorMessage = e.message ?? 'An error occurred';
      isLoading = false;
      notifyListeners();
    }
  }
}
