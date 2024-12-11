import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../viewmodels/eventlist_viewmodel.dart';

class EventListPage extends StatefulWidget {
  const EventListPage({super.key});

  @override
  _EventListPageState createState() => _EventListPageState();
}

class _EventListPageState extends State<EventListPage> {
  late EventListViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = EventListViewModel();
    _viewModel.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event List'),
        backgroundColor: const Color.fromRGBO(134, 86, 210, 1.0),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Search Events',
                    ),
                    onChanged: _viewModel.searchEvents,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.sort),
                  onPressed: () => _showSortOptions(context),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Event>>(
              stream: _viewModel.eventsStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final events = snapshot.data ?? [];
                return ListView.builder(
                  itemCount: events.length,
                  itemBuilder: (context, index) {
                    final event = events[index];
                    final eventStatus = event.status; // Get event status

                    // Set color based on the status
                    Color statusColor;
                    if (eventStatus == 'Upcoming') {
                      statusColor = Colors.red; // Red for upcoming
                    } else if (eventStatus == 'Current') {
                      statusColor = Colors.orange; // Orange for current
                    } else {
                      statusColor = Colors.green; // Green for past
                    }

                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                      leading: Container(
                        width: 24, // Adjust the size of the circle
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: statusColor,
                        ),
                      ),
                      title: Text(event.name),
                      subtitle: Text(event.description),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _showEditEventDialog(context, event),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => _viewModel.deleteEvent(event.id),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: () => _showAddEventDialog(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromRGBO(245, 198, 82, 1.0),
            ),
            child: const Text('Add Event'),
          ),
        ],
      ),
    );
  }

  void _showSortOptions(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Sort By'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Name'),
                onTap: () {
                  _viewModel.sortEventsByName();
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Category'),
                onTap: () {
                  _viewModel.sortEventsByCategory();
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Status'),
                onTap: () {
                  _viewModel.sortEventsByStatus();
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAddEventDialog(BuildContext context) {
    final nameController = TextEditingController();
    final dateController = TextEditingController();
    final locationController = TextEditingController();
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Event'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                TextField(
                  controller: dateController,
                  decoration: const InputDecoration(labelText: 'Date'),
                  onTap: () async {
                    FocusScope.of(context).requestFocus(FocusNode());
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(), // Allow only future dates
                      lastDate: DateTime(2101),
                    );
                    if (date != null) {
                      dateController.text = date.toIso8601String();
                    }
                  },
                ),
                TextField(
                  controller: locationController,
                  decoration: const InputDecoration(labelText: 'Location'),
                ),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final userId = await _viewModel.getCurrentUserId();
                final event = Event(
                  id: '', // Firestore will auto-generate the ID
                  name: nameController.text,
                  date: DateTime.parse(dateController.text),
                  location: locationController.text,
                  description: descriptionController.text,
                  userId: userId,
                  status: _viewModel.determineStatus(DateTime.parse(dateController.text)),
                );
                await _viewModel.addEvent(event);
                Navigator.pop(context);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _showEditEventDialog(BuildContext context, Event event) {
    final nameController = TextEditingController(text: event.name);
    final dateController = TextEditingController(text: event.date.toIso8601String());
    final locationController = TextEditingController(text: event.location);
    final descriptionController = TextEditingController(text: event.description);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Event'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                TextField(
                  controller: dateController,
                  decoration: const InputDecoration(labelText: 'Date'),
                  onTap: () async {
                    FocusScope.of(context).requestFocus(FocusNode());
                    final date = await showDatePicker(
                      context: context,
                      initialDate: event.date,
                      firstDate: DateTime.now(), // Allow only future dates
                      lastDate: DateTime(2101),
                    );
                    if (date != null) {
                      dateController.text = date.toIso8601String();
                    }
                  },
                ),
                TextField(
                  controller: locationController,
                  decoration: const InputDecoration(labelText: 'Location'),
                ),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final updatedEvent = Event(
                  id: event.id,
                  name: nameController.text,
                  date: DateTime.parse(dateController.text),
                  location: locationController.text,
                  description: descriptionController.text,
                  userId: event.userId,
                  status: _viewModel.determineStatus(DateTime.parse(dateController.text)),
                );
                await _viewModel.editEvent(updatedEvent);
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
