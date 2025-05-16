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

    try {
      final response = await _dio.post('register.php', data: model.toJson());

      if (response.data['status'] != 'success') {
        throw ServerException(
          message: 'Server error: ${response.data['message'] ?? response.data}',
          code: 500,
          stackTrace: StackTrace.current,
        );
      }

      return CandidateEntity(candidateId: response.data['candidate_id']);
    } on DioException catch (dioError) {
      // Handle Dio-specific errors (network, timeout, etc.)
      throw ServerException(
        message: 'Network error: ${dioError.message}',
        code: dioError.response?.statusCode,
        stackTrace: dioError.stackTrace,
      );
    } catch (e, stack) {
      // Handle any other errors
      throw ServerException(
        message: 'Unexpected error: $e',
        code: 500,
        stackTrace: stack,
      );
    }
  }

  @override
  Future<QuestionsEntity> loginCandidate(CandidateEntity candidate) async {
    final model = CandidateModel(
      candidateId: candidate.candidateId,
      dob: candidate.dob,
    );

    try {
      final response = await _dio.post('login.php', data: model.toJson());
      debugPrint('Response: ${response.data}');

      if (response.data['status'] == 'failure') {
        
      } else {
        throw ServerException(
          message: 'Server error: ${response.data['message'] ?? response.data}',
          code: 401, // Use appropriate code for login failure
          stackTrace: StackTrace.current,
        );
      }

      return QuestionsModel.fromJson(response.data);
    } on DioException catch (dioError) {
      throw ServerException(
        message: 'Network error: ${dioError.message}',
        code: dioError.response?.statusCode,
        stackTrace: dioError.stackTrace,
      );
    } catch (e, stack) {
      throw ServerException(
        message: 'Unexpected error: $e',
        code: 500,
        stackTrace: stack,
      );
    }
  }
}
