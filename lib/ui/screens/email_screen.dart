import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenify/domain/local/assessment_manager.dart';
import 'package:screenshot/screenshot.dart';

class EmailAssessmentScreen extends StatefulWidget {
  final String assessmentType;
  final String candidateId;
  final Map<String, dynamic> emailData;

  const EmailAssessmentScreen({
    super.key,
    required this.assessmentType,
    required this.candidateId,
    required this.emailData,
  });

  @override
  _EmailAssessmentScreenState createState() => _EmailAssessmentScreenState();
}

class _EmailAssessmentScreenState extends State<EmailAssessmentScreen> {
  final ScreenshotController _screenshotController = ScreenshotController();
  final TextEditingController _toController = TextEditingController();
  final TextEditingController _ccController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();
  final AssessmentDatabaseHelper _dbHelper = AssessmentDatabaseHelper();

  bool _testSubmitted = false;
  DateTime? _startTime;
  late EmailScenario _scenario;

  @override
  void initState() {
    super.initState();
    _loadAssessmentStatus();
    _initializeScenario();
    _startTime = DateTime.now();
  }

  void _initializeScenario() {
    _scenario = EmailScenario(
      title: widget.emailData['title'] ?? "Email Assessment",
      instruction:
          widget.emailData['instruction'] ?? "Write a professional email.",
      expectedTo: widget.emailData['expectedTo'] ?? "",
      expectedCc: widget.emailData['expectedCc'] ?? "",
      expectedSubject: widget.emailData['expectedSubject'] ?? "",
      expectedKeywords: List<String>.from(
        widget.emailData['expectedKeywords'] ?? [],
      ),
      hints: List<String>.from(widget.emailData['hints'] ?? []),
    );
  }

  Future<void> _loadAssessmentStatus() async {
    try {
      final status = await _dbHelper.getAssessmentStatus(
        widget.candidateId,
        widget.assessmentType,
      );

      // If assessment is not started yet, update to pending
      if (status == AssessmentDatabaseHelper.STATUS_NOT_OPENED) {
        await _dbHelper.updateAssessmentStatus(
          widget.candidateId,
          widget.assessmentType,
          AssessmentDatabaseHelper.STATUS_PENDING,
        );
      }
    } catch (e) {
      debugPrint('Error loading assessment status: $e');
    }
  }

  Map<String, dynamic> _evaluateEmail() {
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

    if (hasGreeting) {
      earnedPoints += 2;
    } else {
      errors++;
    }

    if (hasSignature) {
      earnedPoints += 3;
    } else {
      errors++;
    }

    // Calculate final accuracy
    double accuracy = (earnedPoints / totalPoints) * 100;

    // Calculate time spent
    final endTime = DateTime.now();
    int timeInSeconds = endTime.difference(_startTime!).inSeconds;

    setState(() {
      _testSubmitted = true;
    });

    // Prepare result JSON
    Map<String, dynamic> results = {
      'candidateId': widget.candidateId,
      'assessmentType': widget.assessmentType,
      'accuracy': accuracy,
      'timeInSeconds': timeInSeconds,
      'errorCount': errors,
      'totalPoints': totalPoints,
      'earnedPoints': earnedPoints,
      'submittedTo': _toController.text,
      'submittedCc': _ccController.text,
      'submittedSubject': _subjectController.text,
      'submittedBody': _bodyController.text,
      'expectedTo': _scenario.expectedTo,
      'expectedCc': _scenario.expectedCc,
      'expectedSubject': _scenario.expectedSubject,
      'expectedKeywords': _scenario.expectedKeywords,
      'hasGreeting': hasGreeting,
      'hasSignature': hasSignature,
      'completedAt': DateTime.now().toIso8601String(),
    };

    return results;
  }

  Future<void> _handleSubmit() async {
    // Get evaluation results
    Map<String, dynamic> results = _evaluateEmail();

    // Print results to terminal as a single string
    debugPrint(const JsonEncoder().convert(results));

    // Show confirmation dialog
    _showSubmissionConfirmation(results);
  }

  Future<void> _saveResults(Map<String, dynamic> results) async {
    try {
      // Update assessment status to completed
      await _dbHelper.updateAssessmentStatus(
        widget.candidateId,
        widget.assessmentType,
        AssessmentDatabaseHelper.STATUS_COMPLETED,
      );

      // Save assessment results
      await _dbHelper.saveAssessmentResult(
        widget.candidateId,
        widget.assessmentType,
        results,
      );
    } catch (e) {
      debugPrint('Error saving assessment results: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save results to database: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _saveResultsToFile(Map<String, dynamic> results) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final path =
          '${directory.path}/email_results_${widget.candidateId}_$timestamp.json';

      // Write the JSON to a file
      final File file = File(path);
      await file.writeAsString(const JsonEncoder().convert(results));
    } catch (e) {
      debugPrint('Error saving results to file: $e');
    }
  }

  void _showSubmissionConfirmation(Map<String, dynamic> results) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            title: Text('Submit Assessment?'),
            content: Text(
              'Are you sure you want to submit this assessment? You cannot make changes after submission.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  setState(() {
                    _testSubmitted = false; // Allow further editing
                  });
                },
                child: Text('CANCEL'),
              ),
              TextButton(
                onPressed: () async {
                  // Save results
                  await _saveResults(results);
                  await _saveResultsToFile(results);

                  Navigator.pop(context); // Close dialog
                  Navigator.pop(
                    context,
                    true,
                  ); // Return to assessment list with result
                },
                child: Text('SUBMIT'),
              ),
            ],
          ),
    );
  }

  void _resetTest() {
    setState(() {
      _toController.clear();
      _ccController.clear();
      _subjectController.clear();
      _bodyController.clear();
      _testSubmitted = false;
      _startTime = DateTime.now();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange[700],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.email, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 12),
            Text(
              'Email Skill Assessment',
              style: GoogleFonts.poppins(
                color: const Color(0xFF2C3E50),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              _showExitConfirmation(context);
            },
          ),
        ],
      ),
      body: Screenshot(
        controller: _screenshotController,
        child: Container(
          color: Colors.grey[50],
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
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.assignment,
                                      color: Colors.orange[700],
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Scenario: ${_scenario.title}',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.orange[700],
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
                                      padding: const EdgeInsets.only(
                                        bottom: 4.0,
                                      ),
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
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.email,
                                      color: Colors.orange[700],
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Compose Email:',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.orange[700],
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
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
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
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
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
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
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
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
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

                // Action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _testSubmitted ? _resetTest : _handleSubmit,
                      icon: Icon(_testSubmitted ? Icons.refresh : Icons.check),
                      label: Text(
                        _testSubmitted ? 'Try Again' : 'Submit Email',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange[700],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showExitConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Exit Assessment?'),
            content: const Text(
              'Your progress will be saved. You can continue this assessment later. '
              'Are you sure you want to exit?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context), // Close dialog
                child: const Text('CANCEL'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context, true); // Return to assessment list
                },
                child: const Text('EXIT'),
              ),
            ],
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
