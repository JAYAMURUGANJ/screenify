class AssessmentResult {
  String? candidateId;
  String? dateTime;
  Status? status;
  Assessment? assessment;

  AssessmentResult({
    this.candidateId,
    this.dateTime,
    this.status,
    this.assessment,
  });

  AssessmentResult.fromJson(Map<String, dynamic> json) {
    candidateId = json['candidateId'];
    dateTime = json['date_time'];
    status = json['status'] != null ? Status.fromJson(json['status']) : null;
    assessment =
        json['assessment'] != null
            ? Assessment.fromJson(json['assessment'])
            : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['candidateId'] = candidateId;
    data['date_time'] = dateTime;
    if (status != null) {
      data['status'] = status!.toJson();
    }
    if (assessment != null) {
      data['assessment'] = assessment!.toJson();
    }
    return data;
  }
}

class Status {
  String? email;
  String? form;
  String? mCQ;
  String? typing;

  Status({this.email, this.form, this.mCQ, this.typing});

  Status.fromJson(Map<String, dynamic> json) {
    email = json['Email'];
    form = json['Form'];
    mCQ = json['MCQ'];
    typing = json['Typing'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Email'] = email;
    data['Form'] = form;
    data['MCQ'] = mCQ;
    data['Typing'] = typing;
    return data;
  }
}

class Assessment {
  Email? email;
  Form? form;
  MCQ? mCQ;
  Typing? typing;

  Assessment({this.email, this.form, this.mCQ, this.typing});

  Assessment.fromJson(Map<String, dynamic> json) {
    email = json['Email'] != null ? Email.fromJson(json['Email']) : null;
    form = json['Form'] != null ? Form.fromJson(json['Form']) : null;
    mCQ = json['MCQ'] != null ? MCQ.fromJson(json['MCQ']) : null;
    typing = json['Typing'] != null ? Typing.fromJson(json['Typing']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (email != null) {
      data['Email'] = email!.toJson();
    }
    if (form != null) {
      data['Form'] = form!.toJson();
    }
    if (mCQ != null) {
      data['MCQ'] = mCQ!.toJson();
    }
    if (typing != null) {
      data['Typing'] = typing!.toJson();
    }
    return data;
  }
}

class Email {
  int? accuracy;
  int? timeInSeconds;
  int? errorCount;
  int? totalPoints;
  int? earnedPoints;
  String? submittedTo;
  String? submittedCc;
  String? submittedSubject;
  String? submittedBody;
  String? expectedTo;
  String? expectedCc;
  String? expectedSubject;
  List<String>? expectedKeywords;
  bool? hasGreeting;
  bool? hasSignature;
  String? completedAt;

  Email({
    this.accuracy,
    this.timeInSeconds,
    this.errorCount,
    this.totalPoints,
    this.earnedPoints,
    this.submittedTo,
    this.submittedCc,
    this.submittedSubject,
    this.submittedBody,
    this.expectedTo,
    this.expectedCc,
    this.expectedSubject,
    this.expectedKeywords,
    this.hasGreeting,
    this.hasSignature,
    this.completedAt,
  });

  Email.fromJson(Map<String, dynamic> json) {
    accuracy = json['accuracy'];
    timeInSeconds = json['timeInSeconds'];
    errorCount = json['errorCount'];
    totalPoints = json['totalPoints'];
    earnedPoints = json['earnedPoints'];
    submittedTo = json['submittedTo'];
    submittedCc = json['submittedCc'];
    submittedSubject = json['submittedSubject'];
    submittedBody = json['submittedBody'];
    expectedTo = json['expectedTo'];
    expectedCc = json['expectedCc'];
    expectedSubject = json['expectedSubject'];
    expectedKeywords = json['expectedKeywords'].cast<String>();
    hasGreeting = json['hasGreeting'];
    hasSignature = json['hasSignature'];
    completedAt = json['completedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['accuracy'] = accuracy;
    data['timeInSeconds'] = timeInSeconds;
    data['errorCount'] = errorCount;
    data['totalPoints'] = totalPoints;
    data['earnedPoints'] = earnedPoints;
    data['submittedTo'] = submittedTo;
    data['submittedCc'] = submittedCc;
    data['submittedSubject'] = submittedSubject;
    data['submittedBody'] = submittedBody;
    data['expectedTo'] = expectedTo;
    data['expectedCc'] = expectedCc;
    data['expectedSubject'] = expectedSubject;
    data['expectedKeywords'] = expectedKeywords;
    data['hasGreeting'] = hasGreeting;
    data['hasSignature'] = hasSignature;
    data['completedAt'] = completedAt;
    return data;
  }
}

class Form {
  String? submissionDate;
  FormDetails? formDetails;
  Validation? validation;
  String? status;

  Form({this.submissionDate, this.formDetails, this.validation, this.status});

  Form.fromJson(Map<String, dynamic> json) {
    submissionDate = json['submissionDate'];
    formDetails =
        json['formDetails'] != null
            ? FormDetails.fromJson(json['formDetails'])
            : null;
    validation =
        json['validation'] != null
            ? Validation.fromJson(json['validation'])
            : null;
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['submissionDate'] = submissionDate;
    if (formDetails != null) {
      data['formDetails'] = formDetails!.toJson();
    }
    if (validation != null) {
      data['validation'] = validation!.toJson();
    }
    data['status'] = status;
    return data;
  }
}

class FormDetails {
  String? name;
  String? gender;
  String? maritalStatus;
  String? fatherHusbandName;
  String? dob;
  String? appointmentDate;
  String? govtService;
  String? incomeTaxDept;
  String? retirementDate;
  String? office;
  String? designation;
  String? employmentStatus;
  String? basicPay;

