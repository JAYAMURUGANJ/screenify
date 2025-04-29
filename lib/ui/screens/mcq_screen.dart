// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert'; // Add this import for JSON encoding

import 'package:flutter/material.dart';

import '../../domain/local/assessment_manager.dart';
import '../../domain/model/assessment_data.dart';

class MCQAssessmentScreen extends StatefulWidget {
  final List<Question>? questions;
  final String? assessmentType; // Add assessment ID parameter

  const MCQAssessmentScreen({
    super.key,
    required this.questions,
    this.assessmentType,
  });

  @override
  State<MCQAssessmentScreen> createState() => _MCQAssessmentScreenState();
}

class _MCQAssessmentScreenState extends State<MCQAssessmentScreen> {
  int _currentQuestionIndex = 0;
  final PageController _pageController = PageController(initialPage: 0);
  int _score = 0;
  late List<Question> _questions;
  final AssessmentPreferencesManager _prefsManager =
      AssessmentPreferencesManager();

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
    debugPrint(
      'Assessment Result: $jsonResult',
    ); // Better to use debugPrint instead of print

    bool saved = false;

    // If assessmentType is provided, save to preferences
    if (widget.assessmentType != null) {
      try {
        // Use the saveMCQAssessmentResult from the manager which handles both
        // saving the result AND marking the assessment as completed
        saved = await _prefsManager.saveMCQAssessmentResult(
          widget.assessmentType!,
          _questions,
          correctCount,
          wrongCount,
        );

        // Double-check that it's truly marked as completed
        if (saved) {
          final status = await _prefsManager.getAssessmentStatus(
            widget.assessmentType!,
          );
          if (status != AssessmentPreferencesManager.STATUS_COMPLETED) {
            // Explicitly mark as completed if the helper method didn't do it
            await _prefsManager.markAssessmentAsCompleted(
              widget.assessmentType!,
            );
          }
        }
      } catch (e) {
        debugPrint('Error saving assessment result: $e');
        // Handle error
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
          //
        ),
      );
    }

    // Return success to previous screen
    if (mounted && Navigator.canPop(context)) {
      Navigator.pop(context, true);
    }
  }

  @override
  void initState() {
    _questions = widget.questions!;

    // If assessmentType is provided, mark it as started (pending)
    if (widget.assessmentType != null) {
      _prefsManager.markAssessmentAsStarted(widget.assessmentType!);
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('MCQ Assessment'), centerTitle: true),
      body: _buildQuestionScreen(),
    );
  }

  Widget _buildQuestionScreen() {
    return Column(
      children: [
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
                style: const TextStyle(fontSize: 16),
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
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
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
                        child: RadioListTile<int>(
                          title: Text(question.options[optionIndex]),
                          value: optionIndex,
                          groupValue: question.selectedAnswerIndex,
                          onChanged: (value) {
                            setState(() {
                              question.selectedAnswerIndex = value;
                            });
                          },
                          activeColor: Colors.blue,
                          tileColor: Colors.grey[200],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          selected: question.selectedAnswerIndex == optionIndex,
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

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Previous Button
          ElevatedButton(
            onPressed:
                _currentQuestionIndex > 0
                    ? () {
                      _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                    : null,
            child: const Text('Previous'),
          ),

          // Question Navigation Indicators
          Expanded(
            child: SingleChildScrollView(
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
                      width: 28,
                      height: 28,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color:
                            _currentQuestionIndex == index
                                ? Colors.blue
                                : (_questions[index].isAnswered
                                    ? Colors.green
                                    : Colors.grey[300]),
                        shape: BoxShape.circle,
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
          ),

          // Next/Submit Button
          if (_currentQuestionIndex < _questions.length - 1)
            ElevatedButton(
              onPressed: () {
                _pageController.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
              child: const Text('Next'),
            )
          else
            ElevatedButton(
              onPressed:
                  _allQuestionsAnswered
                      ? () {
                        _generateJsonResultAndSave();
                        // Navigate back to previous screen after saving
                        if (widget.assessmentType != null) {
                          Navigator.of(context).pop();
                        }
                      }
                      : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _allQuestionsAnswered ? Colors.green : null,
              ),
              child: const Text('Submit'),
            ),
        ],
      ),
    );
  }
}
