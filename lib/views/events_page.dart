import 'package:flutter/material.dart';

class EventsPage extends StatefulWidget {
  @override
  _EventsPageState createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  List<Map<String, dynamic>> events = [
    {'name': 'Birthday Party', 'category': 'Celebration', 'status': 'Upcoming'},
    {'name': 'Meeting', 'category': 'Work', 'status': 'Current'},
    {'name': 'Anniversary', 'category': 'Celebration', 'status': 'Past'},
  ];

  void _addEvent() {

  }

  void _editEvent(int index) {
  }

  void _deleteEvent(int index) {
    setState(() {
      events.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Events'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: events.length,
              itemBuilder: (context, index) {
                final event = events[index];
                return ListTile(
                  title: Text(event['name']),
                  subtitle: Text('${event['category']} - ${event['status']}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () => _editEvent(index),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () => _deleteEvent(index),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: _addEvent,
            child: Text('Add Event'),
          ),
        ],
      ),
    );
  }
}
