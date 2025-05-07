import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:screenify/ui/widgets/candidate_profile.dart';
import 'package:screenify/ui/widgets/global_timer.dart';
import 'package:screenify/utils/extension.dart';

import '../../domain/local/assessment_helper.dart';
import '../../domain/model/assessment_question.dart';

class McqAssessmentScreen extends StatefulWidget {
  final Assessment mcqData;
  final String? candidateId;

  const McqAssessmentScreen({
    super.key,
    required this.mcqData,
    required this.candidateId,
  });

  @override
  State<McqAssessmentScreen> createState() => _McqAssessmentScreenState();
}

class _McqAssessmentScreenState extends State<McqAssessmentScreen> {
  int _currentQuestionIndex = 0;
  final PageController _pageController = PageController(initialPage: 0);
  int _score = 0;
  late List<Question> _questions;
  final AssessmentDatabaseHelper _dbHelper = AssessmentDatabaseHelper();
  bool _isSubmitting = false;
  DateTime? _startTime;

  // Theme colors to match email assessment screen
  final Color primaryColor = Colors.blue[700]!;
  final Color secondaryColor = Colors.white;
  final Color accentColor = Colors.blue[50]!;

  bool get _allQuestionsAnswered {
    return _questions.every((question) => question.isAnswered);
  }

  int get _answeredCount {
    return _questions.where((question) => question.isAnswered).length;
  }

  void _calculateScore() {
    _score = 0;
    for (var question in _questions) {
      if (question.selectedAnswerIndex == question.correctAnswerIndex) {
        _score++;
      }
    }
  }

