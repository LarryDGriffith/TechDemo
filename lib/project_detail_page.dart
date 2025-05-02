import 'package:flutter/material.dart';
import 'models/project.dart';
import 'widgets/marker_pin.dart';
import 'theme.dart';
import 'marker_details_page.dart';


class ProjectDetailPage extends StatelessWidget {
  final Project project;

  const ProjectDetailPage({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 2,
        title: Text(
          project.name,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: InteractiveViewer(
        panEnabled: true,
        minScale: 1.0,
        maxScale: 5.0,
        child: Stack(
          children: [
            Center(
              child: Image.asset(
                'assets/sitemaps/${project.id}.png',
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.broken_image, size: 100),
              ),
            ),
            ...project.markers.map((marker) => Positioned(
              left: marker.position.dx,
              top: marker.position.dy,
              child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MarkerDetailPage(sampleId: marker.sampleId, dataId: marker.dataId),
                  ),
                );
              },
                child: MarkerPin(
                  color: marker.color,
                  image: marker.image,
                  size: 32, // you can tweak this size
                ),
              ),
            )),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryColor,
        onPressed: () {
          // Placeholder for future functionality
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Add action not implemented yet')),
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
