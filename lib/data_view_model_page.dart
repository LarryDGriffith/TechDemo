import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

class DataViewModelPage extends StatelessWidget {
  const DataViewModelPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Model Data View'),
      ),
      body: const ModelViewer(
          backgroundColor: Color.fromARGB(0xFF, 0xEE, 0xEE, 0xEE),
          src: 'assets/data_models/friend.glb',
          alt: 'A 3D model of Friend',
          ar: true,
          autoRotate: true,
          disableZoom: true,
      ),
    );
  }
}