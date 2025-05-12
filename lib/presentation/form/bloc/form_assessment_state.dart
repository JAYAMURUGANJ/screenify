// FormFillingAssessmentState
class FormFillingAssessmentState {
  final bool isSubmitting;
  final bool isCompleted;
  final String instructions;
  final String description;
  final String title;
  final Map<String, dynamic>? results;
  final String? error;
  final dynamic employmentInfo;

  const FormFillingAssessmentState({
    required this.isSubmitting,
    required this.instructions,
    required this.description,
    required this.title,
    this.isCompleted = false,
    this.results,
    this.error,
    this.employmentInfo,
  });

  FormFillingAssessmentState copyWith({
    bool? isSubmitting,
    bool? isCompleted,
    String? instructions,
    String? description,
    String? title,
    Map<String, dynamic>? results,
    String? error,
    dynamic employmentInfo,
  }) {
    return FormFillingAssessmentState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isCompleted: isCompleted ?? this.isCompleted,
      instructions: instructions ?? this.instructions,
      description: description ?? this.description,
      title: title ?? this.title,
      results: results ?? this.results,
      error: error ?? this.error,
      employmentInfo: employmentInfo ?? this.employmentInfo,
    );
  }
}
