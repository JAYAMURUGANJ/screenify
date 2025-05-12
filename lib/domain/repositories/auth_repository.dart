import 'package:screenify/domain/entities/questions_entity.dart';

import '../entities/candidate_entity.dart';

abstract class AuthRepository {
  Future<CandidateEntity> registerCandidate(CandidateEntity candidate);
  Future<QuestionsEntity> loginCandidate(CandidateEntity candidate);
}
