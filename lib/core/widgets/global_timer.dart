import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../utils/timer_provider.dart';

class GlobalTimerWidget extends StatelessWidget {
  const GlobalTimerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TimerProvider>(
      builder: (context, timerProvider, _) {
        // Format the time as MM:SS
        final timeText = timerProvider.formattedTime;

        // Determine color based on time remaining (red when < 5 minutes)
        final Color timeColor =
            timerProvider.remainingTimeInSeconds < 300
                ? Colors.green
                : Colors.red[800]!;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                spreadRadius: 1,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.timer, size: 20, color: timeColor),
              const SizedBox(width: 6),
              Text(
                timeText,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: timeColor,
                ),
              ),
              // if (!timerProvider.isRunning && !timerProvider.isComplete) ...[
              //   const SizedBox(width: 4),
              //   InkWell(
              //     onTap: timerProvider.startTimer,
              //     child: const Icon(
              //       Icons.play_arrow,
              //       size: 18,
              //       color: Colors.green,
              //     ),
              //   ),
              // ] else if (timerProvider.isRunning) ...[
              //   const SizedBox(width: 4),
              //   InkWell(
              //     onTap: timerProvider.pauseTimer,
              //     child: const Icon(
              //       Icons.pause,
              //       size: 18,
              //       color: Colors.orange,
              //     ),
              //   ),
              // ],
              // const SizedBox(width: 4),
              // InkWell(
              //   onTap: timerProvider.resetTimer,
              //   child: const Icon(
              //     Icons.restart_alt,
              //     size: 18,
              //     color: Colors.blue,
              //   ),
              // ),
            ],
          ),
        );
      },
    );
  }
}
