import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:screenify/core/utils/extension.dart';
import 'package:screenify/core/widgets/candidate_profile.dart';
import 'package:screenify/core/widgets/global_timer.dart';
import 'package:screenify/domain/entities/questions_entity.dart';

import '../../dashboard/bloc/assessment_bloc.dart';
import '../bloc/mcq_assessment_bloc.dart';
import '../bloc/mcq_assessment_state.dart';

class McqAssessmentScreen extends StatelessWidget {
  final AssessmentEntity mcqData;
  final String? candidateId;

  const McqAssessmentScreen({
    super.key,
    required this.mcqData,
    required this.candidateId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (context) => McqAssessmentBloc(
            assessmentBloc: BlocProvider.of<AssessmentBloc>(context),
            candidateId: candidateId,
            mcqData: mcqData,
          ),
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: BlocConsumer<McqAssessmentBloc, McqAssessmentState>(
          listener: (context, state) {
            // Listen for state changes that require UI feedback
            if (state.isCompleted) {
              Navigator.pop(
                context,
                true,
              ); // Return to assessment list with result
            }
          },
          builder: (context, state) {
            return Scaffold(
              appBar: _buildAssessmentAppBar(context),
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

  AppBar _buildAssessmentAppBar(BuildContext context) {
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
            child: Icon(Icons.app_shortcut, color: Colors.white, size: 24),
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
        CandidateProfile(
          name: candidateId ?? "Candidate",
          candidateId: candidateId ?? "Unknown",
        ),
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

  Widget _buildWideLayout(BuildContext context, McqAssessmentState state) {
    final bloc = BlocProvider.of<McqAssessmentBloc>(context);

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
                      getIconFromString(mcqData.icon),
                      color: Colors.white,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        mcqData.title,
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

              // Progress section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Progress',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  Text(
                    '${state.answeredCount}/${state.questions.length}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Progress bar
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: state.answeredCount / state.questions.length,
                  backgroundColor: Colors.white.withOpacity(0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    state.allQuestionsAnswered ? Colors.green : Colors.white,
                  ),
                  minHeight: 8,
                ),
              ),
              const SizedBox(height: 30),

              // Question indicators
              const Text(
                'Questions',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 15),

              // Question navigation grid
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: List.generate(
                  state.questions.length,
                  (index) => GestureDetector(
                    onTap: () {
                      bloc.pageController.animateToPage(
                        index,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    child: Container(
                      width: 35,
                      height: 35,
                      decoration: BoxDecoration(
                        color:
                            state.currentQuestionIndex == index
                                ? Colors.white
                                : (state.questions[index].isAnswered
                                    ? Colors.green[400]
                                    : Colors.white.withOpacity(0.1)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            color:
                                state.currentQuestionIndex == index
                                    ? Colors.blue[700]
                                    : Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const Spacer(),

              // Tips container
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
                      'Read each question carefully. You can navigate between questions using the numbers above.',
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
                // Main question area
                Expanded(
                  child: PageView.builder(
                    controller: bloc.pageController,
                    onPageChanged: (index) {
                      bloc.changeQuestion(index);
                    },
                    itemCount: state.questions.length,
                    itemBuilder: (context, index) {
                      final question = state.questions[index];
                      return _buildQuestionCard(context, question, index);
                    },
                  ),
                ),

                const SizedBox(height: 16),

                // Navigation buttons
                _buildNavigationButtons(context, state),

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

  Widget _buildQuestionCard(
    BuildContext context,
    QuestionEntity question,
    int questionIndex,
  ) {
    final bloc = BlocProvider.of<McqAssessmentBloc>(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Icon(Icons.help_outline, color: Colors.blue[700]),
                const SizedBox(width: 8),
                BlocBuilder<McqAssessmentBloc, McqAssessmentState>(
                  builder: (context, state) {
                    return Expanded(
                      child: Text(
                        'Question ${state.currentQuestionIndex + 1}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[700],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Question content
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
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      question.question,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Select one answer:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Options
                  Expanded(
                    child: ListView.builder(
                      itemCount: question.options.length,
                      itemBuilder: (context, optionIndex) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color:
                                  question.selectedAnswerIndex == optionIndex
                                      ? Colors.blue[700]!
                                      : Colors.grey[300]!,
                              width:
                                  question.selectedAnswerIndex == optionIndex
                                      ? 2
                                      : 1,
                            ),
                            borderRadius: BorderRadius.circular(8),
                            color:
                                question.selectedAnswerIndex == optionIndex
                                    ? Colors.blue[50]
                                    : Colors.white,
                          ),
                          child: RadioListTile<int>(
                            title: Text(
                              question.options[optionIndex],
                              style: TextStyle(
                                fontWeight:
                                    question.selectedAnswerIndex == optionIndex
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                color:
                                    question.selectedAnswerIndex == optionIndex
                                        ? Colors.blue[700]
                                        : Colors.black87,
                              ),
                            ),
                            value: optionIndex,
                            groupValue: question.selectedAnswerIndex,
                            onChanged: (value) {
                              if (value != null) {
                                bloc.selectAnswer(questionIndex, value);
                              }
                            },
                            activeColor: Colors.blue[700],
                            dense: true,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            selected:
                                question.selectedAnswerIndex == optionIndex,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNavigationButtons(
    BuildContext context,
    McqAssessmentState state,
  ) {
    final bloc = BlocProvider.of<McqAssessmentBloc>(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Previous Button
        SizedBox(
          width: 125,
          height: 50,
          child: ElevatedButton.icon(
            onPressed:
                state.currentQuestionIndex > 0
                    ? () => bloc.previousQuestion()
                    : null,
            icon: const Icon(Icons.arrow_back),
            label: const Text('Previous'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[200],
              foregroundColor: Colors.black87,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),

        // Next/Submit Button
        SizedBox(
          width:
              state.currentQuestionIndex < state.questions.length - 1
                  ? 120
                  : 150,
          height: 48,
          child:
              state.currentQuestionIndex < state.questions.length - 1
                  ? ElevatedButton.icon(
                    onPressed: () => bloc.nextQuestion(),
                    icon: const Text('Next'),
                    label: const Icon(Icons.arrow_forward),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[700],
                      foregroundColor: Colors.white,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  )
                  : ElevatedButton.icon(
                    onPressed:
                        state.allQuestionsAnswered && !state.isSubmitting
                            ? () => _showSubmissionConfirmation(context)
                            : null,
                    icon:
                        state.isSubmitting
                            ? Container(
                              width: 20,
                              height: 20,
                              padding: const EdgeInsets.all(2.0),
                              child: const CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                            : const Icon(Icons.check_circle),
                    label: Text(
                      state.isSubmitting ? 'Submitting...' : 'Submit',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          state.allQuestionsAnswered
                              ? Colors.blue[700]
                              : Colors.grey[400],
                      foregroundColor: Colors.white,
                      elevation: state.allQuestionsAnswered ? 2 : 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
        ),
      ],
    );
  }

  void _showExitConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              'Exit Assessment?',
              style: TextStyle(
                color: Colors.blue[700],
                fontWeight: FontWeight.bold,
              ),
            ),
            content: const Text(
              'You can continue this assessment later. Are you sure you want to exit?',
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context), // Close dialog
                child: Text(
                  'CANCEL',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
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

  void _showSubmissionConfirmation(BuildContext context) {
    // Store the bloc reference from the current context before showing the dialog
    final bloc = BlocProvider.of<McqAssessmentBloc>(context);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (dialogContext) => AlertDialog(
            title: Text(
              'Submit Assessment?',
              style: TextStyle(
                color: Colors.blue[700],
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
                onPressed: () {
                  Navigator.pop(dialogContext); // Close dialog
                },
                child: Text(
                  'CANCEL',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogContext); // Close dialog
                  // Use the previously stored bloc instead of trying to access it from dialog context
                  bloc.submitAssessment();
                },
                child: Text(
                  'SUBMIT',
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
