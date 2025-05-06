import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:screenify/domain/local/assessment_manager.dart';
import 'package:screenify/domain/model/assessment_data.dart';
import 'package:screenify/ui/widgets/global_timer.dart';
import 'package:screenify/utils/extension.dart';

import '../widgets/candidate_profile.dart';

class EmailAssessmentScreen extends StatefulWidget {
  final String assessmentType;
  final String candidateId;
  final Assessment emailData;

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
      title: widget.emailData.title,
      description: widget.emailData.description,
      instruction: widget.emailData.instruction ?? "",
      expectedTo: widget.emailData.expectedTo ?? "",
      expectedCc: widget.emailData.expectedCc ?? "",
      expectedSubject: widget.emailData.expectedSubject ?? "",
      expectedKeywords: List<String>.from(widget.emailData.expectedKeywords),
      hints: List<String>.from(widget.emailData.hints),
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

  void _showSubmissionConfirmation(Map<String, dynamic> results) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            title: Text(
              'Submit Assessment?',
              style: TextStyle(
                color: Colors.blue[700],
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
                  Navigator.pop(context); // Close dialog
                  setState(() {
                    _testSubmitted = false; // Allow further editing
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

                  Navigator.pop(context); // Close dialog
                  Navigator.pop(
                    context,
                    true,
                  ); // Return to assessment list with result
                },
                child: Text(
                  'SUBMIT',
                  style: TextStyle(
                    color: Colors.blue[700],
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
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        appBar: _assessmentAppBar(context),
        body: Container(color: Colors.grey[50], child: _buildWideLayout()),
      ),
    );
  }

  Widget _buildWideLayout() {
    return Row(
      children: [
        // Left sidebar - Branding and details
        Container(
          width: 300,
          color: Colors.blue[700],
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
                      getIconFromString(widget.emailData.icon!),
                      color: Colors.white,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.emailData.title,
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
                'Hint',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 15),
              Expanded(
                child: ListView.builder(
                  itemBuilder: (_, index) {
                    final hint = _scenario.hints[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.lightbulb,
                            color: Colors.amber[700],
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              hint,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.white70,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  itemCount: _scenario.hints.length,
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
                      'Read instructions carefully and double-check your work before submission.',
                      style: TextStyle(color: Colors.blue[50], fontSize: 13),
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
                // Scenario Card
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
                            Icon(Icons.assignment, color: Colors.blue[700]),
                            const SizedBox(width: 8),
                            Text(
                              _scenario.description,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[700],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Instructions:',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _scenario.instruction,
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

                // Email Composition Section
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
                              Icon(Icons.email, color: Colors.blue[700]),
                              const SizedBox(width: 8),
                              Text(
                                'Compose Email:',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue[700],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Email form fields
                          _buildEmailField(
                            controller: _toController,
                            label: 'To',
                            icon: Icons.person,
                          ),
                          const SizedBox(height: 8),
                          _buildEmailField(
                            controller: _ccController,
                            label: 'CC',
                            icon: Icons.person_add,
                          ),
                          const SizedBox(height: 8),
                          _buildEmailField(
                            controller: _subjectController,
                            label: 'Subject',
                            icon: Icons.subject,
                          ),
                          const SizedBox(height: 8),
                          Expanded(child: _buildEmailBody()),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Action buttons
                _buildActionButton(),

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

  Widget _buildEmailField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return TextFormField(
      controller: controller,
      enabled: !_testSubmitted,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        prefixIcon: Icon(icon, color: Colors.blue[700]),
        filled: true,
        fillColor: _testSubmitted ? Colors.grey[100] : Colors.white,
        labelStyle: TextStyle(color: Colors.grey[700]),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.blue[700]!, width: 2),
        ),
      ),
    );
  }

  Widget _buildEmailBody() {
    return TextField(
      controller: _bodyController,
      maxLines: null,
      expands: true,
      enabled: !_testSubmitted,
      textAlignVertical: TextAlignVertical.top,
      decoration: InputDecoration(
        labelText: 'Message',
        alignLabelWithHint: true,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        filled: true,
        fillColor: _testSubmitted ? Colors.grey[100] : Colors.white,
        labelStyle: TextStyle(color: Colors.grey[700]),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.blue[700]!, width: 2),
        ),
      ),
    );
  }

  Widget _buildActionButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: _testSubmitted ? _resetTest : _handleSubmit,
        icon: Icon(_testSubmitted ? Icons.refresh : Icons.check_circle),
        label: Text(
          _testSubmitted ? 'Try Again' : 'Submit',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue[700],
          foregroundColor: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  AppBar _assessmentAppBar(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue[700],
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
              color: Colors.blue[700],
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      actions: [
        GlobalTimerWidget(),
        SizedBox(width: 5),
        CandidateProfile(
          name: widget.candidateId,
          candidateId: widget.candidateId,
        ),
        SizedBox(width: 5),
        IconButton(
          icon: Icon(Icons.close, color: Colors.grey[700]),
          onPressed: () {
            _showExitConfirmation(context);
          },
        ),
      ],
    );
  }

  void _showExitConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              'Exit Assessment?',
              style: TextStyle(
                color: Colors.blue[700],
                fontWeight: FontWeight.bold,
              ),
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
                onPressed: () => Navigator.pop(context), // Close dialog
                child: Text(
                  'CANCEL',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context, true); // Return to assessment list
                },
                child: Text(
                  'EXIT',
                  style: TextStyle(
                    color: Colors.blue[700],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
    );
  }
}

// Email scenario model
class EmailScenario {
  final String title;
  final String description;
  final String instruction;
  final String expectedTo;
  final String expectedCc;
  final String expectedSubject;
  final List<String> expectedKeywords;
  final List<String> hints;

  EmailScenario({
    required this.title,
    required this.description,
    required this.instruction,
    required this.expectedTo,
    required this.expectedCc,
    required this.expectedSubject,
    required this.expectedKeywords,
    required this.hints,
  });
}
