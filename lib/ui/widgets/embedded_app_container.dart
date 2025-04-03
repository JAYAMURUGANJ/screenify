import 'package:flutter/material.dart';

import '../../services/window_service.dart';

class EmbeddedAppContainer extends StatelessWidget {
  final GlobalKey embeddedAreaKey;
  final bool hasEmbeddedApp;
  final VoidCallback onMouseEnter;

  const EmbeddedAppContainer({
    super.key,
    required this.embeddedAreaKey,
    required this.hasEmbeddedApp,
    required this.onMouseEnter,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 3,
      child: MouseRegion(
        onEnter: (_) {
          // Call focus method when mouse enters
          WindowService().focusEmbeddedApp();
        },
        child: Container(
          key: embeddedAreaKey,
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              bottomLeft: Radius.circular(16),
            ),
          ),
          child:
              hasEmbeddedApp
                  ? const SizedBox.expand()
                  : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.apps, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 24),
                        Text(
                          'No Application Embedded',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          width: 300,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.blue.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            'Select an application from the sidebar to embed it here',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.blue[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
        ),
      ),
    );
  }
}
