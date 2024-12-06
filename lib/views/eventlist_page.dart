import 'package:flutter/material.dart';
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
        title: const Text('Create Event List'),
        backgroundColor: const Color.fromRGBO(134, 86, 210, 1.0),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Enter Event List Name',
              ),
              onChanged: _viewModel.updateEventListName,
            ),
          ),
          ElevatedButton(
            onPressed: _viewModel.saveEventList,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromRGBO(245, 198, 82, 1.0),
            ),
            child: const Text('Save Event List'),
          ),
        ],
      ),
    );
  }
}
