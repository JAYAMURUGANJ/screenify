import 'package:flutter/material.dart';

import '../../domain/entities/questions_entity.dart';
import '../../presentation/auth/pages/login_screen.dart';
import '../../presentation/auth/pages/registration_screen.dart';
import '../../presentation/dashboard/pages/dashboard_screen.dart';
import '../../presentation/email/pages/email_screen.dart';
import '../../presentation/form/pages/form_screen.dart';
import '../../presentation/mcq/pages/mcq_screen.dart';
import '../../presentation/typing/pages/Typing_screen.dart';
import '../widgets/app_splash.dart';
import '../widgets/global_dialog.dart';

class AppRouter {
  // Global navigation key for accessing navigator from anywhere
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  // Route names as constants to avoid typos
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String assessments = '/assessments';
  static const String mcqAssessment = '/mcq';
  static const String emailAssessment = '/email';
  static const String typingAssessment = '/typing';
  static const String formFillingAssessment = '/form-filling';

  // Routes definition
  static Map<String, WidgetBuilder> get routes => {
    splash: (context) => const AppSplash(),
    login: (context) => const LoginScreen(),
    register: (context) => const RegistrationScreen(),
    assessments: (context) {
      // Get arguments with proper null safety
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

      // Make sure assessmentDetails is non-null
      final assessmentDetails = args?['assessmentDetails'] as QuestionsEntity?;

      // Return the DashboardScreen with valid assessmentDetails or handle null case
      if (assessmentDetails != null) {
        return DashboardScreen(assessmentDetails: assessmentDetails);
      } else {
        // If no assessment details are provided, navigate back to login or handle appropriately
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.of(context).pushReplacementNamed(login);
        });
        // Return a loading screen while navigation is in progress
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }
    },

    mcqAssessment: (context) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

      if (args == null) {
        _showErrorAndGoBack(
          context,
          "Missing arguments",
          "Unable to load MCQ assessment. Required arguments are missing.",
        );
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }

      final candidateId =
          args['candidateId'] as String? ?? "DEFAULT_CANDIDATE_ID";
      final mcqData = _getAssessmentEntity(args['mcqData']);

      if (mcqData == null) {
        _showErrorAndGoBack(
          context,
          "Missing assessment data",
          "Unable to load MCQ assessment. Assessment data is missing.",
        );
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }

      return McqAssessmentScreen(candidateId: candidateId, mcqData: mcqData);
    },

    emailAssessment: (context) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

      if (args == null) {
        _showErrorAndGoBack(
          context,
          "Missing arguments",
          "Unable to load email assessment. Required arguments are missing.",
        );
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }

      final candidateId =
          args['candidateId'] as String? ?? "DEFAULT_CANDIDATE_ID";
      final emailData = _getAssessmentEntity(args['emailData']);

      if (emailData == null) {
        _showErrorAndGoBack(
          context,
          "Missing assessment data",
          "Unable to load email assessment. Assessment data is missing.",
        );
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }

      return EmailAssessmentScreen(
        candidateId: candidateId,
        emailData: emailData,
      );
    },

    typingAssessment: (context) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

      if (args == null) {
        _showErrorAndGoBack(
          context,
          "Missing arguments",
          "Unable to load typing assessment. Required arguments are missing.",
        );
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }

      final candidateId =
          args['candidateId'] as String? ?? "DEFAULT_CANDIDATE_ID";
      final typingData = _getAssessmentEntity(args['typingData']);

      if (typingData == null) {
        _showErrorAndGoBack(
          context,
          "Missing assessment data",
          "Unable to load typing assessment. Assessment data is missing.",
        );
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }

      return TypingAssessmentScreen(
        candidateId: candidateId,
        typingData: typingData,
      );
    },

    formFillingAssessment: (context) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

      if (args == null) {
        _showErrorAndGoBack(
          context,
          "Missing arguments",
          "Unable to load form filling assessment. Required arguments are missing.",
        );
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }

      final candidateId =
          args['candidateId'] as String? ?? "DEFAULT_CANDIDATE_ID";
      final formFillingData = _getAssessmentEntity(args['formFillingData']);

      if (formFillingData == null) {
        _showErrorAndGoBack(
          context,
          "Missing assessment data",
          "Unable to load form filling assessment. Assessment data is missing.",
        );
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }

      return FormFillingAssessmentScreen(
        candidateId: candidateId,
        formFillingData: formFillingData,
      );
    },
  };

  // Helper method to show error and go back
  static void _showErrorAndGoBack(
    BuildContext context,
    String title,
    String message,
  ) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.of(context).pop();
      showErrorDialog(context, title, message);
    });
  }

  // Helper method to get AssessmentEntity safely
  static AssessmentEntity? _getAssessmentEntity(dynamic data) {
    if (data == null) {
      return null;
    }

    if (data is AssessmentEntity) {
      return data;
    }

    if (data is Map<String, dynamic>) {
      try {
        // Create a new AssessmentEntity with the required fields
        return AssessmentEntity(
          type: data['type'] ?? '',
          title: data['title'] ?? '',
          description: data['description'] ?? '',
          icon: data['icon'] ?? '',
          instructions: data['instructions'] ?? '',
          paragraph: data['paragraph'] ?? '',
          expectedTo: data['expectedTo'] ?? '',
          expectedCc: data['expectedCc'] ?? '',
          expectedSubject: data['expectedSubject'] ?? '',
          expectedKeywords:
              data['expectedKeywords'] != null
                  ? List<String>.from(data['expectedKeywords'])
                  : null,
          hints:
              data['hints'] != null ? List<String>.from(data['hints']) : null,
          questions:
              data['questions'] != null
                  ? (data['questions'] as List)
                      .map(
                        (q) => QuestionEntity(
                          question: q['question'] ?? '',
                          options:
                              q['options'] != null
                                  ? List<String>.from(q['options'])
                                  : [],
                          correctAnswerIndex: q['correctAnswerIndex'] ?? 0,
                        ),
                      )
                      .toList()
                  : null,
          status: data['status'] ?? 'not_opened',
        );
      } catch (e) {
        debugPrint('Error creating AssessmentEntity from map: $e');
        return null;
      }
    }

    return null;
  }

  static void showErrorDialog(
    BuildContext context,
    String title,
    String message,
  ) {
    DialogUtils.showError(title: title, message: message);
  }

  static void showGlobalDialog({
    required String title,
    required String message,
    String? buttonText,
    String? secondaryButtonText,
    VoidCallback? primaryCallback,
    VoidCallback? secondaryCallback,
  }) {
    DialogUtils.showGlobalDialog(
      title: title,
      message: message,
      primaryButtonText: buttonText,
      secondaryButtonText: secondaryButtonText,
      primaryCallback: primaryCallback,
      secondaryCallback: secondaryCallback,
    );
  }

  // Helper method to navigate to a named route
  static void navigateTo(String routeName, {Object? arguments}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      navigatorKey.currentState?.pushNamed(routeName, arguments: arguments);
    });
  }

  // Helper method to navigate and replace current route
  static void navigateAndReplace(String routeName, {Object? arguments}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      navigatorKey.currentState?.pushReplacementNamed(
        routeName,
        arguments: arguments,
      );
    });
  }

  //pushUntil method to navigate to a specific route and remove all previous routes
  static void navigateAndPushUntil(String routeName, {Object? arguments}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      navigatorKey.currentState?.pushNamedAndRemoveUntil(
        routeName,
        (route) => false,
        arguments: arguments,
      );
    });
  }

  // Helper method to pop to specific route
  static void popUntil(String routeName) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      navigatorKey.currentState?.popUntil(ModalRoute.withName(routeName));
    });
  }

  // Helper method to go back
  static void goBack<T>([T? result]) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (navigatorKey.currentState?.canPop() == true) {
        navigatorKey.currentState?.pop(result);
      }
    });
  }
}
