import 'package:flutter/material.dart';

class GiftListPage extends StatelessWidget {
  final String friendName;

  const GiftListPage({super.key, required this.friendName});

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