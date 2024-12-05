import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthMethod {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // SignUp User
  Future<String> signupUser({
    required String email,
    required String password,
    required String name,
  }) async {
    String res = "Some error Occurred";
    try {
      if (email.isNotEmpty || password.isNotEmpty || name.isNotEmpty) {
        // register user in auth with email and password
        UserCredential cred = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        // add user to firestore database
        print(cred.user!.uid);
        await _firestore.collection("users").doc(cred.user!.uid).set({
          'name': name,
          'uid': cred.user!.uid,
          'email': email,
        });

        res = "success";
      }
    } catch (err) {
      return err.toString();
    }
    return res;
  }

  // logIn user
  Future<String> loginUser({
    required String email,
    required String password,
  }) async {
    String res = "Some error Occurred";
    try {
      if (email.isNotEmpty || password.isNotEmpty) {
        // logging in user with email and password
        await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        res = "success";
      } else {
        res = "Please enter all the fields";
      }
    } catch (err) {
      return err.toString();
    }
    return res;
  }

  // for signOut
  signOut() async {
    await _auth.signOut();
  }

  // Get current user's UID
  String getUserId() {
    return _auth.currentUser?.uid ?? ''; // Return empty string if no user is signed in
  }

  // Check if a user exists by phone number
  Future<String> checkUserByPhoneNumber(String phoneNumber) async {
    String res = "Some error occurred";
    try {
      // Query the Firestore collection to find the user by phone number
      QuerySnapshot userSnapshot = await _firestore
          .collection("users")
          .where("phoneNumber", isEqualTo: phoneNumber)
          .get();

      // If no documents found, the user does not exist
      if (userSnapshot.docs.isEmpty) {
        res = "No user found with this phone number.";
      } else {
        res = "User found!";
      }
    } catch (err) {
      res = err.toString();
    }
    return res;
  }
}
