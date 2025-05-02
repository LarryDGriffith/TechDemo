import 'package:flutter/material.dart';

class MarkerPoint {
  final Offset position; // e.g. Offset(200, 300)
  final String name;
  final Color color;
  final ImageProvider image;
  final String sampleId;
  final int dataId;

  MarkerPoint({
    required this.position,
    required this.name,
    required this.color,
    required this.image,
    this.sampleId = "",
    required this.dataId,
  });
}
