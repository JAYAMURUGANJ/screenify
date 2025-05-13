import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:window_manager/window_manager.dart';

import 'app.dart';
import 'core/observer/bloc_observer.dart';
import 'core/utils/windows/window_service.dart';

void main() async {
  // Avoid listening to signals on Windows
  if (!Platform.isWindows) {
    ProcessSignal.sigterm.watch().listen((_) {
      // Perform cleanup or shutdown logic here
    });
    // Register a callback for when the app is shutting down
    ProcessSignal.sigterm.watch().listen((_) {
      // Show taskbar before application terminates
      WindowService().showTaskbar();
      exit(0);
    });
  }

  // if (Platform.isWindows) {
  //   // Hide taskbar on Windows
  //   WindowService().hideTaskbar();
  // }
  //only show the observer when debugging
  if (kDebugMode) {
    Bloc.observer = SimpleBlocObserver();
  }

  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  // Initialize FFI for SQLite on desktop
  sqfliteFfiInit();

  // Set the database factory
  databaseFactory = databaseFactoryFfi;

  // Set window to full screen
  windowManager.waitUntilReadyToShow().then((_) async {
    await windowManager.setFullScreen(true);
  });

  runApp(const MyApp());
}
