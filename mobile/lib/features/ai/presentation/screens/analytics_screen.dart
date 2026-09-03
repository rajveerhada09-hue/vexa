import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Placeholder screen for Analytics.
///
/// This is a minimal implementation to enable navigation testing.
/// Will be replaced with a real analytics dashboard in a future phase.
class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0C10),
      appBar: AppBar(
        title: const Text('Analytics'),
        backgroundColor: const Color(0xFF0F1015),
        foregroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/home');
            }
          },
        ),
      ),
      body: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.bar_chart_rounded,
              size: 64,
              color: Color(0xFFFBBF24),
            ),
            SizedBox(height: 16),
            Text(
              'Analytics Screen',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Detailed analytics and reports coming soon',
              style: TextStyle(
                color: Color(0xFF8B95A6),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}