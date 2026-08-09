import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../auth/presentation/screens/login_screen.dart';
import '../user/providers/user_provider.dart';

class AiPersonalityScreen extends StatefulWidget {
  const AiPersonalityScreen({super.key});

  @override
  State<AiPersonalityScreen> createState() => _AiPersonalityScreenState();
}

class _AiPersonalityScreenState extends State<AiPersonalityScreen> {
  String? _selectedPersonality;
  final TextEditingController _customController = TextEditingController();

  static const Color background = Color(0xFF09090B);
  static const Color card = Color(0xFF151518);
  static const Color cardSelected = Color(0xFF19172A);
  static const Color primary = Color(0xFF7C5CFF);
  static const Color primarySoft = Color(0xFFB3A1FF);
  static const Color textPrimary = Color(0xFFF5F5F7);
  static const Color textSecondary = Color(0xFF96969F);

  final List<_Personality> _personalities = const [
    _Personality(
      id: 'professional',
      title: 'Professional',
      description: 'Clear, confident and business-focused.',
      icon: Icons.business_center_outlined,
      preview:
          'Hello, thank you for calling. How may I assist you today?',
    ),
    _Personality(
      id: 'friendly',
      title: 'Friendly',
      description: 'Warm, welcoming and conversational.',
      icon: Icons.waving_hand_outlined,
      preview:
          'Hi! Thanks for calling. How can I help you today?',
    ),
    _Personality(
      id: 'professional_friendly',
      title: 'Professional + Friendly',
      description: 'Polished, natural and approachable.',
      icon: Icons.auto_awesome_outlined,
      preview:
          "Hi, thanks for calling. I'd be happy to help you today. What can I do for you?",
    ),
    _Personality(
      id: 'custom',
      title: 'Custom',
      description: 'Define exactly how Vexa should behave.',
      icon: Icons.tune_outlined,
      preview: '',
    ),
  ];

  @override
  void dispose() {
    _customController.dispose();
    super.dispose();
  }

  bool get _canContinue {
    if (_selectedPersonality == null) {
      return false;
    }

    if (_selectedPersonality == 'custom') {
      return _customController.text.trim().isNotEmpty;
    }

    return true;
  }

  _Personality? get _selectedOption {
    if (_selectedPersonality == null) {
      return null;
    }

    for (final personality in _personalities) {
      if (personality.id == _selectedPersonality) {
        return personality;
      }
    }

    return null;
  }

  void _selectPersonality(String id) {
    setState(() {
      _selectedPersonality = id;
    });
  }

  Future<void> _continue() async {
  if (!_canContinue) return;

  final userProvider = context.read<UserProvider>();

  final success = await userProvider.saveAiPersonality(
    personality: _selectedPersonality!,
    customInstructions: _selectedPersonality == 'custom'
        ? _customController.text.trim()
        : null,
  );

  if (!mounted) return;

  if (!success) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          userProvider.error ?? 'Failed to save personality.',
        ),
      ),
    );
    return;
  }

  // Screen 3 abhi nahi bani hai.
  // Isliye yahin rukenge.
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

                    ..._personalities.map(
                      (personality) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildPersonalityCard(personality),
                      ),
                    ),

                    if (_selectedPersonality != null) ...[
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
                    builder: (_) => const LoginScreen(),
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
                '2 of 8',
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
                  widthFactor: 0.25,
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
          "Choose Vexa's personality",
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
          'Decide how Vexa should sound when speaking with your customers.',
          style: TextStyle(
            color: textSecondary,
            fontSize: 15,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildPersonalityCard(_Personality personality) {
    final selected = _selectedPersonality == personality.id;

    return GestureDetector(
      onTap: () => _selectPersonality(personality.id),
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
                personality.icon,
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
                    personality.title,
                    style: const TextStyle(
                    color: textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    personality.description,
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
    final option = _selectedOption;

    if (option == null) {
      return const SizedBox.shrink();
    }

    if (option.id == 'custom') {
      return _buildCustomInstructions();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Example response',
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
          child: Row(
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
                  option.preview,
                  style: const TextStyle(
                    color: textPrimary,
                    fontSize: 14.5,
                    height: 1.55,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCustomInstructions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'How should Vexa behave?',
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
          maxLines: 5,
          minLines: 4,
          style: const TextStyle(
            color: textPrimary,
            fontSize: 14,
            height: 1.45,
          ),
          cursorColor: primary,
          decoration: InputDecoration(
            hintText:
                'Example: Be polite, concise and helpful. Speak naturally and never sound robotic.',
            hintStyle: TextStyle(
              color: textSecondary.withOpacity(0.55),
              fontSize: 13.5,
              height: 1.4,
            ),
            filled: true,
            fillColor: card,
            contentPadding: const EdgeInsets.all(16),
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
          onPressed: _canContinue ? _continue : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: primary,
            disabledBackgroundColor: card,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: Row(
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

class _Personality {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final String preview;

  const _Personality({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.preview,
  });
}