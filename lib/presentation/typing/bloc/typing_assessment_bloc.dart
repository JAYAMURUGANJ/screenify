import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:screenify/domain/entities/questions_entity.dart';

import '../../../core/local/assessment_database_helper.dart';
import '../../dashboard/bloc/assessment_bloc.dart';
import '../../dashboard/bloc/assessment_event.dart';
import 'typing_assessment_state.dart';

// TypingAssessmentBloc
class TypingAssessmentBloc extends Cubit<TypingAssessmentState> {
  final AssessmentBloc assessmentBloc;
  final String candidateId;
  final AssessmentEntity typingData;
  DateTime? startTime;

  TypingAssessmentBloc({
    required this.assessmentBloc,
    required this.candidateId,
    required this.typingData,
  }) : super(
         TypingAssessmentState(
           typedText: '',
           isSubmitting: false,
           paragraph: typingData.paragraph ?? '',
           instructions: typingData.instructions,
           description: typingData.description,
           title: typingData.title,
         ),
       ) {
    // Initialize start time
    startTime = DateTime.now();

    // Mark assessment as started (pending)
    assessmentBloc.add(
      UpdateAssessmentStatusEvent(
        candidateId: candidateId,
        assessmentType: typingData.type,
        status: AssessmentDatabaseHelper.STATUS_PENDING,
      ),
    );
  }

  void updateTypedText(String text) {
    emit(state.copyWith(typedText: text));
  }

  void resetTest() {
    startTime = DateTime.now();
    emit(state.copyWith(typedText: '', isSubmitting: false));
  }

  void startSubmission() {
    emit(state.copyWith(isSubmitting: true));
  }

