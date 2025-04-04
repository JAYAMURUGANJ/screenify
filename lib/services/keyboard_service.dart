import 'package:flutter/services.dart';

import 'window_service.dart';

class KeyboardService {
  // Singleton pattern
  static final KeyboardService _instance = KeyboardService._internal();
  factory KeyboardService() => _instance;
  KeyboardService._internal();

  // Reference to WindowService to check embedded app status
  final WindowService _windowService = WindowService();
  bool _blockAltTab = false;

  void registerKeyboardHandler() {
    ServicesBinding.instance.keyboard.addHandler(_handleKeyboardEvent);

    // Start blocking Alt+Tab when an app is embedded
    _blockAltTab = _windowService.embeddedWindowHwnd != null;
  }

  void unregisterKeyboardHandler() {
    ServicesBinding.instance.keyboard.removeHandler(_handleKeyboardEvent);
    _blockAltTab = false;
  }

  // Enable or disable Alt+Tab blocking
  void setBlockAltTab(bool block) {
    _blockAltTab = block;
  }

  // Handle keyboard events to block Alt+Tab and other window switching combinations
  bool _handleKeyboardEvent(KeyEvent event) {
    // Only block navigation keys when blocking is enabled
    if (_blockAltTab) {
      if (event is KeyDownEvent) {
        // Block Alt+Tab
        if (event.logicalKey == LogicalKeyboardKey.tab &&
            (HardwareKeyboard.instance.isAltPressed ||
                HardwareKeyboard.instance.isMetaPressed)) {
          return true; // Event handled, don't propagate
        }

        // Block Alt+Esc
        if (event.logicalKey == LogicalKeyboardKey.escape &&
            HardwareKeyboard.instance.isAltPressed) {
          return true;
        }

        // Block Windows key
        if (event.logicalKey == LogicalKeyboardKey.metaLeft ||
            event.logicalKey == LogicalKeyboardKey.metaRight) {
          return true;
        }

        // Block Ctrl+Alt+Delete alternatives
        if (event.logicalKey == LogicalKeyboardKey.delete &&
            HardwareKeyboard.instance.isAltPressed &&
            HardwareKeyboard.instance.isControlPressed) {
          return true;
        }

        // Block Alt+F4 to prevent closing the embedded app directly
        if (event.logicalKey == LogicalKeyboardKey.f4 &&
            HardwareKeyboard.instance.isAltPressed) {
          return true;
        }
      }
    }

    return false; // Not handled, continue propagation
  }
}
