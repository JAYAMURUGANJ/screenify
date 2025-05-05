// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert'; // Add this import for JSON encoding

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:screenify/ui/widgets/global_timer.dart';
import 'package:screenify/utils/extension.dart';

import '../../domain/local/assessment_manager.dart';
import '../../domain/model/assessment_data.dart';

class MCQAssessmentScreen extends StatefulWidget {
  final Assessment mcqData;
  final String? candidateId;

  const MCQAssessmentScreen({
    super.key,
    required this.mcqData,
    required this.candidateId,
  });

  @override
  State<MCQAssessmentScreen> createState() => _MCQAssessmentScreenState();
}

class _MCQAssessmentScreenState extends State<MCQAssessmentScreen> {
  int _currentQuestionIndex = 0;
  final PageController _pageController = PageController(initialPage: 0);
  int _score = 0;
  late List<Question> _questions;
  final AssessmentDatabaseHelper _dbHelper = AssessmentDatabaseHelper();
  bool _isSubmitting = false;

  // Theme color to match login screen
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

  Future<void> saveAssessmentResult() async {
    if (_isSubmitting) return; // Prevent double submission

    setState(() {
      _isSubmitting = true;
    });

    _calculateScore();

    // Calculate correct and wrong counts
    int correctCount = _score;
    int wrongCount = _questions.length - correctCount;

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
      'candidateId': widget.candidateId ?? '',
      'assessmentType': widget.mcqData.type,
      'totalQuestions': _questions.length,
      'correctCount': correctCount,
      'wrongCount': wrongCount,
      'score': _score,
      'scorePercentage': (_score / _questions.length * 100).toStringAsFixed(1),
      'questions': questionsData,
      'completedAt':
          DateTime.now().toIso8601String(), // Add completion timestamp
    };

    // Convert to JSON and log to console
    String jsonResult = jsonEncode(result);
    debugPrint('Assessment Result: $jsonResult');

    bool saved = false;

    // If assessmentType and candidateId are provided, save to database
    if (widget.candidateId != null) {
      try {
        // Use the saveAssessmentResult instead of saveMCQAssessmentResult
        saved = await _dbHelper.saveAssessmentResult(
          widget.candidateId!,
          widget.mcqData.type,
          result,
        );

        // Update the assessment status to completed
        await _dbHelper.updateAssessmentStatus(
          widget.candidateId!,
          widget.mcqData.type,
          AssessmentDatabaseHelper.STATUS_COMPLETED,
        );
      } catch (e) {
        debugPrint('Error saving assessment result: $e');
        saved = false;
      }
    }