  Map<String, dynamic> calculateScore() {
    final String userTypedText = state.typedText.trim();
    final String sampleText = state.paragraph.trim();

    // Normalize and split words
    final List<String> typedWords =
        userTypedText
            .split(RegExp(r'\s+'))
            .where((word) => word.isNotEmpty)
            .toList();
    final List<String> referenceWords =
        sampleText
            .split(RegExp(r'\s+'))
            .where((word) => word.isNotEmpty)
            .toList();

    // Split texts into lines for line accuracy
    final List<String> typedLines = userTypedText.split('\n');
    final List<String> referenceLines = sampleText.split('\n');

    // Detailed analysis data structures
    int correctWords = 0;
    int errorCount = 0;
    int missingWords = 0;
    int extraWords = 0;

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

    // Handle missing words
    missingWords = referenceWords.length - minWordCount;
    if (missingWords > 0) {
      errorCount += missingWords;
    }

    // Handle extra words
    extraWords = typedWords.length - referenceWords.length;
    if (extraWords > 0) {
      // We don't need to add extra words to error count based on the original logic
    }

    // Calculate line-level analysis
    int correctLines = 0;
    final int minLineCount =
        typedLines.length < referenceLines.length
            ? typedLines.length
            : referenceLines.length;

    // Compare lines
    for (int i = 0; i < minLineCount; i++) {
      if (typedLines[i] == referenceLines[i]) {
        correctLines++;
      }
    }

    // Calculate task completion status
    final bool taskCompleted =
        typedWords.length >= referenceWords.length &&
        typedLines.length >= referenceLines.length;

    // Calculate accuracy metrics
    final double wordAccuracy =
        referenceWords.isEmpty
            ? 0.0
            : (correctWords / referenceWords.length) * 100;

    final double lineAccuracy =
        referenceLines.isEmpty
            ? 0.0
            : (correctLines / referenceLines.length) * 100;

    // Calculate overall accuracy (weighted: 70% words, 30% lines)
    final double overallAccuracy = (wordAccuracy * 0.7) + (lineAccuracy * 0.3);

    // Calculate typing speed (WPM)
    final int timeInSeconds = 31; // Fixed value as requested

    // Standard WPM calculation (5 characters = 1 word)
    final int standardWpm =
        timeInSeconds > 0
            ? ((userTypedText.length / 5) * 60 / timeInSeconds).round()
            : 0;

    // Actual WPM calculation based on real words
    final int actualWpm =
        timeInSeconds > 0
            ? ((typedWords.length * 60) / timeInSeconds).round()
            : 0;

    // Calculate errors per minute
    final double errorsPerMinute =
        timeInSeconds > 0 ? (errorCount * 60 / timeInSeconds) : 0;

    // Calculate weighted score out of 100
    final double score = _calculateScore(
      standardWpm,
      overallAccuracy,
      taskCompleted,
    );

    // Determine pass/fail status based on configurable thresholds
    final bool passed = _determinePassFail(
      standardWpm,
      overallAccuracy,
      taskCompleted,
      score,
    );

    // Generate skill assessment and feedback
    String skillLevel = _assessSkillLevel(standardWpm, overallAccuracy);
    String feedback = _generateFeedback(
      standardWpm,
      overallAccuracy,
      errorCount,
      missingWords,
      extraWords,
      passed,
      score,
    );

    // Current timestamp in ISO format
    final String currentTimestamp = DateTime.now().toIso8601String();

    // Prepare simplified result JSON with only the required keys
    final Map<String, dynamic> results = {
      "submissionDate": currentTimestamp,
      "completedAt": currentTimestamp,
      "skillLevel": skillLevel,
      "score": score,
      "scorePercentage": score,
      "passed": passed.toString(),
      "timeInSeconds": timeInSeconds,
      "feedback": feedback,
      "details": {
        "overallAccuracy": double.parse(overallAccuracy.toStringAsFixed(2)),
        "wordAccuracy": double.parse(wordAccuracy.toStringAsFixed(2)),
        "lineAccuracy": double.parse(lineAccuracy.toStringAsFixed(2)),
        "standardWpm": standardWpm,
        "actualWpm": actualWpm,
        "errorsPerMinute": double.parse(errorsPerMinute.toStringAsFixed(2)),
        "errorCount": errorCount,
        "correctWords": correctWords,
        "totalReferenceWords": referenceWords.length,
        "typedWordCount": typedWords.length,
        "missingWords": missingWords,
        "extraWords": extraWords,
        "taskCompleted": taskCompleted,
      },
    };

    return results;
  }

  // Helper function to assess typing skill level
  String _assessSkillLevel(int wpm, double accuracy) {
    if (wpm >= 80 && accuracy >= 98) {
      return 'Expert';
    } else if (wpm >= 60 && accuracy >= 96) {
      return 'Advanced';
    } else if (wpm >= 40 && accuracy >= 94) {
      return 'Intermediate';
    } else if (wpm >= 25 && accuracy >= 90) {
      return 'Basic';
    } else {
      return 'Beginner';
    }
  }

  // Helper function to calculate overall score
  double _calculateScore(int wpm, double accuracy, bool taskCompleted) {
    // Define maximum and minimum values for normalization
    const int maxWpm = 100; // WPM that would give full speed score
    const int minWpm = 10; // WPM below which speed score is zero
    const double maxAccuracy = 100.0; // Maximum possible accuracy

    // Calculate normalized speed score (0-50 points)
    double speedScore = 0.0;
    if (wpm >= maxWpm) {
      speedScore = 50.0;
    } else if (wpm > minWpm) {
      speedScore = ((wpm - minWpm) / (maxWpm - minWpm)) * 50.0;
    }

    // Calculate accuracy score (0-50 points)
    double accuracyScore = (accuracy / maxAccuracy) * 50.0;

    // Calculate combined score
    double combinedScore = speedScore + accuracyScore;

    // Apply task completion penalty if not completed
    if (!taskCompleted) {
      combinedScore *= 0.8; // 20% penalty for not completing the task
    }

    // Round to 1 decimal place and ensure score is between 0-100
    return double.parse((combinedScore.clamp(0.0, 100.0)).toStringAsFixed(1));
  }

