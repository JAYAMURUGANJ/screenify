import 'dart:async';

import 'package:flutter/material.dart';

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

  // Constructor
  TimerProvider({
    required this.durationInMinutes,
    this.onTimerComplete,
    bool autoStart = false,
  }) : _remainingTimeInSeconds = durationInMinutes * 60 {
    if (autoStart) {
      startTimer();
    }
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

  // Start the timer
  void startTimer() {
    if (_isRunning || _isComplete) return;

    _isRunning = true;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTimeInSeconds > 0) {
        _remainingTimeInSeconds--;
        notifyListeners();
      } else {
        _isComplete = true;
        _isRunning = false;
        _timer?.cancel();
        if (onTimerComplete != null) {
          onTimerComplete!();
        }
        notifyListeners();
      }
    });

    notifyListeners();
  }

  // Pause the timer
  void pauseTimer() {
    if (!_isRunning) return;

    _isRunning = false;
    _timer?.cancel();
    notifyListeners();
  }

  // Reset the timer
  void resetTimer() {
    _timer?.cancel();
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
