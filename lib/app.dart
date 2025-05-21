import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:screenify/presentation/dashboard/widget/completion_dialog.dart';

import 'core/local/shared_pref.dart';
import 'core/route/app_route.dart';
import 'core/utils/timer_provider.dart';
import 'data/repositories/assessment_local_repository_impl.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'domain/usecases/assessment_usecase.dart';
import 'domain/usecases/candidate_login_usecase.dart';
import 'domain/usecases/candidate_register_usecase.dart';
import 'presentation/auth/bloc/auth_bloc.dart';
import 'presentation/dashboard/bloc/assessment_bloc.dart';

// Global function to show completion dialog using AppRouter
void showCompletionDialog(String candidateId) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    final context = AppRouter.navigatorKey.currentContext;
    if (context != null) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return CompletionDialog(candidateId: candidateId);
        },
      );
    }
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final candidateRepository = CandidateRepositoryImpl();
    final assessmentRepository = AssessmentLocalRepositoryImpl();

    return MultiBlocProvider(
      providers: [
        // Auth Bloc
        BlocProvider(
          create:
              (_) => AuthBloc(
                registerCandidate: CandidateRegisterUsecase(
                  candidateRepository,
                ),
                loginCandidate: CandidateLoginUsecase(candidateRepository),
              ),
        ),

        // Assessment Bloc
        BlocProvider(
          create:
              (_) => AssessmentBloc(
                getAllAssessmentStatusesUseCase:
                    GetAllAssessmentStatusesUseCase(
                      repository: assessmentRepository,
                    ),
                updateAssessmentStatusUseCase: UpdateAssessmentStatusUseCase(
                  repository: assessmentRepository,
                ),
                saveAssessmentResultUseCase: SaveAssessmentResultUseCase(
                  repository: assessmentRepository,
                ),
                markAssessmentAsStartedUseCase: MarkAssessmentAsStartedUseCase(
                  repository: assessmentRepository,
                ),
                markAssessmentAsCompletedUseCase:
                    MarkAssessmentAsCompletedUseCase(
                      repository: assessmentRepository,
                    ),
                submitAssessmetToApiUseCase: SubmitAssessmetToApiUseCase(
                  repository: assessmentRepository,
                ),
              ),
        ),

        // Timer Provider
        ChangeNotifierProvider(
          create:
              (_) => TimerProvider(
                durationInMinutes: 30,
                autoStart: true,
                onTimerComplete: () async {
                  final sharedPref = await SharedPref.getInstance();
                  final candidateId =
                      sharedPref.getString('candidate_id') ?? '';
                  // Use the global function to show dialog
                  showCompletionDialog(candidateId);
                },
              ),
        ),
      ],
      child: MaterialApp(
        title: 'Screenify',
        debugShowCheckedModeBanner: false,
        themeMode: ThemeMode.system,
        navigatorKey:
            AppRouter.navigatorKey, // Use the existing AppRouter navigatorKey
        initialRoute: AppRouter.splash,
        routes: AppRouter.routes,
      ),
    );
  }
}
