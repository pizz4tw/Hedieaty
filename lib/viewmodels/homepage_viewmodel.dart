import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/authentication.dart';
import '../views/giftlist_page.dart';
import '../views/events_page.dart';
import '../views/profile_page.dart';

class HomePageViewModel {
  final BuildContext context;
  final AuthMethod _authMethod = AuthMethod();
  String currentUserPhone = '';

  late Stream<List<Map<String, dynamic>>> friendsStream;

  HomePageViewModel(this.context);

  void initialize() {
    _fetchFriendsStream();
    _getCurrentUserPhone();
  }

  void _fetchFriendsStream() {
    friendsStream = FirebaseFirestore.instance
        .collection('users')
        .doc(_authMethod.getUserId())
        .collection('friends')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  Future<void> _getCurrentUserPhone() async {
    final currentUser = FirebaseFirestore.instance.collection('users').doc(_authMethod.getUserId());
    final docSnapshot = await currentUser.get();
    if (docSnapshot.exists) {
      currentUserPhone = docSnapshot.data()?['phoneNumber'] ?? '';
    }
  }

  String _normalizePhoneNumber(String phoneNumber) {
    phoneNumber = phoneNumber.trim();
    if (phoneNumber.startsWith('+2')) {
      return phoneNumber.substring(2);
    }
    return phoneNumber;
  }

  String _deNormalizePhoneNumber(String phoneNumber) {
    phoneNumber = phoneNumber.trim();
    if (!phoneNumber.startsWith('+2')) {
      return '+2' + phoneNumber;
    }
    return phoneNumber;
  }

  Future<Map<String, dynamic>?> _findUserByPhoneNumber(String phoneNumber) async {
    final userCollection = FirebaseFirestore.instance.collection('users');
    String denormalizedPhoneNumber = _deNormalizePhoneNumber(phoneNumber);

    final querySnapshot = await userCollection
        .where('phoneNumber', isEqualTo: denormalizedPhoneNumber)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      return querySnapshot.docs.first.data();
    }
    return null;
  }

  void addFriend() async {
    TextEditingController phoneController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Friend by Phone Number'),
          content: TextField(
            controller: phoneController,
            decoration: InputDecoration(hintText: 'Enter phone number'),
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: Text('Search'),
              onPressed: () async {
                Navigator.pop(context);
                String phoneNumber = '+2' + phoneController.text.trim();

                if (_deNormalizePhoneNumber(phoneNumber) == currentUserPhone) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('You cannot add yourself as a friend.')),
                  );
                  return;
                }

                final user = await _findUserByPhoneNumber(phoneNumber);

                if (user != null) {
                  _confirmAddFriend(user);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('User not found')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _confirmAddFriend(Map<String, dynamic> user) async {
    final currentUser = FirebaseFirestore.instance.collection('users').doc(_authMethod.getUserId());
    final querySnapshot = await currentUser.collection('friends')
        .where('phoneNumber', isEqualTo: user['phoneNumber'])
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('This user is already your friend.')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add ${user['username']} as a friend?'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (user['profilePicture'] != null)
                CircleAvatar(
                  backgroundImage: NetworkImage(user['profilePicture']),
                ),
              Text('Username: ${user['username']}'),
              Text('Phone: ${user['phoneNumber']}'),
            ],
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: Text('Add'),
              onPressed: () async {
                await _addFriendToFirestore(user);
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _addFriendToFirestore(Map<String, dynamic> user) async {
    try {
      final currentUser = FirebaseFirestore.instance.collection('users').doc(_authMethod.getUserId());
      await currentUser.collection('friends').doc(user['phoneNumber']).set({
        'name': user['username'],
        'profilePicture': user['profilePicture'] ?? '',
        'phoneNumber': user['phoneNumber'],
        'upcomingEvents': 0,
      });
    } catch (e) {
      print("Error adding friend to Firestore: $e");
    }
  }

  void addFriendFromContacts() async {
    PermissionStatus permissionStatus = await Permission.contacts.request();

    if (permissionStatus.isGranted) {
      Iterable<Contact> contacts = await ContactsService.getContacts();
      _showContactDialog(contacts);
    } else if (permissionStatus.isDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Contacts permission denied. Please enable it in settings.')),
      );
    } else if (permissionStatus.isPermanentlyDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Permission permanently denied. Opening settings...')),
      );
      await openAppSettings();
    }
  }

  void _showContactDialog(Iterable<Contact> contacts) {
    showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: const Text('Select a Contact'),
          children: contacts.map((contact) {
            return SimpleDialogOption(
              onPressed: () async {
                Navigator.pop(context);
                // Normalize the phone number from the contact
                String phoneNumber = contact.phones?.isNotEmpty == true
                    ? _normalizePhoneNumber(contact.phones!.first.value!)
                    : '';

                if (phoneNumber.isNotEmpty) {
                  // Check if the selected contact is the current user
                  if (phoneNumber == _normalizePhoneNumber(currentUserPhone)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('You cannot add yourself as a friend.'),
                      ),
                    );
                    return;
                  }

                  // Find the user in Firestore by phone number
                  final user = await _findUserByPhoneNumber(phoneNumber);
                  if (user != null) {
                    _confirmAddFriend(user);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('No user found for this contact.'),
                      ),
                    );
                  }
                }
              },
              child: Text(contact.displayName ?? 'No Name'),
            );
          }).toList(),
        );
      },
    );
  }


  Future<void> deleteFriend(Map<String, dynamic> friend) async {
    final currentUser = FirebaseFirestore.instance.collection('users').doc(_authMethod.getUserId());
    final querySnapshot = await currentUser.collection('friends')
        .where('phoneNumber', isEqualTo: friend['phoneNumber'])
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      await querySnapshot.docs.first.reference.delete();
    }
  }

  void searchFriends(String query) {
    // To be implemented as per app requirements
  }



  void navigateToEventsPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EventsPage()),
    );
  }

  void navigateToProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ProfilePage()),
    );
  }

  void signOut() async {
    await _authMethod.signOut();
    Navigator.pushReplacementNamed(context, '/login');
  }

  void navigateToSettings() {}
}
