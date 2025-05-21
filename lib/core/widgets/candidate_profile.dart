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
      onTapDown: (details) => _showProfileMenu(context, details.globalPosition),
      child: Center(
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
      ),
    );
  }

  void _showProfileMenu(BuildContext context, Offset position) {
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;

    showMenu(
      context: context,
      position: RelativeRect.fromRect(
        Rect.fromLTWH(position.dx, position.dy, 0, 0),
        Offset.zero & overlay.size,
      ),
      items: [
        PopupMenuItem(
          enabled: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
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
              const SizedBox(height: 12),
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
            ],
          ),
        ),
      ],
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
      Colors.indigo,
      Colors.blue,
      Colors.green,
      Colors.purple,
      Colors.amber,
      Colors.teal,
      Colors.pink,
      Colors.deepOrange,
    ];

    return colors[random.nextInt(colors.length)][300]!;
  }
}