  FormDetails({
    this.name,
    this.gender,
    this.maritalStatus,
    this.fatherHusbandName,
    this.dob,
    this.appointmentDate,
    this.govtService,
    this.incomeTaxDept,
    this.retirementDate,
    this.office,
    this.designation,
    this.employmentStatus,
    this.basicPay,
  });

  FormDetails.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    gender = json['gender'];
    maritalStatus = json['maritalStatus'];
    fatherHusbandName = json['fatherHusbandName'];
    dob = json['dob'];
    appointmentDate = json['appointmentDate'];
    govtService = json['govtService'];
    incomeTaxDept = json['incomeTaxDept'];
    retirementDate = json['retirementDate'];
    office = json['office'];
    designation = json['designation'];
    employmentStatus = json['employmentStatus'];
    basicPay = json['basicPay'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['gender'] = gender;
    data['maritalStatus'] = maritalStatus;
    data['fatherHusbandName'] = fatherHusbandName;
    data['dob'] = dob;
    data['appointmentDate'] = appointmentDate;
    data['govtService'] = govtService;
    data['incomeTaxDept'] = incomeTaxDept;
    data['retirementDate'] = retirementDate;
    data['office'] = office;
    data['designation'] = designation;
    data['employmentStatus'] = employmentStatus;
    data['basicPay'] = basicPay;
    return data;
  }
}

class Validation {
  int? score;
  int? totalFields;
  int? correctFields;
  List<String>? mismatchFields;

  Validation({
    this.score,
    this.totalFields,
    this.correctFields,
    this.mismatchFields,
  });

  Validation.fromJson(Map<String, dynamic> json) {
    score = json['score'];
    totalFields = json['totalFields'];
    correctFields = json['correctFields'];
    mismatchFields = json['mismatchFields'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['score'] = score;
    data['totalFields'] = totalFields;
    data['correctFields'] = correctFields;
    data['mismatchFields'] = mismatchFields;
    return data;
  }
}

class MCQ {
  int? totalQuestions;
  int? correctCount;
  int? wrongCount;
  int? score;
  String? scorePercentage;
  List<Questions>? questions;
  int? timeInSeconds;
  String? completedAt;

  MCQ({
    this.totalQuestions,
    this.correctCount,
    this.wrongCount,
    this.score,
    this.scorePercentage,
    this.questions,
    this.timeInSeconds,
    this.completedAt,
  });

  MCQ.fromJson(Map<String, dynamic> json) {
    totalQuestions = json['totalQuestions'];
    correctCount = json['correctCount'];
    wrongCount = json['wrongCount'];
    score = json['score'];
    scorePercentage = json['scorePercentage'];
    if (json['questions'] != null) {
      questions = <Questions>[];
      json['questions'].forEach((v) {
        questions!.add(Questions.fromJson(v));
      });
    }
    timeInSeconds = json['timeInSeconds'];
    completedAt = json['completedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['totalQuestions'] = totalQuestions;
    data['correctCount'] = correctCount;
    data['wrongCount'] = wrongCount;
    data['score'] = score;
    data['scorePercentage'] = scorePercentage;
    if (questions != null) {
      data['questions'] = questions!.map((v) => v.toJson()).toList();
    }
    data['timeInSeconds'] = timeInSeconds;
    data['completedAt'] = completedAt;
    return data;
  }
}

class Questions {
  String? question;
  int? selectedAnswerIndex;
  int? correctAnswerIndex;
  bool? isCorrect;

  Questions({
    this.question,
    this.selectedAnswerIndex,
    this.correctAnswerIndex,
    this.isCorrect,
  });

  Questions.fromJson(Map<String, dynamic> json) {
    question = json['question'];
    selectedAnswerIndex = json['selectedAnswerIndex'];
    correctAnswerIndex = json['correctAnswerIndex'];
    isCorrect = json['isCorrect'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['question'] = question;
    data['selectedAnswerIndex'] = selectedAnswerIndex;
    data['correctAnswerIndex'] = correctAnswerIndex;
    data['isCorrect'] = isCorrect;
    return data;
  }
}

class Typing {
  int? accuracy;
  int? timeInSeconds;
  int? typingSpeed;
  int? errorCount;
  int? correctWords;
  int? totalWords;
  int? typedWords;
  String? submittedText;
  String? referenceText;
  bool? taskCompleted;
  String? completedAt;

  Typing({
    this.accuracy,
    this.timeInSeconds,
    this.typingSpeed,
    this.errorCount,
    this.correctWords,
    this.totalWords,
    this.typedWords,
    this.submittedText,
    this.referenceText,
    this.taskCompleted,
    this.completedAt,
  });

  Typing.fromJson(Map<String, dynamic> json) {
    accuracy = json['accuracy'];
    timeInSeconds = json['timeInSeconds'];
    typingSpeed = json['typingSpeed'];
    errorCount = json['errorCount'];
    correctWords = json['correctWords'];
    totalWords = json['totalWords'];
    typedWords = json['typedWords'];
    submittedText = json['submittedText'];
    referenceText = json['referenceText'];
    taskCompleted = json['taskCompleted'];
    completedAt = json['completedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['accuracy'] = accuracy;
    data['timeInSeconds'] = timeInSeconds;
    data['typingSpeed'] = typingSpeed;
    data['errorCount'] = errorCount;
    data['correctWords'] = correctWords;
    data['totalWords'] = totalWords;
    data['typedWords'] = typedWords;
    data['submittedText'] = submittedText;
    data['referenceText'] = referenceText;
    data['taskCompleted'] = taskCompleted;
    data['completedAt'] = completedAt;
    return data;
  }
}
