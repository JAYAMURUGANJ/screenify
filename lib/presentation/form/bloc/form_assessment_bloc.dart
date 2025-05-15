import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:screenify/domain/entities/questions_entity.dart';

import '../../../core/local/assessment_database_helper.dart';
import '../../dashboard/bloc/assessment_bloc.dart';
import '../../dashboard/bloc/assessment_event.dart';
import 'form_assessment_state.dart';

// FormFillingAssessmentBloc
class FormFillingAssessmentBloc extends Cubit<FormFillingAssessmentState> {
  final AssessmentBloc assessmentBloc;
  final String candidateId;
  final AssessmentEntity formFillingData;

  FormFillingAssessmentBloc({
    required this.assessmentBloc,
    required this.candidateId,
    required this.formFillingData,
  }) : super(
         FormFillingAssessmentState(
           isSubmitting: false,
           instructions: formFillingData.instructions,
           description: formFillingData.description,
           title: formFillingData.title,
           employmentInfo: formFillingData.employmentInfo,
         ),
       ) {
    // Mark assessment as started (pending)
    assessmentBloc.add(
      UpdateAssessmentStatusEvent(
        candidateId: candidateId,
        assessmentType: formFillingData.type,
        status: AssessmentDatabaseHelper.STATUS_PENDING,
      ),
    );
  }

  // Form field controllers
  TextEditingController nameController = TextEditingController();
  TextEditingController fatherHusbandNameController = TextEditingController();
  TextEditingController dobController = TextEditingController();
  TextEditingController appointmentDateController = TextEditingController();
  TextEditingController govtServiceController = TextEditingController();
  TextEditingController incomeTaxDeptController = TextEditingController();
  TextEditingController retirementDateController = TextEditingController();
  TextEditingController officeController = TextEditingController();
  TextEditingController designationController = TextEditingController();
  TextEditingController basicPayController = TextEditingController();

  // Dropdown values
  String selectedGender = 'Male';
  String maritalStatus = 'Yes';
  String employmentStatus = 'Permanent';

  void updateGender(String value) {
    selectedGender = value;
    emit(state.copyWith());
  }

  void updateMaritalStatus(String value) {
    maritalStatus = value;
    emit(state.copyWith());
  }

  void updateEmploymentStatus(String value) {
    employmentStatus = value;
    emit(state.copyWith());
  }

  void resetForm() {
    nameController.clear();
    fatherHusbandNameController.clear();
    dobController.clear();
    appointmentDateController.clear();
    govtServiceController.clear();
    incomeTaxDeptController.clear();
    retirementDateController.clear();
    officeController.clear();
    designationController.clear();
    basicPayController.clear();
    selectedGender = 'Male';
    maritalStatus = 'Yes';
    employmentStatus = 'Permanent';

    emit(state.copyWith(isSubmitting: false));
  }

