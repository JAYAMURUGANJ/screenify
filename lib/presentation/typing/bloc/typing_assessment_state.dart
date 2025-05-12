// TypingAssessmentState
class TypingAssessmentState {
  final String typedText;
  final bool isSubmitting;
  final bool isCompleted;
  final String sampleText;
  final String instructions;
  final String description;
  final String title;
  final Map<String, dynamic>? results;
  final String? error;

  const TypingAssessmentState({
    required this.typedText,
    required this.isSubmitting,
    required this.sampleText,
    required this.instructions,
    required this.description,
    required this.title,
    this.isCompleted = false,
    this.results,
    this.error,
  });

  TypingAssessmentState copyWith({
    String? typedText,
    bool? isSubmitting,
    bool? isCompleted,
    String? sampleText,
    String? instructions,
    String? description,
    String? title,
    Map<String, dynamic>? results,
    String? error,
  }) {
    return TypingAssessmentState(
      typedText: typedText ?? this.typedText,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isCompleted: isCompleted ?? this.isCompleted,
      sampleText: sampleText ?? this.sampleText,
      instructions: instructions ?? this.instructions,
      description: description ?? this.description,
      title: title ?? this.title,
      results: results ?? this.results,
      error: error ?? this.error,
    );
  }
}
