import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:screenify/core/utils/extension.dart';
import 'package:screenify/core/widgets/global_timer.dart';
import 'package:screenify/domain/entities/questions_entity.dart';

import '../../../core/route/app_route.dart';
import '../../../core/widgets/candidate_profile.dart';
import '../../dashboard/bloc/assessment_bloc.dart';
import '../bloc/email_assessment_bloc.dart';
import '../bloc/email_assessment_state.dart';

class EmailAssessmentScreen extends StatelessWidget {
  final String candidateId;
  final AssessmentEntity emailData;

  const EmailAssessmentScreen({
    super.key,
    required this.candidateId,
    required this.emailData,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (context) => EmailAssessmentBloc(
            assessmentBloc: BlocProvider.of<AssessmentBloc>(context),
            candidateId: candidateId,
            emailData: emailData,
          ),
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: BlocConsumer<EmailAssessmentBloc, EmailAssessmentState>(
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
              body: Container(
                color: Colors.grey[50],
                child: _buildWideLayout(context, state),
              ),
            );
          },
        ),
      ),
    );
  }

  AppBar _assessmentAppBar(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue[700],
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
              color: Colors.blue[700],
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

  Widget _buildWideLayout(BuildContext context, EmailAssessmentState state) {
    final bloc = BlocProvider.of<EmailAssessmentBloc>(context);
    final scenario = state.scenario;

    return Row(
      children: [
        // Left sidebar - Branding and details
        Container(
          width: 300,
          color: Colors.blue[700],
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
                      getIconFromString(emailData.icon),
                      color: Colors.white,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        emailData.title,
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
                'Hint',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 15),
              Expanded(
                child: ListView.builder(
                  itemBuilder: (_, index) {
                    final hint = scenario.hints[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.lightbulb,
                            color: Colors.amber[700],
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              hint,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.white70,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  itemCount: scenario.hints.length,
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
                      'Read instructions carefully and double-check your work before submission.',
                      style: TextStyle(color: Colors.blue[50], fontSize: 13),
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
                // Scenario Card
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
                            Icon(Icons.assignment, color: Colors.blue[700]),
                            const SizedBox(width: 8),
                            Text(
                              scenario.description,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[700],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Instructions:',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          scenario.instruction,
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

                // Email Composition Section
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
                              Icon(Icons.email, color: Colors.blue[700]),
                              const SizedBox(width: 8),
                              Text(
                                'Compose Email:',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue[700],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Email form fields
                          _buildEmailField(
                            context: context,
                            value: state.to,
                            onChanged: bloc.updateTo,
                            label: 'To',
                            icon: Icons.person,
                            enabled: !state.isSubmitting,
                          ),
                          const SizedBox(height: 8),
                          _buildEmailField(
                            context: context,
                            value: state.cc,
                            onChanged: bloc.updateCc,
                            label: 'CC',
                            icon: Icons.person_add,
                            enabled: !state.isSubmitting,
                          ),
                          const SizedBox(height: 8),
                          _buildEmailField(
                            context: context,
                            value: state.subject,
                            onChanged: bloc.updateSubject,
                            label: 'Subject',
                            icon: Icons.subject,
                            enabled: !state.isSubmitting,
                          ),
                          const SizedBox(height: 8),
                          Expanded(
                            child: _buildEmailBody(
                              context: context,
                              value: state.body,
                              onChanged: bloc.updateBody,
                              enabled: !state.isSubmitting,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Action buttons
                _buildActionButton(context, state),

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

  Widget _buildEmailField({
    required BuildContext context,
    required String value,
    required Function(String) onChanged,
    required String label,
    required IconData icon,
    required bool enabled,
  }) {
    return TextFormField(
      initialValue: value,
      enabled: enabled,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        prefixIcon: Icon(icon, color: Colors.blue[700]),
        filled: true,
        fillColor: enabled ? Colors.white : Colors.grey[100],
        labelStyle: TextStyle(color: Colors.grey[700]),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.blue[700]!, width: 2),
        ),
      ),
    );
  }

  Widget _buildEmailBody({
    required BuildContext context,
    required String value,
    required Function(String) onChanged,
    required bool enabled,
  }) {
    return TextField(
      maxLines: null,
      expands: true,
      enabled: enabled,
      controller: TextEditingController(text: value)
        ..selection = TextSelection.fromPosition(
          TextPosition(offset: value.length),
        ),
      onChanged: onChanged,
      textAlignVertical: TextAlignVertical.top,
      decoration: InputDecoration(
        labelText: 'Message',
        alignLabelWithHint: true,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        filled: true,
        fillColor: enabled ? Colors.white : Colors.grey[100],
        labelStyle: TextStyle(color: Colors.grey[700]),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.blue[700]!, width: 2),
        ),
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, EmailAssessmentState state) {
    final bloc = BlocProvider.of<EmailAssessmentBloc>(context);

    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        onPressed:
            state.isSubmitting
                ? () => bloc.resetTest()
                : () => _handleSubmit(context),
        icon: Icon(state.isSubmitting ? Icons.refresh : Icons.check_circle),
        label: Text(
          state.isSubmitting ? 'Try Again' : 'Submit',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue[700],
          foregroundColor: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  void _handleSubmit(BuildContext context) {
    final bloc = BlocProvider.of<EmailAssessmentBloc>(context);

    // Calculate score
    final results = bloc.calculateScore();

    // Print results to terminal as a single string (for debugging)
    debugPrint(const JsonEncoder().convert(results));

    // Show confirmation dialog
    _showSubmissionConfirmation(context, results);
  }

  void _showSubmissionConfirmation(
    BuildContext context,
    Map<String, dynamic> results,
  ) {
    // Store the bloc reference from the current context
    final bloc = BlocProvider.of<EmailAssessmentBloc>(context);

    AppRouter.showGlobalDialog(
      title: 'Submit Assessment?',
      message:
          'Are you sure you want to submit this assessment? You cannot make changes after submission.',
      buttonText: 'SUBMIT',
      secondaryButtonText: 'CANCEL',
      primaryCallback: () {
        // This will run when the user clicks SUBMIT
        bloc.submitAssessment(results);
      },
      secondaryCallback: () {
        // This will run when the user clicks CANCEL
        // No action needed for cancel
      },
    );
  }

  void _showExitConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: Text(
              'Exit Assessment?',
              style: TextStyle(
                color: Colors.blue[700],
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
                    color: Colors.blue[700],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
    );
  }
}
