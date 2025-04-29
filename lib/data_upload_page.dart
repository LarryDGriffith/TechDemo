import 'package:flutter/material.dart';

class DataUploadPage extends StatelessWidget {
  const DataUploadPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Upload'),
      ),
      body: const Center(
        child: Text('This is the Data Upload Page'),
      ),
    );
  }
}