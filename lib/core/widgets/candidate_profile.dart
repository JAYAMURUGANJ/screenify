import 'dart:math';

import 'package:flutter/material.dart';

class CandidateProfile extends StatelessWidget {
  final String name;
  final String candidateId;

  const CandidateProfile({
    super.key,
    required this.name,
    required this.candidateId,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showProfileMenu(context),
      child: Padding(
        padding: const EdgeInsets.only(right: 16),
        child: CircleAvatar(
          radius: 18,
          backgroundColor: _getAvatarColor(name),
          child: Text(
            _getInitials(name),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  void _showProfileMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder:
          (context) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.indigo[100],
                  child: Text(
                    _getInitials(name),
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  candidateId,
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
                const Divider(height: 30),
                ListTile(
                  leading: const Icon(Icons.person_outline),
                  title: const Text('My Profile'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/profile');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.settings_outlined),
                  title: const Text('Settings'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/settings');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text(
                    'Logout',
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: () async {
                    Navigator.pop(context);
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/login',
                      (route) => false,
                    );
                    // Implement your logout logic here
                    //await assessmentPreferencesManager.clearAllAssessmentData();
                  },
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '?';
    final nameParts = name.trim().split(' ');
    if (nameParts.length >= 2) {
      return '${nameParts[0][0]}${nameParts[1][0]}'.toUpperCase();
    } else {
      return name[0].toUpperCase();
    }
  }

  Color _getAvatarColor(String name) {
    if (name.isEmpty) return Colors.grey;

    final int hashCode = name.hashCode;
    final Random random = Random(hashCode);

    final List<MaterialColor> colors = [
      Colors.blue,
      Colors.green,
      Colors.purple,
      Colors.amber,
      Colors.teal,
      Colors.pink,
      Colors.deepOrange,
      Colors.indigo,
    ];

    return colors[random.nextInt(colors.length)][300]!;
  }
}
