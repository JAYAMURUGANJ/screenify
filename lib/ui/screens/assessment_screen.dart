import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../widgets/time_counter.dart';

class AssessmentsScreen extends StatefulWidget {
  const AssessmentsScreen({super.key});

  @override
  State<AssessmentsScreen> createState() => _AssessmentsScreenState();
}

class _AssessmentsScreenState extends State<AssessmentsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, dynamic>> _assessments = [
    {
      'title': 'Multiple Choice Questions (MCQ)',
      'description':
          'Knowledge assessment through multiple choice questions on programming concepts and logic',
      'icon': Icons.quiz,
      'color': Colors.purple,
      'status': 'pending',
      'route': '/mcqAssessment',
    },
    {
      'title': 'Form Filling Skills',
      'description':
          'Assessment of form filling skills including accuracy and speed',
      'icon': Icons.assignment,
      'color': Colors.blue,
      'status': 'not_opened',
      'route': '/FormFillingAssessment',
    },
    {
      'title': 'Typing Test',
      'description': 'Assessment of typing speed and accuracy',
      'icon': Icons.keyboard,
      'color': Colors.green,
      'status': 'completed',
      'route': '/TypingAssessment',
    },
    {
      'title': 'Email Writing',
      'description':
          'Assessment of professional email writing skills and etiquette',
      'icon': Icons.email,
      'color': Colors.orange,
      'status': 'pending',
      'route': '/EmailWritingAssessment',
    },
    {
      'title': 'Excel Skills Assessment',
      'description':
          'Practical assessment of Microsoft Excel skills including formulas and data analysis',
      'icon': Icons.table_chart,
      'color': Colors.teal,
      'status': 'not_opened',
      'route': '/ExcelAssessment',
    },
  ];

  List<Map<String, dynamic>> _filteredAssessments = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _filteredAssessments = List.from(_assessments);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _filterAssessments(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredAssessments = List.from(_assessments);
      });
      return;
    }

    setState(() {
      _filteredAssessments =
          _assessments
              .where(
                (assessment) =>
                    assessment['title'].toLowerCase().contains(
                      query.toLowerCase(),
                    ) ||
                    assessment['description'].toLowerCase().contains(
                      query.toLowerCase(),
                    ),
              )
              .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: _buildAppBar(),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Organization Header with Logo
            _buildOrganizationHeader(),

            // Tab Bar
            Container(
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
                              .where((a) => a['status'] == 'pending')
                              .toList();
                    } else if (index == 2) {
                      _filteredAssessments =
                          _assessments
                              .where((a) => a['status'] == 'completed')
                              .toList();
                    } else if (index == 3) {
                      _filteredAssessments =
                          _assessments
                              .where((a) => a['status'] == 'not_opened')
                              .toList();
                    }
                  });
                },
              ),
            ),

            // Status overview
            _buildStatusOverview(),

            // Assessments list
            Expanded(
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
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // Action to show help or tutorial
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Help and tutorials coming soon!'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
          backgroundColor: Colors.indigo[700],
          child: const Icon(Icons.help_outline),
        ),
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
        // Add the timer widget
        CountdownTimer(
          durationInMinutes: 60,
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
        IconButton(
          icon: const Icon(Icons.filter_list),
          onPressed: () {
            // Show filter dialog
            _showFilterDialog();
          },
          color: Colors.grey[700],
          tooltip: 'Filter',
        ),
        IconButton(
          icon: const Icon(Icons.notifications_outlined),
          onPressed: () {
            // Show notifications
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('No new notifications'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
          color: Colors.grey[700],
          tooltip: 'Notifications',
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildOrganizationHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Logo
            Image.asset('assets/images/logo.png', fit: BoxFit.contain),
            const SizedBox(width: 24),
            // Organization details
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'The Income Tax Department Co-operative Society Limited',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo[800],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '(REGD.No. MSCS/CR-11/90)',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 16, color: Colors.red),
                    const SizedBox(width: 4),
                    Text(
                      '121, MAHATHMA GANDHI SALAI, CHENNAI - 600 034.',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusOverview() {
    final pendingCount =
        _assessments.where((a) => a['status'] == 'pending').length;
    final completedCount =
        _assessments.where((a) => a['status'] == 'completed').length;
    final notOpenedCount =
        _assessments.where((a) => a['status'] == 'not_opened').length;
    final totalCount = _assessments.length;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.indigo[900]!, Colors.indigo[700]!],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.indigo.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.analytics, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Assessment Progress',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Total: $totalCount',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: completedCount / totalCount,
              backgroundColor: Colors.white.withOpacity(0.3),
              color: Colors.white,
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatusChip(
                'Pending',
                pendingCount.toString(),
                Colors.orange,
                Icons.access_time,
              ),
              _buildStatusChip(
                'Completed',
                completedCount.toString(),
                Colors.green,
                Icons.check_circle,
              ),
              _buildStatusChip(
                'Not Opened',
                notOpenedCount.toString(),
                Colors.grey,
                Icons.lock_outline,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(
    String title,
    String count,
    Color color,
    IconData icon,
  ) {
    return Row(
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: Colors.white,
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              count,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAssessmentCard(Map<String, dynamic> assessment) {
    final Color baseColor = assessment['color'];

    // Determine button style and text based on status
    Widget actionButton;
    switch (assessment['status']) {
      case 'pending':
        actionButton = ElevatedButton(
          onPressed: () {
            Navigator.pushNamed(context, assessment['route']);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
            elevation: 2,
            shadowColor: Colors.orange.withOpacity(0.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text('Pending'),
              SizedBox(width: 4),
              Icon(Icons.access_time, size: 16),
            ],
          ),
        );
        break;
      case 'completed':
        actionButton = OutlinedButton(
          onPressed: () {
            // View results
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'You scored ${assessment['result']} in this assessment',
                ),
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('View Results'),
              const SizedBox(width: 4),
              Icon(Icons.analytics, size: 16, color: Colors.green[700]),
            ],
          ),
        );
        break;
      case 'not_opened':
      default:
        actionButton = ElevatedButton(
          onPressed: () {
            Navigator.pushNamed(context, assessment['route']);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: baseColor,
            foregroundColor: Colors.white,
            elevation: 2,
            shadowColor: baseColor.withOpacity(0.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
        side: BorderSide(color: baseColor.withOpacity(0.3), width: 1),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, baseColor.withOpacity(0.05)],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon and status row
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: baseColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: baseColor.withOpacity(0.3),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(assessment['icon'], color: baseColor, size: 24),
            ),
            const SizedBox(height: 16),

            // Title
            Text(
              assessment['title'],
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
                assessment['description'],
                style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            const SizedBox(height: 4),

            // Action button
            SizedBox(width: double.infinity, child: actionButton),
          ],
        ),
      ),
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
            const SizedBox(height: 8),
            Text(
              'Try adjusting your search or filters',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Filter Assessments'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CheckboxListTile(
                  title: const Text('Easy'),
                  value: true,
                  onChanged: (value) {},
                ),
                CheckboxListTile(
                  title: const Text('Medium'),
                  value: true,
                  onChanged: (value) {},
                ),
                CheckboxListTile(
                  title: const Text('Hard'),
                  value: true,
                  onChanged: (value) {},
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Apply'),
              ),
            ],
          ),
    );
  }
}
