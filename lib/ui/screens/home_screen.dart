import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:win32/win32.dart';

import '../../services/keyboard_service.dart';
import '../../services/window_service.dart';
import '../widgets/app_sidebar.dart';
import '../widgets/embedded_app_container.dart';

enum LoadingState { idle, loading, closing }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final WindowService _windowService = WindowService();
  final KeyboardService _keyboardService = KeyboardService();
  String _loadingMessage = '';
  String msOfficePath = "C:\\Program Files (x86)\\Microsoft Office\\Office12";
  LoadingState _loadingState = LoadingState.idle;

  bool get isLoading => _loadingState != LoadingState.idle;

  void _setLoadingState(LoadingState state) {
    setState(() {
      _loadingState = state;
    });
  }

  void _handleLifecycleEvent(String? msg) {
    if (msg == AppLifecycleState.detached.toString()) {
      _windowService.showTaskbar();
    } else if (msg == AppLifecycleState.resumed.toString()) {
      if (_windowService.embeddedWindowHwnd != null) {
        _keyboardService.setBlockAltTab(true);
        _windowService.focusEmbeddedApp();
      }
    }
  }

  // Reference to the sidebar
  final GlobalKey<AppSidebarState> _sidebarKey = GlobalKey<AppSidebarState>();

  // Example: Load paths from a configuration file
  late final Map<String, String> appPaths;

  @override
  void initState() {
    super.initState();
    _keyboardService.registerKeyboardHandler();

    // Initialize appPaths with instance member
    appPaths = {
      'Word': "$msOfficePath\\WINWORD.EXE",
      'Excel': "$msOfficePath\\EXCEL.EXE",
      'PowerPoint': "$msOfficePath\\POWERPNT.EXE",
    };

    // Set up app lifecycle monitoring
    SystemChannels.lifecycle.setMessageHandler((msg) async {
      _handleLifecycleEvent(msg);
      return null;
    });

    // Hide taskbar on application start
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _windowService.hideTaskbar();
    });
  }

  @override
  void dispose() {
    debugPrint('HomeScreen dispose method called');
    _windowService.closeEmbeddedApplication();
    _keyboardService.unregisterKeyboardHandler();

    // Show taskbar when application is closed
    _windowService.showTaskbar();

    super.dispose();
  }

  // Method to handle exit application with loading state
  void _exitApplication() {
    _setLoadingState(LoadingState.closing);
    _loadingMessage = "Application closing, please wait...";

    // Show loading indicator while exiting
    Future.delayed(const Duration(milliseconds: 800), () {
      _windowService.exitApplication();
      // App will terminate, so we don't need to set loading back to idle
    });
  }

  // Method to close the embedded application and clear sidebar selection
  void _closeEmbeddedApp() {
    if (_windowService.embeddedWindowHwnd != null) {
      final currentEmbeddedHwnd = _windowService.embeddedWindowHwnd;

      // Minimize the embedded window
      if (currentEmbeddedHwnd != null) {
        ShowWindow(currentEmbeddedHwnd, SW_MINIMIZE);
      }

      // Bring Flutter window to the foreground
      final flutterWindow = GetActiveWindow();
      if (flutterWindow != 0) {
        SetForegroundWindow(flutterWindow);
      } else {
        debugPrint('Failed to bring Flutter window to the foreground.');
      }

      // Show confirmation dialog
      _showConfirmationDialog(
        context: context,
        title: 'Close ${_windowService.currentAppName}?',
        content:
            'Please save your work before closing. Any unsaved changes will be lost.',
        onClose: () {
          _setLoadingState(LoadingState.closing);

          Future.delayed(const Duration(milliseconds: 500), () {
            try {
              _windowService.closeEmbeddedApplication();
              _sidebarKey.currentState?.clearSelection();
            } catch (e) {
              debugPrint('Error closing embedded application: $e');
            } finally {
              _setLoadingState(LoadingState.idle);
            }
          });
        },
        onCancel: () {
          // Restore the embedded app window
          if (currentEmbeddedHwnd != null) {
            ShowWindow(currentEmbeddedHwnd, SW_RESTORE);
            SetForegroundWindow(currentEmbeddedHwnd);
          }
        },
      );
    } else {
      // Show simpler dialog if no embedded app
      _showConfirmationDialog(
        context: context,
        title: 'Close Application?',
        content: 'Are you sure you want to close this application?',
        onClose: () {
          _setLoadingState(LoadingState.closing);

          Future.delayed(const Duration(milliseconds: 500), () {
            try {
              _windowService.closeEmbeddedApplication();
              _sidebarKey.currentState?.clearSelection();
            } catch (e) {
              debugPrint('Error closing application: $e');
            } finally {
              _setLoadingState(LoadingState.idle);
            }
          });
        },
      );
    }
  }

  void _showConfirmationDialog({
    required BuildContext context,
    required String title,
    required String content,
    required VoidCallback onClose,
    VoidCallback? onCancel,
  }) {
    showDialog(
      context: context,
      useRootNavigator: true,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.7),
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                if (onCancel != null) onCancel();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                onClose();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool hasEmbeddedApp = _windowService.embeddedWindowHwnd != null;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
          backgroundColor: Colors.grey[100],
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.white,
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.app_shortcut, color: Colors.blue),
                ),
                const SizedBox(width: 12),
                Text(
                  _windowService.currentAppName.isEmpty
                      ? 'Screenify'
                      : 'Screenify - ${_windowService.currentAppName}',
                  style: const TextStyle(
                    color: Color(0xFF2C3E50),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                // Show loading indicator in app bar when loading
                if (isLoading)
                  Container(
                    margin: const EdgeInsets.only(left: 12),
                    width: 20,
                    height: 20,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                    ),
                  ),
              ],
            ),
            automaticallyImplyLeading: false,
            actions: [
              if (hasEmbeddedApp && !isLoading)
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.close),
                    onPressed: _closeEmbeddedApp, // Use the new method
                    label: Text('Close ${_windowService.currentAppName}'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red[700],
                      side: BorderSide(color: Colors.red[700]!),
                    ),
                  ),
                ),
              // Exit button - only enabled if no windows are open and not loading
              Tooltip(
                message:
                    hasEmbeddedApp || isLoading
                        ? 'Close open applications first'
                        : 'Exit Application',
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color:
                        hasEmbeddedApp || isLoading
                            ? Colors.grey.withOpacity(0.1)
                            : Colors.red.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.exit_to_app),
                    onPressed:
                        hasEmbeddedApp || isLoading
                            ? null // Disable when windows are open or loading
                            : _exitApplication, // Use the new method with loading message
                    color:
                        hasEmbeddedApp || isLoading
                            ? Colors.grey[400]
                            : Colors.red[700],
                  ),
                ),
              ),
            ],
          ),
          body: Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  spreadRadius: 0,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: GestureDetector(
                onTap: () {
                  if (_windowService.embeddedWindowHwnd != null && !isLoading) {
                    SetForegroundWindow(_windowService.embeddedWindowHwnd!);
                    SetFocus(_windowService.embeddedWindowHwnd!);
                    _windowService.hideTaskbar();
                  }
                },
                behavior: HitTestBehavior.translucent,
                child: Row(
                  children: [
                    // Sidebar is disabled when loading
                    AbsorbPointer(
                      absorbing: isLoading,
                      child: Opacity(
                        opacity: isLoading ? 0.5 : 1.0,
                        child: // Update the AppSidebar in the HomeScreen's build method
                            AppSidebar(
                          key:
                              _sidebarKey, // Keep the key to access sidebar state
                          onEmbedWord: () {
                            try {
                              _windowService.embedApplication(
                                appPaths['Word']!,
                                'Word',
                                setState,
                              );
                            } catch (e) {
                              debugPrint('Failed to embed application: $e');
                            }
                          },
                          onEmbedExcel: () {
                            try {
                              _windowService.embedApplication(
                                appPaths['Excel']!,
                                'Excel',
                                setState,
                              );
                            } catch (e) {
                              debugPrint('Failed to embed application: $e');
                            }
                          },
                          onEmbedPowerPoint: () {
                            try {
                              _windowService.embedApplication(
                                appPaths['PowerPoint']!,
                                'PowerPoint',
                                setState,
                              );
                            } catch (e) {
                              debugPrint('Failed to embed application: $e');
                            }
                          },
                          onSelectionChanged: (selectedApp) {},
                          isLoading: isLoading, // Pass the loading state
                        ),
                      ),
                    ),

                    // Pass loading state to EmbeddedAppContainer
                    // In the build method, update the EmbeddedAppContainer instantiation:
                    EmbeddedAppContainer(
                      embeddedAreaKey: _windowService.embeddedAreaKey,
                      hasEmbeddedApp: hasEmbeddedApp,
                      currentAppName: _windowService.currentAppName,
                      isLoading: isLoading,
                      loadingMessage:
                          _loadingMessage, // Add the loading message
                      onMouseEnter: () {
                        if (_windowService.embeddedWindowHwnd != null &&
                            !isLoading) {
                          SetForegroundWindow(
                            _windowService.embeddedWindowHwnd!,
                          );
                          SetFocus(_windowService.embeddedWindowHwnd!);
                          _windowService.hideTaskbar();
                        }
                      },
                      onRefreshApp:
                          hasEmbeddedApp && !isLoading
                              ? () {
                                // Optional refresh functionality
                                final currentApp =
                                    _windowService.currentAppName;

                                if (appPaths.containsKey(currentApp)) {
                                  // Close the app and clear selection
                                  _closeEmbeddedApp();
                                  // Brief delay to allow proper cleanup
                                  Future.delayed(
                                    const Duration(milliseconds: 300),
                                    () {
                                      try {
                                        _windowService.embedApplication(
                                          appPaths[currentApp]!,
                                          currentApp,
                                          setState,
                                        );
                                      } catch (e) {
                                        debugPrint(
                                          'Failed to embed application: $e',
                                        );
                                      }
                                      // New app selection will set the highlight automatically
                                    },
                                  );
                                }
                              }
                              : null,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
