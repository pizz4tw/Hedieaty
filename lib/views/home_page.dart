import 'package:flutter/material.dart';
import '../viewmodels/homepage_viewmodel.dart';
import 'giftlist_page.dart';
import 'eventlist_page.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late HomePageViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = HomePageViewModel(context);
    _viewModel.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(134, 86, 210, 1.0),
      appBar: AppBar(
        title: const Text('Home'),
        backgroundColor: const Color.fromRGBO(134, 86, 210, 1.0),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _viewModel.addFriend,
            tooltip: 'Add Friend',
          ),
          IconButton(
            icon: const Icon(Icons.contacts),
            onPressed: _viewModel.addFriendFromContacts,
            tooltip: 'Add from Contacts',
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
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
              leading: const Icon(Icons.home, color: Colors.black),
              title: const Text('Home'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.event, color: Colors.black),
              title: const Text('Events'),
              onTap: () {
                Navigator.pop(context);
                _viewModel.navigateToEventsPage();
              },
            ),
            ListTile(
              leading: const Icon(Icons.person, color: Colors.black),
              title: const Text('Profile'),
              onTap: () {
                Navigator.pop(context);
                _viewModel.navigateToProfile();
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings, color: Colors.black),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                _viewModel.navigateToSettings();
              },
            ),
            ListTile(
              leading: const Icon(Icons.exit_to_app, color: Colors.black),
              title: const Text('Sign Out'),
              onTap: _viewModel.signOut,
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
                fillColor: const Color.fromRGBO(245, 198, 82, 1.0),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
              ),
              onChanged: _viewModel.searchFriends,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text('Choose List Type'),
                      content: const Text('Do you want to create a Gift List or an Event List?'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const GiftListPage()),
                            );
                          },
                          child: const Text('Gift List'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const EventListPage()),
                            );
                          },
                          child: const Text('Event List'),
                        ),
                      ],
                    );
                  },
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromRGBO(245, 198, 82, 1.0),
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
              ),
              child: const Text(
                'Create Your Own Event/List',
                style: TextStyle(fontSize: 18),
              ),
            ),
          )
          ,
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _viewModel.friendsStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final friends = snapshot.data ?? [];
                return ListView.builder(
                  itemCount: friends.length,
                  itemBuilder: (context, index) {
                    final friend = friends[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(friend['profilePicture']),
                      ),
                      title: Text(
                        friend['name'],
                        style: const TextStyle(color: Colors.white, fontSize: 18),
                      ),
                      subtitle: Text(
                        friend['upcomingEvents'] > 0
                            ? 'Upcoming Events: ${friend['upcomingEvents']}'
                            : 'No Upcoming Events',
                        style: const TextStyle(color: Colors.white70),
                      ),
                      trailing: friend['upcomingEvents'] > 0
                          ? Container(
                        padding: const EdgeInsets.all(6.0),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '${friend['upcomingEvents']}',
                          style: const TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      )
                          : IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _viewModel.deleteFriend(friend),
                      ),
                      //onTap: () => _viewModel.navigateToGiftList(friend['name']),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
