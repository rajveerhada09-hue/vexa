import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../features/customers/providers/customer_provider.dart';
import '../../../../features/customers/model/customer_model.dart';
import '../../../../features/calls/providers/call_provider.dart';
import '../../../../features/calls/model/call_model.dart';
import '../../../../routes/route_names.dart';

class CustomerDetailScreen extends StatefulWidget {
  final String customerId;

  const CustomerDetailScreen({super.key, required this.customerId});

  @override
  State<CustomerDetailScreen> createState() => _CustomerDetailScreenState();
}

class _CustomerDetailScreenState extends State<CustomerDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<CustomerProvider>().loadCustomerForDetail(widget.customerId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0C10),
      appBar: AppBar(
        title: const Text('Customer Details'),
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
              context.go(RouteNames.customers);
            }
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_rounded),
            onPressed: () => _showEditDialog(context),
            tooltip: 'Edit Customer',
          ),
          IconButton(
            icon: const Icon(Icons.delete_rounded),
            onPressed: () => _confirmDelete(context),
            tooltip: 'Delete Customer',
          ),
        ],
      ),
      body: Consumer2<CustomerProvider, CallProvider>(
        builder: (context, customerProvider, callProvider, _) {
          if (customerProvider.isLoadingCustomers && customerProvider.selectedCustomer?.id != widget.customerId) {
            return const _LoadingState();
          }

          final customer = customerProvider.selectedCustomer;

          if (customer == null || customer.id != widget.customerId) {
            return _ErrorState(
              message: 'Customer not found',
              onRetry: () => customerProvider.selectCustomer(widget.customerId),
            );
          }

          // Load call history when customer is loaded
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && callProvider.customerCallHistory.isEmpty && !callProvider.isLoadingCustomerHistory) {
              callProvider.loadCustomerCallHistory(
                customerId: customer.id,
                phoneNumber: customer.phoneNumber,
              );
            }
          });

          return RefreshIndicator(
            onRefresh: () async {
              await Future.wait([
                customerProvider.selectCustomer(widget.customerId),
                callProvider.loadCustomerCallHistory(
                  customerId: customer.id,
                  phoneNumber: customer.phoneNumber,
                ),
              ]);
            },
            color: const Color(0xFF4ADE80),
            backgroundColor: const Color(0xFF0F1015),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(customer),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Contact Information'),
                  const SizedBox(height: 12),
                  _buildInfoRow(Icons.phone_rounded, 'Phone', customer.phoneNumber, Colors.white),
                  if (customer.email != null && customer.email!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _buildInfoRow(Icons.email_rounded, 'Email', customer.email!, Colors.white),
                  ],
                  if (customer.company != null && customer.company!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _buildInfoRow(Icons.business_rounded, 'Company', customer.company!, Colors.white),
                  ],
                  const SizedBox(height: 24),
                  _buildSectionTitle('Call Activity'),
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    Icons.call_rounded,
                    'Total Calls',
                    '${customer.totalCalls}',
                    Colors.white,
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    Icons.access_time_rounded,
                    'Last Call',
                    customer.formattedLastCallDate,
                    customer.lastCallAt != null ? Colors.white : Colors.white.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 24),
                  _buildCallHistorySection(callProvider),
                  if (customer.notes != null && customer.notes!.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    _buildSectionTitle('Notes'),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF15171F),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
                      ),
                      child: Text(
                        customer.notes!,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  _buildSectionTitle('Metadata'),
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    Icons.calendar_today_rounded,
                    'Created',
                    '${customer.createdAt.day}/${customer.createdAt.month}/${customer.createdAt.year}',
                    Colors.white.withValues(alpha: 0.7),
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    Icons.update_rounded,
                    'Updated',
                    '${customer.updatedAt.day}/${customer.updatedAt.month}/${customer.updatedAt.year}',
                    Colors.white.withValues(alpha: 0.7),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(CustomerModel customer) {
    return Row(
      children: [
        Container(
          height: 64,
          width: 64,
          decoration: BoxDecoration(
            color: const Color(0xFF4ADE80).withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.person_rounded, color: Color(0xFF4ADE80), size: 28),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                customer.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                customer.phoneNumber,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, Color valueColor) {
    return Row(
      children: [
        Container(
          height: 40,
          width: 40,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.white.withValues(alpha: 0.6), size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 12.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  color: valueColor,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCallHistorySection(CallProvider callProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSectionTitle('Call History'),
            if (callProvider.customerCallHistory.isNotEmpty)
              TextButton.icon(
                onPressed: () => _refreshCallHistory(callProvider),
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: const Text('Refresh'),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF4ADE80),
                  padding: EdgeInsets.zero,
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (callProvider.isLoadingCustomerHistory)
          _buildCallHistoryLoading()
        else if (callProvider.customerHistoryError != null)
          _buildCallHistoryError(callProvider)
        else if (callProvider.customerCallHistory.isEmpty)
          _buildCallHistoryEmpty()
        else
          _buildCallHistoryList(callProvider),
      ],
    );
  }

  Widget _buildCallHistoryLoading() {
    return Column(
      children: List.generate(3, (index) => _buildCallHistorySkeleton()),
    );
  }

  Widget _buildCallHistorySkeleton() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: const Color(0xFF15171F),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
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
              Container(
                height: 13,
                width: 80,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCallHistoryError(CallProvider callProvider) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF87171).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF87171).withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.error_outline_rounded, color: Color(0xFFF87171), size: 20),
              const SizedBox(width: 12),
              const Text(
                'Failed to load call history',
                style: TextStyle(color: Color(0xFFF87171), fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            callProvider.customerHistoryError!,
            style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 13),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () => _refreshCallHistory(callProvider),
            icon: const Icon(Icons.refresh_rounded, size: 16),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4ADE80),
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCallHistoryEmpty() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF15171F),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.call_outlined,
            size: 48,
            color: Colors.white.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 12),
          Text(
            'No call history',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Calls will appear here when they are linked to this customer',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.4),
              fontSize: 13,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCallHistoryList(CallProvider callProvider) {
    final groupedCalls = _groupCallsByDate(callProvider.customerCallHistory);
    final dateGroups = groupedCalls.entries.toList()
      ..sort((a, b) => b.key.compareTo(a.key));

    final children = <Widget>[];
    for (final entry in dateGroups) {
      final date = entry.key;
      final calls = entry.value;
      final label = _getDateGroupLabel(date);
      children.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),
      );
      children.addAll(calls.map((call) => _buildCallHistoryItem(call)));
      children.add(const SizedBox(height: 8));
    }

    return Column(children: children);
  }

  Map<DateTime, List<CallModel>> _groupCallsByDate(List<CallModel> calls) {
    final groups = <DateTime, List<CallModel>>{};
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    for (final call in calls) {
      final callDate = DateTime(call.startedAt.year, call.startedAt.month, call.startedAt.day);
      DateTime groupKey;
      if (callDate == today) {
        groupKey = today;
      } else if (callDate == yesterday) {
        groupKey = yesterday;
      } else {
        // Group older calls by week start (Monday)
        final weekStart = callDate.subtract(Duration(days: callDate.weekday - 1));
        groupKey = weekStart;
      }
      groups.putIfAbsent(groupKey, () => []).add(call);
    }
    return groups;
  }

  String _getDateGroupLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    if (date == today) return 'Today';
    if (date == yesterday) return 'Yesterday';

    // For older dates, show the week range
    final weekEnd = date.add(const Duration(days: 6));
    return '${date.day}/${date.month} - ${weekEnd.day}/${weekEnd.month}';
  }

  Widget _buildCallHistoryItem(CallModel call) {
    final statusColor = _getStatusColor(call.status);
    final hasTranscript = call.transcript != null && call.transcript!.isNotEmpty;

    return Material(
      color: const Color(0xFF15171F),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () => _navigateToCallDetail(call),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Status indicator
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: statusColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Caller name and time
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          call.callerName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          call.formattedDateTime,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.5),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Duration and AI badge
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        call.formattedDuration,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (call.aiHandled) ...[
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF8B5CF6).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'AI',
                            style: TextStyle(
                              color: Color(0xFF8B5CF6),
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Purpose and outcome row
              if (call.purpose != null || call.outcome != null) ...[
                Row(
                  children: [
                    if (call.purpose != null) ...[
                      Expanded(
                        child: _buildCallDetailChip(
                          Icons.flag_rounded,
                          call.purpose!,
                          Colors.white.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                    if (call.purpose != null && call.outcome != null) const SizedBox(width: 8),
                    if (call.outcome != null) ...[
                      Expanded(
                        child: _buildCallDetailChip(
                          Icons.check_circle_outline_rounded,
                          _formatOutcome(call.outcome!),
                          const Color(0xFF4ADE80).withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 12),
              ],
              // Transcript indicator
              if (hasTranscript)
                Row(
                  children: [
                    Icon(
                      Icons.description_rounded,
                      size: 16,
                      color: Colors.white.withValues(alpha: 0.4),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Transcript available',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 18,
                      color: Colors.white.withValues(alpha: 0.3),
                    ),
                  ],
                )
              else
                Row(
                  children: [
                    Icon(
                      Icons.description_outlined,
                      size: 16,
                      color: Colors.white.withValues(alpha: 0.2),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'No transcript',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.3),
                        fontSize: 12,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 18,
                      color: Colors.white.withValues(alpha: 0.2),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCallDetailChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(CallStatus status) {
    switch (status) {
      case CallStatus.answered:
        return const Color(0xFF4ADE80);
      case CallStatus.missed:
        return const Color(0xFFF87171);
      case CallStatus.declined:
        return const Color(0xFFFBBF24);
      case CallStatus.voicemail:
        return const Color(0xFF8B5CF6);
      case CallStatus.inProgress:
        return const Color(0xFF3B82F6);
    }
  }

  String _formatOutcome(CallOutcome outcome) {
    switch (outcome) {
      case CallOutcome.booking:
        return 'Booking';
      case CallOutcome.inquiry:
        return 'Inquiry';
      case CallOutcome.support:
        return 'Support';
      case CallOutcome.spam:
        return 'Spam';
      case CallOutcome.callback:
        return 'Callback';
      case CallOutcome.transferred:
        return 'Transferred';
      case CallOutcome.noOutcome:
        return 'No Outcome';
    }
  }

  Future<void> _refreshCallHistory(CallProvider callProvider) async {
    final customer = context.read<CustomerProvider>().selectedCustomer;
    if (customer != null) {
      await callProvider.loadCustomerCallHistory(
        customerId: customer.id,
        phoneNumber: customer.phoneNumber,
      );
    }
  }

  void _navigateToCallDetail(CallModel call) {
    context.push('/calls/${call.id}');
  }

  void _showEditDialog(BuildContext context) {
    final customer = context.read<CustomerProvider>().selectedCustomer;
    if (customer == null) return;

    final nameController = TextEditingController(text: customer.name);
    final phoneController = TextEditingController(text: customer.phoneNumber);
    final emailController = TextEditingController(text: customer.email ?? '');
    final companyController = TextEditingController(text: customer.company ?? '');
    final notesController = TextEditingController(text: customer.notes ?? '');

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF0F1015),
        title: const Text('Edit Customer', style: TextStyle(color: Colors.white)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDialogField(nameController, 'Name', Icons.person_rounded, isRequired: true),
              const SizedBox(height: 12),
              _buildDialogField(phoneController, 'Phone', Icons.phone_rounded, isRequired: true),
              const SizedBox(height: 12),
              _buildDialogField(emailController, 'Email (optional)', Icons.email_rounded),
              const SizedBox(height: 12),
              _buildDialogField(companyController, 'Company (optional)', Icons.business_rounded),
              const SizedBox(height: 12),
              _buildDialogField(notesController, 'Notes (optional)', Icons.note_rounded, maxLines: 3),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.trim().isEmpty) return;
              if (phoneController.text.trim().isEmpty) return;

              Navigator.pop(dialogContext);

              final updated = customer.copyWith(
                name: nameController.text.trim(),
                phoneNumber: phoneController.text.trim(),
                email: emailController.text.trim().isEmpty ? null : emailController.text.trim(),
                company: companyController.text.trim().isEmpty ? null : companyController.text.trim(),
                notes: notesController.text.trim().isEmpty ? null : notesController.text.trim(),
              );

              final success = await context.read<CustomerProvider>().updateCustomer(updated);
              if (success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Customer updated')),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4ADE80)),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _buildDialogField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool isRequired = false,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
        prefixIcon: Icon(icon, color: Colors.white.withValues(alpha: 0.6)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF4ADE80)),
        ),
        filled: true,
        fillColor: const Color(0xFF15171F),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF0F1015),
        title: const Text('Delete Customer', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Are you sure you want to delete this customer? This action cannot be undone.',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              final provider = context.read<CustomerProvider>();
              final success = await provider.deleteCustomer(widget.customerId);
              if (success && context.mounted) {
                context.go(RouteNames.customers);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Customer deleted')),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF87171)),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      children: List.generate(5, (_) => const _DetailSkeleton()),
    );
  }
}

class _DetailSkeleton extends StatelessWidget {
  const _DetailSkeleton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 12,
                  width: 80,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  height: 14,
                  width: 120,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded, size: 64, color: Color(0xFFF87171)),
            const SizedBox(height: 16),
            const Text(
              'Failed to load customer',
              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4ADE80),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}