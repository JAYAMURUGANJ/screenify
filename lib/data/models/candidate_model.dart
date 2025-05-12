import '../../domain/entities/candidate_entity.dart';

class CandidateModel extends CandidateEntity {
  CandidateModel({
    super.candidateId,
    super.aadhar,
    super.name,
    super.email,
    super.phone,
    super.dob,
    super.gender,
  });

  factory CandidateModel.fromJson(Map<String, dynamic> json) {
    // Check for null values or missing keys and handle defaults if necessary
    return CandidateModel(
      candidateId: json['candidate_id'] ?? '', // Default empty string if null
      aadhar: json['aadhar'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      dob: json['dob'] ?? '',
      gender: json['gender'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};

    void addIfNotEmpty(String key, String? value) {
      if (value != null && value.isNotEmpty) {
        data[key] = value;
      }
    }

    addIfNotEmpty('candidate_id', candidateId);
    addIfNotEmpty('aadhar', aadhar);
    addIfNotEmpty('name', name);
    addIfNotEmpty('email', email);
    addIfNotEmpty('phone', phone);
    addIfNotEmpty('dob', dob);
    addIfNotEmpty('gender', gender);

    return data;
  }
}
