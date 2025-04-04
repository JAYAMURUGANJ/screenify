import 'package:flutter/material.dart';

class EmbeddedAppContainer extends StatelessWidget {
  final GlobalKey embeddedAreaKey;
  final bool hasEmbeddedApp;
  final String currentAppName;
  final VoidCallback onMouseEnter;
  final VoidCallback? onRefreshApp;
  final bool isLoading; // Add loading indicator flag

  const EmbeddedAppContainer({
    super.key,
    required this.embeddedAreaKey,
    required this.hasEmbeddedApp,
    required this.currentAppName,
    required this.onMouseEnter,
    this.onRefreshApp,
    required this.isLoading, // New required parameter
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Stack(
        children: [
          // Container for embedding apps
          MouseRegion(
            onEnter: (_) => onMouseEnter(),
            child: Container(
              key: embeddedAreaKey,
              color: Colors.grey[200],
              child:
                  !hasEmbeddedApp
                      ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.apps, size: 80, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text(
                              'Select an application to launch',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Choose from the sidebar on the left',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      )
                      : Container(), // Empty container when an app is embedded
            ),
          ),

          // Loading overlay - completely blocks outside interaction
          if (isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.5),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 4,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        currentAppName.isEmpty
                            ? 'Loading application...'
                            : 'Loading $currentAppName...',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Please wait while the application initializes',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
