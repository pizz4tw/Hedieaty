import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class GiftListPageViewModel {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Add gift to Firestore for the specific friend
  Future<void> addGift(String userId, String friendId, String giftName) async {
    try {
      await _firestore.collection('users')
          .doc(userId)
          .collection('friends')
          .doc(friendId)
          .collection('gifts')
          .add({
        'giftName': giftName,
        'addedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("Error adding gift: $e");
    }
  }

  // Fetch the gifts for a specific friend
  Future<List<Map<String, dynamic>>> getGifts(String userId, String friendId) async {
    List<Map<String, dynamic>> gifts = [];
    try {
      final querySnapshot = await _firestore.collection('users')
          .doc(userId)
          .collection('friends')
          .doc(friendId)
          .collection('gifts')
          .get();

      for (var doc in querySnapshot.docs) {
        gifts.add(doc.data());
      }
    } catch (e) {
      print("Error fetching gifts: $e");
    }
    return gifts;
  }
}
