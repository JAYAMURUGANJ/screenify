import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import 'core/route/app_route.dart';
import 'core/utils/timer_provider.dart';
import 'data/repositories/assessment_local_repository_impl.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'domain/usecases/assessment_usecase.dart';
import 'domain/usecases/candidate_login_usecase.dart';
import 'domain/usecases/candidate_register_usecase.dart';
import 'presentation/auth/bloc/auth_bloc.dart';
import 'presentation/dashboard/bloc/assessment_bloc.dart';

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
              ),
        ),

        // Timer Provider
        ChangeNotifierProvider(
          create:
              (_) => TimerProvider(
                durationInMinutes: 60,
                autoStart: true,
                onTimerComplete: () {
                  AppRouter.showGlobalDialog(
                    title: 'Time is Up!',
                    message:
                        'Your assessment session has ended. Please submit your work.',
                    buttonText: 'OK',
                  );
                },
              ),
        ),
      ],
      child: MaterialApp(
        title: 'Screenify',
        debugShowCheckedModeBanner: false,
        themeMode: ThemeMode.system,
        navigatorKey: AppRouter.navigatorKey,
        initialRoute: AppRouter.splash,
        routes: AppRouter.routes,
      ),
    );
  }
}
