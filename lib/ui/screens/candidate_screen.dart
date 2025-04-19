import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../domain/model/candidate.dart';

class CandidateScreeningPage extends StatefulWidget {
  final Candidate candidate;

  const CandidateScreeningPage({super.key, required this.candidate});

  @override
  State<CandidateScreeningPage> createState() => _CandidateScreeningPageState();
}

class _CandidateScreeningPageState extends State<CandidateScreeningPage> {
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

  bool _isNotificationsExpanded = false;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          elevation: 5,
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
                child: const Icon(
                  Icons.app_shortcut,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Screenify',
                    style: TextStyle(
                      color: Color(0xFF2C3E50),
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  Text(
                    'Candidate Assessment Portal',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
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
                    decoration: const BoxDecoration(
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
                      child: const Row(
                        children: [
                          Icon(Icons.person),
                          SizedBox(width: 8),
                          Text('Profile'),
                        ],
                      ),
                      onTap: () {
                        // Navigate to profile
                      },
                    ),
                    PopupMenuItem(
                      child: const Row(
                        children: [
                          Icon(Icons.settings),
                          SizedBox(width: 8),
                          Text('Settings'),
                        ],
                      ),
                      onTap: () {
                        // Navigate to settings
                      },
                    ),
                    PopupMenuItem(
                      child: const Row(
                        children: [
                          Icon(Icons.help_outline),
                          SizedBox(width: 8),
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
        ),
        body: Stack(
          children: [
            Column(
              children: [
                // Organization Header with Logo
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 20,
                    horizontal: 24,
                  ),
                  color: Colors.white,
                  child: Center(
                    child: Row(
                      mainAxisSize:
                          MainAxisSize
                              .min, // Important for centering the row content
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Logo
                        SizedBox(
                          width: 160,
                          height: 160,
                          child: Image.asset(
                            'assets/images/logo.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Organization details
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: const [
                            Text(
                              'The Income Tax Department Co-operative Society Limited',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 8),
                            Text(
                              '(REGD.No. MSCS/CR-11/90)',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 4),
                            Text(
                              '121, MAHATHMA GANDHI SALAI, CHENNAI - 600 034.',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Main Content (moved inside the Column)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Main content with side-by-side layout
                        Expanded(
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              // Use Row for wider screens, Column for narrower screens
                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Left column - Profile
                                  Expanded(
                                    flex: 1,
                                    child: SingleChildScrollView(
                                      child: _buildProfileSection(),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  // Right column - Assessments
                                  Expanded(
                                    flex: 1,
                                    child: SingleChildScrollView(
                                      child: _buildAssessmentsSection(),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),

                        // Footer
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Text(
                              '© ${DateTime.now().year} Screenify. All rights reserved.',
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Notifications panel (unchanged)
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
                            const Text(
                              'Notifications',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
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
                              child: const Text('Mark all as read'),
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
                                      style: const TextStyle(fontSize: 12),
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

  Widget _buildProfileSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Candidate Profile',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C3E50),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                CircleAvatar(
                  radius: 35,
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
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    // Edit profile
                  },
                  color: Colors.blue[700],
                  tooltip: 'Edit Profile',
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(),
            _buildInfoItem(Icons.email, 'Email', widget.candidate.email),
            _buildInfoItem(Icons.phone, 'Phone', widget.candidate.phone),
            _buildInfoItem(Icons.cake, 'Date of Birth', widget.candidate.dob),
            _buildInfoItem(
              Icons.work,
              'Position Applied',
              'Software Developer',
            ),
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

  Widget _buildAssessmentsSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Assessments',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                const Chip(
                  label: Text('2 Pending'),
                  backgroundColor: Color(0xFFFFECB3),
                  labelStyle: TextStyle(color: Color(0xFFFF8F00)),
                ),
              ],
            ),
            const SizedBox(height: 16),

            _buildAssessmentItem(
              'Multiple Choice Questions (MCQ)',
              'Not scheduled',
              'Not scheduled',
              Icons.quiz,
              Colors.purple[700]!,
              isNotScheduled: true,
              description:
                  'Knowledge assessment through multiple choice questions on programming concepts and logic',
            ),
            const Divider(),
            _buildAssessmentItem(
              'Technical Skills Assessment',
              'April 17, 2025',
              '10:00 AM - 11:30 AM',
              Icons.computer,
              Colors.green[700]!,
              isPending: true,
              description:
                  'Practical assessment on MS Office applications including Word, Excel and PowerPoint',
              navigationRoute: '/technicalAssesment',
            ),
            const Divider(),
            _buildAssessmentItem(
              'Form Filling Skills Assessment',
              'Not scheduled',
              'Not scheduled',
              Icons.assignment,

              Colors.green[700]!,
              isPending: true,
              description:
                  'Assessment of form filling skills including accuracy and speed',
              navigationRoute: '/memberShipForm',
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
    bool isNotScheduled = false,
    required String description,
    String? navigationRoute, // New parameter for the route
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                Text(
                  description,
                  style: TextStyle(color: Colors.grey[700], fontSize: 12),
                ),
                const SizedBox(height: 8),
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
                // Start assessment with the specific route
                if (navigationRoute != null) {
                  Navigator.pushNamed(context, navigationRoute);
                }
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
                if (navigationRoute != null) {
                  Navigator.pushNamed(context, navigationRoute);
                }
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.green[700],
                side: BorderSide(color: Colors.green[700]!),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text('Results'),
            )
          else if (isNotScheduled)
            OutlinedButton(
              onPressed: () {
                // Schedule assessment
                if (navigationRoute != null) {
                  Navigator.pushNamed(context, navigationRoute);
                }
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.blue[700],
                side: BorderSide(color: Colors.blue[700]!),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text('Schedule'),
            ),
        ],
      ),
    );
  }
}
