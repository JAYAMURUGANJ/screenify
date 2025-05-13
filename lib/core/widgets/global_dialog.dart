import 'dart:async';

import 'package:flutter/material.dart';

import '../route/app_route.dart';

/// A dedicated utility class for showing global dialogs throughout the application
class DialogUtils {
  // Use the same navigator key from AppRouter
  static GlobalKey<NavigatorState> get navigatorKey => AppRouter.navigatorKey;

  /// Shows a customizable global dialog without requiring a BuildContext
  ///
  /// Features:
  /// - Material Design 3 styling
  /// - Customizable appearance options
  /// - Animation support
  /// - Accessibility features
  /// - Responsive design
  /// - Support for complex content
  static Future<T?> showGlobalDialog<T>({
    // Basic dialog content
    required String title,
    required String message,

    // Button options
    String? primaryButtonText,
    String? secondaryButtonText,
    VoidCallback? primaryCallback,
    VoidCallback? secondaryCallback,

    // Style customization
    Color? backgroundColor,
    Color? titleColor,
    Color? messageColor,
    Color? primaryButtonColor,
    Color? secondaryButtonColor,

    // Dialog behavior
    bool barrierDismissible = false,
    bool useRootNavigator = true,
    Duration? autoCloseAfter,

    // Optional content
    Widget? customContent,
    EdgeInsets contentPadding = const EdgeInsets.fromLTRB(
      24.0,
      20.0,
      24.0,
      24.0,
    ),

    // Animation options
    Duration animationDuration = const Duration(milliseconds: 250),
    Curve animationCurve = Curves.easeInOut,

    // Accessibility features
    String? semanticsLabel,
    bool enableDismissGesture = false,
  }) async {
    // Ensure we're on the correct frame for UI operations
    return WidgetsBinding.instance.endOfFrame.then((_) async {
      final context = navigatorKey.currentContext;
      if (context == null) {
        debugPrint('Warning: No valid context found for dialog');
        return null;
      }

      // Set up auto-close timer if specified
      Timer? autoCloseTimer;

      T? result = await showGeneralDialog<T>(
        context: context,
        barrierDismissible: barrierDismissible,
        barrierLabel:
            semanticsLabel ??
            MaterialLocalizations.of(context).modalBarrierDismissLabel,
        useRootNavigator: useRootNavigator,
        pageBuilder:
            (_, __, ___) =>
                const SizedBox.shrink(), // Not used with transitionBuilder
        transitionBuilder: (context, animation, secondaryAnimation, child) {
          final curvedAnimation = CurvedAnimation(
            parent: animation,
            curve: animationCurve,
          );

          return ScaleTransition(
            scale: Tween<double>(begin: 0.9, end: 1.0).animate(curvedAnimation),
            child: FadeTransition(
              opacity: Tween<double>(
                begin: 0.0,
                end: 1.0,
              ).animate(curvedAnimation),
              child: AlertDialog(
                backgroundColor: backgroundColor,
                elevation: 4.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0),
                ),
                titlePadding: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 16.0),
                contentPadding: contentPadding,
                title: Semantics(
                  label: 'Dialog title: $title',
                  header: true,
                  child: Text(
                    title,
                    style: TextStyle(
                      color: titleColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                content: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child:
                      customContent ??
                      Semantics(
                        label: 'Dialog content: $message',
                        child: Text(
                          message,
                          style: TextStyle(color: messageColor),
                        ),
                      ),
                ),
                actions: [
                  if (secondaryButtonText != null)
                    TextButton(
                      onPressed: () {
                        if (autoCloseTimer != null) autoCloseTimer.cancel();
                        Navigator.of(context).pop();
                        secondaryCallback?.call();
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: secondaryButtonColor,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                      child: Text(secondaryButtonText),
                    ),
                  FilledButton(
                    onPressed: () {
                      if (autoCloseTimer != null) autoCloseTimer.cancel();
                      Navigator.of(context).pop();
                      primaryCallback?.call();
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: primaryButtonColor,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                    child: Text(primaryButtonText ?? 'OK'),
                  ),
                ],
              ),
            ),
          );
        },
        transitionDuration: animationDuration,
      );

      // Set up auto-close timer if specified
      if (autoCloseAfter != null) {
        autoCloseTimer = Timer(autoCloseAfter, () {
          if (navigatorKey.currentContext != null) {
            Navigator.of(navigatorKey.currentContext!).pop();
            primaryCallback?.call();
          }
        });
      }

      return result;
    });
  }

  /// Shows a simple success dialog with predefined styling
  static Future<void> showSuccess({
    required String title,
    required String message,
    VoidCallback? onDismiss,
  }) {
    return showGlobalDialog(
      title: title,
      message: message,
      primaryButtonText: 'OK',
      primaryCallback: onDismiss,
      backgroundColor: Colors.green.shade50,
      primaryButtonColor: Colors.green,
      barrierDismissible: true,
    );
  }

  /// Shows a simple error dialog with predefined styling
  static Future<void> showError({
    String title = 'Error',
    required String message,
    VoidCallback? onDismiss,
  }) {
    return showGlobalDialog(
      title: title,
      message: message,
      primaryButtonText: 'OK',
      primaryCallback: onDismiss,
      backgroundColor: Colors.red.shade50,
      primaryButtonColor: Colors.red,
    );
  }

  /// Shows a confirmation dialog with Yes/No options
  static Future<bool> showConfirmation({
    required String title,
    required String message,
    String confirmText = 'Yes',
    String cancelText = 'No',
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
  }) async {
    final result = await showGlobalDialog<bool>(
      title: title,
      message: message,
      primaryButtonText: confirmText,
      secondaryButtonText: cancelText,
      primaryCallback: () {
        onConfirm?.call();
      },
      secondaryCallback: () {
        onCancel?.call();
      },
    );

    return result ?? false;
  }

  /// Shows a loading dialog with optional progress indicator and message
  static Future<void> showLoading({
    String title = 'Loading',
    String message = 'Please wait...',
    bool showProgress = false,
    Stream<double>? progressStream,
  }) {
    return showGlobalDialog(
      title: title,
      message: message,
      barrierDismissible: false,
      customContent: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message),
          const SizedBox(height: 16),
          if (showProgress && progressStream != null)
            StreamBuilder<double>(
              stream: progressStream,
              builder: (context, snapshot) {
                final progress = snapshot.data ?? 0.0;
                return LinearProgressIndicator(value: progress);
              },
            )
          else
            const CircularProgressIndicator(),
        ],
      ),
    );
  }

  /// Dismisses any currently showing dialog
  static void dismissCurrentDialog() {
    final context = navigatorKey.currentContext;
    if (context != null && Navigator.canPop(context)) {
      Navigator.of(context).pop();
    }
  }
}
