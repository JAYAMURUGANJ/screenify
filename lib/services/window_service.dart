import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';
import 'package:flutter/material.dart';
import 'package:win32/win32.dart';
import 'package:window_manager/window_manager.dart';

import '../utils/win32_utils.dart';

class WindowService {
  // Singleton pattern
  static final WindowService _instance = WindowService._internal();
  factory WindowService() => _instance;
  WindowService._internal();

  int? embeddedWindowHwnd;
  Process? currentProcess;
  String currentAppName = '';
  final GlobalKey embeddedAreaKey = GlobalKey();

  void focusEmbeddedApp() {
    if (embeddedWindowHwnd == null) return;

    final int hwnd = embeddedWindowHwnd!;

    // Make sure the window is visible and not minimized
    if (IsIconic(hwnd) != 0) {
      ShowWindow(hwnd, SW_RESTORE);
    }

    // Allow setting the foreground window
    AllowSetForegroundWindow(GetCurrentProcessId());

    // Get current foreground and target window threads
    final int foregroundThread = GetWindowThreadProcessId(
      GetForegroundWindow(),
      nullptr,
    );
    final int embeddedThread = GetWindowThreadProcessId(hwnd, nullptr);

    // Attach input queues so that focus can transfer smoothly
    AttachThreadInput(foregroundThread, embeddedThread, TRUE);

    // Try forcing the window to the front
    SetForegroundWindow(hwnd);
    SetActiveWindow(hwnd);
    SetFocus(hwnd);

    // Detach thread input after setting focus
    AttachThreadInput(foregroundThread, embeddedThread, FALSE);
  }

  // Add a method to hide the taskbar
  void hideTaskbar() {
    final taskbarHwnd = FindWindow('Shell_TrayWnd'.toNativeUtf16(), nullptr);
    if (taskbarHwnd != 0) {
      ShowWindow(taskbarHwnd, SW_HIDE);
      debugPrint('Taskbar hidden');
    } else {
      debugPrint('Failed to find taskbar window');
    }
  }

  // Add a method to show the taskbar (for cleanup)
  void showTaskbar() {
    final taskbarHwnd = FindWindow('Shell_TrayWnd'.toNativeUtf16(), nullptr);
    if (taskbarHwnd != 0) {
      ShowWindow(taskbarHwnd, SW_SHOW);
      debugPrint('Taskbar shown');
    }
  }

  Future<void> exitApplication() async {
    // First ensure embedded application is closed
    closeEmbeddedApplication();

    // Show the taskbar again before exiting
    showTaskbar();

    // Wait a moment to ensure the embedded app is properly closed
    await Future.delayed(const Duration(milliseconds: 500));

    // Exit the application
    await windowManager.destroy();
  }

