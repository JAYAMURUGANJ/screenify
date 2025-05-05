import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenify/domain/local/assessment_manager.dart';
import 'package:screenify/domain/model/assessment_data.dart';
import 'package:screenify/utils/extension.dart';
import 'package:screenshot/screenshot.dart';

class TypingAssessmentScreen extends StatefulWidget {
  final String assessmentType;
  final String candidateId;
  final Assessment typingData;

  const TypingAssessmentScreen({
    super.key,
    required this.assessmentType,
    required this.candidateId,
    required this.typingData,
  });

  @override
  State<TypingAssessmentScreen> createState() => _TypingAssessmentScreenState();
}

class _TypingAssessmentScreenState extends State<TypingAssessmentScreen> {
  final ScreenshotController _screenshotController = ScreenshotController();
  final TextEditingController _typingController = TextEditingController();
  final AssessmentDatabaseHelper _dbHelper = AssessmentDatabaseHelper();

  bool _testSubmitted = false;
  double _accuracy = 0.0;
  DateTime? _startTime;

  @override
  void initState() {
    super.initState();
    _loadAssessmentStatus();
    _startTime = DateTime.now();
  }

  @override
  void dispose() {
    _typingController.dispose();
    super.dispose();
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

  Map<String, dynamic> _evaluateTyping() {
    final String userTypedText = _typingController.text.trim();
    final String sampleText = widget.typingData.paragraph!.trim();

    // Split texts into lines and words for multi-level comparison
    final List<String> typedLines = userTypedText.split('\n');
    final List<String> referenceLines = sampleText.split('\n');

    final List<String> typedWords = userTypedText.split(' ');
    final List<String> referenceWords = sampleText.split(' ');

    int correctWords = 0;
    int errorCount = 0;
    final int minWordCount =
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
    final int missingWords = referenceWords.length - minWordCount;
    errorCount += missingWords;

    // Calculate missing lines
    int missingLines = 0;
    if (referenceLines.length > typedLines.length) {
      missingLines = referenceLines.length - typedLines.length;
      errorCount += missingLines * 5; // Add penalty for each missing line
    }

    // Calculate task completion status
    final bool taskCompleted =
        typedWords.length >= referenceWords.length &&
        typedLines.length >= referenceLines.length;

    // Calculate accuracy based on correctly spelled words
    final double accuracy =
        referenceWords.isEmpty
            ? 0.0
            : (correctWords / referenceWords.length) * 100;

    // Calculate typing speed (WPM)
    final endTime = DateTime.now();
    final int timeInSeconds = endTime.difference(_startTime!).inSeconds;

    // Calculate WPM based on actual words typed
    final int typingSpeed =
        timeInSeconds > 0
            ? ((typedWords.length * 60) / timeInSeconds).round()
            : 0;

    setState(() {
      _testSubmitted = true;
      _accuracy = accuracy;
    });

    // Prepare result JSON
    final Map<String, dynamic> results = {
      'candidateId': widget.candidateId,
      'assessmentType': widget.assessmentType,
      'accuracy': accuracy,
      'timeInSeconds': timeInSeconds,
      'typingSpeed': typingSpeed,
      'errorCount': errorCount,
      'correctWords': correctWords,
      'totalWords': referenceWords.length,
      'typedWords': typedWords.length,
      'submittedText': userTypedText,
      'referenceText': sampleText,
      'taskCompleted': taskCompleted,
      'completedAt': DateTime.now().toIso8601String(),
    };

    return results;
  }

  Future<void> _handleSubmit() async {
    // Get evaluation results
    final Map<String, dynamic> results = _evaluateTyping();

    // Print results to terminal as a single string
    debugPrint(const JsonEncoder.withIndent('  ').convert(results));

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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to save results to database: ${e.toString()}',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _saveResultsToFile(Map<String, dynamic> results) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final path =
          '${directory.path}/typing_results_${widget.candidateId}_$timestamp.json';

      // Write the JSON to a file
      final File file = File(path);
      await file.writeAsString(
        const JsonEncoder.withIndent('  ').convert(results),
      );
    } catch (e) {
      debugPrint('Error saving results to file: $e');
    }
  }

  void _showSubmissionConfirmation(Map<String, dynamic> results) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (BuildContext dialogContext) => AlertDialog(
            title: const Text('Submit Assessment?'),
            content: const Text(
              'Are you sure you want to submit this assessment? You cannot make changes after submission.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogContext); // Close dialog
                  setState(() {
                    _testSubmitted = false; // Allow further editing
                  });
                },
                child: const Text('CANCEL'),
              ),
              TextButton(
                onPressed: () async {
                  // Save results
                  await _saveResults(results);
                  await _saveResultsToFile(results);

                  Navigator.pop(dialogContext); // Close dialog
                  if (mounted) {
                    Navigator.pop(
                      context,
                      true,
                    ); // Return to assessment list with result
                  }
                },
                child: const Text('SUBMIT'),
              ),
            ],
          ),
    );
  }

  void _resetTest() {
    setState(() {
      _typingController.clear();
      _testSubmitted = false;
      _accuracy = 0.0;
      _startTime = DateTime.now();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _assessmentAppBar(),
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
                      // Left side - Reference text with formatting
                      Expanded(
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
                                // Instruction section
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.assignment,
                                          color: getColorFromString(
                                            widget.typingData.color ?? 'blue',
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            widget.typingData.description,
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: getColorFromString(
                                                widget.typingData.color ??
                                                    'blue',
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                  ],
                                ),

                                // Reference text heading
                                Text(
                                  widget.typingData.instructions!,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[700],
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Expanded(
                                  child: SingleChildScrollView(
                                    child: Text(
                                      widget.typingData.paragraph ?? '',
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
                                      getIconFromString(
                                        widget.typingData.icon ?? 'description',
                                      ),
                                      color: getColorFromString(
                                        widget.typingData.color ?? 'blue',
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Type Here:',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: getColorFromString(
                                          widget.typingData.color ?? 'blue',
                                        ),
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
                                    textAlignVertical: TextAlignVertical.top,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      hintText:
                                          'Type here to match the text on the left side...',
                                      filled: true,
                                      fillColor:
                                          _testSubmitted
                                              ? Colors.grey[200]
                                              : Colors.white,
                                      alignLabelWithHint: true,
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

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _testSubmitted ? _resetTest : _handleSubmit,
                      icon: Icon(
                        _testSubmitted ? Icons.refresh : Icons.check_circle,
                      ),
                      label: Text(_testSubmitted ? 'Try Again' : 'Submit'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: getColorFromString(
                          widget.typingData.color ?? 'blue',
                        ),
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

  AppBar _assessmentAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: getColorFromString(widget.typingData.color ?? 'blue'),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              getIconFromString(widget.typingData.icon ?? 'description'),
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            widget.typingData.title,
            style: GoogleFonts.poppins(
              color: getColorFromString(widget.typingData.color ?? 'blue'),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            _showExitConfirmation();
          },
        ),
      ],
    );
  }

  void _showExitConfirmation() {
    showDialog(
      context: context,
      builder:
          (BuildContext dialogContext) => AlertDialog(
            title: const Text('Exit Assessment?'),
            content: const Text(
              'Your progress will be saved. You can continue this assessment later. '
              'Are you sure you want to exit?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext), // Close dialog
                child: const Text('CANCEL'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogContext); // Close dialog
                  Navigator.pop(context, true); // Return to assessment list
                },
                child: const Text('EXIT'),
              ),
            ],
          ),
    );
  }
}
