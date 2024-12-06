import 'package:cloud_firestore/cloud_firestore.dart';

class GiftListViewModel {
  String _giftListName = '';

  void initialize() {
    // Initialization logic if needed
  }

  void updateGiftListName(String name) {
    _giftListName = name;
  }

  Future<void> saveGiftList() async {
    if (_giftListName.isEmpty) {
      // Handle empty name case
      return;
    }
    final userId = 'your_user_id'; // Replace with dynamic user ID
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('giftLists')
        .add({'name': _giftListName, 'createdAt': DateTime.now()});
  }
}
