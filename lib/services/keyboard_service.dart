import 'package:flutter/services.dart';

class KeyboardService {
  // Singleton pattern
  static final KeyboardService _instance = KeyboardService._internal();
  factory KeyboardService() => _instance;
  KeyboardService._internal();

  void registerKeyboardHandler() {
    ServicesBinding.instance.keyboard.addHandler(_handleKeyboardEvent);
  }

  void unregisterKeyboardHandler() {
    ServicesBinding.instance.keyboard.removeHandler(_handleKeyboardEvent);
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
}