    // Show a snackbar to indicate the result was generated and saved
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            saved
                ? 'Assessment completed and results saved successfully'
                : 'Results generated but not saved to your profile',
          ),
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          backgroundColor: primaryColor,
        ),
      );
    }

    setState(() {
      _isSubmitting = false;
    });

    // Return success to previous screen
    if (mounted && Navigator.canPop(context)) {
      Navigator.pop(context, true);
    }
  }

  @override
  void initState() {
    super.initState();
    _questions = widget.mcqData.questions;

    // If assessmentType and candidateId are provided, mark it as started (pending)
    if (widget.candidateId != null) {
      _dbHelper.markAssessmentAsStarted(
        widget.candidateId!,
        widget.mcqData.type,
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
    return Scaffold(
      backgroundColor: secondaryColor,
      appBar: _assessmentAppBar(context),
      body: _buildQuestionScreen(),
    );
  }

  void _showExitConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text(
              'Exit Assessment?',
              style: TextStyle(
                color: Color(0xFF2C3E50),
                fontWeight: FontWeight.bold,
              ),
            ),
            content: const Text(
              'Your progress will be saved. You can continue this assessment later. '
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
                  style: TextStyle(color: Colors.grey[700]),
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
                    color: primaryColor,
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
      backgroundColor: secondaryColor,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              getIconFromString(widget.mcqData.icon!),
              color: secondaryColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            widget.mcqData.title,
            style: GoogleFonts.poppins(
              color: const Color(0xFF2C3E50),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      actions: [
        GlobalTimerWidget(),
        IconButton(
          icon: Icon(Icons.help_outline, color: primaryColor),
          onPressed: () {
            _showInstructions();
          },
        ),
        IconButton(
          icon: Icon(Icons.close, color: primaryColor),
          onPressed: () {
            _showExitConfirmation(context);
          },
        ),
      ],
    );
  }

  void _showInstructions() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              'Assessment Instructions',
              style: TextStyle(
                color: const Color(0xFF2C3E50),
                fontWeight: FontWeight.bold,
              ),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    '• Read each question carefully before selecting an answer.',
                    style: TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '• You can navigate between questions using the Previous and Next buttons.',
                    style: TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '• Click on question indicators to jump to a specific question.',
                    style: TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '• The Submit button will be enabled only after answering all questions.',
                    style: TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '• Green indicators show answered questions.',
                    style: TextStyle(fontSize: 14, color: Colors.green[700]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '• Blue indicator shows your current question.',
                    style: TextStyle(fontSize: 14, color: primaryColor),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'GOT IT',
                  style: TextStyle(
                    color: primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
    );
  }

  Widget _buildQuestionScreen() {
    return Column(
      children: [
        _buildProgressIndicator(),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Question ${_currentQuestionIndex + 1}/${_questions.length}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C3E50),
                ),
              ),
              Text(
                'Answered: $_answeredCount/${_questions.length}',
                style: TextStyle(
                  fontSize: 16,
                  color:
                      _allQuestionsAnswered
                          ? Colors.green[700]
                          : Colors.grey[700],
                  fontWeight:
                      _allQuestionsAnswered
                          ? FontWeight.bold
                          : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
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
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: primaryColor.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [secondaryColor, accentColor],
                          ),
                        ),
                        child: Text(
                          question.question,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2C3E50),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...List.generate(
                      question.options.length,
                      (optionIndex) => Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Material(
                          borderRadius: BorderRadius.circular(8),
                          color:
                              question.selectedAnswerIndex == optionIndex
                                  ? primaryColor.withOpacity(0.2)
                                  : Colors.grey[50],
                          child: InkWell(
                            borderRadius: BorderRadius.circular(8),
                            onTap: () {
                              setState(() {
                                question.selectedAnswerIndex = optionIndex;
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: RadioListTile<int>(
                                title: Text(
                                  question.options[optionIndex],
                                  style: TextStyle(
                                    fontWeight:
                                        question.selectedAnswerIndex ==
                                                optionIndex
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                    color:
                                        question.selectedAnswerIndex ==
                                                optionIndex
                                            ? primaryColor
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
                                activeColor: primaryColor,
                                dense: true,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                selected:
                                    question.selectedAnswerIndex == optionIndex,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        _buildNavigationButtons(),
      ],
    );
  }

  Widget _buildProgressIndicator() {
    return LinearProgressIndicator(
      value: _answeredCount / _questions.length,
      backgroundColor: Colors.grey[200],
      valueColor: AlwaysStoppedAnimation<Color>(
        _allQuestionsAnswered ? Colors.green : primaryColor,
      ),
      minHeight: 8,
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      decoration: BoxDecoration(
        color: secondaryColor,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: Column(
        children: [
          // Question Navigation Indicators
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
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
                    width: 32,
                    height: 32,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color:
                          _currentQuestionIndex == index
                              ? primaryColor
                              : (_questions[index].isAnswered
                                  ? Colors.green[700]
                                  : Colors.grey[300]),
                      shape: BoxShape.circle,
                      boxShadow:
                          _currentQuestionIndex == index
                              ? [
                                BoxShadow(
                                  color: primaryColor.withOpacity(0.3),
                                  spreadRadius: 1,
                                  blurRadius: 3,
                                ),
                              ]
                              : null,
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          color:
                              _currentQuestionIndex == index ||
                                      _questions[index].isAnswered
                                  ? Colors.white
                                  : Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Previous/Next/Submit buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Previous Button
              ElevatedButton.icon(
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

              // Next/Submit Button
              if (_currentQuestionIndex < _questions.length - 1)
                ElevatedButton.icon(
                  onPressed: () {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  icon: const Text('Next'),
                  label: const Icon(Icons.arrow_forward),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: secondaryColor,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                )
              else
                ElevatedButton.icon(
                  onPressed:
                      _allQuestionsAnswered && !_isSubmitting
                          ? saveAssessmentResult
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
                            ? Colors.green[700]
                            : Colors.grey[400],
                    foregroundColor: secondaryColor,
                    elevation: _allQuestionsAnswered ? 2 : 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
