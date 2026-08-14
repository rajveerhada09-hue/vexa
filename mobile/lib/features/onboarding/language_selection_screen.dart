import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'business_info_screen.dart';
import 'voice_selection_screen.dart';
import '../user/providers/user_provider.dart';

class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  State<LanguageSelectionScreen> createState() => _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  String? _selectedLanguage = 'auto';
  bool _isLoading = false;

  static const Color background = Color(0xFF09090B);
  static const Color card = Color(0xFF151518);
  static const Color cardSelected = Color(0xFF19172A);
  static const Color primary = Color(0xFF7C5CFF);
  static const Color primarySoft = Color(0xFFB3A1FF);
  static const Color textPrimary = Color(0xFFF5F5F7);
  static const Color textSecondary = Color(0xFF96969F);

  static const List<_LanguageOption> _languages = [
    _LanguageOption(
      code: 'auto',
      label: 'Auto Detect',
      nativeLabel: 'Auto Detect',
      subtitle: 'Use your device language',
      icon: Icons.language_rounded,
      isRecommended: true,
    ),
    _LanguageOption(
      code: 'hi',
      label: 'Hindi',
      nativeLabel: 'हिंदी',
      subtitle: '',
      icon: Icons.translate_rounded,
    ),
    _LanguageOption(
      code: 'en',
      label: 'English',
      nativeLabel: 'English',
      subtitle: '',
      icon: Icons.translate_rounded,
    ),
    _LanguageOption(
      code: 'fr',
      label: 'French',
      nativeLabel: 'Français',
      subtitle: '',
      icon: Icons.translate_rounded,
    ),
    _LanguageOption(
      code: 'es',
      label: 'Spanish',
      nativeLabel: 'Español',
      subtitle: '',
      icon: Icons.translate_rounded,
    ),
    _LanguageOption(
      code: 'de',
      label: 'German',
      nativeLabel: 'Deutsch',
      subtitle: '',
      icon: Icons.translate_rounded,
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
                    ..._languages.map(
                      (language) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildLanguageCard(language),
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
                      builder: (_) => const BusinessInfoScreen(),
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
                '4 of 8',
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
                  widthFactor: 0.5,
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
          'Choose your language',
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
          'Choose the language Vexa should use with you.',
          style: TextStyle(
            color: textSecondary,
            fontSize: 15,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildLanguageCard(_LanguageOption language) {
    final selected = _selectedLanguage == language.code;

    return GestureDetector(
      onTap: () => setState(() => _selectedLanguage = language.code),
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
                language.icon,
                color: selected ? primarySoft : textSecondary,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        language.label,
                        style: const TextStyle(
                          color: textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (language.nativeLabel.isNotEmpty &&
                          language.nativeLabel != language.label) ...[
                        const SizedBox(width: 8),
                        Text(
                          language.nativeLabel,
                          style: const TextStyle(
                            color: textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                      if (language.isRecommended) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: primary.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'Recommended',
                            style: TextStyle(
                              color: primary,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (language.subtitle.isNotEmpty) ...[
                    const SizedBox(height: 5),
                    Text(
                      language.subtitle,
                      style: const TextStyle(
                        color: textSecondary,
                        fontSize: 13.5,
                        height: 1.35,
                      ),
                    ),
                  ],
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
          onPressed: _selectedLanguage != null && !_isLoading ? _continue : null,
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
                        color: _selectedLanguage != null ? Colors.white : textSecondary,
                        fontSize: 15.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.arrow_forward_rounded,
                      color: _selectedLanguage != null ? Colors.white : textSecondary,
                      size: 19,
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Future<void> _continue() async {
    if (_selectedLanguage == null) return;

    setState(() => _isLoading = true);

    final userProvider = context.read<UserProvider>();

    final success = await userProvider.saveLanguagePreference(
      languagePreference: _selectedLanguage!,
    );

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            userProvider.error ?? 'Failed to save language preference.',
          ),
        ),
      );
      return;
    }

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const VoiceSelectionScreen()),
    );
  }
}

class _LanguageOption {
  final String code;
  final String label;
  final String nativeLabel;
  final String subtitle;
  final IconData icon;
  final bool isRecommended;

  const _LanguageOption({
    required this.code,
    required this.label,
    required this.nativeLabel,
    required this.subtitle,
    required this.icon,
    this.isRecommended = false,
  });
}