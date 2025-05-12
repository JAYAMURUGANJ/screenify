import 'package:screenify/domain/entities/candidate_entity.dart';
import 'package:screenify/domain/entities/questions_entity.dart';

import '../repositories/auth_repository.dart';

class CandidateLoginUsecase {
  final AuthRepository repository;

  CandidateLoginUsecase(this.repository);

  Future<QuestionsEntity> call(CandidateEntity candidate) async {
    try {
      return await repository.loginCandidate(candidate);
    } catch (e) {
      throw Exception('Failed to login: $e');
    }
  }
}
