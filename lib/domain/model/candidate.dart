// Next, let's create the Candidate model

// lib/models/candidate.dart
class Candidate {
  String? id; // Auto-generated candidate ID
  final String aadhar;
  final String name;
  final String email;
  final String phone;
  final String dob;

  Candidate({
    this.id,
    required this.aadhar,
    required this.name,
    required this.email,
    required this.phone,
    required this.dob,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'aadhar': aadhar,
      'name': name,
      'email': email,
      'phone': phone,
      'dob': dob,
    };
  }

  factory Candidate.fromMap(Map<String, dynamic> map) {
    return Candidate(
      id: map['id'],
      aadhar: map['aadhar'],
      name: map['name'],
      email: map['email'],
      phone: map['phone'],
      dob: map['dob'],
    );
  }
}
