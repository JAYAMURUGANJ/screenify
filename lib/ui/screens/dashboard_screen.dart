// lib/screens/enhanced_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../domain/model/candidate.dart';

class DashboardScreen extends StatefulWidget {
  final Candidate candidate;

  const DashboardScreen({super.key, required this.candidate});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int selectedIndex = 0;
  bool _isNotificationsExpanded = false;
  final List<Map<String, dynamic>> _notifications = [
    {
      'title': 'Assessment Scheduled',
      'description':
          'Technical Skills Assessment scheduled for tomorrow at 10:00 AM',
      'time': '2 hours ago',
      'read': false,
    },
    {
      'title': 'Results Available',
      'description': 'Your MCQ Assessment results are now available',
      'time': '1 day ago',
      'read': true,
    },
    {
      'title': 'New Assessment Added',
      'description':
          'A new Communication Skills Assessment has been added to your portal',
      'time': '3 days ago',
      'read': true,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {
        selectedIndex = _tabController.index;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final bool isWideScreen = screenSize.width > 1000;
    final bool isMediumScreen =
        screenSize.width > 600 && screenSize.width <= 1000;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          automaticallyImplyLeading: false,
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue[700]!,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.app_shortcut, color: Colors.white),
              ),
              const SizedBox(width: 12),
              const Text(
                'Screenify',
                style: TextStyle(
                  color: Color(0xFF2C3E50),
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ],
          ),
          actions: [
            // Notifications
            Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.notifications_outlined),
                  onPressed: () {
                    setState(() {
                      _isNotificationsExpanded = !_isNotificationsExpanded;
                    });
                  },
                  color: Colors.grey[700],
                  tooltip: 'Notifications',
                ),
                Positioned(
                  top: 10,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${_notifications.where((n) => !n['read']).length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // Profile menu
            PopupMenuButton(
              offset: const Offset(0, 56),
              icon: CircleAvatar(
                backgroundColor: Colors.blue[700],
                child: Text(
                  widget.candidate.name.isNotEmpty
                      ? widget.candidate.name[0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              itemBuilder:
                  (context) => <PopupMenuEntry>[
                    PopupMenuItem(
                      child: Row(
                        children: [
                          const Icon(Icons.person),
                          const SizedBox(width: 8),
                          Text('Profile'),
                        ],
                      ),
                      onTap: () {
                        // Navigate to profile
                      },
                    ),
                    PopupMenuItem(
                      child: Row(
                        children: [
                          const Icon(Icons.settings),
                          const SizedBox(width: 8),
                          Text('Settings'),
                        ],
                      ),
                      onTap: () {
                        // Navigate to settings
                      },
                    ),
                    PopupMenuItem(
                      child: Row(
                        children: [
                          const Icon(Icons.help_outline),
                          const SizedBox(width: 8),
                          Text('Help'),
                        ],
                      ),
                      onTap: () {
                        // Show help
                      },
                    ),
                    const PopupMenuDivider(),
                    PopupMenuItem(
                      child: Row(
                        children: [
                          Icon(Icons.logout, color: Colors.red[700]),
                          const SizedBox(width: 8),
                          Text(
                            'Logout',
                            style: TextStyle(color: Colors.red[700]),
                          ),
                        ],
                      ),
                      onTap: () {
                        Navigator.pushReplacementNamed(context, '/login');
                      },
                    ),
                  ],
            ),
            const SizedBox(width: 16),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(48),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(color: Colors.grey.shade300, width: 1),
                ),
              ),
              child: TabBar(
                controller: _tabController,
                labelColor: Colors.blue[700],
                unselectedLabelColor: Colors.grey[600],
                indicatorColor: Colors.blue[700],
                indicatorSize: TabBarIndicatorSize.tab,
                tabs: const [
                  Tab(text: 'Dashboard'),
                  Tab(text: 'Assessments'),
                  Tab(text: 'Results'),
                ],
              ),
            ),
          ),
        ),
        body: Stack(
          children: [
            TabBarView(
              controller: _tabController,
              children: [
                _buildDashboardTab(isWideScreen, isMediumScreen),
                _buildAssessmentsTab(),
                _buildResultsTab(),
              ],
            ),
            if (_isNotificationsExpanded)
              Positioned(
                top: 0,
                right: 20,
                child: Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Container(
                    width: 320,
                    height: 380,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Notifications',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                //fontSize: a8,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                // Mark all as read logic here
                                setState(() {
                                  for (var notification in _notifications) {
                                    notification['read'] = true;
                                  }
                                });
                              },
                              child: Text('Mark all as read'),
                            ),
                          ],
                        ),
                        const Divider(),
                        Expanded(
                          child: ListView.separated(
                            itemCount: _notifications.length,
                            separatorBuilder:
                                (context, index) => const Divider(),
                            itemBuilder: (context, index) {
                              final notification = _notifications[index];
                              return ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: CircleAvatar(
                                  backgroundColor:
                                      notification['read']
                                          ? Colors.grey[200]
                                          : Colors.blue[50],
                                  child: Icon(
                                    Icons.notifications,
                                    color:
                                        notification['read']
                                            ? Colors.grey[500]
                                            : Colors.blue[700],
                                  ),
                                ),
                                title: Text(
                                  notification['title'],
                                  style: TextStyle(
                                    fontWeight:
                                        notification['read']
                                            ? FontWeight.normal
                                            : FontWeight.bold,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      notification['description'],
                                      style: TextStyle(fontSize: 12),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      notification['time'],
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey[500],
                                      ),
                                    ),
                                  ],
                                ),
                                onTap: () {
                                  setState(() {
                                    notification['read'] = true;
                                  });
                                },
                              );
                            },
                          ),
                        ),
                        const Divider(),
                        Center(
                          child: TextButton(
                            onPressed: () {
                              // View all notifications
                            },
                            child: const Text('View all notifications'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardTab(bool isWideScreen, bool isMediumScreen) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue[700]!, Colors.blue[900]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome, ${widget.candidate.name}!',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your next assessment is scheduled for tomorrow at 10:00 AM',
                  style: TextStyle(fontSize: 16, color: Colors.blue[50]),
                ),
                // const SizedBox(height: 24),
                // Row(
                //   children: [
                //     _buildStatCard(
                //       'Total Assessments',
                //       '2',
                //       Icons.assignment,
                //       Colors.white.withOpacity(0.2),
                //       Colors.white,
                //     ),
                //     const SizedBox(width: 16),
                //     _buildStatCard(
                //       'Completed',
                //       '1',
                //       Icons.check_circle,
                //       Colors.white.withOpacity(0.2),
                //       Colors.white,
                //     ),
                //     const SizedBox(width: 16),
                //     _buildStatCard(
                //       'Pending',
                //       '1',
                //       Icons.pending_actions,
                //       Colors.white.withOpacity(0.2),
                //       Colors.white,
                //     ),
                //   ],
                // ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Main content section with grid layout
          if (isWideScreen)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 2, child: _buildProfileSection()),
                const SizedBox(width: 24),
                Expanded(flex: 3, child: _buildUpcomingAssessmentsSection()),
              ],
            )
          else if (isMediumScreen)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildProfileSection()),
                const SizedBox(width: 16),
                Expanded(child: _buildUpcomingAssessmentsSection()),
              ],
            )
          else
            Column(
              children: [
                _buildProfileSection(),
                const SizedBox(height: 24),
                _buildUpcomingAssessmentsSection(),
              ],
            ),

          const SizedBox(height: 24),

          // // Action Cards
          // GridView.count(
          //   shrinkWrap: true,
          //   physics: const NeverScrollableScrollPhysics(),
          //   crossAxisCount: isWideScreen ? 4 : (isMediumScreen ? 2 : 1),
          //   crossAxisSpacing: 16,
          //   mainAxisSpacing: 16,
          //   childAspectRatio: 1.2,
          //   children: [
          //     _buildActionCard(
          //       'View Results',
          //       'Check your assessment results and performance',
          //       Icons.bar_chart,
          //       Colors.green[700]!,
          //       () {
          //         _tabController.animateTo(2);
          //       },
          //     ),
          //     _buildActionCard(
          //       'Schedule New Assessment',
          //       'Book a time slot for your next assessment',
          //       Icons.calendar_today,
          //       Colors.orange[700]!,
          //       () {
          //         // Navigate to scheduling page
          //       },
          //     ),
          //     _buildActionCard(
          //       'Update Profile',
          //       'Keep your information up to date',
          //       Icons.person,
          //       Colors.purple[700]!,
          //       () {
          //         // Navigate to profile update page
          //       },
          //     ),
          //     _buildActionCard(
          //       'Contact Support',
          //       'Get help with any questions or issues',
          //       Icons.support_agent,
          //       Colors.teal[700]!,
          //       () {
          //         // Navigate to support page
          //       },
          //     ),
          //   ],
          // ),

          // const SizedBox(height: 24),

          // Resources section
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Resources & Materials',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue[50],
                      child: Icon(Icons.description, color: Colors.blue[700]),
                    ),
                    title: const Text('Assessment Preparation Guide'),
                    subtitle: const Text(
                      'Tips and tricks to ace your assessments',
                    ),
                    trailing: Icon(Icons.download, color: Colors.blue[700]),
                    onTap: () {
                      // Download or view guide
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.green[50],
                      child: Icon(
                        Icons.video_library,
                        color: Colors.green[700],
                      ),
                    ),
                    title: const Text('Technical Skills Tutorial Videos'),
                    subtitle: const Text(
                      'Video guides for the technical assessment',
                    ),
                    trailing: Icon(
                      Icons.play_circle_filled,
                      color: Colors.green[700],
                    ),
                    onTap: () {
                      // View videos
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.orange[50],
                      child: Icon(Icons.quiz, color: Colors.orange[700]),
                    ),
                    title: const Text('Practice Questions'),
                    subtitle: const Text(
                      'Sample questions to practice before the assessment',
                    ),
                    trailing: Icon(
                      Icons.arrow_forward,
                      color: Colors.orange[700],
                    ),
                    onTap: () {
                      // Go to practice questions
                    },
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Footer
          Center(
            child: Text(
              '© ${DateTime.now().year} Screenify. All rights reserved.',
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color bgColor,
    Color textColor,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: textColor, size: 28),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: textColor.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.blue[700],
                  child: Text(
                    widget.candidate.name.isNotEmpty
                        ? widget.candidate.name[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.candidate.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Candidate ID: ${widget.candidate.id}',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                // IconButton(
                //   icon: const Icon(Icons.edit),
                //   onPressed: () {
                //     // Edit profile
                //   },
                //   color: Colors.blue[700],
                //   tooltip: 'Edit Profile',
                // ),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(),
            _buildInfoItem(Icons.email, 'Email', widget.candidate.email),
            _buildInfoItem(Icons.phone, 'Phone', widget.candidate.phone),
            _buildInfoItem(Icons.cake, 'Date of Birth', widget.candidate.dob),
            // const Divider(),
            // Center(
            //   child: TextButton.icon(
            //     onPressed: () {
            //       // View full profile
            //     },
            //     icon: Icon(Icons.person, color: Colors.blue[700]),
            //     label: Text(
            //       'View Full Profile',
            //       style: TextStyle(color: Colors.blue[700]),
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingAssessmentsSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Upcoming Assessments',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Chip(
                  label: Text('1 Pending'),
                  backgroundColor: Color(0xFFFFECB3),
                  labelStyle: TextStyle(color: Color(0xFFFF8F00)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildAssessmentItem(
              'Technical Skills Assessment',
              'April 17, 2025',
              '10:00 AM - 11:30 AM',
              Icons.computer,
              Colors.green[700]!,
              isPending: true,
            ),
            const Divider(),
            _buildAssessmentItem(
              'Multiple Choice Questions (MCQ)',
              'April 15, 2025',
              '02:00 PM - 03:00 PM',
              Icons.quiz,
              Colors.blue[700]!,
              isCompleted: true,
            ),
            const SizedBox(height: 16),
            Center(
              child: OutlinedButton.icon(
                onPressed: () {
                  _tabController.animateTo(1);
                },
                icon: const Icon(Icons.view_list),
                label: const Text('View All Assessments'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.blue[700],
                  side: BorderSide(color: Colors.blue[700]!),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssessmentItem(
    String title,
    String date,
    String time,
    IconData icon,
    Color color, {
    bool isPending = false,
    bool isCompleted = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color:
            isPending
                ? Colors.orange[50]
                : (isCompleted ? Colors.green[50] : Colors.white),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.1),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color:
                        isPending
                            ? Colors.orange[800]
                            : (isCompleted
                                ? Colors.green[800]
                                : Colors.black87),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 12,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      date,
                      style: TextStyle(color: Colors.grey[700], fontSize: 12),
                    ),
                    const SizedBox(width: 16),
                    Icon(Icons.access_time, size: 12, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      time,
                      style: TextStyle(color: Colors.grey[700], fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (isPending)
            ElevatedButton(
              onPressed: () {
                // Start assessment
                Navigator.pushNamed(context, '/technicalAssesment');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text('Start'),
            )
          else if (isCompleted)
            OutlinedButton(
              onPressed: () {
                // View results
                _tabController.animateTo(2);
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.green[700],
                side: BorderSide(color: Colors.green[700]!),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text('Results'),
            ),
        ],
      ),
    );
  }

  Widget _buildActionCard(
    String title,
    String description,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: color.withOpacity(0.1),
                child: Icon(icon, color: color, size: 30),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAssessmentsTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search and Filter Row
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search assessments...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              PopupMenuButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.filter_list),
                      const SizedBox(width: 4),
                      Text('Filter', style: TextStyle(color: Colors.grey[800])),
                    ],
                  ),
                ),
                itemBuilder:
                    (context) => [
                      PopupMenuItem(child: Text('All Assessments')),
                      PopupMenuItem(child: Text('Pending')),
                      PopupMenuItem(child: Text('Completed')),
                      PopupMenuItem(child: Text('Technical Skills')),
                      PopupMenuItem(child: Text('MCQ')),
                    ],
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Assessment List
          Expanded(
            child: ListView(
              children: [
                _buildAssessmentCard(
                  'Technical Skills Assessment',
                  'Practical assessment on MS Office applications including Word, Excel and PowerPoint',
                  '90 minutes',
                  Icons.computer,
                  Colors.green[700]!,
                  status: 'Scheduled',
                  dueDate: 'April 17, 2025',
                  onStart: () {
                    Navigator.pushNamed(context, '/technicalAssesment');
                  },
                ),
                _buildAssessmentCard(
                  'Multiple Choice Questions (MCQ)',
                  'Knowledge assessment through multiple choice questions on programming concepts and logic',
                  '60 minutes',
                  Icons.quiz,
                  Colors.blue[700]!,
                  status: 'Completed',
                  dueDate: 'April 15, 2025',
                  completedDate: 'April 15, 2025',
                  score: '85%',
                  onStart: () {
                    // Navigate to results page
                    _tabController.animateTo(2);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssessmentCard(
    String title,
    String description,
    String duration,
    IconData icon,
    Color color, {
    required String status,
    required String dueDate,
    String? completedDate,
    String? score,
    required VoidCallback onStart,
  }) {
    bool isCompleted = status == 'Completed';
    bool isPending = status == 'Scheduled';
    bool isUpcoming = status == 'Upcoming';
    bool isNotScheduled = status == 'Pending';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: color.withOpacity(0.1),
                  radius: 24,
                  child: Icon(icon, color: color, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                          _buildStatusChip(status),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        description,
                        style: TextStyle(color: Colors.grey[700], fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: [
                  Icon(Icons.timer, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    'Duration: $duration',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  const SizedBox(width: 24),
                  Icon(
                    isCompleted ? Icons.calendar_today : Icons.event,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isCompleted
                        ? 'Completed: $completedDate'
                        : isNotScheduled
                        ? 'Status: Not scheduled'
                        : 'Due: $dueDate',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  if (isCompleted && score != null) ...[
                    const SizedBox(width: 24),
                    Icon(Icons.grade, size: 16, color: Colors.amber[600]),
                    const SizedBox(width: 8),
                    Text(
                      'Score: $score',
                      style: TextStyle(
                        color: Colors.amber[800],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (isCompleted)
                  OutlinedButton.icon(
                    icon: const Icon(Icons.bar_chart),
                    label: const Text('View Results'),
                    onPressed: onStart,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.green[700],
                      side: BorderSide(color: Colors.green[700]!),
                    ),
                  )
                else if (isPending)
                  ElevatedButton.icon(
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Start Assessment'),
                    onPressed: onStart,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color,
                      foregroundColor: Colors.white,
                    ),
                  )
                else if (isUpcoming)
                  OutlinedButton.icon(
                    icon: const Icon(Icons.info_outline),
                    label: const Text('Not Available Yet'),
                    onPressed: onStart,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.grey[700],
                      side: BorderSide(color: Colors.grey[400]!),
                    ),
                  )
                else
                  OutlinedButton.icon(
                    icon: const Icon(Icons.calendar_today),
                    label: const Text('Schedule'),
                    onPressed: onStart,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.blue[700],
                      side: BorderSide(color: Colors.blue[700]!),
                    ),
                  ),
                const SizedBox(width: 16),
                if (!isCompleted)
                  IconButton(
                    icon: const Icon(Icons.info_outline),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder:
                            (context) => AlertDialog(
                              title: Text(title),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(description),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'Assessment Details:',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text('• Duration: $duration'),
                                  Text('• Questions: 30'),
                                  Text('• Passing Score: 70%'),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'Instructions:',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    '• You cannot pause the assessment once started.',
                                  ),
                                  const Text(
                                    '• Ensure you have a stable internet connection.',
                                  ),
                                  const Text(
                                    '• Have your ID ready for verification.',
                                  ),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Close'),
                                ),
                              ],
                            ),
                      );
                    },
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color backgroundColor;
    Color textColor;
    IconData iconData;

    switch (status) {
      case 'Completed':
        backgroundColor = Colors.green[100]!;
        textColor = Colors.green[800]!;
        iconData = Icons.check_circle;
        break;
      case 'Scheduled':
        backgroundColor = Colors.orange[100]!;
        textColor = Colors.orange[800]!;
        iconData = Icons.event_available;
        break;
      case 'Upcoming':
        backgroundColor = Colors.blue[100]!;
        textColor = Colors.blue[800]!;
        iconData = Icons.event;
        break;
      case 'Pending':
        backgroundColor = Colors.grey[100]!;
        textColor = Colors.grey[800]!;
        iconData = Icons.pending;
        break;
      default:
        backgroundColor = Colors.grey[100]!;
        textColor = Colors.grey[800]!;
        iconData = Icons.help_outline;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(iconData, size: 16, color: textColor),
          const SizedBox(width: 4),
          Text(
            status,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Results Summary Card
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Results Summary',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildResultsStat(
                          'Average Score',
                          '85%',
                          Icons.show_chart,
                          Colors.blue[700]!,
                        ),
                      ),
                      Expanded(
                        child: _buildResultsStat(
                          'Assessments Taken',
                          '1',
                          Icons.assignment_turned_in,
                          Colors.green[700]!,
                        ),
                      ),
                      Expanded(
                        child: _buildResultsStat(
                          'Highest Score',
                          '85%',
                          Icons.emoji_events,
                          Colors.amber[800]!,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Results List
          const Text(
            'Assessment Results',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          Expanded(
            child: ListView(
              children: [
                _buildResultCard(
                  'Multiple Choice Questions (MCQ)',
                  'April 15, 2025',
                  '85%',
                  Icons.quiz,
                  Colors.blue[700]!,
                  [
                    {'category': 'Programming Concepts', 'score': 90},
                    {'category': 'Logic & Algorithms', 'score': 80},
                    {'category': 'Data Structures', 'score': 85},
                  ],
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.grey[200],
                        child: Icon(
                          Icons.hourglass_empty,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'No More Results',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              'Complete more assessments to see your results here',
                              style: TextStyle(color: Colors.grey[700]),
                            ),
                          ],
                        ),
                      ),
                      OutlinedButton(
                        onPressed: () {
                          _tabController.animateTo(1);
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.blue[700],
                          side: BorderSide(color: Colors.blue[700]!),
                        ),
                        child: const Text('View Assessments'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsStat(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, color: color, size: 30),
        ),
        const SizedBox(height: 12),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(color: Colors.grey[700], fontSize: 14),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildResultCard(
    String title,
    String date,
    String score,
    IconData icon,
    Color color,
    List<Map<String, dynamic>> categoryScores,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: color.withOpacity(0.1),
                  child: Icon(icon, color: color),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        'Completed on $date',
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _getScoreColor(
                      double.parse(score.replaceAll('%', '')),
                    ).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    score,
                    style: TextStyle(
                      color: _getScoreColor(
                        double.parse(score.replaceAll('%', '')),
                      ),
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            const Text(
              'Category Breakdown',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            ...categoryScores.map(
              (category) => _buildCategoryScore(
                category['category'],
                category['score'].toDouble(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  onPressed: () {
                    // Download certificate
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Certificate downloading...'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.download),
                  label: const Text('Download Certificate'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.blue[700],
                    side: BorderSide(color: Colors.blue[700]!),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () {
                    // View detailed results
                    showDialog(
                      context: context,
                      builder:
                          (context) => AlertDialog(
                            title: Text('$title Results'),
                            content: const SingleChildScrollView(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Detailed analysis of your assessment performance:',
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    'Strengths:',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '• Strong understanding of core programming concepts',
                                  ),
                                  Text('• Excellent problem-solving approach'),
                                  SizedBox(height: 12),
                                  Text(
                                    'Areas for Improvement:',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '• Data structure implementation could be improved',
                                  ),
                                  Text(
                                    '• Optimization techniques need more practice',
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    'Recommendations:',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text('• Review advanced data structures'),
                                  Text(
                                    '• Practice more algorithm optimization exercises',
                                  ),
                                  Text(
                                    '• Consider taking the advanced programming course',
                                  ),
                                ],
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Close'),
                              ),
                            ],
                          ),
                    );
                  },
                  icon: const Icon(Icons.bar_chart),
                  label: const Text('View Details'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryScore(String category, double score) {
    final color = _getScoreColor(score);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(category),
              Text(
                '$score%',
                style: TextStyle(fontWeight: FontWeight.bold, color: color),
              ),
            ],
          ),
          const SizedBox(height: 6),
          LinearProgressIndicator(
            value: score / 100,
            backgroundColor: Colors.grey[200],
            color: color,
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 90) return Colors.green[700]!;
    if (score >= 75) return Colors.blue[700]!;
    if (score >= 60) return Colors.orange[700]!;
    return Colors.red[700]!;
  }
}
