import 'package:flutter/material.dart';
import 'models/project.dart';
import 'theme.dart';
import 'project_detail_page.dart';
import 'models/marker_point.dart';


final List<Project> projects = [
  Project(
    id: 1,
    name: 'Temple Hill Survey',
    location: 'Lambayeque, Peru',
    markers: [
      MarkerPoint(
        position: Offset(120, 220),
        name: 'Temple Entrance',
        color: Colors.red,
        image: const AssetImage('assets/data_images/1.png'),
        sampleId: 'PAP17OCT2021_SUR_-214',
        dataId: 1,
      ),
      MarkerPoint(
        position: Offset(300, 400),
        name: 'Wall Segment',
        color: Colors.blue,
        image: const AssetImage('assets/data_images/2.png'),
        dataId: 1,
      ),
    ],
  ),
  Project(
    id: 2,
    name: 'Copper Ridge Dig',
    location: 'Chiclayo, Peru',
    markers: [
      MarkerPoint(
        position: Offset(170, 650),
        name: 'Temple Entrance',
        color: Colors.red,
        image: const AssetImage('assets/data_images/1.png'),
        dataId: 1,
      ),
      MarkerPoint(
        position: Offset(300, 200),
        name: 'Wall Segment',
        color: Colors.blue,
        image: const AssetImage('assets/data_images/2.png'),
        dataId: 1,
      ),
    ],
  ),
];


class ProjectSelectionPage extends StatelessWidget {
  const ProjectSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 2,
        leading: IconButton(
          icon: Image.asset(
            'assets/icon.png',
            width: 24,
            height: 24,
          ),
          onPressed: () {
            // This will open the drawer in the future
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Menu not implemented yet")),
            );
          },
        ),
        title: const Text(
          'Project Selection',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: projects.length,
        itemBuilder: (context, index) {
          final project = projects[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProjectDetailPage(project: project),
                ),
              );
            },
            child: Card(
              color: inputFillColor,
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        'assets/sitemaps/${project.id.toString()}.png',
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 80,
                          height: 80,
                          color: Colors.grey.shade300,
                          child: const Icon(Icons.image_not_supported, size: 40),
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            project.name,
                            style: TextStyle(fontSize: baseFontSize + 2, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            project.location,
                            style: TextStyle(fontSize: baseFontSize),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
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
