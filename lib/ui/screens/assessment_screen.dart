import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:screenify/ui/screens/Typing_screen.dart';
import 'package:screenify/ui/screens/email_screen.dart';
import 'package:screenify/ui/screens/mcq_screen.dart';
import 'package:screenify/ui/widgets/department_details.dart';
import 'package:screenify/ui/widgets/global_timer.dart';
import 'package:screenify/utils/extension.dart';

import '../../domain/api/assessment_service.dart';
import '../../domain/local/assessment_manager.dart';
import '../../domain/model/assessment_data.dart';
import '../widgets/candidate_profile.dart';
import 'form_screen.dart';

class AssessmentsScreen extends StatefulWidget {
  final String candidateId;

  const AssessmentsScreen({super.key, required this.candidateId});

  @override
  State<AssessmentsScreen> createState() => _AssessmentsScreenState();
}

class _AssessmentsScreenState extends State<AssessmentsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final AssessmentService _assessmentService = AssessmentService();
  final AssessmentDatabaseHelper _dbHelper = AssessmentDatabaseHelper();

  bool _isLoading = true;
  List<Assessment> _assessments = [];
  List<Assessment> _filteredAssessments = [];
  late String _candidateName;
  int _selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_handleTabChange);
    _candidateName = "Candidate"; // Default value
    _loadCandidateInfo();
    _loadAllAssessments();
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging) {
      setState(() {
        _selectedTabIndex = _tabController.index;
        _filterAssessments(_selectedTabIndex);
      });
    }
  }

  void _filterAssessments(int tabIndex) {
    setState(() {
      if (tabIndex == 0) {
        _filteredAssessments = List.from(_assessments);
      } else if (tabIndex == 1) {
        _filteredAssessments =
            _assessments
                .where(
                  (a) => a.status == AssessmentDatabaseHelper.STATUS_PENDING,
                )
                .toList();
      } else if (tabIndex == 2) {
        _filteredAssessments =
            _assessments
                .where(
                  (a) => a.status == AssessmentDatabaseHelper.STATUS_COMPLETED,
                )
                .toList();
      } else if (tabIndex == 3) {
        _filteredAssessments =
            _assessments
                .where(
                  (a) => a.status == AssessmentDatabaseHelper.STATUS_NOT_OPENED,
                )
                .toList();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadCandidateInfo() async {
    try {
      // You would implement this to get candidate info from your database
      // For now, we'll use placeholder data
      setState(() {
        _candidateName = "Jayamurugan";
      });
    } catch (e) {
      debugPrint('Error loading candidate info: $e');
      // Use default values if there's an error
    }
  }

  Future<void> _loadAllAssessments() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _assessmentService.loadAssessmentData();

      // Get all the different types of assessments and combine them
      final List<String> assessmentTypes =
          _assessmentService.getAvailableAssessmentTypes();
      List<Assessment> allAssessments = [];

      for (String type in assessmentTypes) {
        allAssessments.addAll(_assessmentService.getAssessmentsByType(type));
      }

      // Get stored assessment statuses for this candidate
      Map<String, String> statusMap;
      try {
        statusMap = await _dbHelper.getAllAssessmentStatuses(
          widget.candidateId,
        );
      } catch (dbError) {
        debugPrint('Error fetching assessment statuses: $dbError');
        // Fallback to empty map if there's a database error
        statusMap = {};
      }

      // Update assessment statuses from database safely
      for (var assessment in allAssessments) {
        try {
          if (statusMap.containsKey(assessment.type)) {
            assessment.status = statusMap[assessment.type]!;
          }
        } catch (updateError) {
          debugPrint(
            'Error updating status for ${assessment.type}: $updateError',
          );
          // Continue with next assessment without failing the entire process
        }
      }

      setState(() {
        _assessments = allAssessments;
        _filteredAssessments = List.from(_assessments);
        _isLoading = false;
      });

      // Filter assessments based on current tab
      _filterAssessments(_selectedTabIndex);
    } catch (e) {
      debugPrint('Error loading assessments: $e');

      // Show error to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load assessments: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }

      setState(() {
        _isLoading = false;
        // Initialize with empty lists to prevent null issues
        _assessments = [];
        _filteredAssessments = [];
      });
    }
  }

  Future _navigateToAssessment(Assessment assessment) async {
    // Set status to pending as soon as assessment is started
    await _dbHelper.updateAssessmentStatus(
      widget.candidateId,
      assessment.type,
      AssessmentDatabaseHelper.STATUS_PENDING,
    );

    // Update UI to show pending status
    setState(() {
      // Update the status in our local assessment list
      for (var a in _assessments) {
        if (a.type == assessment.type) {
          a.status = AssessmentDatabaseHelper.STATUS_PENDING;
        }
      }
      // Reapply current filter to update UI
      _filterAssessments(_selectedTabIndex);
    });

    // Determine which type of assessment to open
    if (assessment.type.toLowerCase().contains('email')) {
      // Navigate to email assessment screen using AppRouter
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => EmailAssessmentScreen(
                assessmentType: assessment.type,
                candidateId: widget.candidateId,
                emailData: assessment,
              ),
        ),
      );
    } else if (assessment.type.toLowerCase().contains('mcq')) {
      // Navigate to MCQ assessment screen using AppRouter
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => MCQAssessmentScreen(
                mcqData: assessment,
                candidateId: widget.candidateId,
              ),
        ),
      );
    } else if (assessment.type.toLowerCase().contains('typing')) {
      // Navigate to typing assessment screen using AppRouter
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => TypingAssessmentScreen(
                assessmentType: assessment.type,
                candidateId: widget.candidateId,
                typingData: assessment,
              ),
        ),
      );
    }
    if (assessment.type.toLowerCase().contains('form')) {
      // Navigate to form assessment screen using AppRouter
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => FormFillingScreen(
                assessmentType: assessment.type,
                candidateId: widget.candidateId,
                formData: assessment,
              ),
        ),
      );
    }

    // Always reload the assessments list when returning from an assessment screen
    _loadAllAssessments();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: _buildAppBar(),
        body:
            _isLoading
                ? _buildLoadingView()
                : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DepartmentDetails(),
                    // Tab Bar
                    _buildTabBar(),

                    // Assessments list
                    _buildAssessmentList(),
                  ],
                ),
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

  Expanded _buildAssessmentList() {
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
                    onPressed: _loadAllAssessments,
                    tooltip: 'Refresh assessment statuses',
                    color: Colors.blue[700],
                  ),
                ],
              ),
            ),
            _filteredAssessments.isEmpty
                ? _buildNoAssessmentsFound()
                : Expanded(
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount:
                              4, // Adjusted for better responsiveness
                          crossAxisSpacing: 20,
                          mainAxisSpacing: 16,
                          childAspectRatio: 1.2,
                        ),
                    itemCount: _filteredAssessments.length,
                    itemBuilder: (context, index) {
                      final assessment = _filteredAssessments[index];
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
          Tab(text: 'PENDING'),
          Tab(text: 'COMPLETED'),
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
        CandidateProfile(name: _candidateName, candidateId: widget.candidateId),
        IconButton(
          icon: const Icon(Icons.restart_alt),
          tooltip: 'Reset Database (Debug)',
          onPressed: () async {
            // Show confirmation dialog
            final shouldReset = await showDialog<bool>(
              context: context,
              builder:
                  (context) => AlertDialog(
                    title: const Text('Reset Database?'),
                    content: const Text(
                      'This will delete all assessment status data. '
                      'This action cannot be undone. Continue?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('CANCEL'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                        child: const Text('RESET'),
                      ),
                    ],
                  ),
            );

            if (shouldReset == true) {
              final success = await _dbHelper.resetDatabase();
              if (success && mounted) {
                // The dashboard will auto-update, but we still need to update the list UI
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Database reset successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
                // Reload assessments for the UI
                _loadAllAssessments();
              } else if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Failed to reset database'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          },
        ),
      ],
    );
  }

  Widget _buildAssessmentCard(Assessment assessment) {
    final String assessmentType = assessment.type;

    // Add a special icon for email assessments
    IconData assessmentIcon = getIconFromString(assessment.icon!);

    // Show progress indicator while loading status
    return FutureBuilder<String>(
      future: _dbHelper.getAssessmentStatus(widget.candidateId, assessmentType),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: CircularProgressIndicator(color: Colors.blue[700]),
              ),
            ),
          );
        }

        final status = snapshot.data!;

        // Determine button style and text based on status
        Widget actionButton;
        switch (status) {
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              child: Text('Continue'),
            );
            break;
          case AssessmentDatabaseHelper.STATUS_COMPLETED:
            actionButton = FutureBuilder<Map<String, dynamic>?>(
              future: _dbHelper.getAssessmentResult(
                widget.candidateId,
                assessmentType,
              ),
              builder: (context, resultSnapshot) {
                final hasResult =
                    resultSnapshot.hasData && resultSnapshot.data != null;
                debugPrint('Assessment result for $assessmentType: $hasResult');

                return OutlinedButton(
                  onPressed: () async {},
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.green[700],
                    side: BorderSide(color: Colors.green[700]!),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  child: const Text('Completed'),
                );
              },
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              child: Text('Start Now'),
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
                Row(
                  children: [
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
                      child: Icon(
                        assessmentIcon,
                        color: Colors.blue[700],
                        size: 24,
                      ),
                    ),
                    const Spacer(),
                    if (status == AssessmentDatabaseHelper.STATUS_COMPLETED ||
                        status == AssessmentDatabaseHelper.STATUS_PENDING)
                      Align(
                        alignment: Alignment.centerRight,
                        child: IconButton(
                          icon: Icon(
                            Icons.refresh,
                            color: Colors.grey[600],
                            size: 20,
                          ),
                          tooltip: 'Restart Assessment',
                          onPressed: () async {
                            final shouldRestart = await showDialog<bool>(
                              context: context,
                              builder:
                                  (context) => AlertDialog(
                                    title: const Text('Restart Assessment?'),
                                    content: const Text(
                                      'This will reset your progress for this assessment. '
                                      'Are you sure you want to restart?',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed:
                                            () => Navigator.pop(context, false),
                                        child: const Text('CANCEL'),
                                      ),
                                      TextButton(
                                        onPressed:
                                            () => Navigator.pop(context, true),
                                        child: const Text('RESTART'),
                                      ),
                                    ],
                                  ),
                            );

                            if (shouldRestart == true) {
                              // Reset assessment status
                              await _dbHelper.updateAssessmentStatus(
                                widget.candidateId,
                                assessmentType,
                                AssessmentDatabaseHelper.STATUS_NOT_OPENED,
                              );
                              // Refresh assessments list
                              _loadAllAssessments();
                            }
                          },
                        ),
                      ),
                  ],
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
      },
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
              onPressed: _loadAllAssessments,
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