  // Helper function to determine pass/fail status
  bool _determinePassFail(
    int wpm,
    double accuracy,
    bool taskCompleted,
    double score,
  ) {
    // Configurable thresholds
    const int minimumWpm = 30; // Minimum WPM to pass
    const double minimumAccuracy = 90.0; // Minimum accuracy percentage to pass
    const double minimumScore = 60.0; // Minimum overall score to pass

    // Must complete the task and meet minimum thresholds
    return taskCompleted &&
        wpm >= minimumWpm &&
        accuracy >= minimumAccuracy &&
        score >= minimumScore;
  }

  // Helper function to generate feedback based on performance
  String _generateFeedback(
    int wpm,
    double accuracy,
    int errorCount,
    int missingWords,
    int extraWords,
    bool passed,
    double score,
  ) {
    List<String> feedbackPoints = [];

    // Speed feedback
    if (wpm >= 80) {
      feedbackPoints.add('Your typing speed is excellent!');
    } else if (wpm >= 60) {
      feedbackPoints.add('Your typing speed is very good.');
    } else if (wpm >= 40) {
      feedbackPoints.add('Your typing speed is average.');
    } else if (wpm >= 25) {
      feedbackPoints.add('Your typing speed could use some improvement.');
    } else {
      feedbackPoints.add(
        'Focus on improving your typing speed with more practice.',
      );
    }

    // Accuracy feedback
    if (accuracy >= 98) {
      feedbackPoints.add('Your accuracy is exceptional.');
    } else if (accuracy >= 95) {
      feedbackPoints.add('Your accuracy is very good.');
    } else if (accuracy >= 90) {
      feedbackPoints.add('Your accuracy is acceptable.');
    } else {
      feedbackPoints.add('Work on improving your typing accuracy.');
    }

    // Error feedback
    if (errorCount > 0) {
      if (missingWords > 0) {
        feedbackPoints.add(
          'You missed $missingWords word${missingWords > 1 ? 's' : ''}.',
        );
      }

      if (extraWords > 0) {
        feedbackPoints.add(
          'You added $extraWords extra word${extraWords > 1 ? 's' : ''}.',
        );
      }

      if (errorCount > (missingWords + extraWords)) {
        int typos = errorCount - (missingWords + extraWords);
        feedbackPoints.add('You made $typos typo${typos > 1 ? 's' : ''}.');
      }
    }

    // Special case for perfect performance
    if (accuracy == 100 && wpm >= 60) {
      return 'Perfect performance! Score: $score. Both your speed and accuracy are excellent. You passed!';
    }

    // Add pass/fail result to feedback
    if (passed) {
      feedbackPoints.add('You passed the typing test with a score of $score!');
    } else {
      feedbackPoints.add(
        'You did not pass the test. Your score is $score. Please try again to meet the minimum requirements.',
      );
    }

    return feedbackPoints.join(' ');
  }

  Future<void> submitAssessment(Map<String, dynamic> results) async {
    emit(state.copyWith(isSubmitting: true, isCompleted: false));

    try {
      // Update assessment status to completed
      assessmentBloc.add(
        UpdateAssessmentStatusEvent(
          candidateId: candidateId,
          assessmentType: typingData.type,
          status: AssessmentDatabaseHelper.STATUS_COMPLETED,
        ),
      );

      // Save assessment results
      assessmentBloc.add(
        SaveAssessmentResultEvent(
          candidateId: candidateId,
          assessmentType: typingData.type,
          result: results,
        ),
      );

      emit(
        state.copyWith(
          isSubmitting: false,
          isCompleted: true,
          results: results,
        ),
      );
    } catch (e) {
      debugPrint('Error saving assessment results: $e');
      emit(
        state.copyWith(
          isSubmitting: false,
          error: 'Failed to save results: ${e.toString()}',
        ),
      );
    }
  }
}
