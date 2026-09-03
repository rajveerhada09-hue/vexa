import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../features/calls/model/call_model.dart';
import '../../../../features/calls/providers/call_provider.dart';
import '../../../../routes/route_names.dart';
import '../widgets/dashboard_card.dart';

class CallsScreen extends StatefulWidget {
  const CallsScreen({super.key});

  @override
  State<CallsScreen> createState() => _CallsScreenState();
}

class _CallsScreenState extends State<CallsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<CallProvider>().loadRecentCalls(limit: 20);
      }
    });
  }

  Future<void> _onRefresh() async {
    await context.read<CallProvider>().loadRecentCalls(limit: 20);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0C10),
      appBar: AppBar(
        title: const Text('Calls'),
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
              context.go(RouteNames.home);
            }
          },
        ),
      ),
      body: Consumer<CallProvider>(
        builder: (context, callProvider, _) {
          if (callProvider.isLoading && callProvider.recentCalls.isEmpty) {
            return const _LoadingState();
          }

          if (callProvider.error != null && callProvider.recentCalls.isEmpty) {
            return _ErrorState(
              message: callProvider.error!,
              onRetry: () => context.read<CallProvider>().loadRecentCalls(limit: 20),
            );
          }

          if (callProvider.recentCalls.isEmpty) {
            return const _EmptyState();
          }

          return RefreshIndicator(
            onRefresh: _onRefresh,
            color: const Color(0xFF7C8CFF),
            backgroundColor: const Color(0xFF0F1015),
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
              itemCount: callProvider.recentCalls.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final call = callProvider.recentCalls[index];
                return _CallListItem(call: call);
              },
            ),
          );
        },
      ),
    );
  }
}

class _CallListItem extends StatelessWidget {
  final CallModel call;

  const _CallListItem({required this.call});

  @override
  Widget build(BuildContext context) {
    final isMissed = call.status == CallStatus.missed;
    final statusColor = isMissed ? const Color(0xFFF87171) : const Color(0xFF4ADE80);
    final leadingIcon = isMissed ? Icons.call_missed_rounded : Icons.call_rounded;

    String subtitle = call.purpose ?? '';
    if (call.aiHandled) {
      subtitle = subtitle.isEmpty ? 'AI handled' : '$subtitle · AI handled';
    }

    return DashboardCard(
      leadingIcon: leadingIcon,
      leadingIconColor: statusColor,
      title: call.callerName,
      subtitle: subtitle.isEmpty ? 'No details' : subtitle,
      trailingLabel: call.formattedDuration,
      statusLabel: call.status.value.toUpperCase(),
      statusColor: statusColor,
      onTap: () => _showCallDetail(context, call),
    );
  }

  void _showCallDetail(BuildContext context, CallModel call) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0F1015),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      isScrollControlled: true,
      builder: (context) => _CallDetailSheet(call: call),
    );
  }
}

class _CallDetailSheet extends StatelessWidget {
  final CallModel call;

  const _CallDetailSheet({required this.call});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Container(
                height: 56,
                width: 56,
                decoration: BoxDecoration(
                  color: (call.status == CallStatus.missed
                          ? const Color(0xFFF87171)
                          : const Color(0xFF4ADE80))
                      .withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  call.status == CallStatus.missed
                      ? Icons.call_missed_rounded
                      : Icons.call_rounded,
                  color: call.status == CallStatus.missed
                      ? const Color(0xFFF87171)
                      : const Color(0xFF4ADE80),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      call.callerName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      call.phoneNumber,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: (call.status == CallStatus.missed
                          ? const Color(0xFFF87171)
                          : const Color(0xFF4ADE80))
                      .withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  call.status.value.toUpperCase(),
                  style: TextStyle(
                    color: call.status == CallStatus.missed
                        ? const Color(0xFFF87171)
                        : const Color(0xFF4ADE80),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _DetailRow(
            label: 'Duration',
            value: call.formattedDuration,
          ),
          const SizedBox(height: 12),
          _DetailRow(
            label: 'Date & Time',
            value: call.formattedDateTime,
          ),
          if (call.purpose != null) ...[
            const SizedBox(height: 12),
            _DetailRow(
              label: 'Purpose',
              value: call.purpose!,
            ),
          ],
          if (call.aiHandled) ...[
            const SizedBox(height: 12),
            _DetailRow(
              label: 'AI Handled',
              value: 'Yes',
              valueColor: const Color(0xFF7C8CFF),
            ),
          ],
          if (call.outcome != null) ...[
            const SizedBox(height: 12),
            _DetailRow(
              label: 'Outcome',
              value: call.outcome!.value.replaceAll('_', ' ').toUpperCase(),
            ),
          ],
          if (call.transcript != null && call.transcript!.isNotEmpty) ...[
            const SizedBox(height: 20),
            const Text(
              'Transcript',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF15171F),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
              ),
              child: Text(
                call.transcript!,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _DetailRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.5),
            fontSize: 13.5,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? Colors.white,
            fontSize: 13.5,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      itemCount: 5,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (_, _) => _CallSkeleton(),
    );
  }
}

class _CallSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF15171F),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
        ),
        child: Row(
          children: [
            Container(
              height: 44,
              width: 44,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(13),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 16,
                    width: 120,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 13,
                    width: 180,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  height: 13,
                  width: 60,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  height: 16,
                  width: 70,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.call_rounded,
              size: 64,
              color: Color(0xFF7C8CFF),
            ),
            const SizedBox(height: 16),
            const Text(
              'No calls yet',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your call history will appear here',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
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

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: Color(0xFFF87171),
            ),
            const SizedBox(height: 16),
            const Text(
              'Failed to load calls',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7C8CFF),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}