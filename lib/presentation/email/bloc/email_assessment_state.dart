// EmailAssessmentState
class EmailAssessmentState {
  final String to;
  final String cc;
  final String subject;
  final String body;
  final bool isSubmitting;
  final bool isCompleted;
  final EmailScenario scenario;
  final Map<String, dynamic>? results;
  final String? error;

  const EmailAssessmentState({
    required this.to,
    required this.cc,
    required this.subject,
    required this.body,
    required this.isSubmitting,
    required this.scenario,
    this.isCompleted = false,
    this.results,
    this.error,
  });

  EmailAssessmentState copyWith({
    String? to,
    String? cc,
    String? subject,
    String? body,
    bool? isSubmitting,
    bool? isCompleted,
    EmailScenario? scenario,
    Map<String, dynamic>? results,
    String? error,
  }) {
    return EmailAssessmentState(
      to: to ?? this.to,
      cc: cc ?? this.cc,
      subject: subject ?? this.subject,
      body: body ?? this.body,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isCompleted: isCompleted ?? this.isCompleted,
      scenario: scenario ?? this.scenario,
      results: results ?? this.results,
      error: error ?? this.error,
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
