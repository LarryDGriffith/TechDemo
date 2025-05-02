import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart';

class CSVLoader {
  static Future<List<Map<String, String>>> loadCsvData(String path) async {
    final rawData = await rootBundle.loadString(path);
    final List<List<dynamic>> csvTable = const CsvToListConverter().convert(rawData);

    final headers = csvTable.first.map((e) => e.toString()).toList();
    final rows = csvTable.skip(1);

    return rows.map((row) {
      return Map<String, String>.fromIterables(
        headers,
        row.map((e) => e.toString()),
      );
    }).toList();
  }
}
