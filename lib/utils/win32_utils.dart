import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart';

class Win32Utils {
  // Global variable to store the target PID and result HWND
  static int _targetPid = 0;
  static int _resultHwnd = 0;

  // Static callback function for EnumWindows
  static int _enumWindowsCallback(int hWnd, int lParam) {
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
  static final _enumWindowsProcPointer = Pointer.fromFunction<WNDENUMPROC>(
    _enumWindowsCallback,
    1,
  );

  static int findWindowByPid(int pid) {
    // Set the target PID
    _targetPid = pid;
    _resultHwnd = 0;

    // Enumerate windows
    EnumWindows(_enumWindowsProcPointer, 0);

    return _resultHwnd;
  }
}
