import 'package:flutter/material.dart';

class AppErrorHandler {
  static void showFriendlyError(BuildContext context, dynamic error) {
    String message = 'An unexpected error occurred. Please try again.';

    final errorStr = error.toString().toLowerCase();

    if (errorStr.contains('socket') || errorStr.contains('network') || errorStr.contains('internet')) {
      message = 'No internet connection. Please check your network and try again.';
    } else if (errorStr.contains('timeout')) {
      message = 'Request timed out. The server took too long to respond.';
    } else if (errorStr.contains('session') || errorStr.contains('expired') || errorStr.contains('unauthorized')) {
      message = 'Your session has expired. Please log in again.';
    } else if (errorStr.contains('database') || errorStr.contains('sqlite') || errorStr.contains('storage')) {
      message = 'Database failure. Unable to save data locally.';
    } else if (errorStr.contains('image') || errorStr.contains('upload')) {
      message = 'Failed image upload. Please select a smaller photo or retry.';
    } else if (errorStr.contains('server') || errorStr.contains('500') || errorStr.contains('503')) {
      message = 'Server error. Our technical team has been notified.';
    } else if (error.toString().trim().isNotEmpty) {
      message = error.toString().replaceAll('Exception: ', '');
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(child: Text(message, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
          ],
        ),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