  Map<String, dynamic> calculateScore() {
    List<String> emptyFields = [];
    int totalFields = 13; // Total number of fields to validate
    int correctCount = 0;

    // Check for empty fields first
    if (nameController.text.trim().isEmpty) {
      emptyFields.add('Name');
    } else {
      correctCount++; // Count non-empty name as correct
    }

    if (fatherHusbandNameController.text.trim().isEmpty) {
      emptyFields.add('Father\'s/Husband\'s Name');
    } else {
      correctCount++; // Count non-empty father/husband name as correct
    }

    if (dobController.text.trim().isEmpty) {
      emptyFields.add('Date of Birth');
    } else {
      correctCount++; // Count non-empty DOB as correct
    }

    if (appointmentDateController.text.trim().isEmpty) {
      emptyFields.add('Date of Appointment');
    } else {
      correctCount++; // Count non-empty appointment date as correct
    }

    if (retirementDateController.text.trim().isEmpty) {
      emptyFields.add('Date of Retirement');
    } else {
      correctCount++; // Count non-empty retirement date as correct
    }

    if (officeController.text.trim().isEmpty) {
      emptyFields.add('Current Office');
    } else {
      correctCount++; // Count non-empty office as correct
    }

    if (designationController.text.trim().isEmpty) {
      emptyFields.add('Designation');
    } else {
      correctCount++; // Count non-empty designation as correct
    }

    if (basicPayController.text.trim().isEmpty) {
      emptyFields.add('Basic Pay');
    } else {
      correctCount++; // Count non-empty basic pay as correct
    }

    if (govtServiceController.text.trim().isEmpty) {
      emptyFields.add('Government Service Details');
    } else {
      correctCount++; // Count non-empty govt service details as correct
    }

    if (incomeTaxDeptController.text.trim().isEmpty) {
      emptyFields.add('Income Tax Department Details');
    } else {
      correctCount++; // Count non-empty income tax dept details as correct
    }

    // For the dropdown fields, assume they are always selected with some value
    correctCount +=
        3; // Adding 3 for Gender, Marital Status, and Employment Status

    // Calculate score percentage rounded to 2 decimal places
    double score = ((correctCount / totalFields) * 100).toDouble();
    // Round to 2 decimal places
    score = double.parse(score.toStringAsFixed(2));

    String passed = (score >= 80).toString();

    // Generate simplified assessment result
    Map<String, dynamic> assessmentResult = {
      "submissionDate": DateTime.now().toIso8601String(),
      "completedAt": DateTime.now().toIso8601String(),
      "skillLevel": "Intermediate",
      "score": score,
      "scorePercentage": score,
      "passed": passed,
      "feedback": generateFeedback(score, emptyFields),
      "details": {
        "formDetails": {
          "name": nameController.text,
          "gender": selectedGender,
          "maritalStatus": maritalStatus,
          "fatherHusbandName": fatherHusbandNameController.text,
          "dob": dobController.text,
          "appointmentDate": appointmentDateController.text,
          "govtService": govtServiceController.text,
          "incomeTaxDept": incomeTaxDeptController.text,
          "retirementDate": retirementDateController.text,
          "office": officeController.text,
          "designation": designationController.text,
          "employmentStatus": employmentStatus,
          "basicPay": basicPayController.text,
        },
        "validation": {
          "totalFields": totalFields,
          "correctFields": correctCount,
          "emptyFields": emptyFields,
        },
      },
    };

    return assessmentResult;
  }

  // Helper function to generate feedback based on score and issues
  String generateFeedback(double score, List<String> emptyFields) {
    if (score == 100) {
      return "Excellent! All fields were filled correctly.";
    } else if (score >= 80) {
      return "Good job! You filled most fields correctly. Please review the following fields: ${emptyFields.join(', ')}.";
    } else if (score >= 50) {
      return "You've made several errors. Please review the following fields carefully: ${emptyFields.join(', ')}.";
    } else {
      return "Please complete the form. Many fields are empty or incorrect: ${emptyFields.join(', ')}.";
    }
  }

  Future<void> submitAssessment(Map<String, dynamic> results) async {
    emit(state.copyWith(isSubmitting: true, isCompleted: false));

    try {
      // Update assessment status to completed
      assessmentBloc.add(
        UpdateAssessmentStatusEvent(
          candidateId: candidateId,
          assessmentType: formFillingData.type,
          status: AssessmentDatabaseHelper.STATUS_COMPLETED,
        ),
      );

      // Save assessment results
      assessmentBloc.add(
        SaveAssessmentResultEvent(
          candidateId: candidateId,
          assessmentType: formFillingData.type,
          result: results,
        ),
      );

      emit(
        state.copyWith(
          isSubmitting: false,
          isCompleted: true,
          results: results,
        ),
      );
    } catch (e) {
      debugPrint('Error saving assessment results: $e');
      emit(
        state.copyWith(
          isSubmitting: false,
          error: 'Failed to save results: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<void> close() {
    // Clean up controllers
    nameController.dispose();
    fatherHusbandNameController.dispose();
    dobController.dispose();
    appointmentDateController.dispose();
    govtServiceController.dispose();
    incomeTaxDeptController.dispose();
    retirementDateController.dispose();
    officeController.dispose();
    designationController.dispose();
    basicPayController.dispose();
    return super.close();
  }
}
