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
    var employmentInfo = state.employmentInfo;

    List<String> mismatchFields = [];
    int totalFields = 8;
    int correctCount = 0;

    if (employmentInfo != null) {
      // Perform validation against expected data
      if (nameController.text.trim().toUpperCase() ==
          employmentInfo.name!.toUpperCase()) {
        correctCount++;
      } else {
        mismatchFields.add('Name');
      }

      if (fatherHusbandNameController.text.trim().toUpperCase() ==
          employmentInfo.fatherName!.toUpperCase()) {
        correctCount++;
      } else {
        mismatchFields.add('Father\'s/Husband\'s Name');
      }

      if (dobController.text.trim() == employmentInfo.dateOfBirth!.trim()) {
        correctCount++;
      } else {
        mismatchFields.add('Date of Birth');
      }

      if (appointmentDateController.text.trim() ==
          employmentInfo.dateOfAppointment!.trim()) {
        correctCount++;
      } else {
        mismatchFields.add('Date of Appointment');
      }

      if (retirementDateController.text.trim() ==
          employmentInfo.dateOfRetirement!.trim()) {
        correctCount++;
      } else {
        mismatchFields.add('Date of Retirement');
      }

      if (officeController.text.trim().toUpperCase() ==
          employmentInfo.currentOffice!.toUpperCase()) {
        correctCount++;
      } else {
        mismatchFields.add('Current Office');
      }

      if (designationController.text.trim().toUpperCase() ==
          employmentInfo.designation!.toUpperCase()) {
        correctCount++;
      } else {
        mismatchFields.add('Designation');
      }

      if (basicPayController.text.trim() == employmentInfo.basicPay!.trim()) {
        correctCount++;
      } else {
        mismatchFields.add('Basic Pay');
      }
    } else {
      // If no employment info to validate against, just compile form values
      correctCount = totalFields; // No validation, so all fields are "correct"
    }

    double score = (correctCount / totalFields) * 100;

    Map<String, dynamic> assessmentResult = {
      'submissionDate': DateTime.now().toIso8601String(),
      'formDetails': {
        'name': nameController.text,
        'gender': selectedGender,
        'maritalStatus': maritalStatus,
        'fatherHusbandName': fatherHusbandNameController.text,
        'dob': dobController.text,
        'appointmentDate': appointmentDateController.text,
        'govtService': govtServiceController.text,
        'incomeTaxDept': incomeTaxDeptController.text,
        'retirementDate': retirementDateController.text,
        'office': officeController.text,
        'designation': designationController.text,
        'employmentStatus': employmentStatus,
        'basicPay': basicPayController.text,
      },
      'validation': {
        'score': score,
        'totalFields': totalFields,
        'correctFields': correctCount,
        'mismatchFields': mismatchFields,
      },
      'status': 'submitted',
    };

    return assessmentResult;
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
