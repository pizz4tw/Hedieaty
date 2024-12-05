import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hedeyety/viewmodels/profile_view_model.dart';
import 'update_info_page.dart';
import 'home_page.dart';
import 'login.dart'; // Import your login page here

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final profileViewModel = Provider.of<ProfileViewModel>(context);

    return Scaffold(
      backgroundColor: Color.fromRGBO(134, 86, 210, 1.0),
      appBar: AppBar(
        title: Text('Profile'),
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
                // Navigate to events page
              },
            ),
            ListTile(
              leading: Icon(Icons.person, color: Colors.black),
              title: Text('Profile'),
              onTap: () {
                Navigator.pop(context);
                // Stay on the current screen
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
      body: FutureBuilder(
        future: profileViewModel.fetchUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: Colors.white));
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading profile',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            );
          } else {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: profileViewModel.profilePicture != null
                          ? NetworkImage(profileViewModel.profilePicture!)
                          : null,
                      backgroundColor: Color.fromRGBO(245, 198, 82, 1.0),
                      child: profileViewModel.profilePicture == null
                          ? Icon(Icons.person, size: 50, color: Colors.white)
                          : null,
                    ),
                  ),
                  SizedBox(height: 16),
                  Center(
                    child: Text(
                      profileViewModel.name ?? 'N/A',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Center(
                    child: Text(
                      profileViewModel.email ?? 'N/A',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  ListTile(
                    tileColor: Color.fromRGBO(245, 198, 82, 1.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    leading: Icon(Icons.edit, color: Colors.black),
                    title: Text(
                      'Update Personal Information',
                      style: TextStyle(color: Colors.black),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => UpdateInfoPage()),
                      );
                    },
                  ),
                  SizedBox(height: 16),
                  ListTile(
                    tileColor: Color.fromRGBO(245, 198, 82, 1.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    leading: Icon(Icons.notifications, color: Colors.black),
                    title: Text(
                      'Toggle Notifications',
                      style: TextStyle(color: Colors.black),
                    ),
                    trailing: Switch(
                      value: profileViewModel.notificationsEnabled,
                      onChanged: profileViewModel.toggleNotifications,
                      activeColor: Color.fromRGBO(134, 86, 210, 1.0),
                    ),
                  ),
                  SizedBox(height: 16),
                  GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Delete Account'),
                            content: Text(
                                'Are you sure you want to delete your account? This action is irreversible.'),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () async {
                                  await profileViewModel.deleteAccount();
                                  Navigator.of(context).pop();
                                  // Navigate to the login page after account deletion
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => LoginScreen()),
                                  );
                                },
                                child: Text('Delete', style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(vertical: 14),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(
                        'Delete Account',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
