import '../../../domain/entities/candidate_entity.dart';

abstract class AuthEvent {}

class RegisterCandidateEvent extends AuthEvent {
  final CandidateEntity candidate;

  RegisterCandidateEvent(this.candidate);
}

class LoginCandidateEvent extends AuthEvent {
  final CandidateEntity candidate;

  LoginCandidateEvent(this.candidate);
}
