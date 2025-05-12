import 'package:screenify/domain/entities/candidate_entity.dart';

import '../../../domain/entities/questions_entity.dart';

abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

/// Register States
class RegisterSuccess extends AuthState {
  final CandidateEntity candidateDetails;
  RegisterSuccess(this.candidateDetails);
}

class RegisterFailure extends AuthState {
  final String error;
  RegisterFailure(this.error);
}

/// Login States
class LoginSuccess extends AuthState {
  final QuestionsEntity assessmentDetails;
  LoginSuccess(this.assessmentDetails);
}

class LoginFailure extends AuthState {
  final String error;
  LoginFailure(this.error);
}
