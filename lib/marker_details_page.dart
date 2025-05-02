import 'package:flutter/material.dart';
import 'utils/csv_loader.dart';

class MarkerDetailPage extends StatefulWidget {
  final String sampleId;
  final int dataId;

  const MarkerDetailPage({super.key, required this.sampleId, required this.dataId});

  @override
  State<MarkerDetailPage> createState() => _MarkerDetailPageState();
}

class _MarkerDetailPageState extends State<MarkerDetailPage> {
  Map<String, String>? data;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final allRows = await CSVLoader.loadCsvData('assets/data_csv/${widget.dataId}.csv');
    final match = allRows.firstWhere(
      (row) => row['Sample ID'] == widget.sampleId,
      orElse: () => {},
    );

    if (mounted) {
      setState(() {
        data = match.isNotEmpty ? match : null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.sampleId),
      ),
      body: data == null
        ? const Center(child: Text('No data found for this marker.'))
        : ListView(
            padding: const EdgeInsets.all(16),
            children: data!.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        entry.key,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(flex: 3, child: Text(entry.value)),
                  ],
                ),
              );
            }).toList(),
          ),
    );
  }
}
