class AssessmentData {
  final List<Assessment> assessments;

  AssessmentData({required this.assessments});

  factory AssessmentData.fromJson(Map<String, dynamic> json) {
    return AssessmentData(
      assessments:
          (json['assessments'] as List<dynamic>?)
              ?.map((v) => Assessment.fromJson(v))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
    'assessments': assessments.map((v) => v.toJson()).toList(),
  };
}

class Assessment {
  final String type;
  final String title;
  final String description;
  final String? icon;
  final String? color;
  final String? route;
  final List<Question> questions;
  final String? instruction;
  final String? expectedTo;
  final String? expectedCc;
  final String? expectedSubject;
  final List<String> expectedKeywords;
  final List<String> hints;
  final String? instructions;
  final String? paragraph;
  String? status;

  Assessment({
    required this.type,
    required this.title,
    required this.description,
    this.icon,
    this.color,
    this.route,
    required this.questions,
    this.instruction,
    this.expectedTo,
    this.expectedCc,
    this.expectedSubject,
    this.expectedKeywords = const [],
    this.hints = const [],
    this.instructions,
    this.paragraph,
    this.status = 'not_opened',
  });

  factory Assessment.fromJson(Map<String, dynamic> json) {
    return Assessment(
      type: json['type'] ?? '',
      title: json['title'] ?? '',
      questions:
          (json['questions'] as List<dynamic>?)
              ?.map((v) => Question.fromJson(v))
              .toList() ??
          [],
      instruction: json['instruction'],
      expectedTo: json['expectedTo'],
      expectedCc: json['expectedCc'],
      expectedSubject: json['expectedSubject'],
      expectedKeywords: List<String>.from(json['expectedKeywords'] ?? []),
      hints: List<String>.from(json['hints'] ?? []),
      instructions: json['instructions'],
      paragraph: json['paragraph'],
      status: json['status'] ?? 'not_opened',
      description: json['description'] ?? '',
      icon: json['icon'],
      color: json['color'],
      route: json['route'],
    );
  }

  Map<String, dynamic> toJson() => {
    'type': type,
    'title': title,
    'description': description,
    'questions': questions.map((v) => v.toJson()).toList(),
    'instruction': instruction,
    'expectedTo': expectedTo,
    'expectedCc': expectedCc,
    'expectedSubject': expectedSubject,
    'expectedKeywords': expectedKeywords,
    'hints': hints,
    'instructions': instructions,
    'paragraph': paragraph,
    'status': status,
    'icon': icon,
    'color': color,
    'route': route,
  };
}

class Question {
  final String question;
  final List<String> options;
  final int correctAnswerIndex;
  int? selectedAnswerIndex;

  Question({
    required this.question,
    required this.options,
    required this.correctAnswerIndex,
    this.selectedAnswerIndex,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      question: json['question'] ?? '',
      options: List<String>.from(json['options'] ?? []),
      correctAnswerIndex: json['correctAnswerIndex'] ?? 0,
      selectedAnswerIndex: json['selectedAnswerIndex'],
    );
  }

  Map<String, dynamic> toJson() => {
    'question': question,
    'options': options,
    'correctAnswerIndex': correctAnswerIndex,
    'selectedAnswerIndex': selectedAnswerIndex,
  };

  /// Computed property: whether user has answered
  bool get isAnswered => selectedAnswerIndex != null;

  /// Computed property: whether the selected answer is correct
  bool get isCorrect => selectedAnswerIndex == correctAnswerIndex;
}
