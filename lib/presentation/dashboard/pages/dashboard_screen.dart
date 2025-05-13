import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '/core/route/app_route.dart';
import '/core/utils/extension.dart';
import '/core/widgets/candidate_profile.dart';
import '/core/widgets/department_details.dart';
import '/core/widgets/global_timer.dart';
import '/domain/entities/questions_entity.dart';
import '../../../core/local/assessment_database_helper.dart';
import '../../../core/widgets/completion_dialog.dart';
import '../bloc/assessment_bloc.dart';
import '../bloc/assessment_event.dart';
import '../bloc/assessment_state.dart';

class DashboardScreen extends StatefulWidget {
  final QuestionsEntity assessmentDetails;

  const DashboardScreen({super.key, required this.assessmentDetails});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final AssessmentDatabaseHelper _dbHelper = AssessmentDatabaseHelper();

  int _selectedTabIndex = 0;
  bool _checkedCompletionStatus = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_handleTabChange);

    // Initialize Bloc with assessments data
    _loadAssessmentsFromEntity();
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging) {
      _selectedTabIndex = _tabController.index;
      // Use Bloc for tab selection
      context.read<AssessmentBloc>().add(
        ChangeTabEvent(tabIndex: _selectedTabIndex),
      );
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<String> getCandidateAssessmentResultsJson(String candidateId) async {
    final resultsMap = await _dbHelper.getAllAssessmentResults(candidateId);
    return jsonEncode(resultsMap);
  }

  void _loadAssessmentsFromEntity() {
    // Dispatch Bloc event to refresh assessment statuses
    context.read<AssessmentBloc>().add(
      RefreshAssessmentStatusesEvent(
        candidateId: widget.assessmentDetails.candidateId,
        assessments: widget.assessmentDetails.assessments,
      ),
    );
  }

  void _checkAllAssessmentsCompleted(List<AssessmentEntity> assessments) {
    if (_checkedCompletionStatus) return;

    // Filter assessments by candidateId

    // Check if all assessments for the candidate are completed
    bool allCompleted = assessments.every(
      (assessment) =>
          assessment.status == AssessmentDatabaseHelper.STATUS_COMPLETED,
    );

    // Check if there are exactly 4 unique assessment types for this candidate
    int assessmentTypeCount = assessments.length;

    if (allCompleted && assessmentTypeCount == 4) {
      _checkedCompletionStatus = true;
      // Show completion dialog
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return CompletionDialog(
              candidateId: widget.assessmentDetails.candidateId,
            );
          },
        );
      });
    }
  }

  Future<void> _navigateToAssessment(AssessmentEntity assessment) async {
    // Mark assessment as started using BLoC
    context.read<AssessmentBloc>().add(
      MarkAssessmentStartedEvent(
        candidateId: widget.assessmentDetails.candidateId,
        assessmentType: assessment.type,
      ),
    );

    // Use named routes for navigation
    String? route;
    Map<String, dynamic> arguments = {
      'candidateId': widget.assessmentDetails.candidateId,
    };

    if (assessment.type.toLowerCase().contains('email')) {
      route = AppRouter.emailAssessment;
      arguments['emailData'] = assessment; // Pass the entire assessment entity
    } else if (assessment.type.toLowerCase().contains('mcq')) {
      route = AppRouter.mcqAssessment;
      arguments['mcqData'] =
          assessment; // Pass the assessment entity as mcqData
    } else if (assessment.type.toLowerCase().contains('typing')) {
      route = AppRouter.typingAssessment;
      arguments['typingData'] = assessment;
    } else if (assessment.type.toLowerCase().contains('form')) {
      route = AppRouter.formFillingAssessment;
      arguments['formFillingData'] = assessment;
    }

    if (route != null) {
      await Navigator.pushNamed(context, route, arguments: arguments);
    }

    // Refresh the assessment status after returning
    _refreshAssessmentStatuses();
  }

  Future<void> _refreshAssessmentStatuses() async {
    // Use BLoC to refresh assessment statuses
    context.read<AssessmentBloc>().add(
      RefreshAssessmentStatusesEvent(
        candidateId: widget.assessmentDetails.candidateId,
        assessments: widget.assessmentDetails.assessments,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: BlocBuilder<AssessmentBloc, AssessmentState>(
        builder: (context, state) {
          if (state is AssessmentLoading) {
            return Scaffold(
              backgroundColor: Colors.grey[50],
              appBar: _buildAppBar(),
              body: _buildLoadingView(),
            );
          } else if (state is AssessmentsLoaded) {
            // Check if all assessments are completed
            _checkAllAssessmentsCompleted(state.assessments);

            return Scaffold(
              backgroundColor: Colors.grey[50],
              appBar: _buildAppBar(),
              body: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DepartmentDetails(),
                  // Tab Bar
                  _buildTabBar(),
                  // Assessments list
                  _buildAssessmentList(state),
                ],
              ),
            );
          } else if (state is AssessmentError) {
            return Scaffold(
              backgroundColor: Colors.grey[50],
              appBar: _buildAppBar(),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error, size: 80, color: Colors.red[400]),
                    const SizedBox(height: 16),
                    Text(
                      'Error',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.red[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.message,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _refreshAssessmentStatuses,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[700],
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else {
            // Initial state or other states
            return Scaffold(
              backgroundColor: Colors.grey[50],
              appBar: _buildAppBar(),
              body: _buildLoadingView(),
            );
          }
        },
      ),
    );
  }

  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Colors.blue[700]),
          const SizedBox(height: 16),
          Text(
            'Loading assessments...',
            style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }

  Expanded _buildAssessmentList(AssessmentsLoaded state) {
    final filteredAssessments = state.filteredAssessments;

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 16, bottom: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Available Assessments',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2C3E50),
                    ),
                  ),
                  // Add refresh button
                  IconButton(
                    icon: const Icon(Icons.restart_alt_outlined),
                    onPressed: _refreshAssessmentStatuses,
                    tooltip: 'Refresh assessment statuses',
                    color: Colors.blue[700],
                  ),
                ],
              ),
            ),
            filteredAssessments.isEmpty
                ? _buildNoAssessmentsFound()
                : Expanded(
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          crossAxisSpacing: 20,
                          mainAxisSpacing: 16,
                          childAspectRatio: 1.2,
                        ),
                    itemCount: filteredAssessments.length,
                    itemBuilder: (context, index) {
                      final assessment = filteredAssessments[index];
                      return _buildAssessmentCard(assessment);
                    },
                  ),
                ),
          ],
        ),
      ),
    );
  }

  Container _buildTabBar() {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        labelColor: Colors.blue[700],
        unselectedLabelColor: Colors.grey[600],
        indicatorColor: Colors.blue[700],
        indicatorWeight: 3,
        indicatorSize: TabBarIndicatorSize.tab,
        labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        tabs: const [
          Tab(text: 'ALL'),
          Tab(text: 'COMPLETED'),
          Tab(text: 'PENDING'),
          Tab(text: 'NOT OPENED'),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
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
              color: const Color(0xFF2C3E50),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      actions: [
        GlobalTimerWidget(),
        const SizedBox(width: 12),
        CandidateProfile(
          name: widget.assessmentDetails.candidateName,
          candidateId: widget.assessmentDetails.candidateId,
        ),
      ],
    );
  }

  Widget _buildAssessmentCard(AssessmentEntity assessment) {
    // Get icon from icon string
    IconData assessmentIcon = getIconFromString(assessment.icon);

    // Determine button style and text based on status
    Widget actionButton;
    switch (assessment.status) {
      case AssessmentDatabaseHelper.STATUS_PENDING:
        actionButton = ElevatedButton(
          onPressed: () async {
            // Continue assessment
            await _navigateToAssessment(assessment);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
            elevation: 2,
            shadowColor: Colors.orange.withOpacity(0.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          child: const Text('Continue'),
        );
        break;
      case AssessmentDatabaseHelper.STATUS_COMPLETED:
        actionButton = OutlinedButton(
          onPressed: () {
            // View result or details if needed
          },
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.green[700],
            side: BorderSide(color: Colors.green[700]!),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          child: const Text('Completed'),
        );
        break;
      case AssessmentDatabaseHelper.STATUS_NOT_OPENED:
      default:
        actionButton = ElevatedButton(
          onPressed: () async {
            // Navigate to assessment screen
            await _navigateToAssessment(assessment);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue[700],
            foregroundColor: Colors.white,
            elevation: 2,
            shadowColor: Colors.blue.withOpacity(0.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          child: const Text('Start Now'),
        );
        break;
    }

    return Card(
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.blue[100]!, width: 1),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, Colors.blue[50]!],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row with icon and status badge
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.blue[100],
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue[300]!.withOpacity(0.3),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(assessmentIcon, color: Colors.blue[700], size: 24),
            ),
            const SizedBox(height: 16),

            // Title
            Text(
              assessment.title,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF2C3E50),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),

            // Description
            Expanded(
              child: Text(
                assessment.description,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey[700],
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // Action button
            SizedBox(width: double.infinity, child: actionButton),
          ],
        ),
      ),
    );
  }

  // Widget to show when no assessments are found
  Widget _buildNoAssessmentsFound() {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assignment_outlined, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No assessments found',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try changing filters or check back later',
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[500]),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _refreshAssessmentStatuses,
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[700],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
