import 'package:flutter/material.dart';

/// A reusable section header used throughout the Home Dashboard.
///
/// Displays a bold title with optional trailing action text (e.g. "See all").
/// Keeps section headings visually consistent across the dashboard.
class SectionTitle extends StatelessWidget {
  final String title;
  final String? trailingText;
  final VoidCallback? onTrailingTap;

  const SectionTitle({
    super.key,
    required this.title,
    this.trailingText,
    this.onTrailingTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.white,
              letterSpacing: 0.1,
            ),
          ),
          if (trailingText != null)
            GestureDetector(
              onTap: onTrailingTap,
              child: Text(
                trailingText!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF7C8CFF),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
