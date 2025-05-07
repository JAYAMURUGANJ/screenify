import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'services/timer_provider.dart';
import 'utils/app_route.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
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
