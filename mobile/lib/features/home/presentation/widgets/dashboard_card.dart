import 'package:flutter/material.dart';

/// A general-purpose card row used for list-style content on the
/// dashboard — primarily the "Recent Activity" / "Recent Calls" list.
///
/// Shows a leading icon/avatar, a title, a subtitle, and trailing
/// metadata (e.g. call duration or timestamp) with an optional status
/// badge/color to indicate call outcome (answered, missed, etc.).
class DashboardCard extends StatelessWidget {
  final IconData leadingIcon;
  final Color leadingIconColor;
  final String title;
  final String subtitle;
  final String trailingLabel;
  final String? statusLabel;
  final Color? statusColor;
  final VoidCallback? onTap;

  const DashboardCard({
    super.key,
    required this.leadingIcon,
    required this.title,
    required this.subtitle,
    required this.trailingLabel,
    this.leadingIconColor = const Color(0xFF7C8CFF),
    this.statusLabel,
    this.statusColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF15171F),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
          ),
          child: Row(
            children: [
              // Leading icon container
              Container(
                height: 44,
                width: 44,
                decoration: BoxDecoration(
                  color: leadingIconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(leadingIcon, color: leadingIconColor, size: 20),
              ),
              const SizedBox(width: 12),
              // Title + subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Trailing metadata + optional status badge
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    trailingLabel,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (statusLabel != null) ...[
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: (statusColor ?? const Color(0xFF4ADE80))
                            .withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        statusLabel!,
                        style: TextStyle(
                          color: statusColor ?? const Color(0xFF4ADE80),
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