  Future<void> _handleSubmit() async {
    if (_isSubmitting) return; // Prevent double submission

    setState(() {
      _isSubmitting = true;
    });

    _calculateScore();

    // Calculate correct and wrong counts
    int correctCount = _score;
    int wrongCount = _questions.length - correctCount;

    // Calculate time spent
    final endTime = DateTime.now();
    int timeInSeconds = endTime.difference(_startTime!).inSeconds;

    // Create a map for all questions with their selected answers
    List<Map<String, dynamic>> questionsData =
        _questions.map((question) {
          return {
            'question': question.question,
            'selectedAnswerIndex': question.selectedAnswerIndex,
            'correctAnswerIndex': question.correctAnswerIndex,
            'isCorrect':
                question.selectedAnswerIndex == question.correctAnswerIndex,
          };
        }).toList();

    // Create the final result object with completion timestamp
    Map<String, dynamic> result = {
      'totalQuestions': _questions.length,
      'correctCount': correctCount,
      'wrongCount': wrongCount,
      'score': _score,
      'scorePercentage': (_score / _questions.length * 100).toStringAsFixed(1),
      'questions': questionsData,
      'timeInSeconds': timeInSeconds,
      'completedAt': DateTime.now().toIso8601String(),
    };

    // Convert to JSON and log to console
    String jsonResult = jsonEncode(result);
    debugPrint('Assessment Result: $jsonResult');

    // Show submission confirmation dialog before saving to database
    _showSubmissionConfirmation(result);

    setState(() {
      _isSubmitting = false;
    });
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
                  // Save to database if candidateId is provided
                  if (widget.candidateId != null) {
                    try {
                      // Use the saveAssessmentResult method
                      await _dbHelper.saveAssessmentResult(
                        widget.candidateId!,
                        widget.mcqData.type,
                        results,
                      );

                      // Update the assessment status to completed
                      await _dbHelper.updateAssessmentStatus(
                        widget.candidateId!,
                        widget.mcqData.type,
                        AssessmentDatabaseHelper.STATUS_COMPLETED,
                      );
                    } catch (e) {
                      debugPrint('Error saving assessment result: $e');
                    }
                  }

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

  @override
  void initState() {
    super.initState();
    _questions = widget.mcqData.questions;
    _startTime = DateTime.now();

    // If assessmentType and candidateId are provided, mark it as started (pending)
    if (widget.candidateId != null) {
      _dbHelper.updateAssessmentStatus(
        widget.candidateId!,
        widget.mcqData.type,
        AssessmentDatabaseHelper.STATUS_PENDING,
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
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
            child: Icon(Icons.app_shortcut, color: Colors.white, size: 24),
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
        const SizedBox(width: 5),
        CandidateProfile(
          name: widget.candidateId ?? "Candidate",
          candidateId: widget.candidateId ?? "Unknown",
        ),
        const SizedBox(width: 5),
        IconButton(
          icon: Icon(Icons.close, color: Colors.grey[700]),
          onPressed: () {
            _showExitConfirmation(context);
          },
        ),
      ],
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
                      getIconFromString(widget.mcqData.icon!),
                      color: Colors.white,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.mcqData.title,
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

              // Progress section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Progress',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  Text(
                    '$_answeredCount/${_questions.length}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Progress bar
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: _answeredCount / _questions.length,
                  backgroundColor: Colors.white.withOpacity(0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _allQuestionsAnswered ? Colors.green : Colors.white,
                  ),
                  minHeight: 8,
                ),
              ),
              const SizedBox(height: 30),

              // Question indicators
              const Text(
                'Questions',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 15),

              // Question navigation grid
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: List.generate(
                  _questions.length,
                  (index) => GestureDetector(
                    onTap: () {
                      _pageController.animateToPage(
                        index,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    child: Container(
                      width: 35,
                      height: 35,
                      decoration: BoxDecoration(
                        color:
                            _currentQuestionIndex == index
                                ? Colors.white
                                : (_questions[index].isAnswered
                                    ? Colors.green[400]
                                    : Colors.white.withOpacity(0.1)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            color:
                                _currentQuestionIndex == index
                                    ? Colors.blue[700]
                                    : Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const Spacer(),

              // Tips container
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
                      'Read each question carefully. You can navigate between questions using the numbers above.',
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
                // Main question area
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentQuestionIndex = index;
                      });
                    },
                    itemCount: _questions.length,
                    itemBuilder: (context, index) {
                      final question = _questions[index];
                      return _buildQuestionCard(question);
                    },
                  ),
                ),

                const SizedBox(height: 16),

                // Navigation buttons
                _buildNavigationButtons(),

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

  Widget _buildQuestionCard(Question question) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Icon(Icons.help_outline, color: Colors.blue[700]),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Question ${_currentQuestionIndex + 1}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[700],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Question content
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
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      question.question,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Select one answer:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Options
                  Expanded(
                    child: ListView.builder(
                      itemCount: question.options.length,
                      itemBuilder: (context, optionIndex) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color:
                                  question.selectedAnswerIndex == optionIndex
                                      ? Colors.blue[700]!
                                      : Colors.grey[300]!,
                              width:
                                  question.selectedAnswerIndex == optionIndex
                                      ? 2
                                      : 1,
                            ),
                            borderRadius: BorderRadius.circular(8),
                            color:
                                question.selectedAnswerIndex == optionIndex
                                    ? Colors.blue[50]
                                    : Colors.white,
                          ),
                          child: RadioListTile<int>(
                            title: Text(
                              question.options[optionIndex],
                              style: TextStyle(
                                fontWeight:
                                    question.selectedAnswerIndex == optionIndex
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                color:
                                    question.selectedAnswerIndex == optionIndex
                                        ? Colors.blue[700]
                                        : Colors.black87,
                              ),
                            ),
                            value: optionIndex,
                            groupValue: question.selectedAnswerIndex,
                            onChanged: (value) {
                              setState(() {
                                question.selectedAnswerIndex = value;
                              });
                            },
                            activeColor: Colors.blue[700],
                            dense: true,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            selected:
                                question.selectedAnswerIndex == optionIndex,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNavigationButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Previous Button
        SizedBox(
          width: 125,
          height: 50,
          child: ElevatedButton.icon(
            onPressed:
                _currentQuestionIndex > 0
                    ? () {
                      _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                    : null,
            icon: const Icon(Icons.arrow_back),
            label: const Text('Previous'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[200],
              foregroundColor: Colors.black87,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),

        // Next/Submit Button
        SizedBox(
          width: _currentQuestionIndex < _questions.length - 1 ? 120 : 150,
          height: 48,
          child:
              _currentQuestionIndex < _questions.length - 1
                  ? ElevatedButton.icon(
                    onPressed: () {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    icon: const Text('Next'),
                    label: const Icon(Icons.arrow_forward),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[700],
                      foregroundColor: Colors.white,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  )
                  : ElevatedButton.icon(
                    onPressed:
                        _allQuestionsAnswered && !_isSubmitting
                            ? _handleSubmit
                            : null,
                    icon:
                        _isSubmitting
                            ? Container(
                              width: 20,
                              height: 20,
                              padding: const EdgeInsets.all(2.0),
                              child: const CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                            : const Icon(Icons.check_circle),
                    label: Text(_isSubmitting ? 'Submitting...' : 'Submit'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          _allQuestionsAnswered
                              ? Colors.blue[700]
                              : Colors.grey[400],
                      foregroundColor: Colors.white,
                      elevation: _allQuestionsAnswered ? 2 : 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
        ),
      ],
    );
  }
}
