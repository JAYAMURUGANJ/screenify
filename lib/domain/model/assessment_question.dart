class AssessmentQuestions {
  final List<Assessment> assessments;

  AssessmentQuestions({required this.assessments});

  factory AssessmentQuestions.fromJson(Map<String, dynamic> json) {
    return AssessmentQuestions(
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

  AssessmentQuestions copyWith({List<Assessment>? assessments}) {
    return AssessmentQuestions(assessments: assessments ?? this.assessments);
  }
}

class Assessment {
  final String type;
  final String title;
  final String description;
  final String? icon;
  final List<Question> questions;
  final String? expectedTo;
  final String? expectedCc;
  final String? expectedSubject;
  final List<String> expectedKeywords;
  final List<String> hints;
  final String? instructions;
  final String? paragraph;
  String status; // made non-final
  final EmploymentInfo? employmentInfo;
  final List<String>? expectedFields;

  Assessment({
    required this.type,
    required this.title,
    required this.description,
    this.icon,
    required this.questions,
    this.expectedTo,
    this.expectedCc,
    this.expectedSubject,
    this.expectedKeywords = const [],
    this.hints = const [],
    this.instructions,
    this.paragraph,
    this.status = 'not_opened',
    this.employmentInfo,
    this.expectedFields,
  });

  factory Assessment.fromJson(Map<String, dynamic> json) {
    return Assessment(
      type: json['type'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      icon: json['icon'],
      questions:
          (json['questions'] as List<dynamic>?)
              ?.map((v) => Question.fromJson(v))
              .toList() ??
          [],
      expectedTo: json['expectedTo'],
      expectedCc: json['expectedCc'],
      expectedSubject: json['expectedSubject'],
      expectedKeywords: List<String>.from(json['expectedKeywords'] ?? []),
      hints: List<String>.from(json['hints'] ?? []),
      instructions: json['instructions'],
      paragraph: json['paragraph'],
      status: json['status'] ?? 'not_opened',
      employmentInfo:
          json['employmentInfo'] != null
              ? EmploymentInfo.fromJson(json['employmentInfo'])
              : null,

      expectedFields:
          (json['expectedFields'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'type': type,
    'title': title,
    'description': description,
    'icon': icon,
    'questions': questions.map((v) => v.toJson()).toList(),
    'expectedTo': expectedTo,
    'expectedCc': expectedCc,
    'expectedSubject': expectedSubject,
    'expectedKeywords': expectedKeywords,
    'hints': hints,
    'instructions': instructions,
    'paragraph': paragraph,
    'status': status,
    'employmentInfo': employmentInfo!.toJson(),
    'expectedFields': expectedFields,
  };

  Assessment copyWith({
    String? type,
    String? title,
    String? description,
    String? icon,
    List<Question>? questions,
    String? expectedTo,
    String? expectedCc,
    String? expectedSubject,
    List<String>? expectedKeywords,
    List<String>? hints,
    String? instructions,
    String? paragraph,
    String? status,
    EmploymentInfo? employmentInfo,
    List<String>? expectedFields,
  }) {
    return Assessment(
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      questions: questions ?? this.questions,
      expectedTo: expectedTo ?? this.expectedTo,
      expectedCc: expectedCc ?? this.expectedCc,
      expectedSubject: expectedSubject ?? this.expectedSubject,
      expectedKeywords: expectedKeywords ?? this.expectedKeywords,
      hints: hints ?? this.hints,
      instructions: instructions ?? this.instructions,
      paragraph: paragraph ?? this.paragraph,
      status: status ?? this.status,
      employmentInfo: employmentInfo ?? this.employmentInfo,
      expectedFields: expectedFields ?? this.expectedFields,
    );
  }
}

class Question {
  final String question;
  final List<String> options;
  final int correctAnswerIndex;
  int? selectedAnswerIndex; // made non-final

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

  Question copyWith({
    String? question,
    List<String>? options,
    int? correctAnswerIndex,
    int? selectedAnswerIndex,
  }) {
    return Question(
      question: question ?? this.question,
      options: options ?? this.options,
      correctAnswerIndex: correctAnswerIndex ?? this.correctAnswerIndex,
      selectedAnswerIndex: selectedAnswerIndex ?? this.selectedAnswerIndex,
    );
  }
}

class EmploymentInfo {
  final String? name;
  final String? gender;
  final String? maritalStatus;
  final String? fatherName;
  final String? dateOfBirth;
  final bool? photoRequired;
  final String? dateOfAppointment;
  final String? govtServiceDetails;
  final String? incomeTaxDeptDetails;
  final String? dateOfRetirement;
  final String? currentOffice;
  final String? designation;
  final String? employmentStatus;
  final String? basicPay;

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

  factory EmploymentInfo.fromJson(Map<String, dynamic> json) {
    return EmploymentInfo(
      name: json['name'],
      gender: json['gender'],
      maritalStatus: json['maritalStatus'],
      fatherName: json['fatherName'],
      dateOfBirth: json['dateOfBirth'],
      photoRequired: json['photoRequired'],
      dateOfAppointment: json['dateOfAppointment'],
      govtServiceDetails: json['govtServiceDetails'],
      incomeTaxDeptDetails: json['incomeTaxDeptDetails'],
      dateOfRetirement: json['dateOfRetirement'],
      currentOffice: json['currentOffice'],
      designation: json['designation'],
      employmentStatus: json['employmentStatus'],
      basicPay: json['basicPay'],
    );
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

  EmploymentInfo copyWith({
    String? name,
    String? gender,
    String? maritalStatus,
    String? fatherName,
    String? dateOfBirth,
    bool? photoRequired,
    String? dateOfAppointment,
    String? govtServiceDetails,
    String? incomeTaxDeptDetails,
    String? dateOfRetirement,
    String? currentOffice,
    String? designation,
    String? employmentStatus,
    String? basicPay,
  }) {
    return EmploymentInfo(
      name: name ?? this.name,
      gender: gender ?? this.gender,
      maritalStatus: maritalStatus ?? this.maritalStatus,
      fatherName: fatherName ?? this.fatherName,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      photoRequired: photoRequired ?? this.photoRequired,
      dateOfAppointment: dateOfAppointment ?? this.dateOfAppointment,
      govtServiceDetails: govtServiceDetails ?? this.govtServiceDetails,
      incomeTaxDeptDetails: incomeTaxDeptDetails ?? this.incomeTaxDeptDetails,
      dateOfRetirement: dateOfRetirement ?? this.dateOfRetirement,
      currentOffice: currentOffice ?? this.currentOffice,
      designation: designation ?? this.designation,
      employmentStatus: employmentStatus ?? this.employmentStatus,
      basicPay: basicPay ?? this.basicPay,
    );
  }
}
