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
  FormFields? formFields;
  EvaluationCriteria? evaluationCriteria;
  List<String>? expectedFields;

  Assessment({
    required this.type,
    required this.title,
    required this.description,
    this.icon,
    this.color,
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
    this.formFields,
    this.evaluationCriteria,
    this.expectedFields,
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
      formFields:
          json['formFields'] != null
              ? FormFields.fromJson(json['formFields'])
              : null,
      evaluationCriteria:
          json['evaluationCriteria'] != null
              ? EvaluationCriteria.fromJson(json['evaluationCriteria'])
              : null,
      expectedFields: List<String>.from(json['expectedFields'] ?? []),
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
    'formFields': formFields?.toJson(),
    'evaluationCriteria': evaluationCriteria?.toJson(),
    'expectedFields': expectedFields,
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

class FormFields {
  EmploymentInfo? employmentInfo;

  FormFields({this.employmentInfo});

  FormFields.fromJson(Map<String, dynamic> json) {
    employmentInfo =
        json['employmentInfo'] != null
            ? EmploymentInfo.fromJson(json['employmentInfo'])
            : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (employmentInfo != null) {
      data['employmentInfo'] = employmentInfo!.toJson();
    }
    return data;
  }
}

class EmploymentInfo {
  String? name;
  String? gender;
  String? maritalStatus;
  String? fatherName;
  String? dateOfBirth;
  bool? photoRequired;
  String? dateOfAppointment;
  String? govtServiceDetails;
  String? incomeTaxDeptDetails;
  String? dateOfRetirement;
  String? currentOffice;
  String? designation;
  String? employmentStatus;
  String? basicPay;

  EmploymentInfo({
    this.name,
    this.gender,
    this.maritalStatus,
    this.fatherName,
    this.dateOfBirth,
    this.photoRequired,
    this.dateOfAppointment,
    this.govtServiceDetails,
    this.incomeTaxDeptDetails,
    this.dateOfRetirement,
    this.currentOffice,
    this.designation,
    this.employmentStatus,
    this.basicPay,
  });

  EmploymentInfo.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    gender = json['gender'];
    maritalStatus = json['maritalStatus'];
    fatherName = json['fatherName'];
    dateOfBirth = json['dateOfBirth'];
    photoRequired = json['photoRequired'];
    dateOfAppointment = json['dateOfAppointment'];
    govtServiceDetails = json['govtServiceDetails'];
    incomeTaxDeptDetails = json['incomeTaxDeptDetails'];
    dateOfRetirement = json['dateOfRetirement'];
    currentOffice = json['currentOffice'];
    designation = json['designation'];
    employmentStatus = json['employmentStatus'];
    basicPay = json['basicPay'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['gender'] = gender;
    data['maritalStatus'] = maritalStatus;
    data['fatherName'] = fatherName;
    data['dateOfBirth'] = dateOfBirth;
    data['photoRequired'] = photoRequired;
    data['dateOfAppointment'] = dateOfAppointment;
    data['govtServiceDetails'] = govtServiceDetails;
    data['incomeTaxDeptDetails'] = incomeTaxDeptDetails;
    data['dateOfRetirement'] = dateOfRetirement;
    data['currentOffice'] = currentOffice;
    data['designation'] = designation;
    data['employmentStatus'] = employmentStatus;
    data['basicPay'] = basicPay;
    return data;
  }
}

class EvaluationCriteria {
  String? completeness;
  String? accuracy;
  String? formatAdherence;
  String? attention;

  EvaluationCriteria({
    this.completeness,
    this.accuracy,
    this.formatAdherence,
    this.attention,
  });

  EvaluationCriteria.fromJson(Map<String, dynamic> json) {
    completeness = json['completeness'];
    accuracy = json['accuracy'];
    formatAdherence = json['formatAdherence'];
    attention = json['attention'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['completeness'] = completeness;
    data['accuracy'] = accuracy;
    data['formatAdherence'] = formatAdherence;
    data['attention'] = attention;
    return data;
  }
}
