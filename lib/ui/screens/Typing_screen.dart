// ignore: file_names
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';

class TypingAssessment extends StatefulWidget {
  const TypingAssessment({super.key});

  @override
  _TypingAssessmentState createState() => _TypingAssessmentState();
}

class _TypingAssessmentState extends State<TypingAssessment> {
  final ScreenshotController _screenshotController = ScreenshotController();
  final TextEditingController _typingController = TextEditingController();
  bool _testSubmitted = false;
  double _accuracy = 0.0;
  int _timeInSeconds = 0;
  int _typingSpeed = 0; // WPM
  int _errorCount = 0;
  DateTime? _startTime;

  // Simple string reference content
  final String referenceContent =
      'The quick brown fox jumps over the lazy dog. Touch typing is the ability to use muscle memory to find keys fast, without using the sense of sight, and with all the available fingers, just like piano players do. It significantly improves typing speed and eliminates errors. Touch typing simply makes you more productive and it is a skill worth learning.';

  String get _plainReferenceText {
    return referenceContent; // Just return the string directly
  }

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
  }

  void _calculateAccuracy() {
    String userTypedText = _typingController.text.trim();
    String sampleText = _plainReferenceText.trim();

    // Split texts into lines and words for multi-level comparison
    List<String> typedLines = userTypedText.split('\n');
    List<String> referenceLines = sampleText.split('\n');

    List<String> typedWords = userTypedText.split(' ');
    List<String> referenceWords = sampleText.split(' ');

    int correctWords = 0;
    int errorCount = 0;
    int minWordCount =
        typedWords.length < referenceWords.length
            ? typedWords.length
            : referenceWords.length;

    // Compare words
    for (int i = 0; i < minWordCount; i++) {
      if (typedWords[i] == referenceWords[i]) {
        correctWords++;
      } else {
        errorCount++;
      }
    }

    // Count missing or extra words as errors
    int missingWords = referenceWords.length - minWordCount;
    errorCount += missingWords;

    // Calculate missing lines
    int missingLines = 0;
    if (referenceLines.length > typedLines.length) {
      missingLines = referenceLines.length - typedLines.length;
      errorCount += missingLines * 5; // Add penalty for each missing line
    }

    // Calculate task completion status
    bool taskCompleted =
        typedWords.length >= referenceWords.length &&
        typedLines.length >= referenceLines.length;

    // Calculate accuracy based on correctly spelled words
    _accuracy =
        referenceWords.isEmpty
            ? 0.0
            : (correctWords / referenceWords.length) * 100;
    _errorCount = errorCount;

    // Calculate typing speed (WPM)
    final endTime = DateTime.now();
    _timeInSeconds = endTime.difference(_startTime!).inSeconds;

    // Calculate WPM based on actual words typed
    _typingSpeed =
        _timeInSeconds > 0
            ? ((typedWords.length * 60) / _timeInSeconds).round()
            : 0;

    setState(() {
      _testSubmitted = true;
    });
  }

  Future<void> _saveScreenshot() async {
    final directory = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final path = '${directory.path}/typing_test_$timestamp.png';

    await _screenshotController.captureAndSave(path);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Screenshot saved to: $path')));
  }

  void _resetTest() {
    setState(() {
      _typingController.clear();
      _testSubmitted = false;
      _accuracy = 0.0;
      _timeInSeconds = 0;
      _typingSpeed = 0;
      _errorCount = 0;
      _startTime = DateTime.now();
    });
  }

  Color _getAccuracyColor(double accuracy) {
    if (accuracy >= 95) return Colors.green[600]!;
    if (accuracy >= 85) return Colors.lightGreen[600]!;
    if (accuracy >= 70) return Colors.amber[700]!;
    return Colors.red[600]!;
  }

  Color _getSpeedColor(int wpm) {
    if (wpm >= 60) return Colors.green[600]!;
    if (wpm >= 40) return Colors.lightGreen[600]!;
    if (wpm >= 20) return Colors.amber[700]!;
    return Colors.red[600]!;
  }

  Widget _buildResultItem({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(color: color, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Typing Skill Test')),
      body: Screenshot(
        controller: _screenshotController,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left side - Reference text with formatting
                    Expanded(
                      child: Card(
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: const [
                                  Icon(Icons.description, color: Colors.blue),
                                  SizedBox(width: 8),
                                  Text(
                                    'Reference Text:',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 16),
                              Expanded(
                                child: SingleChildScrollView(
                                  child: Text(
                                    referenceContent,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 16),

                    // Right side - Typing area
                    Expanded(
                      child: Card(
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.keyboard,
                                    color: Colors.blue,
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Type Here:',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue,
                                    ),
                                  ),
                                  const Spacer(),
                                  if (!_testSubmitted)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.blue.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.timer,
                                            size: 16,
                                            color: Colors.blue,
                                          ),
                                          const SizedBox(width: 4),
                                          StreamBuilder(
                                            stream: Stream.periodic(
                                              const Duration(seconds: 1),
                                            ),
                                            builder: (context, snapshot) {
                                              if (_startTime == null) {
                                                return const Text('00:00');
                                              }
                                              final elapsed =
                                                  DateTime.now()
                                                      .difference(_startTime!)
                                                      .inSeconds;
                                              final minutes = elapsed ~/ 60;
                                              final seconds = elapsed % 60;
                                              return Text(
                                                '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
                                                style: const TextStyle(
                                                  color: Colors.blue,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Expanded(
                                child: TextField(
                                  controller: _typingController,
                                  maxLines: null,
                                  expands: true,
                                  enabled: !_testSubmitted,
                                  textAlignVertical:
                                      TextAlignVertical
                                          .top, // This aligns text to top
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                    hintText:
                                        'Type here to match the text on the left side...',
                                    filled: true,
                                    fillColor:
                                        _testSubmitted
                                            ? Colors.grey[200]
                                            : Colors.white,
                                    alignLabelWithHint:
                                        true, // This helps with the alignment
                                  ),
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Results area
              if (_testSubmitted)
                Card(
                  color: Colors.blue[50],
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.assessment, color: Colors.blue),
                            SizedBox(width: 8),
                            Text(
                              'Test Results',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildResultItem(
                              icon: Icons.check_circle,
                              title: 'Accuracy',
                              value: '${_accuracy.toStringAsFixed(2)}%',
                              color: _getAccuracyColor(_accuracy),
                            ),
                            _buildResultItem(
                              icon: Icons.timer,
                              title: 'Time',
                              value: '$_timeInSeconds sec',
                              color: Colors.blue,
                            ),
                            _buildResultItem(
                              icon: Icons.speed,
                              title: 'Speed',
                              value: '$_typingSpeed WPM',
                              color: _getSpeedColor(_typingSpeed),
                            ),
                            _buildResultItem(
                              icon: Icons.error,
                              title: 'Errors',
                              value: '$_errorCount',
                              color: Colors.red[400]!,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 16),

              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: _testSubmitted ? _resetTest : _calculateAccuracy,
                    icon: Icon(_testSubmitted ? Icons.refresh : Icons.check),
                    label: Text(_testSubmitted ? 'Try Again' : 'Submit'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  if (_testSubmitted)
                    ElevatedButton.icon(
                      onPressed: _saveScreenshot,
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Save Screenshot'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
