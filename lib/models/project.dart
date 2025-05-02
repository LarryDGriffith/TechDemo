import 'marker_point.dart';

class Project {
  final int id;
  final String name;
  final String location;
  final List<MarkerPoint> markers;

  Project({
    required this.id,
    required this.name,
    required this.location,
    this.markers = const [],
  });
}
