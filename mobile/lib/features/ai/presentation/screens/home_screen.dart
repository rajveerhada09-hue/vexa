import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../dashboard/provider/dashboard_provider.dart';
import '../../../user/providers/user_provider.dart'
    show UserProvider;
import '../../../calls/providers/call_provider.dart'
    show CallProvider;
import '../../../../services/auth/auth_service.dart';
import '../widgets/analytics_tile.dart';
import '../widgets/dashboard_card.dart';
import '../widgets/quick_action_button.dart'
    show QuickActionButton;
import '../widgets/section_title.dart';
import '../../../../routes/route_names.dart';
import '../../../../features/calls/model/call_model.dart';

/// The Home Dashboard screen for Vexa Voice.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      context.read<UserProvider>().loadCurrentUser();
      context.read<DashboardProvider>().loadDashboard();
      context.read<CallProvider>().loadRecentCalls(limit: 5);
      context.read<CallProvider>().loadTodaysCalls();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0C10),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            _buildAppBar(context),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const SizedBox(height: 8),
                  _buildQuickActionsSection(),
                  const SizedBox(height: 28),
                  _buildAnalyticsSection(context),
                  const SizedBox(height: 28),
                  _buildRecentActivitySection(),
                  const SizedBox(height: 100),
                ]),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    final user = context.watch<UserProvider>().currentUser;

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hello, ${user?.fullName ?? "User"} 👋',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.businessName ?? 'No Business',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 13.5,
                    ),
                  ),
                ],
              ),
            ),

            Row(
              children: [
                Container(
                  height: 46,
                  width: 46,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF5B6EF5),
                  ),
                  child: Center(
                    child: Text(
                      (user?.fullName.isNotEmpty ?? false)
                          ? user!.fullName[0].toUpperCase()
                          : "U",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                IconButton(
                  icon: const Icon(
                    Icons.logout,
                    color: Colors.white,
                  ),
                  tooltip: "Logout",
                  onPressed: () async {
                    final shouldLogout = await showDialog<bool>(
                      context: context,
                      builder: (dialogContext) {
                        return AlertDialog(
                          title: const Text("Logout"),
                          content: const Text("Are you sure you want to logout?"),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(dialogContext, false),
                              child: const Text("Cancel"),
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.pop(dialogContext, true),
                              child: const Text("Logout"),
                            ),
                          ],
                        );
                      },
                    );

                    if (shouldLogout != true) return;

                    if (!mounted) return;

                    try {
                      await context.read<AuthService>().signOut();
                    } catch (e, stackTrace) {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Logout failed: $e')),
                      );
                      return;
                    }

                    if (!mounted) return;

                    context.read<UserProvider>().clearUserData();
                    context.read<DashboardProvider>().clearDashboard();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(title: 'Quick Actions'),
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(
              child: QuickActionButton(
                icon: Icons.graphic_eq_rounded,
                label: 'AI Calls',
                iconColor: const Color(0xFF7C8CFF),
                onTap: () => context.go(RouteNames.calls),
              ),
            ),
            Expanded(
              child: QuickActionButton(
                icon: Icons.people_alt_rounded,
                label: 'Customers',
                iconColor: const Color(0xFF4ADE80),
                onTap: () => context.go(RouteNames.customers),
              ),
            ),
            Expanded(
              child: QuickActionButton(
                icon: Icons.bar_chart_rounded,
                label: 'Analytics',
                iconColor: const Color(0xFFFBBF24),
                onTap: () => context.go(RouteNames.analytics),
              ),
            ),
            Expanded(
              child: QuickActionButton(
                icon: Icons.settings_rounded,
                label: 'Settings',
                iconColor: const Color(0xFFA78BFA),
                onTap: () => context.go(RouteNames.settings),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAnalyticsSection(BuildContext context) {
    final dashboard = context.watch<DashboardProvider>().dashboard;
    final callProvider = context.watch<CallProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(title: 'Analytics'),
        const SizedBox(height: 4),
        LayoutBuilder(
          builder: (context, constraints) {
            final tileWidth = (constraints.maxWidth - 12) / 2;
            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                SizedBox(
                  width: tileWidth,
                  child: AnalyticsTile(
                    label: "Today's Calls",
                    value: '${callProvider.todayCallsCount}',
                    icon: Icons.phone_in_talk_rounded,
                    accentColor: const Color(0xFF7C8CFF),
                    trend: dashboard?.todayCallsTrend ?? '0%',
                    isPositiveTrend:
                        !(dashboard?.todayCallsTrend.startsWith('-') ?? false),
                  ),
                ),
                SizedBox(
                  width: tileWidth,
                  child: AnalyticsTile(
                    label: 'Appointments',
                    value: '${dashboard?.appointments ?? 0}',
                    icon: Icons.event_available_rounded,
                    accentColor: const Color(0xFF4ADE80),
                    trend: dashboard?.appointmentsTrend ?? '0%',
                    isPositiveTrend:
                        !(dashboard?.appointmentsTrend.startsWith('-') ?? false),
                  ),
                ),
                SizedBox(
                  width: tileWidth,
                  child: AnalyticsTile(
                    label: 'Revenue',
                    value: '₹${dashboard?.revenue ?? 0}',
                    icon: Icons.currency_rupee_rounded,
                    accentColor: const Color(0xFFFBBF24),
                    trend: dashboard?.revenueTrend ?? '0%',
                    isPositiveTrend:
                        !(dashboard?.revenueTrend.startsWith('-') ?? false),
                  ),
                ),
                SizedBox(
                  width: tileWidth,
                  child: AnalyticsTile(
                    label: 'AI Accuracy',
                    value: '${dashboard?.aiAccuracy ?? 0}%',
                    icon: Icons.psychology_rounded,
                    accentColor: const Color(0xFFA78BFA),
                    trend: dashboard?.aiAccuracyTrend ?? '0%',
                    isPositiveTrend:
                        !(dashboard?.aiAccuracyTrend.startsWith('-') ?? false),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildRecentActivitySection() {
    return Consumer<CallProvider>(
      builder: (context, callProvider, _) {
        final calls = callProvider.recentCalls;

        if (callProvider.isLoading && calls.isEmpty) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionTitle(
                title: 'Recent Activity',
                trailingText: 'See all',
                onTrailingTap: () => context.go(RouteNames.calls),
              ),
              const SizedBox(height: 4),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 3,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (_, _) => const _CallSkeleton(),
              ),
            ],
          );
        }

        if (callProvider.error != null && calls.isEmpty) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionTitle(
                title: 'Recent Activity',
                trailingText: 'See all',
                onTrailingTap: () => context.go(RouteNames.calls),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF15171F),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline_rounded, color: Color(0xFFF87171), size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Failed to load recent calls',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 13.5,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => callProvider.loadRecentCalls(limit: 5),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ],
          );
        }

        if (calls.isEmpty) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionTitle(
                title: 'Recent Activity',
                trailingText: 'See all',
                onTrailingTap: () => context.go(RouteNames.calls),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF15171F),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
                ),
                child: Center(
                  child: Column(
                    children: [
                      const Icon(
                        Icons.call_rounded,
                        size: 32,
                        color: Color(0xFF7C8CFF),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'No calls yet',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Your recent call activity will appear here',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 12.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionTitle(
              title: 'Recent Activity',
              trailingText: 'See all',
              onTrailingTap: () => context.go(RouteNames.calls),
            ),
            const SizedBox(height: 4),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: calls.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final call = calls[index];
                return _buildCallCard(call);
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildCallCard(CallModel call) {
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
      onTap: () {},
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F1015),
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
        ),
      ),
      child: SafeArea(
        child: BottomNavigationBar(
          currentIndex: 0,
          onTap: (index) {
            switch (index) {
              case 0:
                context.go(RouteNames.home);
                break;
              case 1:
                context.go(RouteNames.calls);
                break;
              case 2:
                context.go(RouteNames.analytics);
                break;
              case 3:
                context.go(RouteNames.profile);
                break;
            }
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: const Color(0xFF7C8CFF),
          unselectedItemColor: Colors.white.withValues(alpha: 0.4),
          selectedLabelStyle: const TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: const TextStyle(fontSize: 11.5),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.call_rounded),
              label: 'Calls',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart_rounded),
              label: 'Analytics',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}

class _CallSkeleton extends StatelessWidget {
  const _CallSkeleton();

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