import 'package:flutter/material.dart';

/// Banner widget for displaying error messages.
///
/// Shows errors in a dismissible format with optional retry action.
class ErrorBanner extends StatelessWidget {
  const ErrorBanner({
    super.key,
    required this.message,
    this.onDismiss,
    this.onRetry,
  });

  /// The error message to display
  final String message;

  /// Callback when the dismiss button is tapped
  final VoidCallback? onDismiss;

  /// Callback when the retry button is tapped (optional)
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xE6E53935), // Red with high opacity
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline,
            color: Colors.white,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (onRetry != null) ...[
            const SizedBox(width: 8),
            IconButton(
              onPressed: onRetry,
              icon: const Icon(
                Icons.refresh,
                color: Colors.white,
                size: 20,
              ),
              constraints: const BoxConstraints(
                minWidth: 36,
                minHeight: 36,
              ),
              padding: EdgeInsets.zero,
            ),
          ],
          if (onDismiss != null) ...[
            const SizedBox(width: 4),
            IconButton(
              onPressed: onDismiss,
              icon: const Icon(
                Icons.close,
                color: Colors.white70,
                size: 20,
              ),
              constraints: const BoxConstraints(
                minWidth: 36,
                minHeight: 36,
              ),
              padding: EdgeInsets.zero,
            ),
          ],
        ],
      ),
    );
  }
}
