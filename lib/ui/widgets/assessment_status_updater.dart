import 'package:flutter/material.dart';

import '../../domain/local/assessment_manager.dart';

class AssessmentStatusDashboard extends StatefulWidget {
  const AssessmentStatusDashboard({super.key});

  @override
  State<AssessmentStatusDashboard> createState() =>
      _AssessmentStatusDashboardState();
}

class _AssessmentStatusDashboardState extends State<AssessmentStatusDashboard> {
  final AssessmentPreferencesManager _manager = AssessmentPreferencesManager();

  Map<String, int> _statusCounts = {
    'not_opened': 0,
    'pending': 0,
    'completed': 0,
  };

  bool _isLoading = true;
  int _totalCount = 0;

  @override
  void initState() {
    super.initState();
    _loadAssessmentStatuses();
  }

  Future<void> _loadAssessmentStatuses() async {
    setState(() {
      _isLoading = true;
    });

    final statuses = await _manager.getAllAssessmentStatuses();

    int notOpenedCount = 0;
    int pendingCount = 0;
    int completedCount = 0;

    for (var status in statuses.values) {
      if (status == AssessmentPreferencesManager.STATUS_NOT_OPENED) {
        notOpenedCount++;
      } else if (status == AssessmentPreferencesManager.STATUS_PENDING) {
        pendingCount++;
      } else if (status == AssessmentPreferencesManager.STATUS_COMPLETED) {
        completedCount++;
      }
    }

    setState(() {
      _statusCounts = {
        'not_opened': notOpenedCount,
        'pending': pendingCount,
        'completed': completedCount,
      };
      _totalCount = statuses.length;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.indigo[900]!, Colors.indigo[700]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
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
      child:
          _isLoading
              ? const Center(
                child: CircularProgressIndicator(color: Colors.white),
              )
              : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.analytics, color: Colors.white, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Assessment Progress',
                            style: TextStyle(
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
                          'Total: $_totalCount',
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

                  // Progress Bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value:
                          _totalCount > 0
                              ? _statusCounts['completed']! / _totalCount
                              : 0,
                      backgroundColor: Colors.white.withOpacity(0.3),
                      color: Colors.white,
                      minHeight: 8,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Status Chips Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatusChip(
                        'Not Opened',
                        _statusCounts['not_opened'].toString(),
                        Colors.orange,
                        Icons.lock_outline,
                      ),
                      _buildStatusChip(
                        'Pending',
                        _statusCounts['pending'].toString(),
                        Colors.amber,
                        Icons.access_time,
                      ),
                      _buildStatusChip(
                        'Completed',
                        _statusCounts['completed'].toString(),
                        Colors.green,
                        Icons.check_circle,
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
}
