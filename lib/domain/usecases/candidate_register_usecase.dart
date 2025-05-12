import '../entities/candidate_entity.dart';
import '../repositories/auth_repository.dart';

class CandidateRegisterUsecase {
  final AuthRepository repository;

  CandidateRegisterUsecase(this.repository);

  Future<CandidateEntity> call(CandidateEntity candidate) async {
    try {
      return await repository.registerCandidate(candidate);
    } catch (e) {
     
      throw Exception('Registration failed: $e');
    }
  }
}
