import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CountdownTimer extends StatefulWidget {
  final int durationInMinutes;
  final Function()? onTimerComplete;
  final bool autoStart;

  const CountdownTimer({
    super.key,
    this.durationInMinutes = 60,
    this.onTimerComplete,
    this.autoStart = false,
  });

  @override
  CountdownTimerState createState() => CountdownTimerState();
}

class CountdownTimerState extends State<CountdownTimer> {
  late Timer _timer;
  late int _secondsRemaining;
  bool _isRunning = false;

  @override
  void initState() {
    super.initState();
    _secondsRemaining = widget.durationInMinutes * 60;

    // Auto-start timer if specified
    if (widget.autoStart) {
      // Use a post-frame callback to ensure the widget is fully built
      WidgetsBinding.instance.addPostFrameCallback((_) {
        startTimer();
      });
    }
  }

  @override
  void dispose() {
    if (_isRunning) {
      _timer.cancel();
    }
    super.dispose();
  }

  void startTimer() {
    if (!_isRunning) {
      _isRunning = true;
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          if (_secondsRemaining > 0) {
            _secondsRemaining--;
          } else {
            _timer.cancel();
            _isRunning = false;
            if (widget.onTimerComplete != null) {
              widget.onTimerComplete!();
            }
          }
        });
      });
    }
  }

  void pauseTimer() {
    if (_isRunning) {
      _timer.cancel();
      setState(() {
        _isRunning = false;
      });
    }
  }

  void resetTimer() {
    if (_isRunning) {
      _timer.cancel();
    }
    setState(() {
      _secondsRemaining = widget.durationInMinutes * 60;
      _isRunning = false;
    });
  }

  String get timerText {
    int hours = _secondsRemaining ~/ 3600;
    int minutes = (_secondsRemaining % 3600) ~/ 60;
    int seconds = _secondsRemaining % 60;

    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color:
            _isRunning
                ? _secondsRemaining < 300
                    ? Colors.red[100]
                    : Colors.blue[50]
                : Colors.grey[200],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color:
              _isRunning
                  ? _secondsRemaining < 300
                      ? Colors.red
                      : Colors.blue
                  : Colors.grey,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.timer,
            size: 18,
            color: _isRunning ? Colors.blue[700] : Colors.grey[700],
          ),
          const SizedBox(width: 4),
          Text(
            timerText,
            style: GoogleFonts.poppins(
              color:
                  _isRunning
                      ? _secondsRemaining < 300
                          ? Colors.red[800]
                          : Colors.blue[800]
                      : Colors.grey[700],
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          //const SizedBox(width: 8),
          // GestureDetector(
          //   onTap: _isRunning ? pauseTimer : startTimer,
          //   child: Icon(
          //     _isRunning ? Icons.pause : Icons.play_arrow,
          //     size: 18,
          //     color: _isRunning ? Colors.blue[700] : Colors.grey[700],
          //   ),
          // ),
          // const SizedBox(width: 4),
          // GestureDetector(
          //   onTap: resetTimer,
          //   child: Icon(Icons.refresh, size: 18, color: Colors.grey[700]),
          // ),
        ],
      ),
    );
  }
}
