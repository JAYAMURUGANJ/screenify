import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:screenify/core/utils/extension.dart';
import 'package:screenify/core/widgets/global_timer.dart';
import 'package:screenify/domain/entities/questions_entity.dart';
import 'package:screenshot/screenshot.dart';

import '../../../core/widgets/candidate_profile.dart';
import '../../dashboard/bloc/assessment_bloc.dart';
import '../bloc/typing_assessment_bloc.dart';
import '../bloc/typing_assessment_state.dart';

class TypingAssessmentScreen extends StatelessWidget {
  final String candidateId;
  final AssessmentEntity typingData;

  const TypingAssessmentScreen({
    super.key,
    required this.candidateId,
    required this.typingData,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (context) => TypingAssessmentBloc(
            assessmentBloc: BlocProvider.of<AssessmentBloc>(context),
            candidateId: candidateId,
            typingData: typingData,
          ),
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: BlocConsumer<TypingAssessmentBloc, TypingAssessmentState>(
          listener: (context, state) {
            // Listen for state changes that require UI feedback
            if (state.isCompleted) {
              Navigator.pop(
                context,
                true,
              ); // Return to assessment list with result
            }

            if (state.error != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.error!),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            return Scaffold(
              appBar: _assessmentAppBar(context),
              body: Screenshot(
                controller: ScreenshotController(),
                child: Container(
                  color: Colors.grey[50],
                  child: _buildWideLayout(context, state),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  AppBar _assessmentAppBar(BuildContext context) {
    final MaterialColor blueColor = Colors.blue;

    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: blueColor[700],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.app_shortcut,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Screenify',
            style: GoogleFonts.poppins(
              color: blueColor[700],
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      actions: [
        const GlobalTimerWidget(),
        const SizedBox(width: 5),
        CandidateProfile(name: candidateId, candidateId: candidateId),
        const SizedBox(width: 5),
        IconButton(
          icon: Icon(Icons.close, color: Colors.grey[700]),
          onPressed: () {
            _showExitConfirmation(context);
          },
        ),
      ],
    );
  }

  Widget _buildWideLayout(BuildContext context, TypingAssessmentState state) {
    final bloc = BlocProvider.of<TypingAssessmentBloc>(context);
    final MaterialColor blueColor = Colors.blue;
    return Row(
      children: [
        // Left sidebar - Branding and instructions
        Container(
          width: 300,
          color: blueColor[700],
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      getIconFromString(typingData.icon),
                      color: Colors.white,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        state.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                'Instructions',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 15),
              Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      state.description,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.instructions,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.tips_and_updates,
                      color: Colors.white,
                      size: 28,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Assessment Tips',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Take your time and focus on accuracy. Pay attention to spelling, punctuation and formatting.',
                      style: TextStyle(color: blueColor[50], fontSize: 13),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),

        // Main content area
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                // Instructions Card
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.assignment, color: blueColor[700]),
                            const SizedBox(width: 8),
                            Text(
                              'Typing Assessment',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: blueColor[700],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Sample Text:',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          state.sampleText,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Typing Section
                Expanded(
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.keyboard, color: blueColor[700]),
                              const SizedBox(width: 8),
                              Text(
                                'Type Here:',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: blueColor[700],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Expanded(
                            child: TextField(
                              controller: TextEditingController(
                                  text: state.typedText,
                                )
                                ..selection = TextSelection.fromPosition(
                                  TextPosition(offset: state.typedText.length),
                                ),
                              onChanged: (text) => bloc.updateTypedText(text),
                              maxLines: null,
                              expands: true,
                              enabled: !state.isSubmitting,
                              textAlignVertical: TextAlignVertical.top,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                hintText:
                                    'Type here to match the sample text...',
                                filled: true,
                                fillColor:
                                    state.isSubmitting
                                        ? Colors.grey[100]
                                        : Colors.white,
                                alignLabelWithHint: true,
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                    color: blueColor[700]!,
                                    width: 2,
                                  ),
                                ),
                              ),
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Action button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed:
                        state.isSubmitting
                            ? () => bloc.resetTest()
                            : () => _handleSubmit(context),
                    icon: Icon(
                      state.isSubmitting ? Icons.refresh : Icons.check_circle,
                    ),
                    label: Text(
                      state.isSubmitting ? 'Try Again' : 'Submit',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: blueColor[700],
                      foregroundColor: Colors.white,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Footer
                Text(
                  '© ${DateTime.now().year} Screenify. All rights reserved.',
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _handleSubmit(BuildContext context) {
    final bloc = BlocProvider.of<TypingAssessmentBloc>(context);

    // Calculate score
    final Map<String, dynamic> results = bloc.calculateScore();

    // Print results to terminal as a single string (for debugging)
    debugPrint(results.toString());

    // Show confirmation dialog
    _showSubmissionConfirmation(context, results);
  }

  void _showSubmissionConfirmation(
    BuildContext context,
    Map<String, dynamic> results,
  ) {
    // Store the bloc reference from the current context before showing the dialog
    final bloc = BlocProvider.of<TypingAssessmentBloc>(context);
    final MaterialColor blueColor = Colors.blue;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (dialogContext) => AlertDialog(
            title: Text(
              'Submit Assessment?',
              style: TextStyle(
                color: blueColor[700],
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Text(
              'Are you sure you want to submit this assessment? You cannot make changes after submission.',
              style: TextStyle(color: Colors.grey[700]),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext), // Close dialog
                child: Text(
                  'CANCEL',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogContext); // Close dialog
                  bloc.submitAssessment(results);
                },
                child: Text(
                  'SUBMIT',
                  style: TextStyle(
                    color: blueColor[700],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
    );
  }

  void _showExitConfirmation(BuildContext context) {
    final MaterialColor blueColor = Colors.blue;

    showDialog(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: Text(
              'Exit Assessment?',
              style: TextStyle(
                color: blueColor[700],
                fontWeight: FontWeight.bold,
              ),
            ),
            content: const Text(
              'You can continue this assessment later. '
              'Are you sure you want to exit?',
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext), // Close dialog
                child: Text(
                  'CANCEL',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogContext); // Close dialog
                  Navigator.pop(context, true); // Return to assessment list
                },
                child: Text(
                  'EXIT',
                  style: TextStyle(
                    color: blueColor[700],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
    );
  }
}
