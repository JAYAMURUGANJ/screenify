import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../local/assessment_database_helper.dart';

class CompletionDialog extends StatefulWidget {
  final String candidateId;
  const CompletionDialog({super.key, required this.candidateId});

  @override
  State<CompletionDialog> createState() => _CompletionDialogState();
}

class _CompletionDialogState extends State<CompletionDialog> {
  final AssessmentDatabaseHelper _dbHelper = AssessmentDatabaseHelper();
  int _secondsRemaining = 10;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    // Start countdown timer
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_secondsRemaining > 0) {
          _secondsRemaining--;
        } else {
          _timer.cancel();
          // Auto-submit after 10 seconds
          _handleSubmit();
        }
      });
    });
  }

  Future<String> getCandidateAssessmentResultsJson(String candidateId) async {
    final resultsMap = await _dbHelper.getAllAssessmentResults(candidateId);
    return jsonEncode(resultsMap);
  }

  void _handleSubmit() async {
    _timer.cancel();

    var results = await getCandidateAssessmentResultsJson(widget.candidateId);
    debugPrint(results); // Print as JSON string

    // Navigate to login page
    Navigator.of(context).pushNamedAndRemoveUntil(
      '/login', // Replace with your app's login route
      (route) => false, // Remove all previous routes
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      // Prevent back button dismissal
      onWillPop: () async => false,
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 5,
        backgroundColor: Colors.white,
        child: Container(
          padding: const EdgeInsets.all(24),
          width: MediaQuery.of(context).size.width * 0.4,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Completion icon
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle,
                  color: Colors.green[700],
                  size: 64,
                ),
              ),
              const SizedBox(height: 24),

              // Title
              Text(
                'All Assessments Completed!',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[700],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Description
              Text(
                'Congratulations! You have successfully completed all the required assessments.',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.grey[700],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // Submit button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[700],
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey[300],
                    disabledForegroundColor: Colors.grey[500],
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'Submit in $_secondsRemaining s',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