  Future<void> embedApplication(
    String exePath,
    String appName,
    Function setState,
  ) async {
    try {
      debugPrint('Attempting to embed $appName from path: $exePath');

      // Close any existing embedded application
      if (embeddedWindowHwnd != null) {
        closeEmbeddedApplication();
      }

      // Start the process
      final process = await Process.start(exePath, []);
      currentProcess = process;
      int pid = process.pid;

      // Update the current app name and trigger UI rebuild
      setState(() {
        currentAppName = appName;
        debugPrint('Set currentAppName to $appName');
      });

      debugPrint('Starting $appName with PID: $pid');

      // Wait for the application to initialize
      await Future.delayed(const Duration(seconds: 3));

      // Find the window handle for the process
      final hwnd = Win32Utils.findWindowByPid(pid);
      if (hwnd != 0) {
        debugPrint('Found window handle: $hwnd for $appName');

        // Update state with the window handle and ensure UI rebuild
        setState(() {
          embeddedWindowHwnd = hwnd;
          debugPrint('Set embeddedWindowHwnd to $hwnd');
        });

        // Wait for state update to complete
        WidgetsBinding.instance.addPostFrameCallback((_) {
          // Get Flutter window handle
          final flutterHwnd = GetForegroundWindow();
          if (flutterHwnd != 0) {
            // First make sure the window is visible at its original position
            ShowWindow(hwnd, SW_SHOWNOACTIVATE);

            // Get the container dimensions
            final containerBox =
                embeddedAreaKey.currentContext?.findRenderObject()
                    as RenderBox?;
            if (containerBox != null) {
              final containerRect =
                  containerBox.localToGlobal(Offset.zero) & containerBox.size;

              // Disable window menu
              SetMenu(hwnd, 0);

              // Remove window decorations and make it a child window
              final style = GetWindowLongPtr(hwnd, GWL_STYLE);
              SetWindowLongPtr(
                hwnd,
                GWL_STYLE,
                (style &
                        ~WS_POPUP &
                        ~WS_CAPTION &
                        ~WS_THICKFRAME &
                        ~WS_SYSMENU) |
                    WS_CHILD,
              );

              // Set the parent
              SetParent(hwnd, flutterHwnd);

              // Position the window exactly within our container
              SetWindowPos(
                hwnd,
                HWND_TOP,
                containerRect.left.toInt(),
                containerRect.top.toInt(),
                containerRect.width.toInt(),
                containerRect.height.toInt(),
                0, // No flags - apply all changes immediately
              );

              // Capture keyboard events to prevent Alt+Tab
              RegisterHotKey(
                flutterHwnd,
                1, // ID
                MOD_ALT,
                VK_TAB,
              );

              // Hide taskbar
              hideTaskbar();

              // Activate and focus the window
              ShowWindow(hwnd, SW_SHOW);
              SetForegroundWindow(hwnd);
              SetFocus(hwnd);

              // Force UI update to ensure close button appears
              setState(() {
                // Just trigger a rebuild to ensure UI is updated
                debugPrint('Forcing UI update after embedding $appName');
              });

              // Set up a timer to periodically check and refocus if needed
              Future.delayed(const Duration(milliseconds: 500), () {
                _startFocusMonitoring(hwnd);
              });
            }
          } else {
            debugPrint('Error: Flutter window not found.');
          }
        });
      } else {
        setState(() {
          currentAppName = '';
          debugPrint(
            'Failed to find window for $appName, reset currentAppName',
          );
        });
        debugPrint('Error: Could not find the window for PID: $pid');
      }
    } catch (e) {
      setState(() {
        currentAppName = '';
        debugPrint('Error occurred, reset currentAppName');
      });
      debugPrint('Error opening application: $e');
    }
  }

  // Periodically check and refocus the embedded window
  void _startFocusMonitoring(int hwnd) {
    if (embeddedWindowHwnd == hwnd) {
      // Check if this is the foreground window
      final foregroundWindow = GetForegroundWindow();
      if (foregroundWindow != hwnd) {
        // If our window lost focus, reset it
        SetForegroundWindow(hwnd);
        SetFocus(hwnd);
      }

      // Check if taskbar is visible and hide it again if needed
      final taskbarHwnd = FindWindow('Shell_TrayWnd'.toNativeUtf16(), nullptr);
      if (taskbarHwnd != 0) {
        if (IsWindowVisible(taskbarHwnd) != 0) {
          ShowWindow(taskbarHwnd, SW_HIDE);
        }
      }

      // Schedule next check if still active
      if (embeddedWindowHwnd != null) {
        Future.delayed(const Duration(milliseconds: 500), () {
          _startFocusMonitoring(hwnd);
        });
      }
    }
  }

  void closeEmbeddedApplication() {
    if (embeddedWindowHwnd != null) {
      debugPrint('Closing embedded application: $currentAppName');
      try {
        final hwndToClose = embeddedWindowHwnd!;

        // Send a close message to the application
        PostMessage(hwndToClose, WM_CLOSE, 0, 0);

        // Kill the process forcefully if it doesn't close
        Future.delayed(const Duration(seconds: 1), () {
          try {
            if (currentProcess != null) {
              // Use the correct signal for termination
              currentProcess!.kill(ProcessSignal.sigterm);
              currentProcess = null;
              debugPrint('Process terminated');
            }
          } catch (e) {
            debugPrint('Error force-killing process: $e');
          }
        });
      } catch (e) {
        debugPrint('Error closing application: $e');
      }

      embeddedWindowHwnd = null;
      currentAppName = '';
      debugPrint('Reset embeddedWindowHwnd and currentAppName');
    }
  }
}
