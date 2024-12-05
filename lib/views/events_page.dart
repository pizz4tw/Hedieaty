import 'package:flutter/material.dart';
import 'home_page.dart';
import 'profile_page.dart';// Assuming you want to navigate to home from here.

class EventsPage extends StatelessWidget {
  const EventsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Events'),
        backgroundColor: Color.fromRGBO(134, 86, 210, 1.0),
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
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HomePage()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.event, color: Colors.black),
              title: Text('Events'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.person, color: Colors.black),
              title: Text('Profile'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfilePage()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.settings, color: Colors.black),
              title: Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to settings screen (if you have one)
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: Text('Events content goes here.'),
      ),
    );
  }
}
