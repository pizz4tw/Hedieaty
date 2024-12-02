import 'package:flutter/material.dart';
import 'events_page.dart';
import 'profile_page.dart';
import '../services/authentication.dart'; // Import AuthMethod

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AuthMethod _authMethod = AuthMethod(); // Create an instance of AuthMethod

  List<Map<String, dynamic>> friends = [
    {'name': 'John Doe', 'profilePicture': 'assets/john.jpg', 'upcomingEvents': 1},
    {'name': 'Jane Smith', 'profilePicture': 'assets/jane.jpg', 'upcomingEvents': 0},
    {'name': 'Emily Clark', 'profilePicture': 'assets/emily.jpg', 'upcomingEvents': 3},
  ];

  void _addFriend() {}

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

  // Sign out function
  void _signOut() async {
    await _authMethod.signOut(); // Call the sign-out method from AuthMethod
    print('User signed out');
    Navigator.pushReplacementNamed(context, '/login'); // Navigate to login page
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
            onPressed: _addFriend,
            tooltip: 'Add Friend',
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
              onTap: () {
                Navigator.pop(context);
              },
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
            // Sign Out Button
            ListTile(
              leading: Icon(Icons.exit_to_app, color: Colors.black),
              title: Text('Sign Out'),
              onTap: _signOut, // Call the sign-out method
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search bar
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
          // List of friends
          Expanded(
            child: ListView.builder(
              itemCount: friends.length,
              itemBuilder: (context, index) {
                final friend = friends[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: AssetImage(friend['profilePicture']),
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
                      : null,
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

class GiftListPage extends StatelessWidget {
  final String friendName;

  const GiftListPage({required this.friendName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$friendName\'s Gift List'),
      ),
      body: Center(
        child: Text('Gift list details and pledge options for $friendName.'),
      ),
    );
  }
}
