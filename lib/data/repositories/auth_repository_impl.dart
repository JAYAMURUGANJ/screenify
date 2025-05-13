import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:screenify/core/exception/server_exception.dart';
import 'package:screenify/core/network/dio_client.dart';
import 'package:screenify/data/models/questions_model.dart';
import 'package:screenify/domain/entities/questions_entity.dart';

import '../../domain/entities/candidate_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/candidate_model.dart';

class CandidateRepositoryImpl implements AuthRepository {
  final Dio _dio = DioClient.create();

  @override
  Future<CandidateEntity> registerCandidate(CandidateEntity candidate) async {
    final model = CandidateModel(
      aadhar: candidate.aadhar,
      name: candidate.name,
      email: candidate.email,
      phone: candidate.phone,
      dob: candidate.dob,
      gender: candidate.gender,
    );

    final response = await _dio.post('register.php', data: model.toJson());

    if (response.data['status'] != 'success') {
      throw ServerException('Registration failed: ${response.data}');
    }

    return CandidateEntity(candidateId: response.data['candidate_id']);
  }

  @override
  Future<QuestionsEntity> loginCandidate(CandidateEntity candidate) async {
    final model = CandidateModel(
      candidateId: candidate.candidateId,
      dob: candidate.dob,
    );

    final response = await _dio.post('login.php', data: model.toJson());
    debugPrint('Response: ${response.data}');

    if (response.data['status'] != 'success') {
      throw ServerException('Login failed: ${response.data}');
    }

    return QuestionsModel.fromJson(response.data);
  }
}
