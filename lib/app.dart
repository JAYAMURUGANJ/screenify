import 'package:flutter/material.dart';
import 'package:screenify/ui/screens/excel_screen.dart';

import 'ui/screens/Typing_screen.dart';
import 'ui/screens/assessment_screen.dart';
import 'ui/screens/email_screen.dart';
import 'ui/screens/form_screen.dart';
import 'ui/screens/login_screen.dart';
import 'ui/screens/registration_screen.dart';
import 'ui/screens/splash_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Screenify',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
          primary: Colors.blue[700]!,
          secondary: Colors.blue[500]!,
          tertiary: Colors.blue[300]!,
        ),
        scaffoldBackgroundColor: Colors.blue[50],
        cardTheme: CardTheme(
          color: Colors.white,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue[700],
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.blue[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.blue[700]!, width: 2),
          ),
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.blue,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
          primary: Colors.blue[400]!,
          secondary: Colors.blue[300]!,
          tertiary: Colors.blue[200]!,
        ),
        scaffoldBackgroundColor: const Color(0xFF1A1A2E),
        cardTheme: CardTheme(
          color: const Color(0xFF2D2D44),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue[400],
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.blue[200]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.blue[400]!, width: 2),
          ),
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      themeMode: ThemeMode.system,
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/FormFillingAssessment': (context) => const FormFillingAssessment(),
        '/Assessments': (context) => const AssessmentsScreen(),
        '/Login': (context) => const LoginScreen(),
        '/Register': (context) => const RegistrationScreen(),
        '/TypingAssessment': (context) => const TypingAssessment(),
        '/EmailWritingAssessment': (context) => const EmailAssessment(),
        '/ExcelAssessment': (context) => const ExcelAssessment(),
      },
    );
  }
}
