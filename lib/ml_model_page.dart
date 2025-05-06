import 'dart:math';
import 'dart:io';
import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class MLModelPage extends StatefulWidget {
  const MLModelPage({super.key});

  @override
  State<MLModelPage> createState() => _MLModelPageState();
}

class _MLModelPageState extends State<MLModelPage> {
  // Asset paths
  static const String trainingCsvPath = 'assets/data_csv/fake_pxrf_data.csv';
  static const String newDataCsvPath = 'assets/data_csv/fake_pxrf_data.csv';
  static const String imagePath = 'assets/sitemaps/sightmap.png';

  String? trainingData;
  String? newData;
  ImageProvider? backgroundImage;
  ui.Image? originalImage;
  bool isAnalysisReady = false;
  bool isAnalyzing = false;
  String statusMessage = 'Loading files...';
  List<Map<String, dynamic>>? importantLocations;

  @override
  void initState() {
    super.initState();
    _loadFiles();
  }

  Future<void> _loadFiles() async {
    try {
      // Load training data
      trainingData = await rootBundle.loadString(trainingCsvPath);

      // Load new data
      newData = await rootBundle.loadString(newDataCsvPath);

      // Load image
      final byteData = await rootBundle.load(imagePath);
      originalImage = await _loadImage(byteData.buffer.asUint8List());
      backgroundImage = MemoryImage(byteData.buffer.asUint8List());

      // All files loaded successfully, start analysis
      _runAnalysis();
    } catch (e) {
      setState(() {
        statusMessage = 'Error loading files: $e';
      });
      debugPrint('Error loading files: $e');
    }
  }

  // Helper method to load an image from bytes
  Future<ui.Image> _loadImage(Uint8List bytes) async {
    final completer = Completer<ui.Image>();
    ui.decodeImageFromList(bytes, completer.complete);
    return completer.future;
  }

