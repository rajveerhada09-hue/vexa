import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../calls/providers/call_provider.dart';
import '../../../calls/model/call_model.dart';
import '../../../../routes/route_names.dart';

class CallDetailScreen extends StatefulWidget {
  final String callId;

  const CallDetailScreen({super.key, required this.callId});

  @override
  State<CallDetailScreen> createState() => _CallDetailScreenState();
}

class _CallDetailScreenState extends State<CallDetailScreen> {
  CallModel? _call;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCall();
  }

  Future<void> _loadCall() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final callProvider = context.read<CallProvider>();

      // First check if call is in recent calls
      _call = callProvider.recentCalls.firstWhere(
        (c) => c.id == widget.callId,
        orElse: () => _call!,
      );

      // If not found, fetch from repository
      if (_call == null) {
        // We need to fetch all recent calls and find it, or fetch by ID
        // For now, we'll load recent calls with a larger limit
        await callProvider.loadRecentCalls(limit: 100);
        if (mounted) {
          _call = callProvider.recentCalls.firstWhere(
            (c) => c.id == widget.callId,
            orElse: () => throw Exception('Call not found'),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load call details: ${e.toString().replaceFirst('Exception: ', '')}';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0C10),
      appBar: AppBar(
        title: const Text('Call Details'),
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
              context.go(RouteNames.calls);
            }
          },
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const _LoadingState();
    }

    if (_error != null) {
      return _ErrorState(
        message: _error!,
        onRetry: _loadCall,
      );
    }

    if (_call == null) {
      return _ErrorState(
        message: 'Call not found',
        onRetry: _loadCall,
      );
    }

    return RefreshIndicator(
      onRefresh: _loadCall,
      color: const Color(0xFF4ADE80),
      backgroundColor: const Color(0xFF0F1015),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(_call!),
            const SizedBox(height: 24),
            _buildSectionTitle('Call Information'),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.access_time_rounded, 'Date & Time', _call!.formattedDateTime, Colors.white),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.timer_rounded, 'Duration', _call!.formattedDuration, Colors.white),
            const SizedBox(height: 12),
            _buildInfoRow(
              Icons.call_rounded,
              'Status',
              _formatStatus(_call!.status),
              _getStatusColor(_call!.status),
            ),
            if (_call!.purpose != null) ...[
              const SizedBox(height: 12),
              _buildInfoRow(Icons.flag_rounded, 'Purpose', _call!.purpose!, Colors.white),
            ],
            if (_call!.outcome != null) ...[
              const SizedBox(height: 12),
              _buildInfoRow(Icons.check_circle_outline_rounded, 'Outcome', _formatOutcome(_call!.outcome!), const Color(0xFF4ADE80)),
            ],
            const SizedBox(height: 12),
            _buildInfoRow(
              _call!.aiHandled ? Icons.smart_toy_rounded : Icons.person_rounded,
              'Handled By',
              _call!.aiHandled ? 'AI Assistant' : 'Human',
              _call!.aiHandled ? const Color(0xFF8B5CF6) : Colors.white,
            ),
            if (_call!.phoneNumber.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildInfoRow(Icons.phone_rounded, 'Phone Number', _call!.phoneNumber, Colors.white.withValues(alpha: 0.8)),
            ],
            const SizedBox(height: 24),
            if (_call!.transcript != null && _call!.transcript!.isNotEmpty) ...[
              _buildSectionTitle('Transcript'),
              const SizedBox(height: 12),
              _buildTranscript(_call!.transcript!),
            ] else ...[
              _buildSectionTitle('Transcript'),
              const SizedBox(height: 12),
              _buildTranscriptUnavailable(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(CallModel call) {
    final statusColor = _getStatusColor(call.status);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF15171F),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 56,
                width: 56,
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  _getStatusIcon(call.status),
                  color: statusColor,
                  size: 26,
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
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _formatStatus(call.status),
                            style: TextStyle(
                              color: statusColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (call.aiHandled) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF8B5CF6).withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'AI Handled',
                              style: TextStyle(
                                color: Color(0xFF8B5CF6),
                                fontSize: 12,
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
            ],
          ),
        ],
      ),
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

  Widget _buildTranscript(String transcript) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF15171F),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Transcript content with speaker detection
          ..._parseTranscript(transcript).map((segment) => _buildTranscriptSegment(segment)),
        ],
      ),
    );
  }

  List<_TranscriptSegment> _parseTranscript(String transcript) {
    // Simple speaker detection: looks for patterns like "Speaker 1:", "User:", "AI:", "Agent:", etc.
    final segments = <_TranscriptSegment>[];
    final lines = transcript.split('\n');

    String currentSpeaker = '';
    String currentText = '';

    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;

      // Check for speaker labels
      final speakerMatch = RegExp(r'^(Speaker\s*\d+|User|AI|Agent|Customer|Caller|System)\s*:\s*(.*)$', caseSensitive: false).firstMatch(trimmed);
      if (speakerMatch != null) {
        // Save previous segment
        if (currentSpeaker.isNotEmpty || currentText.isNotEmpty) {
          segments.add(_TranscriptSegment(
            speaker: currentSpeaker,
            text: currentText.trim(),
          ));
        }
        currentSpeaker = speakerMatch.group(1)!;
        currentText = speakerMatch.group(2)!;
      } else {
        // Continuation of current speaker's text
        if (currentText.isNotEmpty) {
          currentText += '\n';
        }
        currentText += trimmed;
      }
    }

    // Add last segment
    if (currentSpeaker.isNotEmpty || currentText.isNotEmpty) {
      segments.add(_TranscriptSegment(
        speaker: currentSpeaker,
        text: currentText.trim(),
      ));
    }

    // If no speakers detected, treat as single segment
    if (segments.isEmpty) {
      segments.add(_TranscriptSegment(
        speaker: '',
        text: transcript.trim(),
      ));
    }

    return segments;
  }

  Widget _buildTranscriptSegment(_TranscriptSegment segment) {
    final isAI = segment.speaker.toLowerCase().contains('ai') ||
        segment.speaker.toLowerCase().contains('agent') ||
        segment.speaker.toLowerCase().contains('system');
    final isCustomer = segment.speaker.toLowerCase().contains('customer') ||
        segment.speaker.toLowerCase().contains('caller') ||
        segment.speaker.toLowerCase().contains('user');

    final speakerColor = isAI
        ? const Color(0xFF8B5CF6)
        : isCustomer
            ? const Color(0xFF4ADE80)
            : Colors.white.withValues(alpha: 0.7);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (segment.speaker.isNotEmpty) ...[
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: speakerColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  segment.speaker,
                  style: TextStyle(
                    color: speakerColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
          ],
          SelectableText(
            segment.text,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 14.5,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTranscriptUnavailable() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: const Color(0xFF15171F),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.description_outlined,
            size: 48,
            color: Colors.white.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'Transcript unavailable',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'No transcript was recorded for this call',
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

  IconData _getStatusIcon(CallStatus status) {
    switch (status) {
      case CallStatus.answered:
        return Icons.call_rounded;
      case CallStatus.missed:
        return Icons.call_missed_rounded;
      case CallStatus.declined:
        return Icons.call_end_rounded;
      case CallStatus.voicemail:
        return Icons.voicemail_rounded;
      case CallStatus.inProgress:
        return Icons.call_rounded;
    }
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

  String _formatStatus(CallStatus status) {
    switch (status) {
      case CallStatus.answered:
        return 'Answered';
      case CallStatus.missed:
        return 'Missed';
      case CallStatus.declined:
        return 'Declined';
      case CallStatus.voicemail:
        return 'Voicemail';
      case CallStatus.inProgress:
        return 'In Progress';
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
}

class _TranscriptSegment {
  final String speaker;
  final String text;

  const _TranscriptSegment({required this.speaker, required this.text});
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
              'Failed to load call details',
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
                foregroundColor: Colors.black,
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