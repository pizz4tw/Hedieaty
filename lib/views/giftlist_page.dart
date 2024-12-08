import 'package:flutter/material.dart';
import '../viewmodels/giftlist_viewmodel.dart';

class GiftListPage extends StatefulWidget {
  const GiftListPage({super.key});

  @override
  _GiftListPageState createState() => _GiftListPageState();
}

class _GiftListPageState extends State<GiftListPage> {
  late GiftListViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = GiftListViewModel();
    _viewModel.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Gift List'),
        backgroundColor: const Color.fromRGBO(134, 86, 210, 1.0),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Enter Gift List Name',
              ),
              onChanged: _viewModel.updateGiftListName,
            ),
          ),
          ElevatedButton(
            onPressed: _viewModel.saveGiftList,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromRGBO(245, 198, 82, 1.0),
            ),
            child: const Text('Save Gift List'),
          ),
        ],
      ),
    );
  }
}
