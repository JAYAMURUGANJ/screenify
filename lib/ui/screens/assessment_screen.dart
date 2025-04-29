import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:screenify/ui/screens/mcq_screen.dart';
import 'package:screenify/ui/widgets/department_details.dart';

import '../../domain/api/assessment_service.dart';
import '../../domain/local/assessment_manager.dart';
import '../../domain/model/assessment_data.dart';
import '../widgets/assessment_status_updater.dart';
import '../widgets/profile_widget.dart';
import '../widgets/time_counter.dart';

class AssessmentsScreen extends StatefulWidget {
  const AssessmentsScreen({super.key});

  @override
  State<AssessmentsScreen> createState() => _AssessmentsScreenState();
}

class _AssessmentsScreenState extends State<AssessmentsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final AssessmentService _assessmentService = AssessmentService();
  final AssessmentPreferencesManager _prefsManager =
      AssessmentPreferencesManager();

  bool _isLoading = true;
  List<Assessment> _assessments = [];
  List<Assessment> _filteredAssessments = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadAllAssessments();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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

      // Get stored assessment statuses
      final Map<String, String> statusMap =
          await _prefsManager.getAllAssessmentStatuses();

      // Update assessment statuses from preferences
      for (var assessment in allAssessments) {
        if (statusMap.containsKey(assessment.type)) {
          assessment.status = statusMap[assessment.type];
        }
      }

      setState(() {
        _assessments = allAssessments;
        _filteredAssessments = List.from(_assessments);
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading assessments: $e');
      setState(() {
        _isLoading = false;
      });
    }
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
                ? const Center(child: CircularProgressIndicator())
                : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DepartmentDetails(),
                    // Tab Bar
                    _buildTabBar(),
                    // Status overview
                    AssessmentStatusDashboard(),
                    // Assessments list
                    _buildAssessmentList(),
                  ],
                ),
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
                  // Add refresh button
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
        onTap: (index) {
          setState(() {
            if (index == 0) {
              _filteredAssessments = List.from(_assessments);
            } else if (index == 1) {
              _filteredAssessments =
                  _assessments
                      .where(
                        (a) =>
                            a.status ==
                            AssessmentPreferencesManager.STATUS_PENDING,
                      )
                      .toList();
            } else if (index == 2) {
              _filteredAssessments =
                  _assessments
                      .where(
                        (a) =>
                            a.status ==
                            AssessmentPreferencesManager.STATUS_COMPLETED,
                      )
                      .toList();
            } else if (index == 3) {
              _filteredAssessments =
                  _assessments
                      .where(
                        (a) =>
                            a.status ==
                            AssessmentPreferencesManager.STATUS_NOT_OPENED,
                      )
                      .toList();
            }
          });
        },
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
          name: "Jayamurugan",
          email: "jamu@gmail.com",
          candidateId: "CAND-2025-GEG9IA",
        ),
      ],
    );
  }

  Widget _buildAssessmentCard(Assessment assessment) {
    final String? baseColor = assessment.color;
    final String assessmentType = assessment.type;

    // Show progress indicator while loading status
    return FutureBuilder<String>(
      future: _prefsManager.getAssessmentStatus(assessmentType),
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
          case AssessmentPreferencesManager.STATUS_PENDING:
            actionButton = ElevatedButton(
              onPressed: () async {
                // Continue assessment
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => MCQAssessmentScreen(
                          questions: assessment.questions,
                          assessmentType: assessment.type,
                        ),
                  ),
                );

                // Refresh the list after returning
                if (result == true) {
                  _loadAllAssessments();
                }
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
                  Icon(Icons.check, size: 16),
                ],
              ),
            );
            break;
          case AssessmentPreferencesManager.STATUS_COMPLETED:
            actionButton = FutureBuilder<Map<String, dynamic>?>(
              future: _prefsManager.getAssessmentResult(assessmentType),
              builder: (context, resultSnapshot) {
                final bool hasResult =
                    resultSnapshot.hasData && resultSnapshot.data != null;
                debugPrint('Assessment result: $hasResult');
                return OutlinedButton(
                  onPressed: () async {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Assessment was completed successfully!'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
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
          case AssessmentPreferencesManager.STATUS_NOT_OPENED:
          default:
            actionButton = ElevatedButton(
              onPressed: () async {
                // Mark assessment as started
                await _prefsManager.markAssessmentAsStarted(assessmentType);
                // Navigate to assessment screen
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => MCQAssessmentScreen(
                          questions: assessment.questions,
                          assessmentType: assessment.type,
                        ),
                  ),
                );

                // Refresh the list after returning
                if (result == true) {
                  _loadAllAssessments();
                }
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
                        _getIconFromString(assessment.icon!),
                        color: _getColorFromString(baseColor),
                        size: 24,
                      ),
                    ),
                    const Spacer(),
                    if (status ==
                            AssessmentPreferencesManager.STATUS_COMPLETED ||
                        status == AssessmentPreferencesManager.STATUS_PENDING)
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
                              await _prefsManager.updateAssessmentStatus(
                                assessmentType,
                                AssessmentPreferencesManager.STATUS_NOT_OPENED,
                              );
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

                const SizedBox(height: 8),

                // Action button
                SizedBox(width: double.infinity, child: actionButton),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNoAssessmentsFound() {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No assessments found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
