import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';

class EmailAssessment extends StatefulWidget {
  const EmailAssessment({super.key});

  @override
  _EmailAssessmentState createState() => _EmailAssessmentState();
}

class _EmailAssessmentState extends State<EmailAssessment> {
  final ScreenshotController _screenshotController = ScreenshotController();
  final TextEditingController _toController = TextEditingController();
  final TextEditingController _ccController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();

  bool _testSubmitted = false;
  double _accuracy = 0.0;
  int _timeInSeconds = 0;
  int _errorCount = 0;
  DateTime? _startTime;

  // Single test scenario
  final EmailScenario _scenario = EmailScenario(
    title: "Customer Support Issue",
    instruction:
        "You received a defective product (Model X200 Printer) from TechSupplies Inc. Write an email to their customer service explaining the issue and requesting a replacement or refund. Your order number is #45678.",
    expectedTo: "support@techsupplies.com",
    expectedCc: "",
    expectedSubject: "Defective Product - Order #45678",
    expectedKeywords: [
      "defective",
      "product",
      "printer",
      "X200",
      "replacement",
      "refund",
      "order",
      "#45678",
      "issue",
    ],
    hints: [
      "Include your order number",
      "Describe the product issue clearly",
      "Specify what resolution you want",
      "Be polite but direct",
    ],
  );

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
  }

  void _evaluateEmail() {
    int errors = 0;
    int totalPoints = 0;
    int earnedPoints = 0;

    // Check recipient (3 points)
    totalPoints += 3;
    if (_toController.text.trim().toLowerCase() ==
        _scenario.expectedTo.toLowerCase()) {
      earnedPoints += 3;
    } else {
      errors++;
    }

    // Check CC if expected (2 points)
    if (_scenario.expectedCc.isNotEmpty) {
      totalPoints += 2;
      if (_ccController.text.trim().toLowerCase() ==
          _scenario.expectedCc.toLowerCase()) {
        earnedPoints += 2;
      } else {
        errors++;
      }
    }

    // Check subject (5 points)
    totalPoints += 5;
    final String normalizedSubject =
        _subjectController.text.trim().toLowerCase();
    final String expectedSubject = _scenario.expectedSubject.toLowerCase();
    if (normalizedSubject == expectedSubject) {
      earnedPoints += 5;
    } else if (normalizedSubject.contains(
          expectedSubject.split(" - ")[0].toLowerCase(),
        ) ||
        normalizedSubject.contains(
          expectedSubject.split(" - ").last.toLowerCase(),
        )) {
      // Partial match - contains at least part of expected subject
      earnedPoints += 2;
      errors++;
    } else {
      errors++;
    }

    // Check for keywords in body (10 points)
    totalPoints += _scenario.expectedKeywords.length * 2;
    for (String keyword in _scenario.expectedKeywords) {
      if (_bodyController.text.toLowerCase().contains(keyword.toLowerCase())) {
        earnedPoints += 2;
      } else {
        errors++;
      }
    }

    // Check for proper email format (5 points)
    totalPoints += 5;
    bool hasGreeting =
        _bodyController.text.toLowerCase().contains("dear") ||
        _bodyController.text.toLowerCase().contains("hello") ||
        _bodyController.text.toLowerCase().contains("hi");
    bool hasSignature =
        _bodyController.text.toLowerCase().contains("sincerely") ||
        _bodyController.text.toLowerCase().contains("regards") ||
        _bodyController.text.toLowerCase().contains("thank you");

    if (hasGreeting)
      earnedPoints += 2;
    else
      errors++;

    if (hasSignature)
      earnedPoints += 3;
    else
      errors++;

    // Calculate final accuracy
    _accuracy = (earnedPoints / totalPoints) * 100;
    _errorCount = errors;

    // Calculate time spent
    final endTime = DateTime.now();
    _timeInSeconds = endTime.difference(_startTime!).inSeconds;

    setState(() {
      _testSubmitted = true;
    });
  }

  void _resetTest() {
    setState(() {
      _toController.clear();
      _ccController.clear();
      _subjectController.clear();
      _bodyController.clear();
      _testSubmitted = false;
      _accuracy = 0.0;
      _timeInSeconds = 0;
      _errorCount = 0;
      _startTime = DateTime.now();
    });
  }

  Future<void> _saveScreenshot() async {
    final directory = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final path = '${directory.path}/email_test_$timestamp.png';

    await _screenshotController.captureAndSave(path);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Screenshot saved to: $path')));
  }

  Color _getAccuracyColor(double accuracy) {
    if (accuracy >= 90) return Colors.green[600]!;
    if (accuracy >= 75) return Colors.lightGreen[600]!;
    if (accuracy >= 60) return Colors.amber[700]!;
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
      appBar: AppBar(title: Text('Email Skill Test')),
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
                    // Left side - Scenario and Instructions
                    Expanded(
                      flex: 2,
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
                                    Icons.assignment,
                                    color: Colors.blue,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Scenario: ${_scenario.title}',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Instructions:',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _scenario.instruction,
                                style: TextStyle(fontSize: 16),
                              ),
                              const SizedBox(height: 24),
                              if (!_testSubmitted) ...[
                                Text(
                                  'Hints:',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue[700],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                ..._scenario.hints.map(
                                  (hint) => Padding(
                                    padding: const EdgeInsets.only(bottom: 4.0),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Icon(
                                          Icons.lightbulb_outline,
                                          size: 16,
                                          color: Colors.amber[700],
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(child: Text(hint)),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                              if (_testSubmitted) ...[
                                const SizedBox(height: 16),
                                Text(
                                  'Expected Recipients:',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text('To: ${_scenario.expectedTo}'),
                                if (_scenario.expectedCc.isNotEmpty)
                                  Text('CC: ${_scenario.expectedCc}'),
                                const SizedBox(height: 16),
                                Text(
                                  'Expected Subject:',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(_scenario.expectedSubject),
                                const SizedBox(height: 16),
                                Text(
                                  'Expected Keywords:',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Wrap(
                                  spacing: 8,
                                  children:
                                      _scenario.expectedKeywords
                                          .map(
                                            (keyword) => Chip(
                                              label: Text(keyword),
                                              backgroundColor:
                                                  _bodyController.text
                                                          .toLowerCase()
                                                          .contains(
                                                            keyword
                                                                .toLowerCase(),
                                                          )
                                                      ? Colors.green[100]
                                                      : Colors.red[100],
                                            ),
                                          )
                                          .toList(),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 16),

                    // Right side - Email composition
                    Expanded(
                      flex: 3,
                      child: Card(
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.email, color: Colors.blue),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Compose Email:',
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
                                        mainAxisSize: MainAxisSize.min,
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
                              const SizedBox(height: 16),
                              // Email form fields
                              TextFormField(
                                controller: _toController,
                                enabled: !_testSubmitted,
                                decoration: InputDecoration(
                                  labelText: 'To',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.person),
                                  filled: true,
                                  fillColor:
                                      _testSubmitted
                                          ? Colors.grey[200]
                                          : Colors.white,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _ccController,
                                enabled: !_testSubmitted,
                                decoration: InputDecoration(
                                  labelText: 'CC',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.person_add),
                                  filled: true,
                                  fillColor:
                                      _testSubmitted
                                          ? Colors.grey[200]
                                          : Colors.white,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _subjectController,
                                enabled: !_testSubmitted,
                                decoration: InputDecoration(
                                  labelText: 'Subject',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.subject),
                                  filled: true,
                                  fillColor:
                                      _testSubmitted
                                          ? Colors.grey[200]
                                          : Colors.white,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Expanded(
                                child: TextField(
                                  controller: _bodyController,
                                  maxLines: null,
                                  expands: true,
                                  enabled: !_testSubmitted,
                                  textAlignVertical: TextAlignVertical.top,
                                  decoration: InputDecoration(
                                    labelText: 'Message',
                                    alignLabelWithHint: true,
                                    border: OutlineInputBorder(),
                                    filled: true,
                                    fillColor:
                                        _testSubmitted
                                            ? Colors.grey[200]
                                            : Colors.white,
                                  ),
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
                              'Email Assessment Results',
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
                    onPressed: _testSubmitted ? _resetTest : _evaluateEmail,
                    icon: Icon(_testSubmitted ? Icons.refresh : Icons.check),
                    label: Text(_testSubmitted ? 'Try Again' : 'Submit Email'),
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
                      label: const Text('Save Results'),
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

// Email scenario model
class EmailScenario {
  final String title;
  final String instruction;
  final String expectedTo;
  final String expectedCc;
  final String expectedSubject;
  final List<String> expectedKeywords;
  final List<String> hints;

  EmailScenario({
    required this.title,
    required this.instruction,
    required this.expectedTo,
    required this.expectedCc,
    required this.expectedSubject,
    required this.expectedKeywords,
    required this.hints,
  });
}
