import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'events_page.dart';
import 'profile_page.dart';
import '../services/authentication.dart';
import 'package:permission_handler/permission_handler.dart';
import 'giftlist_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AuthMethod _authMethod = AuthMethod();
  List<Map<String, dynamic>> friends = [];
  String currentUserPhone = ''; // Store the current user's phone number

  @override
  void initState() {
    super.initState();
    _getCurrentUserPhone();
    _loadFriendsFromFirestore();
  }

  // Utility function to normalize phone numbers by removing the country code
  String _normalizePhoneNumber(String phoneNumber) {
    phoneNumber = phoneNumber.trim();
    if (phoneNumber.startsWith('+2')) {
      return phoneNumber.substring(2); // Remove the "+2" prefix
    }
    return phoneNumber; // Return the phone number as is if no country code is present
  }
  String _deNormalizePhoneNumber(String phoneNumber) {
    phoneNumber = phoneNumber.trim();
    if (phoneNumber.startsWith('+2')) {
      return phoneNumber; // Return the phone number as is if it starts with "+2"
    } else {
      return '+2' + phoneNumber; // Add "+2" prefix if it's not already there
    }
  }

  Future<bool> _showDeleteConfirmationDialog(Map<String, dynamic> friend) async {
    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Deletion'),
          content: Text('Are you sure you want to remove ${friend['name']} from your friends list?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(false);  // Return false if cancelled
              },
            ),
            TextButton(
              child: Text('Delete'),
              onPressed: () {
                Navigator.of(context).pop(true);  // Return true if confirmed
              },
            ),
          ],
        );
      },
    ) ?? false;  // Return false if dialog is dismissed without selection
  }

  // Fetch the current user's phone number (assuming it is stored in Firestore)
  Future<void> _getCurrentUserPhone() async {
    final currentUser = FirebaseFirestore.instance.collection('users').doc(_authMethod.getUserId());
    final docSnapshot = await currentUser.get();
    if (docSnapshot.exists) {
      setState(() {
        currentUserPhone = docSnapshot.data()?['phoneNumber'] ?? '';
      });
    }
  }

  Future<void> _deleteFriendFromFirestore(Map<String, dynamic> friend) async {
    final currentUser = FirebaseFirestore.instance.collection('users').doc(_authMethod.getUserId());
    final querySnapshot = await currentUser.collection('friends')
        .where('phoneNumber', isEqualTo: friend['phoneNumber'])
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      // Delete the friend document from Firestore
      await querySnapshot.docs.first.reference.delete();

      // Update the local friends list to remove the deleted friend
      setState(() {
        friends.removeWhere((f) => f['phoneNumber'] == friend['phoneNumber']);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Friend not found in your list.')),
      );
    }
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

  void _addFriend() async {
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

                // Check if the phone number matches the current user's phone number
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
    // Check if the user is already in the friends list
    final currentUser = FirebaseFirestore.instance.collection('users').doc(_authMethod.getUserId());
    final querySnapshot = await currentUser.collection('friends')
        .where('phoneNumber', isEqualTo: user['phoneNumber'])
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      // Show a message if the user is already a friend
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
                setState(() {
                  friends.add({
                    'name': user['username'],
                    'profilePicture': user['profilePicture'] ?? '',
                    'upcomingEvents': 0,
                  });
                });
                // Save the friend data to Firestore under the user's friends subcollection
                await _addFriendToFirestore(user);
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }


  Future<void> _loadFriendsFromFirestore() async {
    final currentUser = FirebaseFirestore.instance.collection('users').doc(_authMethod.getUserId());
    final querySnapshot = await currentUser.collection('friends').get();

    List<Map<String, dynamic>> loadedFriends = [];
    for (var doc in querySnapshot.docs) {
      loadedFriends.add(doc.data());
    }

    setState(() {
      friends = loadedFriends;
    });
  }

  Future<void> _addFriendToFirestore(Map<String, dynamic> user) async {
    try {
      final currentUser = FirebaseFirestore.instance.collection('users').doc(_authMethod.getUserId());
      await currentUser.collection('friends').add({
        'name': user['username'],
        'profilePicture': user['profilePicture'] ?? '',
        'phoneNumber': user['phoneNumber'],
        'upcomingEvents': 0,
      });
    } catch (e) {
      print("Error adding friend to Firestore: $e");
    }
  }


  void _addFriendFromContacts() async {
    // Request permission for contacts
    PermissionStatus permissionStatus = await Permission.contacts.request();

    if (permissionStatus.isGranted) {
      // Permission granted: proceed to fetch contacts
      Iterable<Contact> contacts = await ContactsService.getContacts();
      _showContactDialog(contacts);
    } else if (permissionStatus.isDenied) {
      // Permission denied: show a SnackBar message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Contacts permission denied. Please enable it in settings.')),
      );
    } else if (permissionStatus.isPermanentlyDenied) {
      // Permission permanently denied: open app settings
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Permission permanently denied. Opening settings...')),
      );
      await openAppSettings(); // Direct the user to the app settings
    }
  }

  void _showContactDialog(Iterable<Contact> contacts) {
    showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: Text('Select a Contact'),
          children: contacts.map((contact) {
            return SimpleDialogOption(
              onPressed: () async {
                Navigator.pop(context);
                // Normalize the phone number before searching in Firestore
                String phoneNumber = contact.phones?.isNotEmpty == true
                    ? _normalizePhoneNumber(contact.phones!.first.value!)
                    : '';

                if (phoneNumber.isNotEmpty) {
                  final user = await _findUserByPhoneNumber(phoneNumber);
                  if (user != null) {
                    _confirmAddFriend(user);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('No user found for this contact')),
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

  void _searchFriends(String query) {}

  void _navigateToGiftList(String friendName) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => GiftListPage(friendName: friendName)),
    );
  }

  void _navigateToEventsPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EventsPage()),
    );
  }

  void _navigateToProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ProfilePage()),
    );
  }

  void _navigateToSettings() {}

  void _signOut() async {
    await _authMethod.signOut();
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(134, 86, 210, 1.0),
      appBar: AppBar(
        title: Text('Home'),
        backgroundColor: Color.fromRGBO(134, 86, 210, 1.0),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => _addFriend(), // Updated to add friend by phone number
            tooltip: 'Add Friend',
          ),
          IconButton(
            icon: Icon(Icons.contacts),
            onPressed: _addFriendFromContacts, // Adding from contacts
            tooltip: 'Add from Contacts',
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Color.fromRGBO(134, 86, 210, 1.0),
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Color.fromRGBO(245, 198, 82, 1.0),
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.home, color: Colors.black),
              title: Text('Home'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: Icon(Icons.event, color: Colors.black),
              title: Text('Events'),
              onTap: () {
                Navigator.pop(context);
                _navigateToEventsPage();
              },
            ),
            ListTile(
              leading: Icon(Icons.person, color: Colors.black),
              title: Text('Profile'),
              onTap: () {
                Navigator.pop(context);
                _navigateToProfile();
              },
            ),
            ListTile(
              leading: Icon(Icons.settings, color: Colors.black),
              title: Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                _navigateToSettings();
              },
            ),
            ListTile(
              leading: Icon(Icons.exit_to_app, color: Colors.black),
              title: Text('Sign Out'),
              onTap: _signOut,
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search friends...',
                filled: true,
                fillColor: Color.fromRGBO(245, 198, 82, 1.0),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
              ),
              onChanged: _searchFriends,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromRGBO(245, 198, 82, 1.0),
                padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
              ),
              child: Text('Create Your Own Event/List', style: TextStyle(fontSize: 18)),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: friends.length,
              itemBuilder: (context, index) {
                final friend = friends[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(friend['profilePicture']),
                  ),
                  title: Text(
                    friend['name'],
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  subtitle: Text(
                    friend['upcomingEvents'] > 0
                        ? 'Upcoming Events: ${friend['upcomingEvents']}'
                        : 'No Upcoming Events',
                    style: TextStyle(color: Colors.white70),
                  ),
                  trailing: friend['upcomingEvents'] > 0
                      ? Container(
                    padding: EdgeInsets.all(6.0),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${friend['upcomingEvents']}',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  )
                      : IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      // Show the confirmation dialog before deleting
                      bool confirmDelete = await _showDeleteConfirmationDialog(friend);
                      if (confirmDelete) {
                        // If confirmed, delete the friend from Firestore
                        await _deleteFriendFromFirestore(friend);
                      }
                    },
                  ),

                  onTap: () => _navigateToGiftList(friend['name']),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
