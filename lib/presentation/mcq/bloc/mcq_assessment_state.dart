import 'package:screenify/domain/entities/questions_entity.dart';

class McqAssessmentState {
  final int currentQuestionIndex;
  final List<QuestionEntity> questions;
  final bool isSubmitting;
  final bool isCompleted;
  final int? score;
  final Map<String, dynamic>? result;

  const McqAssessmentState({
    required this.currentQuestionIndex,
    required this.questions,
    required this.isSubmitting,
    this.isCompleted = false,
    this.score,
    this.result,
  });

  bool get allQuestionsAnswered {
    return questions.every((question) => question.isAnswered);
  }

  int get answeredCount {
    return questions.where((question) => question.isAnswered).length;
  }

  McqAssessmentState copyWith({
    int? currentQuestionIndex,
    List<QuestionEntity>? questions,
    bool? isSubmitting,
    bool? isCompleted,
    int? score,
    Map<String, dynamic>? result,
  }) {
    return McqAssessmentState(
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      questions: questions ?? this.questions,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isCompleted: isCompleted ?? this.isCompleted,
      score: score ?? this.score,
      result: result ?? this.result,
    );
  }
}
