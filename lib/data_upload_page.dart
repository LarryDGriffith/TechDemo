import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

class DataUploadPage extends StatefulWidget {
  const DataUploadPage({super.key});

  @override
  State<DataUploadPage> createState() => _DataUploadPageState();
}

class _DataUploadPageState extends State<DataUploadPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Upload'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async {
                await parseCSV();
              },
              child: const Text('Upload CSV file'),
            ),
          ],
        ),
      ),
    );
  }

  /*
  Function: parseCSV
  Process: Parses a CSV file selected by the user and saves uploaded data to local storage
  Return: Returns a list of lists containing pXRF data as strings
  */
  Future<List<List<dynamic>>?> parseCSV() async {
    // Opens file picker UI
    final selection = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );
    // checks for empty selection
    if (selection != null) {
      String filePath = selection.files.single.path!;

      // opens file as a stream
      final input = File(filePath).openRead();
      final csvData =
      await input
          .transform(utf8.decoder)
          .transform(const CsvToListConverter())
          .toList();
      await saveData('pxrfDataBox', csvData);
      return csvData;
    } else {
      // returns null if file is empty
      return null;
    }
  }
}

Future<void> initializeHive() async {
  final directory = await getApplicationDocumentsDirectory();
  Hive.init(directory.path);
}

Future<void> saveData(String boxName, List<List<dynamic>> data) async {
  var box = await Hive.openBox(boxName);
  await box.put('csvData', data);
  await box.close();
}

Future<List<List<dynamic>>?> loadData(String boxName) async {
  var box = await Hive.openBox(boxName);
  var data = box.get('csvData');
  await box.close();
  return data;
}