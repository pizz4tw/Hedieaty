import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hedeyety/viewmodels/profile_view_model.dart';

class UpdateInfoPage extends StatelessWidget {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _profilePictureController = TextEditingController();

  UpdateInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    final profileViewModel = Provider.of<ProfileViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Update Information'),
        backgroundColor: Color.fromRGBO(134, 86, 210, 1.0), // Match color scheme
      ),
      backgroundColor: Color.fromRGBO(134, 86, 210, 1.0), // Match color scheme
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController..text = profileViewModel.name ?? '',
              decoration: InputDecoration(
                labelText: 'Name',
                labelStyle: TextStyle(color: Colors.black), // Label color
                filled: true,
                fillColor: Color.fromRGBO(245, 198, 82, 1.0), // Fill color
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0), // Rounded edges
                ),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _profilePictureController
                ..text = profileViewModel.profilePicture ?? '',
              decoration: InputDecoration(
                labelText: 'Profile Picture URL',
                labelStyle: TextStyle(color: Colors.black), // Label color
                filled: true,
                fillColor: Color.fromRGBO(245, 198, 82, 1.0), // Fill color
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0), // Rounded edges
                ),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                String updatedName = _nameController.text.trim();
                String updatedProfilePicture =
                _profilePictureController.text.trim();

                await profileViewModel.updatePersonalInfo(
                    updatedName, updatedProfilePicture, context);

                // Navigate back if successful
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromRGBO(245, 198, 82, 1.0),
                foregroundColor: Colors.black,
                padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
              ),
              child: Text('Update'),
            )
            ,
          ],
        ),
      ),
    );
  }
}
