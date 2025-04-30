// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert'; // Add this import for JSON encoding

import 'package:flutter/material.dart';

import '../../domain/local/assessment_manager.dart';
import '../../domain/model/assessment_data.dart';

class MCQAssessmentScreen extends StatefulWidget {
  final List<Question>? questions;
  final String? assessmentType;
  final String? candidateId;

  const MCQAssessmentScreen({
    super.key,
    required this.questions,
    this.assessmentType,
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

  Future<void> _generateJsonResultAndSave() async {
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
    if (widget.assessmentType != null && widget.candidateId != null) {
      try {
        // Use the saveMCQAssessmentResult from the database helper
        saved = await _dbHelper.saveMCQAssessmentResult(
          widget.candidateId!,
          widget.assessmentType!,
          _questions,
          correctCount,
          wrongCount,
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
    _questions = widget.questions ?? [];

    // If assessmentType and candidateId are provided, mark it as started (pending)
    if (widget.assessmentType != null && widget.candidateId != null) {
      _dbHelper.markAssessmentAsStarted(
        widget.candidateId!,
        widget.assessmentType!,
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
      appBar: AppBar(
        title: const Text('MCQ Assessment'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () {
              _showInstructions();
            },
          ),
        ],
      ),
      body: _buildQuestionScreen(),
    );
  }

  void _showInstructions() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Assessment Instructions'),
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
                    style: TextStyle(fontSize: 14, color: Colors.blue[700]),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('GOT IT'),
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
                          color: Colors.blue.withOpacity(0.5),
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
                            colors: [
                              Colors.white,
                              Colors.blue.withOpacity(0.1),
                            ],
                          ),
                        ),
                        child: Text(
                          question.question,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
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
                                  ? Colors.blue.withOpacity(0.2)
                                  : Colors.grey[200],
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
      backgroundColor: Colors.grey[300],
      valueColor: AlwaysStoppedAnimation<Color>(
        _allQuestionsAnswered ? Colors.green : Colors.blue,
      ),
      minHeight: 8,
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
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
                              ? Colors.blue[700]
                              : (_questions[index].isAnswered
                                  ? Colors.green[700]
                                  : Colors.grey[300]),
                      shape: BoxShape.circle,
                      boxShadow:
                          _currentQuestionIndex == index
                              ? [
                                BoxShadow(
                                  color: Colors.blue.withOpacity(0.3),
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
                    backgroundColor: Colors.blue[700],
                    foregroundColor: Colors.white,
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
                          ? _generateJsonResultAndSave
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
                    foregroundColor: Colors.white,
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