  Future<void> _runAnalysis() async {
    if (trainingData == null || newData == null || backgroundImage == null) return;

    setState(() {
      isAnalyzing = true;
      statusMessage = 'Analyzing data...';
    });

    try {
      final processor = PxrfDataProcessor();
      processor.loadFromCsv(trainingData!);
      processor.trainModel();

      final newDataProcessor = PxrfDataProcessor();
      newDataProcessor.loadFromCsv(newData!);

      final locations = processor.predictImportantLocations(newDataProcessor.samples);

      setState(() {
        isAnalyzing = false;
        isAnalysisReady = true;
        importantLocations = locations;
        statusMessage = 'Analysis complete: Found ${locations.length} important locations';
      });

      // Navigate to results page automatically
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => PxrfResultsPage(
              importantLocations: locations,
              backgroundImage: backgroundImage!,
              originalImage: originalImage!,
            ),
          ),
        );
      }
    } catch (e) {
      setState(() {
        isAnalyzing = false;
        statusMessage = 'Error during analysis: $e';
      });
      debugPrint('Error during analysis: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PXRF Analysis'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'PXRF Data Analysis',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Text(
              statusMessage,
              style: TextStyle(
                color: isAnalysisReady ? Colors.green :
                isAnalyzing ? Colors.blue : Colors.orange,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            _buildFileSection(
              title: 'Training Data (CSV)',
              description: 'Loaded from $trainingCsvPath',
              icon: Icons.table_chart,
              isLoaded: trainingData != null,
            ),
            const SizedBox(height: 12),
            _buildFileSection(
              title: 'New PXRF Data (CSV)',
              description: 'Loaded from $newDataCsvPath',
              icon: Icons.assessment,
              isLoaded: newData != null,
            ),
            const SizedBox(height: 12),
            _buildFileSection(
              title: 'Background Image',
              description: 'Loaded from $imagePath',
              icon: Icons.image,
              isLoaded: backgroundImage != null,
            ),
            const Spacer(),
            if (isAnalyzing)
              const Center(child: CircularProgressIndicator()),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildFileSection({
    required String title,
    required String description,
    required IconData icon,
    required bool isLoaded,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: isLoaded ? Colors.green : Colors.grey.shade300,
          width: isLoaded ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: isLoaded ? Colors.green.withAlpha(50) : Colors.grey.withAlpha(50),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Icon(
                icon,
                color: isLoaded ? Colors.green : Colors.grey,
                size: 30,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: isLoaded ? Colors.green : Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              isLoaded ? Icons.check_circle : Icons.error_outline,
              color: isLoaded ? Colors.green : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}

class PxrfResultsPage extends StatelessWidget {
  final List<Map<String, dynamic>> importantLocations;
  final ImageProvider backgroundImage;
  final ui.Image originalImage;

  const PxrfResultsPage({
    super.key,
    required this.importantLocations,
    required this.backgroundImage,
    required this.originalImage,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analysis Results'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            tooltip: 'Save Image',
            onPressed: () => _saveImageWithDots(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Found ${importantLocations.length} important locations',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 4.0,
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 0.8, // 80% of screen height
                child: Stack(
                  children: [
                    // Background image - now larger
                    Image(
                      image: backgroundImage,
                      fit: BoxFit.fitHeight,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                    // Original dots overlay
                    CustomPaint(
                      painter: PxrfImagePainter(
                        importantLocations: importantLocations,
                        scaleX: 50.0,
                        scaleY: 40.0,
                        offsetX: 50.0,
                        offsetY: 50.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: 'save_btn',
            onPressed: () => _saveImageWithDots(context),
            child: const Icon(Icons.save),
          ),
          const SizedBox(width: 16),
          FloatingActionButton(
            heroTag: 'table_btn',
            onPressed: () => _showDataTable(context),
            child: const Icon(Icons.table_chart),
          ),
        ],
      ),
    );
  }

  Future<void> _saveImageWithDots(BuildContext context) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // Create the image with dots (your existing code)
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      canvas.drawImage(originalImage, Offset.zero, Paint());

      final painter = PxrfImagePainter(
        importantLocations: importantLocations,
        scaleX: originalImage.width / 100,
        scaleY: originalImage.height / 100,
        offsetX: 0,
        offsetY: 0,
      );
      painter.paint(canvas, Size(originalImage.width.toDouble(), originalImage.height.toDouble()));

      final ui.Image image = await recorder.endRecording().toImage(
        originalImage.width,
        originalImage.height,
      );

      final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        Navigator.pop(context);
        _showMessage(context, 'Failed to create image');
        return;
      }

      final Uint8List pngBytes = byteData.buffer.asUint8List();

      // Save to temporary file
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/sightmap_${DateTime.now().millisecondsSinceEpoch}.png');
      await file.writeAsBytes(pngBytes);

      // Call native Android code to save to gallery
      const channel = MethodChannel('gallery_saver');
      final success = await channel.invokeMethod('saveImage', file.path);

      Navigator.pop(context);
      _showMessage(context, success ? 'Image saved to gallery!' : 'Failed to save image');

    } catch (e) {
      Navigator.of(context, rootNavigator: true).pop();
      _showMessage(context, 'Error: $e');
    }
  }

  // Helper method to show messages
  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: 'OK',
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  // Add this constant for the transparent placeholder image
  static final kTransparentImage = Uint8List.fromList([
    0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D,
    0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
    0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00,
    0x0A, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
    0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49,
    0x45, 0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82,
  ]);

  void _showDataTable(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.8,
        expand: false,
        builder: (context, scrollController) {
          return Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.grey.shade200,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Important Locations Data',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 4.0,
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height * 0.85, // 85% of screen
                    child: Stack(
                      children: [
                        Image(
                          image: backgroundImage,
                          fit: BoxFit.contain,
                        ),
                        CustomPaint(
                          painter: PxrfImagePainter(
                            importantLocations: importantLocations,
                            scaleX: MediaQuery.of(context).size.width / 100,
                            scaleY: MediaQuery.of(context).size.height / 100,
                            offsetX: 0,
                            offsetY: 0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class PxrfImagePainter extends CustomPainter {
  final List<Map<String, dynamic>> importantLocations;
  final double scaleX;
  final double scaleY;
  final double offsetX;
  final double offsetY;
  final Color dotColor;
  final double dotRadius;
  final double highlightRadius;

  PxrfImagePainter({
    required this.importantLocations,
    required this.scaleX,
    required this.scaleY,
    required this.offsetX,
    required this.offsetY,
    this.dotColor = Colors.red,
    this.dotRadius = 6.0,
    this.highlightRadius = 12.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint highlightPaint = Paint()
      ..color = dotColor.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    final Paint dotPaint = Paint()
      ..color = dotColor
      ..style = PaintingStyle.fill;

    for (final location in importantLocations) {
      final x = (location['x'] as num).toDouble() * scaleX + offsetX;
      final y = (location['y'] as num).toDouble() * scaleY + offsetY;

      // Draw highlight circle
      canvas.drawCircle(Offset(x, y), highlightRadius, highlightPaint);

      // Draw main dot
      canvas.drawCircle(Offset(x, y), dotRadius, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// PXRF Data Processing Classes

class PxrfSample {
  final String room;
  final double xCoord;
  final double yCoord;
  final Map<String, double> elements;
  final int important;

  PxrfSample({
    required this.room,
    required this.xCoord,
    required this.yCoord,
    required this.elements,
    required this.important,
  });

  // Create a feature vector for ML algorithms
  List<double> toFeatureVector() {
    return [
      xCoord,
      yCoord,
      elements['Ag K12'] ?? 0,
      elements['Ag L1'] ?? 0,
      elements['As K12'] ?? 0,
      elements['Ca K12'] ?? 0,
      elements['V K12'] ?? 0,
      elements['Ti K12'] ?? 0,
      elements['Sr K12'] ?? 0,
      elements['Ni K12'] ?? 0,
      elements['Cr K12'] ?? 0,
      elements['Mn K12'] ?? 0,
      elements['Ga K12'] ?? 0,
      elements['Fe K12'] ?? 0,
      elements['Cu K12'] ?? 0,
    ];
  }
}

class LogisticRegressionModel {
  List<double>? weights;
  double? bias;
  final double learningRate;
  final int maxIterations;

  LogisticRegressionModel({
    this.learningRate = 0.01,
    this.maxIterations = 1000,
  });

  // Sigmoid activation function
  double sigmoid(double x) {
    // Clip to avoid overflow
    if (x < -709) return 0;
    if (x > 709) return 1;
    return 1 / (1 + exp(-x));
  }

  // Calculate dot product of two vectors
  double dotProduct(List<double> a, List<double> b) {
    if (a.length != b.length) {
      throw Exception('Vectors must be of the same length');
    }
    double sum = 0;
    for (int i = 0; i < a.length; i++) {
      sum += a[i] * b[i];
    }
    return sum;
  }

  // Train the model
  void train(List<List<double>> X, List<int> y) {
    if (X.isEmpty || y.isEmpty || X.length != y.length) {
      throw Exception('Invalid training data');
    }

    final int numSamples = X.length;
    final int numFeatures = X[0].length;
    weights = List<double>.filled(numFeatures, 0);
    bias = 0;

    for (int iter = 0; iter < maxIterations; iter++) {
      List<double> predictions = [];
      for (int i = 0; i < numSamples; i++) {
        double linearPred = dotProduct(X[i], weights!) + bias!;
        predictions.add(sigmoid(linearPred));
      }

      // Calculate gradients
      List<double> dw = List<double>.filled(numFeatures, 0);
      double db = 0;

      for (int i = 0; i < numSamples; i++) {
        double error = predictions[i] - y[i];
        db += error;
        for (int j = 0; j < numFeatures; j++) {
          dw[j] += error * X[i][j];
        }
      }

      // Update weights and bias
      for (int j = 0; j < numFeatures; j++) {
        weights![j] -= learningRate * dw[j] / numSamples;
      }
      bias = bias! - learningRate * db / numSamples;
    }
  }

  // Predict the probability of a sample being "important"
  double predictProbability(List<double> x) {
    if (weights == null || bias == null) {
      throw Exception('Model not trained');
    }
    return sigmoid(dotProduct(x, weights!) + bias!);
  }

  // Predict class (0 or 1)
  int predict(List<double> x) {
    double probability = predictProbability(x);
    return probability > 0.5 ? 1 : 0;
  }
}

class PxrfDataProcessor {
  List<PxrfSample> samples = [];
  LogisticRegressionModel? model;

  void loadFromCsv(String csvData) {
    try {
      List<List<dynamic>> rowsAsListOfValues = const CsvToListConverter().convert(csvData);
      if (rowsAsListOfValues.isEmpty) {
        throw Exception('CSV data is empty');
      }

      // Extract header to identify column positions
      List<String> headers = rowsAsListOfValues[0].map((e) => e.toString()).toList();
      debugPrint('CSV Headers: $headers');

      // Find indices for each column
      int roomIndex = headers.indexOf('ROOM');
      int xCoordIndex = headers.indexOf('X_COORD');
      int yCoordIndex = headers.indexOf('Y_COORD');
      int importantIndex = headers.indexOf('IMPORTANT');

      // Validate column indices
      if (roomIndex == -1 || xCoordIndex == -1 || yCoordIndex == -1 || importantIndex == -1) {
        throw Exception('Missing required columns in CSV');
      }

      // Process each row
      for (int i = 1; i < rowsAsListOfValues.length; i++) {
        try {
          List<dynamic> row = rowsAsListOfValues[i];
          debugPrint('Processing row $i: $row');

          // Create elements map
          Map<String, double> elements = {};
          for (int j = 0; j < headers.length; j++) {
            String header = headers[j];
            if (header != 'ROOM' &&
                header != 'X_COORD' &&
                header != 'Y_COORD' &&
                header != 'IMPORTANT') {
              elements[header] = _parseDouble(row[j]);
            }
          }

          // Create PxrfSample
          samples.add(PxrfSample(
            room: _parseString(row[roomIndex]),
            xCoord: _parseDouble(row[xCoordIndex]),
            yCoord: _parseDouble(row[yCoordIndex]),
            elements: elements,
            important: _parseInt(row[importantIndex]),
          ));
        } catch (e) {
          debugPrint('Error processing row $i: $e');
          rethrow;
        }
      }
    } catch (e) {
      debugPrint('Error loading CSV: $e');
      rethrow;
    }
  }

  double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      try {
        return double.parse(value.trim());
      } catch (e) {
        debugPrint('Failed to parse double from: $value');
        return 0.0;
      }
    }
    debugPrint('Unexpected type for double: ${value.runtimeType}');
    return 0.0;
  }

  int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      try {
        return int.parse(value.trim());
      } catch (e) {
        debugPrint('Failed to parse int from: $value');
        return 0;
      }
    }
    debugPrint('Unexpected type for int: ${value.runtimeType}');
    return 0;
  }

  String _parseString(dynamic value) {
    if (value == null) return '';
    return value.toString();
  }

  // Train the logistic regression model
  void trainModel() {
    if (samples.isEmpty) {
      throw Exception("No samples to train on");
    }

    // Prepare data
    List<List<double>> X = [];
    List<int> y = [];

    for (var sample in samples) {
      X.add(sample.toFeatureVector());
      y.add(sample.important);
    }

    // Create and train model
    model = LogisticRegressionModel(learningRate: 0.01, maxIterations: 1000);
    model!.train(X, y);
  }

  // Predict important locations and return their coordinates
  List<Map<String, dynamic>> predictImportantLocations(List<PxrfSample> newSamples) {
    if (model == null) {
      throw Exception('Model not trained');
    }

    List<Map<String, dynamic>> importantLocations = [];

    for (var sample in newSamples) {
      List<double> features = sample.toFeatureVector();
      double probability = model!.predictProbability(features);

      if (probability > 0.5) {
        importantLocations.add({
          'room': sample.room,
          'x': sample.xCoord,
          'y': sample.yCoord,
          'probability': probability,
        });
      }
    }

    return importantLocations;
  }
}