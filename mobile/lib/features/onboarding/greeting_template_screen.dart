import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:audio_session/audio_session.dart';
import 'package:flutter/material.dart'
    hide Card;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:just_audio/just_audio.dart';

import '../user/providers/user_provider.dart';
import 'voice_selection_screen.dart';
import 'knowledge_base_screen.dart';
import '../../../../services/voice/voice_service.dart';

class GreetingTemplateScreen extends StatefulWidget {
  const GreetingTemplateScreen({super.key});

  @override
  State<GreetingTemplateScreen> createState() => _GreetingTemplateScreenState();
}

class _GreetingTemplateScreenState extends State<GreetingTemplateScreen> {
  String? _selectedTemplate;
  final TextEditingController _customController = TextEditingController();
  bool _isLoading = false;
  bool _isPlayingPreview = false;

  static const Color background = Color(0xFF09090B);
  static const Color card = Color(0xFF151518);
  static const Color cardSelected = Color(0xFF19172A);
  static const Color primary = Color(0xFF7C5CFF);
  static const Color primarySoft = Color(0xFFB3A1FF);
  static const Color textPrimary = Color(0xFFF5F5F7);
  static const Color textSecondary = Color(0xFF96969F);

  final List<_GreetingTemplate> _templates = const [
    _GreetingTemplate(
      id: 'professional',
      title: 'Professional',
      subtitle: 'Polished and business-appropriate',
      icon: Icons.business_center_outlined,
      text:
          'Thank you for calling. How may I assist you today?',
    ),
    _GreetingTemplate(
      id: 'friendly',
      title: 'Friendly',
      subtitle: 'Warm and welcoming',
      icon: Icons.waving_hand_outlined,
      text:
          "Hi there! Thanks for calling. How can I help you today?",
    ),
    _GreetingTemplate(
      id: 'brief',
      title: 'Brief',
      subtitle: 'Short and direct',
      icon: Icons.speed_outlined,
      text:
          'Hello. How can I help?',
    ),
    _GreetingTemplate(
      id: 'custom',
      title: 'Custom',
      subtitle: 'Write your own greeting',
      icon: Icons.edit_outlined,
      text: '',
    ),
  ];

  @override
  void dispose() {
    _customController.dispose();
    super.dispose();
  }

  bool get _canContinue {
    if (_selectedTemplate == null) {
      return false;
    }

    if (_selectedTemplate == 'custom') {
      return _customController.text.trim().isNotEmpty;
    }

    return true;
  }

  _GreetingTemplate? get _selectedOption {
    if (_selectedTemplate == null) {
      return null;
    }

    for (final template in _templates) {
      if (template.id == _selectedTemplate) {
        return template;
      }
    }

    return null;
  }

  String get _previewText {
    final option = _selectedOption;
    if (option == null) return '';

    if (option.id == 'custom') {
      return _customController.text.trim();
    }

    return option.text;
  }

  void _selectTemplate(String id) {
    setState(() {
      _selectedTemplate = id;
    });
  }

  Future<void> _playPreview() async {
    if (_isPlayingPreview || _previewText.isEmpty) return;

    final userProvider = context.read<UserProvider>();
    final languagePreference = userProvider.currentUser?.languagePreference ?? 'en';
    final languageCode = languagePreference == 'auto' ? 'en' : languagePreference;
    final voiceGender = userProvider.currentUser?.voicePreference ?? 'male';

    setState(() {
      _isPlayingPreview = true;
    });

    try {
      final voiceService = VoiceService();
      final audioBase64 = await voiceService.synthesize(
        text: _previewText,
        language: languageCode,
        voiceGender: voiceGender,
      );

      if (!mounted) return;

      await _playAudioFromBase64(audioBase64);
    } catch (e, stackTrace) {
      developer.log(
        'Error playing greeting preview',
        error: e,
        stackTrace: stackTrace,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Preview unavailable: ${e.toString()}'),
          backgroundColor: Colors.orangeAccent,
          duration: const Duration(seconds: 3),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isPlayingPreview = false;
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
        'Decoded greeting preview audio: ${bytes.length} bytes',
      );

      if (bytes.isEmpty) {
        throw Exception('Decoded audio is empty.');
      }

      final tempDir = await getTemporaryDirectory();

      file = File(
        '${tempDir.path}/vexa_greeting_preview_${DateTime.now().millisecondsSinceEpoch}.mp3',
      );

      await file.writeAsBytes(bytes, flush: true);

      developer.log(
        'Greeting preview file created: ${file.path}, size: ${await file.length()} bytes',
      );

      final duration = await player.setFilePath(file.path);

      developer.log(
        'Audio loaded successfully. Duration: $duration',
      );

      await player.setVolume(1.0);

      await player.play();

      developer.log('Greeting preview playback started.');

      await player.playerStateStream.firstWhere(
        (state) => state.processingState == ProcessingState.completed,
      );

      developer.log('Greeting preview playback completed.');
    } catch (e, stackTrace) {
      developer.log(
        'ERROR playing greeting preview audio',
        error: e,
        stackTrace: stackTrace,
      );
    } finally {
      await player.dispose();
    }
  }

