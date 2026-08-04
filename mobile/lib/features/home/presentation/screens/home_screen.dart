import 'package:flutter/material.dart';

import '../widgets/analytics_tile.dart';
import '../widgets/dashboard_card.dart';
import '../widgets/quick_action_button.dart';
import '../widgets/section_title.dart';

/// The Home Dashboard screen for Vexa Voice.
///
/// Pure UI layer: no Firebase calls, no state management packages.
/// All content below is placeholder/static data — wire it up to real
/// data sources (Firestore streams, view-models, etc.) separately.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Bottom navigation selected index — local UI state only.
  int _selectedNavIndex = 0;

  // Static placeholder data for the "Recent Calls" list.
  final List<_RecentCallData> _recentCalls = const [
    _RecentCallData(
      title: 'Aarav Mehta',
      subtitle: 'Booking inquiry · AI handled',
      trailing: '2m 14s',
      status: 'Answered',
      statusColor: Color(0xFF4ADE80),
      icon: Icons.call_rounded,
    ),
    _RecentCallData(
      title: 'Priya Sharma',
      subtitle: 'Appointment reschedule',
      trailing: '1m 02s',
      status: 'Answered',
      statusColor: Color(0xFF4ADE80),
      icon: Icons.call_rounded,
    ),
    _RecentCallData(
      title: 'Unknown Caller',
      subtitle: 'No response',
      trailing: '10:42 AM',
      status: 'Missed',
      statusColor: Color(0xFFF87171),
      icon: Icons.call_missed_rounded,
    ),
    _RecentCallData(
      title: 'Karan Malhotra',
      subtitle: 'Pricing question · AI handled',
      trailing: '3m 40s',
      status: 'Answered',
      statusColor: Color(0xFF4ADE80),
      icon: Icons.call_rounded,
    ),
  ];

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
                  const SizedBox(height: 100), // space above bottom nav
                ]),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  /// Top app bar with greeting, business info and profile avatar.
  Widget _buildAppBar(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Greeting + business info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Hello, Rajveer 👋',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        'Rajveer Motors',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 13.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        height: 3,
                        width: 3,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Automotive Services',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 13.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Profile avatar
            Container(
              height: 46,
              width: 46,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFF7C8CFF), Color(0xFF5B6EF5)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: const Center(
                child: Text(
                  'R',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// "Quick Actions" row: AI Calls, Customers, Analytics, Settings.
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
                onTap: () {},
              ),
            ),
            Expanded(
              child: QuickActionButton(
                icon: Icons.people_alt_rounded,
                label: 'Customers',
                iconColor: const Color(0xFF4ADE80),
                onTap: () {},
              ),
            ),
            Expanded(
              child: QuickActionButton(
                icon: Icons.bar_chart_rounded,
                label: 'Analytics',
                iconColor: const Color(0xFFFBBF24),
                onTap: () {},
              ),
            ),
            Expanded(
              child: QuickActionButton(
                icon: Icons.settings_rounded,
                label: 'Settings',
                iconColor: const Color(0xFFA78BFA),
                onTap: () {},
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Analytics grid: Today's Calls, Appointments, Revenue, AI Accuracy.
  ///
  /// Uses a responsive 2-column grid via LayoutBuilder so tile sizing
  /// adapts cleanly across phone widths.
  Widget _buildAnalyticsSection(BuildContext context) {
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
                  child: const AnalyticsTile(
                    label: "Today's Calls",
                    value: '38',
                    icon: Icons.phone_in_talk_rounded,
                    accentColor: Color(0xFF7C8CFF),
                    trend: '+12%',
                    isPositiveTrend: true,
                  ),
                ),
                SizedBox(
                  width: tileWidth,
                  child: const AnalyticsTile(
                    label: 'Appointments',
                    value: '14',
                    icon: Icons.event_available_rounded,
                    accentColor: Color(0xFF4ADE80),
                    trend: '+5%',
                    isPositiveTrend: true,
                  ),
                ),
                SizedBox(
                  width: tileWidth,
                  child: const AnalyticsTile(
                    label: 'Revenue',
                    value: '₹42,300',
                    icon: Icons.currency_rupee_rounded,
                    accentColor: Color(0xFFFBBF24),
                    trend: '+8%',
                    isPositiveTrend: true,
                  ),
                ),
                SizedBox(
                  width: tileWidth,
                  child: const AnalyticsTile(
                    label: 'AI Accuracy',
                    value: '96.4%',
                    icon: Icons.psychology_rounded,
                    accentColor: Color(0xFFA78BFA),
                    trend: '-0.3%',
                    isPositiveTrend: false,
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  /// "Recent Activity" — recent calls list built from DashboardCard rows.
  Widget _buildRecentActivitySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(
          title: 'Recent Activity',
          trailingText: 'See all',
          onTrailingTap: () {},
        ),
        const SizedBox(height: 4),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _recentCalls.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final call = _recentCalls[index];
            return DashboardCard(
              leadingIcon: call.icon,
              leadingIconColor: call.statusColor,
              title: call.title,
              subtitle: call.subtitle,
              trailingLabel: call.trailing,
              statusLabel: call.status,
              statusColor: call.statusColor,
              onTap: () {},
            );
          },
        ),
      ],
    );
  }

  /// Bottom navigation bar with 4 primary destinations.
  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F1015),
        border: Border(
          top: BorderSide(color: Colors.white.withOpacity(0.06)),
        ),
      ),
      child: SafeArea(
        child: BottomNavigationBar(
          currentIndex: _selectedNavIndex,
          onTap: (index) => setState(() => _selectedNavIndex = index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: const Color(0xFF7C8CFF),
          unselectedItemColor: Colors.white.withOpacity(0.4),
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

/// Internal placeholder model for a "Recent Calls" list entry.
/// UI-only — replace with a real domain model when wiring up data.
class _RecentCallData {
  final String title;
  final String subtitle;
  final String trailing;
  final String status;
  final Color statusColor;
  final IconData icon;

  const _RecentCallData({
    required this.title,
    required this.subtitle,
    required this.trailing,
    required this.status,
    required this.statusColor,
    required this.icon,
  });
}
