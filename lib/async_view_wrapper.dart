import 'package:flutter/material.dart';

class AsyncViewWrapper<T> extends StatelessWidget {
  final bool isLoading;
  final String? errorMessage;
  final List<T> items;
  final Widget Function(List<T> items) onSuccess;
  final VoidCallback onRetry;
  final String emptyMessage;

  const AsyncViewWrapper({
    super.key,
    required this.isLoading,
    required this.errorMessage,
    required this.items,
    required this.onSuccess,
    required this.onRetry,
    this.emptyMessage = 'No items found.',
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: Color(0xFF2563EB), strokeWidth: 3),
              const SizedBox(height: 16),
              const Text('Loading data...', style: TextStyle(fontSize: 13, color: Color(0xFF64748B), fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      );
    }

    if (errorMessage != null && errorMessage!.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline_rounded, color: Colors.red, size: 48),
              const SizedBox(height: 12),
              Text(
                errorMessage!,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Retry', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      );
    }

    if (items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.inbox_outlined, color: Colors.grey.shade400, size: 52),
              const SizedBox(height: 12),
              Text(
                emptyMessage,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey.shade600),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return onSuccess(items);
  }
}
