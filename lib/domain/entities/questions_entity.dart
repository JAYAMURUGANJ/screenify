class QuestionsEntity {
  final String status;
  final String? message;
  final String? candidateId;
  final String? candidateName;
  final List<AssessmentEntity>? assessments;

  QuestionsEntity({
    required this.status,
    this.candidateName,
    this.candidateId,
    this.assessments,
    this.message,
  });
}

class AssessmentEntity {
  final String type;
  final String title;
  final String description;
  final String icon;
  final String instructions;
  final String? paragraph;
  final String? expectedTo;
  final String? expectedCc;
  final String? expectedSubject;
  final List<String>? expectedKeywords;
  final List<String>? hints;
  final List<QuestionEntity>? questions;
  final EmploymentInfoEntity? employmentInfo;
  final List<String>? expectedFields;
  String status;

  AssessmentEntity({
    required this.type,
    required this.title,
    required this.description,
    required this.icon,
    required this.instructions,
    this.paragraph,
    this.expectedTo,
    this.expectedCc,
    this.expectedSubject,
    this.expectedKeywords,
    this.hints,
    this.questions,
    this.employmentInfo,
    this.expectedFields,
    required this.status,
  });

  AssessmentEntity copyWith({
    String? type,
    String? title,
    String? description,
    String? icon,
    String? instructions,
    String? paragraph,
    String? expectedTo,
    String? expectedCc,
    String? expectedSubject,
    List<String>? expectedKeywords,
    List<String>? hints,
    List<QuestionEntity>? questions,
    EmploymentInfoEntity? employmentInfo,
    List<String>? expectedFields,
    String? status,
  }) {
    return AssessmentEntity(
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      instructions: instructions ?? this.instructions,
      paragraph: paragraph ?? this.paragraph,
      expectedTo: expectedTo ?? this.expectedTo,
      expectedCc: expectedCc ?? this.expectedCc,
      expectedSubject: expectedSubject ?? this.expectedSubject,
      expectedKeywords: expectedKeywords ?? this.expectedKeywords,
      hints: hints ?? this.hints,
      questions: questions ?? this.questions,
      employmentInfo: employmentInfo ?? this.employmentInfo,
      expectedFields: expectedFields ?? this.expectedKeywords,
      status: status ?? this.status,
    );
  }
}

class QuestionEntity {
  final String question;
  final List<String> options;
  final int correctAnswerIndex;
  int? selectedAnswerIndex;

  QuestionEntity({
    this.selectedAnswerIndex,
    required this.question,
    required this.options,
    required this.correctAnswerIndex,
  });

  /// Computed property: whether user has answered
  bool get isAnswered => selectedAnswerIndex != null;

  /// Computed property: whether the selected answer is correct
  bool get isCorrect => selectedAnswerIndex == correctAnswerIndex;
}

class EmploymentInfoEntity {
  final String name;
  final String gender;
  final String basicPay;
  final String fatherHusbandName;
  final String dateOfBirth;
  final String designation;
  final String currentOffice;
  final String maritalStatus;
  final String dateOfRetirement;
  final String employmentStatus;
  final String dateOfAppointment;
  final String govtServiceDetails;
  final String incomeTaxDeptDetails;

  EmploymentInfoEntity({
    required this.name,
    required this.gender,
    required this.basicPay,
    required this.fatherHusbandName,
    required this.dateOfBirth,
    required this.designation,
    required this.currentOffice,
    required this.maritalStatus,
    required this.dateOfRetirement,
    required this.employmentStatus,
    required this.dateOfAppointment,
    required this.govtServiceDetails,
    required this.incomeTaxDeptDetails,
  });

  EmploymentInfoEntity copyWith({
    String? name,
    String? fatherHusbandName,
    String? designation,
    String? basicPay,
    String? gender,
    String? dateOfBirth,
    String? currentOffice,
    String? maritalStatus,
    String? dateOfRetirement,
    String? employmentStatus,
    String? dateOfAppointment,
    String? govtServiceDetails,
    String? incomeTaxDeptDetails,
  }) {
    return EmploymentInfoEntity(
      name: name ?? this.name,
      fatherHusbandName: fatherHusbandName ?? this.fatherHusbandName,
      designation: designation ?? this.designation,
      basicPay: basicPay ?? this.basicPay,
      gender: gender ?? this.gender,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      currentOffice: currentOffice ?? this.currentOffice,
      maritalStatus: maritalStatus ?? this.maritalStatus,
      dateOfRetirement: dateOfRetirement ?? this.dateOfRetirement,
      employmentStatus: employmentStatus ?? this.employmentStatus,
      dateOfAppointment: dateOfAppointment ?? this.dateOfAppointment,
      govtServiceDetails: govtServiceDetails ?? this.govtServiceDetails,
      incomeTaxDeptDetails: incomeTaxDeptDetails ?? this.incomeTaxDeptDetails,
    );
  }
}
