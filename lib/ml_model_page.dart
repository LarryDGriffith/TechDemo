import 'package:flutter/material.dart';

class MLModelPage extends StatelessWidget {
  const MLModelPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ML Model'),
      ),
      body: const Center(
        child: Text('This is the ML Model Page'),
      ),
    );
  }
}
