import 'package:flutter/material.dart';
import 'package:screenify/ui/screens/splash_screen.dart';

import 'ui/screens/form_screen.dart';
import 'ui/screens/login_screen.dart';
import 'ui/screens/registration_screen.dart';
import 'ui/screens/tech_assesment_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Screenify',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/memberShipForm': (context) => const MembershipForm(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegistrationScreen(),
        // '/candidateScreen': (context) => const CandidateScreeningPage(),
        '/technicalAssesment': (context) => const TechnicalAssesment(),
      },
    );
  }
}
