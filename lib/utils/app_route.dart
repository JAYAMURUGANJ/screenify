import 'package:flutter/material.dart';

import '../ui/screens/Typing_screen.dart';
import '../ui/screens/assessment_screen.dart';
import '../ui/screens/email_screen.dart';
import '../ui/screens/form_screen.dart';
import '../ui/screens/login_screen.dart';
import '../ui/screens/mcq_screen.dart';
import '../ui/screens/registration_screen.dart';
import '../ui/screens/splash_screen.dart';

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
    splash: (context) => const SplashScreen(),
    login: (context) => const LoginScreen(),
    register: (context) => const RegistrationScreen(),
    assessments: (context) {
      final args = ModalRoute.of(context)?.settings.arguments;
      final candidateId = args is String ? args : "CAND-2025-Y2LKKQ";
      return AssessmentsScreen(candidateId: candidateId);
    },
    mcqAssessment: (context) {
      final args = ModalRoute.of(context)?.settings.arguments;
      final candidateId = args is String ? args : "CAND-2025-Y2LKKQ";
      final mcqData = args is Map<String, dynamic> ? args['mcqData'] : null;
      return McqAssessmentScreen(candidateId: candidateId, mcqData: mcqData);
    },
    emailAssessment: (context) {
      final args = ModalRoute.of(context)?.settings.arguments;
      final candidateId = args is String ? args : "CAND-2025-Y2LKKQ";
      final emailData = args is Map<String, dynamic> ? args['emailData'] : null;
      return EmailAssessmentScreen(
        candidateId: candidateId,
        emailData: emailData,
      );
    },
    typingAssessment: (context) {
      final args = ModalRoute.of(context)?.settings.arguments;
      final candidateId = args is String ? args : "CAND-2025-Y2LKKQ";
      final typingData =
          args is Map<String, dynamic> ? args['typingData'] : null;
      return TypingAssessmentScreen(
        candidateId: candidateId,
        typingData: typingData,
      );
    },
    formFillingAssessment: (context) {
      final args = ModalRoute.of(context)?.settings.arguments;
      final candidateId = args is String ? args : "CAND-2025-Y2LKKQ";
      final formFillingData =
          args is Map<String, dynamic> ? args['formFillingData'] : null;
      return FormFillingAssessmentScreen(
        candidateId: candidateId,
        formFillingData: formFillingData,
      );
    },
    // Add other routes here
  };

  // Method to show a global dialog without context
  static void showGlobalDialog({
    required String title,
    required String message,
    String? buttonText,
  }) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context = navigatorKey.currentContext;
      if (context != null) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(title),
              content: Text(message),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(buttonText ?? 'OK'),
                ),
              ],
            );
          },
        );
      }
    });
  }

  // Helper method to navigate to a named route
  static void navigateTo<T>(String routeName, {Object? arguments}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      navigatorKey.currentState?.pushNamed(routeName, arguments: arguments);
    });
  }

  // Helper method to navigate and replace current route
  static void navigateAndReplace<T>(String routeName, {Object? arguments}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      navigatorKey.currentState?.pushReplacementNamed(
        routeName,
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
