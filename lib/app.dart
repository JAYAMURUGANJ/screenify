import 'package:flutter/material.dart';
import 'package:screenify/ui/screens/splash_screen.dart';

import 'domain/model/candidate.dart';
import 'ui/screens/candidate_screen.dart';
import 'ui/screens/login_screen.dart';
import 'ui/screens/registration_screen.dart';
import 'ui/screens/tech_assesment_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Office App Embedder',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/',
      routes: {
        '/aa': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegistrationScreen(),
        '/':
            (context) => CandidateScreeningPage(
              candidate: Candidate(
                aadhar: '293008805934',
                name: 'Jai',
                email: 'jai@gmail.com',
                phone: '1234567890',
                dob: '1990-01-01',
              ),
            ),
        '/technicalAssesment': (context) => const TechnicalAssesment(),
      },
    );
  }
}
