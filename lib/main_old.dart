import 'dart:io';
import 'dart:ffi';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  // Set window to full screen
  windowManager.waitUntilReadyToShow().then((_) async {
    await windowManager.setFullScreen(true);
  });

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  GlobalKey embeddedAreaKey = GlobalKey();
  int? embeddedWindowHwnd;
  Process? currentProcess;
  String currentAppName = '';

  @override
  void initState() {
    super.initState();

    // Set up keyboard event handling
    ServicesBinding.instance.keyboard.addHandler(_handleKeyboardEvent);

    // Debug initial state
    debugPrint(
      'Initial state: embeddedWindowHwnd=$embeddedWindowHwnd, currentAppName=$currentAppName',
    );
  }

  // Handle keyboard events to block Alt+Tab
  bool _handleKeyboardEvent(KeyEvent event) {
    // Block Alt+Tab combination
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.tab &&
          (HardwareKeyboard.instance.isAltPressed ||
              HardwareKeyboard.instance.isMetaPressed)) {
        return true; // Event handled, don't propagate
      }
    }
    return false; // Not handled, continue propagation
  }

  @override
  void dispose() {
    closeEmbeddedApplication();
    ServicesBinding.instance.keyboard.removeHandler(_handleKeyboardEvent);
    super.dispose();
  }

  Future<void> exitApplication() async {
    // First ensure embedded application is closed
    closeEmbeddedApplication();

    // Wait a moment to ensure the embedded app is properly closed
    await Future.delayed(const Duration(milliseconds: 500));

    // Exit the application
    await windowManager.destroy();
  }

  @override
  Widget build(BuildContext context) {
    // Debug build method
    debugPrint(
      'Building UI with embeddedWindowHwnd: $embeddedWindowHwnd, currentAppName: $currentAppName',
    );

    return MaterialApp(
      home: WillPopScope(
        // Prevent back navigation
        onWillPop: () async => false,
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              currentAppName.isEmpty
                  ? 'Embed Office Apps'
                  : 'Embed Office Apps - $currentAppName',
            ),
            automaticallyImplyLeading: false, // Remove back button
            actions: [
              // Add close button for the embedded application
              if (embeddedWindowHwnd != null)
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.close),
                    onPressed: closeEmbeddedApplication,
                    label: Text('Close $currentAppName'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[700],
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              // Add close button to the app bar
              IconButton(
                icon: const Icon(Icons.exit_to_app),
                onPressed: exitApplication,
                tooltip: 'Exit Application',
              ),
            ],
          ),
          body: GestureDetector(
            // Intercept taps on the main window to prevent focus change
            onTap: () {
              // If we have an embedded app, make sure it stays in focus
              if (embeddedWindowHwnd != null) {
                SetForegroundWindow(embeddedWindowHwnd!);
                SetFocus(embeddedWindowHwnd!);
              }
            },
            behavior: HitTestBehavior.translucent,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
                    color: Colors.grey[200],
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const Text(
                          'Office Applications',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.edit_document),
                          onPressed:
                              () => embedApplication(
                                'C:\\Program Files (x86)\\Microsoft Office\\Office12\\WINWORD.EXE',
                                'Word',
                              ),
                          label: const Text('Embed Microsoft Word'),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.table_chart),
                          onPressed:
                              () => embedApplication(
                                'C:\\Program Files (x86)\\Microsoft Office\\Office12\\EXCEL.EXE',
                                'Excel',
                              ),
                          label: const Text('Embed Microsoft Excel'),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.slideshow),
                          onPressed:
                              () => embedApplication(
                                'C:\\Program Files (x86)\\Microsoft Office\\Office12\\POWERPNT.EXE',
                                'PowerPoint',
                              ),
                          label: const Text('Embed Microsoft PowerPoint'),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: MouseRegion(
                    // Detect mouse enter/exit for the embedded application area
                    onEnter: (_) {
                      if (embeddedWindowHwnd != null) {
                        SetForegroundWindow(embeddedWindowHwnd!);
                        SetFocus(embeddedWindowHwnd!);
                      }
                    },
                    child: Container(
                      key: embeddedAreaKey,
                      color: Colors.grey[300],
                      child:
                          embeddedWindowHwnd == null
                              ? const Center(
                                child: Text(
                                  'Embedded Application Area\nClick a button to embed an application',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              )
                              : const SizedBox.expand(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void embedApplication(String exePath, String appName) async {
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
      final hwnd = findWindowByPid(pid);
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

      setState(() {
        embeddedWindowHwnd = null;
        currentAppName = '';
        debugPrint('Reset embeddedWindowHwnd and currentAppName');
      });
    }
  }
}

// Global variable to store the target PID and result HWND
int _targetPid = 0;
int _resultHwnd = 0;

// Static callback function for EnumWindows
int _enumWindowsCallback(int hWnd, int lParam) {
  final processId = calloc<Uint32>();
  GetWindowThreadProcessId(hWnd, processId);

  if (processId.value == _targetPid) {
    // Check for visible windows
    if (IsWindowVisible(hWnd) != 0) {
      final buffer = wsalloc(256);
      final length = GetWindowText(hWnd, buffer, 256);

      // For Office apps, we want the main window which typically has a title
      if (length > 0) {
        _resultHwnd = hWnd;
        free(buffer);
        calloc.free(processId);
        return 0; // Stop enumeration
      }
      free(buffer);
    }
  }

  calloc.free(processId);
  return 1; // Continue enumeration
}

// Function pointer for the callback
final _enumWindowsProcPointer = Pointer.fromFunction<WNDENUMPROC>(
  _enumWindowsCallback,
  1,
);

int findWindowByPid(int pid) {
  // Set the target PID
  _targetPid = pid;
  _resultHwnd = 0;

  // Enumerate windows
  EnumWindows(_enumWindowsProcPointer, 0);

  return _resultHwnd;
}