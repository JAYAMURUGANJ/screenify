import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:window_manager/window_manager.dart';

import 'app.dart';
import 'services/window_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  // Initialize FFI for SQLite on desktop
  sqfliteFfiInit();

  // Set the database factory
  databaseFactory = databaseFactoryFfi;

  // Register a callback for when the app is shutting down
  ProcessSignal.sigterm.watch().listen((_) {
    // Show taskbar before application terminates
    WindowService().showTaskbar();
    exit(0);
  });

  // Set window to full screen
  windowManager.waitUntilReadyToShow().then((_) async {
    await windowManager.setFullScreen(true);
  });

  runApp(const MyApp());
}
