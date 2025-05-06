import 'package:flutter/material.dart';
import 'theme.dart';
import 'data_view_pxrf_page.dart';
import 'data_view_model_page.dart';
import 'data_view_image_page.dart';

class DataViewPage extends StatelessWidget {
  const DataViewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data View'),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const DataViewPxrfPage()),
                      );
                    },

                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                    ),
                    child: Text(
                      'View pXRF data',
                      style: TextStyle(
                        fontSize: baseFontSize,
                        color: Colors.white,
                      ),
                    ),
                  ),
            ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const DataViewModelPage()),
                      );
                    },

                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                    ),
                    child: Text(
                      'View 3D model',
                      style: TextStyle(
                        fontSize: baseFontSize,
                        color: Colors.white,
                      ),
                    ),
                  ),
            ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const DataViewImagePage()),
                      );
                    },

                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                    ),
                    child: Text(
                      'View 2D image',
                      style: TextStyle(
                        fontSize: baseFontSize,
                        color: Colors.white,
                      ),
                    ),
                  ),
          ],
        )
      ),
    );
  }
}