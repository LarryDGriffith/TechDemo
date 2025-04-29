import 'package:flutter/material.dart';

class DataViewPage extends StatelessWidget {
  const DataViewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data View'),
      ),
      body: const Center(
        child: Text('This is the Data View Page'),
      ),
    );
  }
}