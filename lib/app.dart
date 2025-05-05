import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'utils/app_route.dart';
import 'utils/timer_provider.dart';

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
                  // This will now use post-frame callback internally
                  AppRouter.showGlobalDialog(
                    title: 'Time is Up!',
                    message: 'Your assessment session has ended.',
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
        navigatorKey: AppRouter.navigatorKey, // Use the global navigator key
        initialRoute: AppRouter.splash,
        routes: AppRouter.routes, // Use routes from AppRouter
      ),
    );
  }
}
