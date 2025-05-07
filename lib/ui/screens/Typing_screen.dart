import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:screenify/domain/local/assessment_helper.dart';
import 'package:screenify/domain/model/assessment_question.dart';
import 'package:screenify/ui/widgets/global_timer.dart';
import 'package:screenify/utils/extension.dart';
import 'package:screenshot/screenshot.dart';

import '../widgets/candidate_profile.dart';

class TypingAssessmentScreen extends StatefulWidget {
  final String candidateId;
  final Assessment typingData;

  const TypingAssessmentScreen({
    super.key,
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

  // Define blue color to use throughout the app
  final Color primaryBlue = Colors.blue;
  final MaterialColor blueColor = Colors.blue;

  bool _isSubmitting = false;
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
        widget.typingData.type,
      );

      // If assessment is not started yet, update to pending
      if (status == AssessmentDatabaseHelper.STATUS_NOT_OPENED) {
        await _dbHelper.updateAssessmentStatus(
          widget.candidateId,
          widget.typingData.type,
          AssessmentDatabaseHelper.STATUS_PENDING,
        );
      }
    } catch (e) {
      debugPrint('Error loading assessment status: $e');
    }
  }

  Map<String, dynamic> _calculateScore() {
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
      _isSubmitting = true;
      _accuracy = accuracy;
    });

    // Prepare result JSON
    final Map<String, dynamic> results = {
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
    final Map<String, dynamic> results = _calculateScore();
    // Print results to terminal as a single string
    debugPrint(results.toString());
    // Show confirmation dialog
    _showSubmissionConfirmation(results);
  }

  Future<void> _saveResults(Map<String, dynamic> results) async {
    try {
      // Update assessment status to completed
      await _dbHelper.updateAssessmentStatus(
        widget.candidateId,
        widget.typingData.type,
        AssessmentDatabaseHelper.STATUS_COMPLETED,
      );

      // Save assessment results
      await _dbHelper.saveAssessmentResult(
        widget.candidateId,
        widget.typingData.type,
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

  void _showSubmissionConfirmation(Map<String, dynamic> results) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (BuildContext dialogContext) => AlertDialog(
            title: Text(
              'Submit Assessment?',
              style: TextStyle(
                color: blueColor[700],
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Text(
              'Are you sure you want to submit this assessment? You cannot make changes after submission.',
              style: TextStyle(color: Colors.grey[700]),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogContext); // Close dialog
                  setState(() {
                    _isSubmitting = false; // Allow further editing
                  });
                },
                child: Text(
                  'CANCEL',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
              TextButton(
                onPressed: () async {
                  // Save results
                  await _saveResults(results);

                  Navigator.pop(dialogContext); // Close dialog
                  if (mounted) {
                    Navigator.pop(
                      context,
                      true,
                    ); // Return to assessment list with result
                  }
                },
                child: Text(
                  'SUBMIT',
                  style: TextStyle(
                    color: blueColor[700],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
    );
  }

  void _resetTest() {
    setState(() {
      _typingController.clear();
      _isSubmitting = false;
      _accuracy = 0.0;
      _startTime = DateTime.now();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        appBar: _assessmentAppBar(),
        body: Screenshot(
          controller: _screenshotController,
          child: Container(color: Colors.grey[50], child: _buildWideLayout()),
        ),
      ),
    );
  }

  Widget _buildWideLayout() {
    return Row(
      children: [
        // Left sidebar - Branding and instructions
        Container(
          width: 300,
          color: blueColor[700],
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      getIconFromString(
                        widget.typingData.icon ?? 'description',
                      ),
                      color: Colors.white,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.typingData.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                'Instructions',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 15),
              Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.typingData.description,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.typingData.instructions ??
                          'Type the text exactly as shown.',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.tips_and_updates,
                      color: Colors.white,
                      size: 28,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Assessment Tips',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Take your time and focus on accuracy. Pay attention to spelling, punctuation and formatting.',
                      style: TextStyle(color: blueColor[50], fontSize: 13),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),

        // Main content area
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                // Instructions Card
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.assignment, color: blueColor[700]),
                            const SizedBox(width: 8),
                            Text(
                              'Typing Assessment',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: blueColor[700],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Sample Text:',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          widget.typingData.paragraph ??
                              'Type the text exactly as shown.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Typing Section
                Expanded(
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.keyboard, color: blueColor[700]),
                              const SizedBox(width: 8),
                              Text(
                                'Type Here:',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: blueColor[700],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Expanded(
                            child: TextField(
                              controller: _typingController,
                              maxLines: null,
                              expands: true,
                              enabled: !_isSubmitting,
                              textAlignVertical: TextAlignVertical.top,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                hintText:
                                    'Type here to match the sample text...',
                                filled: true,
                                fillColor:
                                    _isSubmitting
                                        ? Colors.grey[100]
                                        : Colors.white,
                                alignLabelWithHint: true,
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                    color: blueColor[700]!,
                                    width: 2,
                                  ),
                                ),
                              ),
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Action button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: _isSubmitting ? _resetTest : _handleSubmit,
                    icon: Icon(
                      _isSubmitting ? Icons.refresh : Icons.check_circle,
                    ),
                    label: Text(
                      _isSubmitting ? 'Try Again' : 'Submit',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: blueColor[700],
                      foregroundColor: Colors.white,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Footer
                Text(
                  '© ${DateTime.now().year} Screenify. All rights reserved.',
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ],
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
              color: blueColor[700],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.app_shortcut,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Screenify',
            style: GoogleFonts.poppins(
              color: blueColor[700],
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      actions: [
        const GlobalTimerWidget(),
        const SizedBox(width: 5),
        CandidateProfile(
          name: widget.candidateId,
          candidateId: widget.candidateId,
        ),
        const SizedBox(width: 5),
        IconButton(
          icon: Icon(Icons.close, color: Colors.grey[700]),
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
            title: Text(
              'Exit Assessment?',
              style: TextStyle(color: blueColor, fontWeight: FontWeight.bold),
            ),
            content: const Text(
              'You can continue this assessment later. '
              'Are you sure you want to exit?',
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext), // Close dialog
                child: Text(
                  'CANCEL',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogContext); // Close dialog
                  Navigator.pop(context, true); // Return to assessment list
                },
                child: Text(
                  'EXIT',
                  style: TextStyle(
                    color: blueColor[700],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
    );
  }
}
