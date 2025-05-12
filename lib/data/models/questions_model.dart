// File: data/models/questions_model.dart
import '../../domain/entities/questions_entity.dart';

class QuestionsModel extends QuestionsEntity {
  QuestionsModel({
    required super.status,
    required super.candidateId,
    required super.candidateName,
    required List<AssessmentModel> super.assessments,
  });

  factory QuestionsModel.fromJson(Map<String, dynamic> json) {
    return QuestionsModel(
      status: json['status'],
      candidateId: json['candidate_id'],
      candidateName: json['candidate_name'],
      assessments:
          (json['assessments'] as List)
              .map((e) => AssessmentModel.fromJson(e))
              .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'candidate_id': candidateId,
      'candidate_name': candidateName,
      'assessments':
          (assessments as List<AssessmentModel>)
              .map((e) => e.toJson())
              .toList(),
    };
  }
}

class AssessmentModel extends AssessmentEntity {
  AssessmentModel({
    required super.type,
    required super.title,
    required super.description,
    required super.icon,
    required super.instructions,
    super.paragraph,
    super.expectedTo,
    super.expectedCc,
    super.expectedSubject,
    super.expectedKeywords,
    super.hints,
    List<QuestionModel>? questions,
    EmploymentInfoModel? employmentInfo,
    super.expectedFields,
    required super.status,
  }) : super(questions: questions);

  factory AssessmentModel.fromJson(Map<String, dynamic> json) {
    return AssessmentModel(
      type: json['type'],
      title: json['title'],
      description: json['description'],
      icon: json['icon'],
      instructions: json['instructions'],
      paragraph: json['paragraph'],
      expectedTo: json['expectedTo'],
      expectedCc: json['expectedCc'],
      expectedSubject: json['expectedSubject'],
      expectedKeywords:
          json['expectedKeywords'] != null
              ? List<String>.from(json['expectedKeywords'])
              : null,
      hints: json['hints'] != null ? List<String>.from(json['hints']) : null,
      questions:
          json['questions'] != null
              ? (json['questions'] as List)
                  .map((e) => QuestionModel.fromJson(e))
                  .toList()
              : null,
      employmentInfo:
          json['employmentInfo'] != null
              ? EmploymentInfoModel.fromJson(json['employmentInfo'])
              : null,
      expectedFields:
          json['expectedFields'] != null
              ? List<String>.from(json['expectedFields'])
              : null,
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'type': type,
      'title': title,
      'description': description,
      'icon': icon,
      'instructions': instructions,
      'status': status,
    };

    if (paragraph != null) data['paragraph'] = paragraph;
    if (expectedTo != null) data['expectedTo'] = expectedTo;
    if (expectedCc != null) data['expectedCc'] = expectedCc;
    if (expectedSubject != null) data['expectedSubject'] = expectedSubject;
    if (expectedKeywords != null) data['expectedKeywords'] = expectedKeywords;
    if (hints != null) data['hints'] = hints;
    if (questions != null) {
      data['questions'] =
          (questions as List<QuestionModel>).map((e) => e.toJson()).toList();
    }
    if (employmentInfo != null) {
      data['employmentInfo'] = employmentInfo;
    }
    if (expectedFields != null) {
      data['expectedFields'] = expectedFields;
    }

    return data;
  }
}

class QuestionModel extends QuestionEntity {
  QuestionModel({
    required super.question,
    required super.options,
    required super.correctAnswerIndex,
    super.selectedAnswerIndex,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    return QuestionModel(
      question: json['question'],
      options: List<String>.from(json['options']),
      correctAnswerIndex: json['correctAnswerIndex'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'question': question,
      'options': options,
      'correctAnswerIndex': correctAnswerIndex,
    };

    if (selectedAnswerIndex != null) {
      data['selectedAnswerIndex'] = selectedAnswerIndex;
    }

    return data;
  }
}

class EmploymentInfoModel extends EmploymentInfoEntity {
  EmploymentInfoModel({
    required super.name,
    required super.fatherHusbandName,

    required super.designation,
    required super.basicPay,
    required super.gender,
    required super.dateOfBirth,
    required super.currentOffice,
    required super.maritalStatus,
    required super.dateOfRetirement,
    required super.employmentStatus,
    required super.dateOfAppointment,
    required super.govtServiceDetails,
    required super.incomeTaxDeptDetails,
  });

  factory EmploymentInfoModel.fromJson(Map<String, dynamic> json) {
    return EmploymentInfoModel(
      name: json['name'],
      fatherHusbandName: json['fatherHusbandName'],
      designation: json['designation'],
      basicPay: json['basicPay'],
      gender: json['gender'],
      dateOfBirth: json['dateOfBirth'],
      currentOffice: json['currentOffice'],
      maritalStatus: json['maritalStatus'],
      dateOfRetirement: json['dateOfRetirement'],
      employmentStatus: json['employmentStatus'],
      dateOfAppointment: json['dateOfAppointment'],
      govtServiceDetails: json['govtServiceDetails'],
      incomeTaxDeptDetails: json['incomeTaxDeptDetails'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'fatherHusbandName': fatherHusbandName,
      'designation': designation,
      'basicPay': basicPay,
      'gender': gender,
      'dateOfBirth': dateOfBirth,
      'currentOffice': currentOffice,
      'maritalStatus': maritalStatus,
      'dateOfRetirement': dateOfRetirement,
      'employmentStatus': employmentStatus,
      'dateOfAppointment': dateOfAppointment,
      'govtServiceDetails': govtServiceDetails,
      'incomeTaxDeptDetails': incomeTaxDeptDetails,
    };
  }
}
