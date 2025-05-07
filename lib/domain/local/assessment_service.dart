import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../model/assessment_question.dart';

class AssessmentService {
  static final AssessmentService _instance = AssessmentService._internal();

  factory AssessmentService() => _instance;

  AssessmentService._internal();

  AssessmentQuestions? _assessmentData;

  /// Load JSON from assets and parse into AssessmentData model
  Future<void> loadAssessmentData() async {
    try {
      final String jsonString = await rootBundle.loadString(
        'assets/data/assessments.json',
      );
      final Map<String, dynamic> jsonMap = json.decode(jsonString);
      _assessmentData = AssessmentQuestions.fromJson(jsonMap);
    } catch (e) {
      debugPrint('Error loading assessment data: $e');
      // Create empty assessment data in case of error
      _assessmentData = AssessmentQuestions(assessments: []);
    }
  }

  /// Generic: Get assessments by type
  List<Assessment> getAssessmentsByType(String type) {
    return _assessmentData?.assessments
            .where((assessment) => assessment.type == type)
            .toList() ??
        [];
  }

  /// Get all assessment types available
  List<String> getAvailableAssessmentTypes() {
    return _assessmentData?.assessments.map((a) => a.type).toSet().toList() ??
        [];
  }

  /// Get count of assessments by status
  int getAssessmentCountByStatus(String status) {
    return _assessmentData?.assessments
            .where((assessment) => assessment.status == status)
            .length ??
        0;
  }

  /// Get pending assessment count
  int getPendingAssessmentCount() {
    return getAssessmentCountByStatus('pending');
  }

  /// Get completed assessment count
  int getCompletedAssessmentCount() {
    return getAssessmentCountByStatus('completed');
  }

  /// Get not opened assessment count
  int getNotOpenedAssessmentCount() {
    return getAssessmentCountByStatus('not_opened');
  }
}