  Future<void> _continue() async {
    if (!_canContinue) return;

    setState(() => _isLoading = true);

    final userProvider = context.read<UserProvider>();

    final success = await userProvider.saveGreetingTemplate(
      greetingTemplate: _selectedTemplate!,
      customGreeting: _selectedTemplate == 'custom'
          ? _customController.text.trim()
          : null,
    );

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            userProvider.error ?? 'Failed to save greeting template.',
          ),
        ),
      );
      return;
    }

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const KnowledgeBaseScreen()),
    );
  }

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
                    ..._templates.map(
                      (template) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildTemplateCard(template),
                      ),
                    ),
                    if (_selectedTemplate != null) ...[
                      const SizedBox(height: 12),
                      _buildPreviewSection(),
                    ],
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
                      builder: (_) => const VoiceSelectionScreen(),
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
                '7 of 8',
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
                  widthFactor: 0.875,
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
          'Choose a greeting',
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
          'This is what callers will hear when Vexa answers.',
          style: TextStyle(
            color: textSecondary,
            fontSize: 15,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildTemplateCard(_GreetingTemplate template) {
    final selected = _selectedTemplate == template.id;

    return GestureDetector(
      onTap: () => _selectTemplate(template.id),
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
                template.icon,
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
                    template.title,
                    style: const TextStyle(
                      color: textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    template.subtitle,
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

  Widget _buildPreviewSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Preview',
          style: TextStyle(
            color: textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: card,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: Colors.white.withOpacity(0.055),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.format_quote_rounded,
                    color: primary,
                    size: 22,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _previewText.isEmpty
                          ? 'Select a template or enter custom text'
                          : '"$_previewText"',
                      style: TextStyle(
                        color: _previewText.isEmpty ? textSecondary : textPrimary,
                        fontSize: 14.5,
                        height: 1.55,
                        fontStyle: _previewText.isEmpty ? FontStyle.italic : FontStyle.normal,
                      ),
                    ),
                  ),
                ],
              ),
              if (_previewText.isNotEmpty) ...[
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: _isPlayingPreview ? null : _playPreview,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: _isPlayingPreview
                          ? primary.withOpacity(0.2)
                          : primary.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _isPlayingPreview
                            ? primary
                            : primary.withOpacity(0.75),
                        width: _isPlayingPreview ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _isPlayingPreview
                            ? SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: primary,
                                ),
                              )
                            : Icon(
                                Icons.play_arrow_rounded,
                                color: primarySoft,
                                size: 20,
                              ),
                        const SizedBox(width: 8),
                        Text(
                          _isPlayingPreview ? 'Playing...' : 'Play preview',
                          style: TextStyle(
                            color: _isPlayingPreview ? primary : primarySoft,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        if (_selectedTemplate == 'custom') ...[
          const SizedBox(height: 16),
          _buildCustomInput(),
        ],
      ],
    );
  }

  Widget _buildCustomInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Custom greeting',
          style: TextStyle(
            color: textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _customController,
          onChanged: (_) => setState(() {}),
          maxLines: 4,
          minLines: 3,
          maxLength: 300,
          style: const TextStyle(
            color: textPrimary,
            fontSize: 14,
            height: 1.45,
          ),
          cursorColor: primary,
          decoration: InputDecoration(
            hintText:
                'Enter the greeting callers will hear...',
            hintStyle: TextStyle(
              color: textSecondary.withOpacity(0.55),
              fontSize: 13.5,
              height: 1.4,
            ),
            filled: true,
            fillColor: card,
            contentPadding: const EdgeInsets.all(16),
            counterStyle: TextStyle(
              color: textSecondary.withOpacity(0.55),
              fontSize: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: Colors.white.withOpacity(0.055),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: Colors.white.withOpacity(0.055),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: primary,
                width: 1.2,
              ),
            ),
          ),
        ),
      ],
    );
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
          onPressed: _canContinue && !_isLoading ? _continue : null,
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
                        color: _canContinue ? Colors.white : textSecondary,
                        fontSize: 15.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.arrow_forward_rounded,
                      color: _canContinue ? Colors.white : textSecondary,
                      size: 19,
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _GreetingTemplate {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final String text;

  const _GreetingTemplate({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.text,
  });
}