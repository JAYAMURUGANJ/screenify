import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:screenify/ui/screens/email_screen.dart';
import 'package:screenify/ui/screens/mcq_screen.dart';
import 'package:screenify/ui/widgets/department_details.dart';
import 'package:screenshot/screenshot.dart';

import '../../domain/api/assessment_service.dart';
import '../../domain/local/assessment_manager.dart';
import '../../domain/model/assessment_data.dart';
import '../widgets/profile_widget.dart';
import '../widgets/time_counter.dart';

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
  final ScreenshotController _screenshotController =
      ScreenshotController(); // For capturing screenshots

  bool _isLoading = true;
  List<Assessment> _assessments = [];
  List<Assessment> _filteredAssessments = [];
  late String _candidateName;
  late String _candidateEmail;
  int _selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_handleTabChange);
    _candidateName = "Candidate"; // Default value
    _candidateEmail = "candidate@example.com"; // Default value
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

  // Load candidate information from the database
  Future<void> _loadCandidateInfo() async {
    try {
      // You would implement this to get candidate info from your database
      // For now, we'll use placeholder data
      setState(() {
        _candidateName = "Jayamurugan";
        _candidateEmail = "jamu@gmail.com";
      });
    } catch (e) {
      debugPrint('Error loading candidate info: $e');
      // Use default values if there's an error
    }
  }

  // Function to map icon string from JSON to IconData
  IconData _getIconFromString(String iconName) {
    switch (iconName) {
      case 'quiz':
        return Icons.quiz;
      case 'email':
        return Icons.email;
      case 'keyboard':
        return Icons.keyboard;
      case 'assignment':
        return Icons.assignment;
      case 'table_chart':
        return Icons.table_chart;
      default:
        return Icons.assessment;
    }
  }

  // Function to map color string from JSON to Color
  Color _getColorFromString(String colorName) {
    switch (colorName) {
      case 'purple':
        return Colors.purple;
      case 'orange':
        return Colors.orange;
      case 'green':
        return Colors.green;
      case 'blue':
        return Colors.blue;
      case 'teal':
        return Colors.teal;
      default:
        return Colors.indigo;
    }
  }

  // Function to load all assessments from the service and update their statuses
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load assessments: ${e.toString()}'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );

      setState(() {
        _isLoading = false;
        // Initialize with empty lists to prevent null issues
        _assessments = [];
        _filteredAssessments = [];
      });
    }
  }

  // Function to navigate to assessment screen based on type
  Future<void> _navigateToAssessment(Assessment assessment) async {
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
      // Navigate to email assessment screen
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => EmailAssessmentScreen(
                assessmentType: assessment.type,
                candidateId: widget.candidateId,
                emailData: {
                  'title': assessment.title,
                  'instruction': assessment.instruction,
                  'expectedTo': assessment.expectedTo,
                  'expectedCc': assessment.expectedCc,
                  'expectedSubject': assessment.expectedSubject,
                  'expectedKeywords': assessment.expectedKeywords,
                  'hints': assessment.hints,
                },
              ),
        ),
      );

      // Always reload the assessments list when returning from an assessment screen
      // regardless of the result
      _loadAllAssessments();
    } else if (assessment.type.toLowerCase().contains('mcq')) {
      // Navigate to MCQ assessment screen (default)
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => MCQAssessmentScreen(
                questions: assessment.questions,
                assessmentType: assessment.type,
                candidateId: widget.candidateId,
              ),
        ),
      );

      // Always reload the assessments list when returning from an assessment screen
      // regardless of the result
      _loadAllAssessments();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Screenshot(
        controller: _screenshotController,
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
      ),
    );
  }

  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Colors.indigo[700]),
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
                      color: Colors.grey[800],
                    ),
                  ),
                  // Add search and refresh buttons
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: _loadAllAssessments,
                    tooltip: 'Refresh assessment statuses',
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
                          crossAxisCount: 5,
                          crossAxisSpacing: 20,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.85,
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
        labelColor: Colors.indigo[700],
        unselectedLabelColor: Colors.grey[600],
        indicatorColor: Colors.indigo[700],
        indicatorWeight: 3,
        labelStyle: const TextStyle(fontWeight: FontWeight.bold),
        tabs: const [
          Tab(text: 'All'),
          Tab(text: 'Pending'),
          Tab(text: 'Completed'),
          Tab(text: 'Not Opened'),
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
              color: Colors.indigo[700],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.assessment, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 12),
          Text(
            'My Assessments',
            style: GoogleFonts.poppins(
              color: const Color(0xFF2C3E50),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      actions: [
        CountdownTimer(
          key: const ValueKey("assessmentTimer"),
          durationInMinutes: 1,
          autoStart: true,
          onTimerComplete: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Time is up!'),
                behavior: SnackBarBehavior.floating,
                backgroundColor: Colors.red,
              ),
            );
          },
        ),
        const SizedBox(width: 12),
        UserProfileView(
          name: _candidateName,
          email: _candidateEmail,
          candidateId: widget.candidateId,
        ),

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
              if (success) {
                // The dashboard will auto-update, but we still need to update the list UI
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Database reset successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
                // Reload assessments for the UI
                _loadAllAssessments();
              } else {
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
    final String? baseColor = assessment.color;
    final String assessmentType = assessment.type;
    final bool isEmailAssessment = assessmentType.toLowerCase().contains(
      'email',
    );

    // Add a special icon for email assessments
    IconData assessmentIcon =
        isEmailAssessment
            ? Icons.email
            : _getIconFromString(assessment.icon ?? 'assessment');

    // Show progress indicator while loading status
    return FutureBuilder<String>(
      future: _dbHelper.getAssessmentStatus(widget.candidateId, assessmentType),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Card(
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: CircularProgressIndicator(),
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
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text('Continue'),
                  SizedBox(width: 4),
                  Icon(Icons.rotate_90_degrees_cw_outlined, size: 16),
                ],
              ),
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
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Completed'),
                      const SizedBox(width: 4),
                      Icon(Icons.analytics, size: 16, color: Colors.green[700]),
                    ],
                  ),
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
                backgroundColor: _getColorFromString(baseColor!),
                foregroundColor: Colors.white,
                elevation: 2,
                shadowColor: _getColorFromString(baseColor).withOpacity(0.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text('Start Now'),
                  SizedBox(width: 4),
                  Icon(Icons.arrow_forward, size: 16),
                ],
              ),
            );
            break;
        }

        return Card(
          elevation: 4,
          shadowColor: Colors.black.withOpacity(0.1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: _getColorFromString(baseColor!).withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white,
                  _getColorFromString(baseColor).withOpacity(0.05),
                ],
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
                        color: _getColorFromString(baseColor).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: _getColorFromString(
                              baseColor,
                            ).withOpacity(0.3),
                            spreadRadius: 1,
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        assessmentIcon,
                        color: _getColorFromString(baseColor),
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
                    color: Colors.grey[800],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),

                // Description
                Expanded(
                  child: Text(
                    assessment.description,
                    style: TextStyle(fontSize: 12, color: Colors.grey[700]),
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
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadAllAssessments,
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo[700],
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
