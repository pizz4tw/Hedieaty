import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Event {
  final String id;
  final String name;
  final DateTime date;
  final String location;
  final String description;
  final String userId;
  final String status;

  Event({
    required this.id,
    required this.name,
    required this.date,
    required this.location,
    required this.description,
    required this.userId,
    required this.status,
  });

  factory Event.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Event(
      id: doc.id,
      name: data['name'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      location: data['location'] ?? '',
      description: data['description'] ?? '',
      userId: data['userId'] ?? '',
      status: data['status'] ?? '',
    );
  }
}

class EventListViewModel {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late Stream<List<Event>> eventsStream;
  List<Event> _allEvents = []; // Store all events for filtering and sorting

  void initialize() {
    eventsStream = _firestore
        .collection('events')
        .snapshots()
        .map((snapshot) {
      _allEvents = snapshot.docs.map((doc) => Event.fromDocument(doc)).toList();
      return _allEvents;
    });
  }

  Future<String> getCurrentUserId() async {
    final user = _auth.currentUser;
    if (user != null) {
      return user.uid;
    } else {
      throw Exception('No user logged in');
    }
  }

  String determineStatus(DateTime date) {
    final now = DateTime.now();
    // Strip the time part from both the input date and current date
    final dateOnly = DateTime(date.year, date.month, date.day);
    final nowOnly = DateTime(now.year, now.month, now.day);

    if (dateOnly.isBefore(nowOnly)) {
      return 'Past';
    } else if (dateOnly.isAfter(nowOnly)) {
      return 'Upcoming';
    } else {
      return 'Current';
    }
  }


  void searchEvents(String query) {
    eventsStream = Stream.value(
      _allEvents.where((event) {
        final lowerQuery = query.toLowerCase();
        return event.name.toLowerCase().contains(lowerQuery) ||
            event.description.toLowerCase().contains(lowerQuery) ||
            event.location.toLowerCase().contains(lowerQuery);
      }).toList(),
    );
  }

  void sortEventsByName() {
    _allEvents.sort((a, b) => a.name.compareTo(b.name));
    eventsStream = Stream.value(_allEvents);
  }

  void sortEventsByCategory() {
    // Assuming 'category' is a field you will add later
    _allEvents.sort((a, b) => a.location.compareTo(b.location)); // Replace with category field
    eventsStream = Stream.value(_allEvents);
  }

  void sortEventsByStatus() {
    _allEvents.sort((a, b) => a.status.compareTo(b.status));
    eventsStream = Stream.value(_allEvents);
  }

  Future<void> addEvent(Event event) async {
    final userId = await getCurrentUserId();
    final status = determineStatus(event.date);
    await _firestore.collection('events').add({
      'name': event.name,
      'date': event.date,
      'location': event.location,
      'description': event.description,
      'userId': userId,
      'status': status,
    });
  }

  Future<void> editEvent(Event event) async {
    final status = determineStatus(event.date);
    await _firestore.collection('events').doc(event.id).update({
      'name': event.name,
      'date': event.date,
      'location': event.location,
      'description': event.description,
      'status': status,
    });
  }

  Future<void> deleteEvent(String eventId) async {
    await _firestore.collection('events').doc(eventId).delete();
  }
}
