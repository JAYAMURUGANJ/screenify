import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/local/shared_pref.dart';
import '../../../domain/usecases/candidate_login_usecase.dart';
import '../../../domain/usecases/candidate_register_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final CandidateRegisterUsecase registerCandidate;
  final CandidateLoginUsecase loginCandidate;

  AuthBloc({required this.registerCandidate, required this.loginCandidate})
    : super(AuthInitial()) {
    // Example import (uncomment and adjust the path as needed):
    // import 'package:your_project_name/utils/shared_pref.dart';

    // final SharedPref sharedPref = SharedPref();
    on<RegisterCandidateEvent>((event, emit) async {
      emit(AuthLoading());
      try {
        final candidateDetails = await registerCandidate(event.candidate);
        emit(RegisterSuccess(candidateDetails));
      } catch (e) {
        emit(RegisterFailure(e.toString()));
      }
    });

    on<LoginCandidateEvent>((event, emit) async {
      emit(AuthLoading());
      try {
        final assessmentQuestions = await loginCandidate(event.candidate);

        debugPrint('Assessment Questions: ${assessmentQuestions.candidateId}');

        // Get SharedPref instance
        final sharedPref = await SharedPref.getInstance();

        // Store candidateId to SharedPreferences
        await sharedPref.setString(
          'candidate_id',
          assessmentQuestions.candidateId.toString(),
        );

        emit(LoginSuccess(assessmentQuestions));
      } catch (e) {
        emit(LoginFailure(e.toString()));
      }
    });
  }
}
