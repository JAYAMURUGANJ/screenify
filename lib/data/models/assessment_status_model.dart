class AssessmentStatusModel {
  final int? id;
  final String candidateId;
  final String assessmentType;
  final String status;
  final String updatedAt;

  AssessmentStatusModel({
    this.id,
    required this.candidateId,
    required this.assessmentType,
    required this.status,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'candidate_id': candidateId,
      'assessment_type': assessmentType,
      'status': status,
      'updated_at': updatedAt,
    };
  }

  factory AssessmentStatusModel.fromMap(Map<String, dynamic> map) {
    return AssessmentStatusModel(
      id: map['id'],
      candidateId: map['candidate_id'],
      assessmentType: map['assessment_type'],
      status: map['status'],
      updatedAt: map['updated_at'],
    );
  }
}
