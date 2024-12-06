import 'package:cloud_firestore/cloud_firestore.dart';

class EventListViewModel {
  String _eventListName = '';

  void initialize() {
    // Initialization logic if needed
  }

  void updateEventListName(String name) {
    _eventListName = name;
  }

  Future<void> saveEventList() async {
    if (_eventListName.isEmpty) {
      // Handle empty name case
      return;
    }
    final userId = 'your_user_id'; // Replace with dynamic user ID
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('eventLists')
        .add({'name': _eventListName, 'createdAt': DateTime.now()});
  }
}
