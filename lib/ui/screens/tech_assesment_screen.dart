import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:win32/win32.dart';

import '../../services/keyboard_service.dart';
import '../../services/window_service.dart';
import '../widgets/app_sidebar.dart';
import '../widgets/embedded_app_container.dart';

enum LoadingState { idle, loading, closing }

class TechnicalAssesment extends StatefulWidget {
  const TechnicalAssesment({super.key});

  @override
  State<TechnicalAssesment> createState() => _TechnicalAssesmentState();
}

class _TechnicalAssesmentState extends State<TechnicalAssesment> {
  final WindowService _windowService = WindowService();
  final KeyboardService _keyboardService = KeyboardService();
  final String _loadingMessage = '';
  String msOfficePath = ""; // Default path
  LoadingState _loadingState = LoadingState.idle;

  // Reference to the sidebar
  final GlobalKey<AppSidebarState> _sidebarKey = GlobalKey<AppSidebarState>();

  // Initialize with default paths, not using late keyword
  Map<String, String> appPaths = {};

  bool get isLoading => _loadingState != LoadingState.idle;

  void _setLoadingState(LoadingState state) {
    setState(() {
      _loadingState = state;
    });
  }

  Future<void> _loadOfficePathFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedPath = prefs.getString('ms_office_path');

      if (savedPath != null && savedPath.isNotEmpty) {
        setState(() {
          msOfficePath = savedPath;
          // Update paths with new Office path
          appPaths = {
            'Word': "$msOfficePath\\WINWORD.EXE",
            'Excel': "$msOfficePath\\EXCEL.EXE",
            'PowerPoint': "$msOfficePath\\POWERPNT.EXE",
          };
        });
        debugPrint('Loaded Office path from preferences: $msOfficePath');
      } else {
        // No saved path found, use default and save it
        await _saveOfficePathToPrefs(msOfficePath);
      }
    } catch (e) {
      debugPrint('Error loading Office path from preferences: $e');
    }
  }

  Future<void> _saveOfficePathToPrefs(String path) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('ms_office_path', path);
      debugPrint('Saved Office path to preferences: $path');
    } catch (e) {
      debugPrint('Error saving Office path to preferences: $e');
    }
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

  @override
  void initState() {
    super.initState();
    _keyboardService.registerKeyboardHandler();

    // Initialize appPaths with default values first
    appPaths = {
      'Word': "$msOfficePath\\WINWORD.EXE",
      'Excel': "$msOfficePath\\EXCEL.EXE",
      'PowerPoint': "$msOfficePath\\POWERPNT.EXE",
    };

    // Load the saved Office path (will update appPaths in setState if path is found)
    _loadOfficePathFromPrefs();

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

  // Method to close the embedded application and clear sidebar selection
  void _closeEmbeddedApp() {
    if (_windowService.embeddedWindowHwnd != null) {
      final currentEmbeddedHwnd = _windowService.embeddedWindowHwnd;

      // Hide the embedded window when opening dialog
      if (currentEmbeddedHwnd != null) {
        ShowWindow(
          currentEmbeddedHwnd,
          SW_HIDE,
        ); // Change from SW_MINIMIZE to SW_HIDE
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
          // Restore the embedded app window when canceled
          if (currentEmbeddedHwnd != null) {
            ShowWindow(currentEmbeddedHwnd, SW_SHOW); // Show the window again
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

  // Add method to show settings for Office path
  void _showOfficePathSettingsDialog() {
    final TextEditingController controller = TextEditingController(
      text: msOfficePath,
    );

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Microsoft Office Path'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: controller,
                  decoration: const InputDecoration(
                    labelText: 'Office Installation Path',
                    hintText:
                        'C:\\Program Files (x86)\\Microsoft Office\\Office12',
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final newPath = controller.text.trim();
                  if (newPath.isNotEmpty) {
                    await _saveOfficePathToPrefs(newPath);
                    setState(() {
                      msOfficePath = newPath;
                      // Update appPaths with new msOfficePath
                      appPaths = {
                        'Word': "$msOfficePath\\WINWORD.EXE",
                        'Excel': "$msOfficePath\\EXCEL.EXE",
                        'PowerPoint': "$msOfficePath\\POWERPNT.EXE",
                      };
                    });
                  }
                  Navigator.pop(context);
                },
                child: const Text('Save'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool hasEmbeddedApp = _windowService.embeddedWindowHwnd != null;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          automaticallyImplyLeading: true,
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
          actions: [
            // Settings button for Office path
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: _showOfficePathSettingsDialog,
              tooltip: 'Office Path Settings',
            ),
            if (hasEmbeddedApp && !isLoading)
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.close),
                  onPressed: _closeEmbeddedApp,
                  label: Text('Close ${_windowService.currentAppName}'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red[700],
                    side: BorderSide(color: Colors.red[700]!),
                  ),
                ),
              ),
            // Exit button
            Tooltip(
              message:
                  hasEmbeddedApp || isLoading
                      ? 'Close opened applications first'
                      : 'Logout',
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
                          ? null
                          : () {
                            Navigator.pushReplacementNamed(
                              context,
                              '/candidateScreen',
                            );
                          },
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
                      child: AppSidebar(
                        key: _sidebarKey,
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
                        isLoading: isLoading,
                      ),
                    ),
                  ),

                  EmbeddedAppContainer(
                    embeddedAreaKey: _windowService.embeddedAreaKey,
                    hasEmbeddedApp: hasEmbeddedApp,
                    currentAppName: _windowService.currentAppName,
                    isLoading: isLoading,
                    loadingMessage: _loadingMessage,
                    onMouseEnter: () {
                      if (_windowService.embeddedWindowHwnd != null &&
                          !isLoading) {
                        SetForegroundWindow(_windowService.embeddedWindowHwnd!);
                        SetFocus(_windowService.embeddedWindowHwnd!);
                        _windowService.hideTaskbar();
                      }
                    },
                    onRefreshApp:
                        hasEmbeddedApp && !isLoading
                            ? () {
                              final currentApp = _windowService.currentAppName;

                              if (appPaths.containsKey(currentApp)) {
                                _closeEmbeddedApp();
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
    );
  }
}
