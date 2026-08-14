import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:audio_session/audio_session.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';

import 'language_selection_screen.dart';
import 'greeting_template_screen.dart';
import '../user/providers/user_provider.dart';
import '../../../../services/voice/voice_service.dart';

class VoiceSelectionScreen extends StatefulWidget {
  const VoiceSelectionScreen({super.key});

  @override
  State<VoiceSelectionScreen> createState() => _VoiceSelectionScreenState();
}

class _VoiceSelectionScreenState extends State<VoiceSelectionScreen> {
  String? _selectedVoice = 'male';
  bool _isLoading = false;
  bool _isPlayingPreview = false;
  String? _playingVoice; // 'male' or 'female'

  static const Color background = Color(0xFF09090B);
  static const Color card = Color(0xFF151518);
  static const Color cardSelected = Color(0xFF19172A);
  static const Color primary = Color(0xFF7C5CFF);
  static const Color primarySoft = Color(0xFFB3A1FF);
  static const Color textPrimary = Color(0xFFF5F5F7);
  static const Color textSecondary = Color(0xFF96969F);

  static const List<_VoiceOption> _voices = [
    _VoiceOption(
      code: 'male',
      label: 'Male',
      subtitle: 'Clear and confident',
      icon: Icons.male_rounded,
    ),
    _VoiceOption(
      code: 'female',
      label: 'Female',
      subtitle: 'Clear and natural',
      icon: Icons.female_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTitle(),
                    const SizedBox(height: 28),
                    ..._voices.map(
                      (voice) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildVoiceCard(voice),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            _buildBottomButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      child: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (_) => const LanguageSelectionScreen(),
                    ),
                  );
                },
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: card,
                    borderRadius: BorderRadius.circular(13),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.06),
                    ),
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: textPrimary,
                    size: 17,
                  ),
                ),
              ),
              const Spacer(),
              const Text(
                '5 of 8',
                style: TextStyle(
                  color: textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Stack(
              children: [
                Container(
                  height: 4,
                  width: double.infinity,
                  color: card,
                ),
                FractionallySizedBox(
                  widthFactor: 0.625,
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          'Choose your voice',
          style: TextStyle(
            color: textPrimary,
            fontSize: 28,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.7,
            height: 1.15,
          ),
        ),
        SizedBox(height: 10),
        Text(
          'Choose how Vexa should sound when speaking to you.',
          style: TextStyle(
            color: textSecondary,
            fontSize: 15,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildVoiceCard(_VoiceOption voice) {
    final selected = _selectedVoice == voice.code;
    final isPlaying = _isPlayingPreview && _playingVoice == voice.code;

    return GestureDetector(
      onTap: () => setState(() => _selectedVoice = voice.code),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? cardSelected : card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected
                ? primary.withOpacity(0.75)
                : Colors.white.withOpacity(0.055),
            width: selected ? 1.4 : 1,
          ),
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: selected
                    ? primary.withOpacity(0.18)
                    : background,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                voice.icon,
                color: selected ? primarySoft : textSecondary,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    voice.label,
                    style: const TextStyle(
                      color: textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    voice.subtitle,
                    style: const TextStyle(
                      color: textSecondary,
                      fontSize: 13.5,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            // Preview button
            GestureDetector(
              onTap: _isPlayingPreview
                  ? null
                  : () => _playPreview(voice.code),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isPlaying
                      ? primary.withOpacity(0.2)
                      : selected
                          ? primary.withOpacity(0.18)
                          : background,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isPlaying
                        ? primary
                        : selected
                            ? primary.withOpacity(0.75)
                            : Colors.white.withOpacity(0.055),
                    width: isPlaying ? 1.5 : 1,
                  ),
                ),
                child: Center(
                  child: isPlaying
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: primary,
                          ),
                        )
                      : Icon(
                          Icons.play_arrow_rounded,
                          color: selected ? primarySoft : textSecondary,
                          size: 22,
                        ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? primary : Colors.transparent,
                border: Border.all(
                  color: selected
                      ? primary
                      : Colors.white.withOpacity(0.2),
                  width: 1.5,
                ),
              ),
              child: selected
                  ? const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 14,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _playPreview(String voiceCode) async {
    if (_isPlayingPreview) return;

    final userProvider = context.read<UserProvider>();
    final languagePreference = userProvider.currentUser?.languagePreference ?? 'en';
    final languageCode = languagePreference == 'auto' ? 'en' : languagePreference;

    setState(() {
      _isPlayingPreview = true;
      _playingVoice = voiceCode;
    });

    try {
      final voiceService = VoiceService();
      final audioBase64 = await voiceService.generatePreview(
        language: languageCode,
        voiceGender: voiceCode,
      );

      if (!mounted) return;

      // Play audio from base64
      await _playAudioFromBase64(audioBase64);
    } catch (e, stackTrace) {
      developer.log(
        'Error playing preview',
        error: e,
        stackTrace: stackTrace,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to play preview: ${e.toString()}'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isPlayingPreview = false;
          _playingVoice = null;
        });
      }
    }
  }

  Future<void> _playAudioFromBase64(String base64String) async {
  final player = AudioPlayer();
  File? file;

  try {
    final session = await AudioSession.instance;

    await session.configure(
      const AudioSessionConfiguration.music(),
    );

    await session.setActive(true);

    final bytes = base64Decode(base64String);

    developer.log(
      'Decoded preview audio: ${bytes.length} bytes',
    );

    if (bytes.isEmpty) {
      throw Exception('Decoded audio is empty.');
    }

    final tempDir = await getTemporaryDirectory();

    file = File(
      '${tempDir.path}/vexa_preview_${DateTime.now().millisecondsSinceEpoch}.mp3',
    );

    await file.writeAsBytes(bytes, flush: true);

    developer.log(
      'Preview file created: ${file.path}, size: ${await file.length()} bytes',
    );

    final duration = await player.setFilePath(file.path);

    developer.log(
      'Audio loaded successfully. Duration: $duration',
    );

    await player.setVolume(1.0);

    await player.play();

    developer.log('Preview playback started.');

    await player.playerStateStream.firstWhere(
      (state) => state.processingState == ProcessingState.completed,
    );

    developer.log('Preview playback completed.');
  } catch (e, stackTrace) {
    developer.log(
      'ERROR playing preview audio',
      error: e,
      stackTrace: stackTrace,
    );
  } finally {
    await player.dispose();
  }
}

  Widget _buildBottomButton() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
      decoration: BoxDecoration(
        color: background,
        border: Border(
          top: BorderSide(
            color: Colors.white.withOpacity(0.045),
          ),
        ),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 54,
        child: ElevatedButton(
          onPressed: _selectedVoice != null && !_isLoading ? _continue : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: primary,
            disabledBackgroundColor: card,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.2,
                    color: Colors.white,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Continue',
                      style: TextStyle(
                        color: _selectedVoice != null ? Colors.white : textSecondary,
                        fontSize: 15.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.arrow_forward_rounded,
                      color: _selectedVoice != null ? Colors.white : textSecondary,
                      size: 19,
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Future<void> _continue() async {
    if (_selectedVoice == null) return;

    setState(() => _isLoading = true);

    final userProvider = context.read<UserProvider>();

    final success = await userProvider.saveVoicePreference(
      voicePreference: _selectedVoice!,
    );

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            userProvider.error ?? 'Failed to save voice preference.',
          ),
        ),
      );
      return;
    }

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const GreetingTemplateScreen()),
    );
  }
}

class _VoiceOption {
  final String code;
  final String label;
  final String subtitle;
  final IconData icon;

  const _VoiceOption({
    required this.code,
    required this.label,
    required this.subtitle,
    required this.icon,
  });
}