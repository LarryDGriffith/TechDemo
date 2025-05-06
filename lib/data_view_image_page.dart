import 'package:flutter/material.dart';

class DataViewImagePage extends StatelessWidget {
  const DataViewImagePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Data View'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 5),
            Text("PNG Image"),
            Image.asset("assets/data_images/friend.png"),
            SizedBox(height: 5),
            Text("JPG Image"),
            Image.asset("assets/data_images/friend.jpg"),
          ],)
      ),
    );
  }
}