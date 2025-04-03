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

  @override
  void initState() {
    super.initState();
    _keyboardService.registerKeyboardHandler();

    // Set up app lifecycle monitoring
    SystemChannels.lifecycle.setMessageHandler((msg) async {
      if (msg == AppLifecycleState.detached.toString()) {
        _windowService.showTaskbar();
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
                      ? 'Office App Embedder'
                      : 'Office App Embedder - ${_windowService.currentAppName}',
                  style: const TextStyle(
                    color: Color(0xFF2C3E50),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            automaticallyImplyLeading: false,
            actions: [
              if (hasEmbeddedApp)
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      _windowService.closeEmbeddedApplication();
                      setState(() {});
                    },
                    label: Text('Close ${_windowService.currentAppName}'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red[700],
                      side: BorderSide(color: Colors.red[700]!),
                    ),
                  ),
                ),
              // Exit button - only enabled if no windows are open
              Tooltip(
                message:
                    hasEmbeddedApp
                        ? 'Close open applications first'
                        : 'Exit Application',
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color:
                        hasEmbeddedApp
                            ? Colors.grey.withOpacity(0.1)
                            : Colors.red.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.exit_to_app),
                    onPressed:
                        hasEmbeddedApp
                            ? null // Disable when windows are open
                            : _windowService.exitApplication,
                    color: hasEmbeddedApp ? Colors.grey[400] : Colors.red[700],
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
                  if (_windowService.embeddedWindowHwnd != null) {
                    SetForegroundWindow(_windowService.embeddedWindowHwnd!);
                    SetFocus(_windowService.embeddedWindowHwnd!);
                    _windowService.hideTaskbar();
                  }
                },
                behavior: HitTestBehavior.translucent,
                child: Row(
                  children: [
                    AppSidebar(
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
                    ),
                    EmbeddedAppContainer(
                      embeddedAreaKey: _windowService.embeddedAreaKey,
                      hasEmbeddedApp: hasEmbeddedApp,
                      onMouseEnter: () {
                        if (_windowService.embeddedWindowHwnd != null) {
                          SetForegroundWindow(
                            _windowService.embeddedWindowHwnd!,
                          );
                          SetFocus(_windowService.embeddedWindowHwnd!);
                          _windowService.hideTaskbar();
                        }
                      },
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
