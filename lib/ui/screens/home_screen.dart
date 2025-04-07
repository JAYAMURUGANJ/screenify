import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:win32/win32.dart';

import '../../services/keyboard_service.dart';
import '../../services/window_service.dart';
import '../widgets/app_sidebar.dart';
import '../widgets/embedded_app_container.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final WindowService _windowService = WindowService();
  final KeyboardService _keyboardService = KeyboardService();
  String _loadingMessage = '';
  // Reference to the sidebar
  final GlobalKey<AppSidebarState> _sidebarKey = GlobalKey<AppSidebarState>();

  @override
  void initState() {
    super.initState();
    _keyboardService.registerKeyboardHandler();

    // Set up app lifecycle monitoring
    SystemChannels.lifecycle.setMessageHandler((msg) async {
      if (msg == AppLifecycleState.detached.toString()) {
        _windowService.showTaskbar();
      } else if (msg == AppLifecycleState.resumed.toString()) {
        // When app regains focus, check if we have an embedded app
        if (_windowService.embeddedWindowHwnd != null) {
          // Re-enable Alt+Tab blocking
          _keyboardService.setBlockAltTab(true);
          // Refocus embedded app
          _windowService.focusEmbeddedApp();
        }
      }
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
    setState(() {
      // Set loading state to true when beginning to exit
      _windowService.isLoading = true;
      _loadingMessage = "Application closing, please wait...";
    });

    // Show loading indicator while exiting
    Future.delayed(const Duration(milliseconds: 800), () {
      _windowService.exitApplication();
      // App will terminate, so we don't need to set loading back to false
    });
  }

  // Method to close the embedded application and clear sidebar selection
  void _closeEmbeddedApp() {
    setState(() {
      // Set loading state to true when beginning to close the app
      _windowService.isLoading = true;
      _loadingMessage =
          "Closing ${_windowService.currentAppName}, please wait...";
    });

    // Show loading indicator while closing the app
    Future.delayed(const Duration(milliseconds: 500), () {
      _windowService.closeEmbeddedApplication();

      // Clear the selection in the sidebar using the onSelectionChanged callback
      if (_sidebarKey.currentState != null) {
        _sidebarKey.currentState!.clearSelection();
      }

      // Set loading state back to false after closing is complete
      setState(() {
        _windowService.isLoading = false;
        _loadingMessage = "";
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool hasEmbeddedApp = _windowService.embeddedWindowHwnd != null;
    final bool isLoading = _windowService.isLoading;

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
                        child: AppSidebar(
                          key: _sidebarKey, // Add key to access sidebar state
                          onEmbedWord:
                              () => _windowService.embedApplication(
                                'C:\\Program Files (x86)\\Microsoft Office\\Office12\\WINWORD.EXE',
                                'Word',
                                setState,
                              ),
                          onEmbedExcel:
                              () => _windowService.embedApplication(
                                'C:\\Program Files (x86)\\Microsoft Office\\Office12\\EXCEL.EXE',
                                'Excel',
                                setState,
                              ),
                          onEmbedPowerPoint:
                              () => _windowService.embedApplication(
                                'C:\\Program Files (x86)\\Microsoft Office\\Office12\\POWERPNT.EXE',
                                'PowerPoint',
                                setState,
                              ),
                          onSelectionChanged: (selectedApp) {},
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
                                final appPaths = {
                                  'Word':
                                      'C:\\Program Files (x86)\\Microsoft Office\\Office12\\WINWORD.EXE',
                                  'Excel':
                                      'C:\\Program Files (x86)\\Microsoft Office\\Office12\\EXCEL.EXE',
                                  'PowerPoint':
                                      'C:\\Program Files (x86)\\Microsoft Office\\Office12\\POWERPNT.EXE',
                                };

                                if (appPaths.containsKey(currentApp)) {
                                  // Close the app and clear selection
                                  _closeEmbeddedApp();
                                  // Brief delay to allow proper cleanup
                                  Future.delayed(
                                    const Duration(milliseconds: 300),
                                    () {
                                      _windowService.embedApplication(
                                        appPaths[currentApp]!,
                                        currentApp,
                                        setState,
                                      );
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
