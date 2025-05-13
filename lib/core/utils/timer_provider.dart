import 'dart:async';

import 'package:flutter/material.dart';

import '../route/app_route.dart';

class TimerProvider extends ChangeNotifier {
  // Total duration in minutes
  final int durationInMinutes;

  // Remaining time in seconds
  int _remainingTimeInSeconds;

  // Timer instance
  Timer? _timer;

  // Timer status
  bool _isRunning = false;
  bool _isComplete = false;

  // Completion callback
  final VoidCallback? onTimerComplete;

  // BuildContext for showing dialogs
  BuildContext? _context;

  // Constructor
  TimerProvider({
    required this.durationInMinutes,
    this.onTimerComplete,
    bool autoStart = false,
  }) : _remainingTimeInSeconds = durationInMinutes * 60 {
    // Auto-start timer if specified
    if (autoStart) {
      _isRunning = true;
      _startTimerInternal();
    }
  }

  // Set context for showing dialogs
  void setContext(BuildContext context) {
    _context = context;
  }

  // Getters
  int get remainingTimeInSeconds => _remainingTimeInSeconds;
  bool get isRunning => _isRunning;
  bool get isComplete => _isComplete;

  // Format time as MM:SS
  String get formattedTime {
    final minutes = (_remainingTimeInSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_remainingTimeInSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  // Private method to handle the actual timer logic
  void _startTimerInternal() {
    // Only start if not already running
    if (_timer != null) return;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTimeInSeconds > 0) {
        _remainingTimeInSeconds--;

        // Check for 10-minute mark
        if (_remainingTimeInSeconds == 600) {
          _showTenMinuteWarning();
        }

        notifyListeners();
      } else {
        _isComplete = true;
        _isRunning = false;
        _timer?.cancel();
        _timer = null;
        if (onTimerComplete != null) {
          onTimerComplete!();
        }
        notifyListeners();
      }
    });
  }

  // Start the timer
  void startTimer([BuildContext? context]) {
    if (_isComplete) return;

    if (context != null) {
      _context = context;
    }

    if (_isRunning) return;

    _isRunning = true;
    _startTimerInternal();
    notifyListeners();
  }

  void _showTenMinuteWarning() {
    // Use AppRouter.showGlobalDialog instead of direct context

    AppRouter.showGlobalDialog(
      title: 'Only 10 Minutes Remaining',
      message:
          'Please submit all completed tasks. If any assessments are pending, complete them quickly.',
      buttonText: 'Okay',
    );
  }

  // Pause the timer
  void pauseTimer() {
    if (!_isRunning) return;

    _isRunning = false;
    _timer?.cancel();
    _timer = null;
    notifyListeners();
  }

  // Resume the timer
  void resumeTimer() {
    if (_isRunning || _isComplete) return;

    _isRunning = true;
    _startTimerInternal();
    notifyListeners();
  }

  // Reset the timer
  void resetTimer() {
    _timer?.cancel();
    _timer = null;
    _isRunning = false;
    _isComplete = false;
    _remainingTimeInSeconds = durationInMinutes * 60;
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
