import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_timezone/flutter_timezone.dart';

import 'ai_personality_screen.dart';
import 'language_selection_screen.dart';
import '../user/providers/user_provider.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/data/time_zones.dart';

class BusinessInfoScreen extends StatefulWidget {
  const BusinessInfoScreen({super.key});

  @override
  State<BusinessInfoScreen> createState() => _BusinessInfoScreenState();
}

class _BusinessInfoScreenState extends State<BusinessInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _businessNameController = TextEditingController();
  String? _selectedBusinessType;
  TimeOfDay? _openingTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay? _closingTime = const TimeOfDay(hour: 18, minute: 0);
  String? _selectedTimeZone;
  bool _isLoading = false;
  bool _loadingTimeZones = true;
  List<TimeZoneOption> _availableTimeZones = [];

  static const Color background = Color(0xFF09090B);
  static const Color card = Color(0xFF151518);
  static const Color primary = Color(0xFF7C5CFF);
  static const Color textPrimary = Color(0xFFF5F5F7);
  static const Color textSecondary = Color(0xFF96969F);

  static const List<String> _businessTypes = [
    'Restaurant / Cafe',
    'Salon / Spa',
    'Clinic / Healthcare',
    'Retail Store',
    'Real Estate',
    'Professional Services',
    'Agency / Consulting',
    'E-commerce',
    'Education / Training',
    'Fitness / Gym',
    'Entertainment / Events',
    'Hospitality / Travel',
    'Interior Design / Architecture',
    'Automotive / Car Dealership',
    'Coaching / Personal Development',
    'Non-profit / Charity',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _businessNameController.addListener(() => setState(() {}));
    _loadTimeZones();
  }

  Future<void> _loadTimeZones() async {
  _availableTimeZones = timeZoneOptions;

  String? detectedZone;

  try {
    final timezoneInfo = await FlutterTimezone.getLocalTimezone();
    detectedZone = timezoneInfo.identifier;
  } catch (_) {
    detectedZone = null;
  }

  final fallbackIndex = _availableTimeZones.indexWhere(
    (z) => z.ianaId == 'Asia/Kolkata',
  );

  final detectedIndex = detectedZone != null
      ? _availableTimeZones.indexWhere(
          (z) => z.ianaId == detectedZone,
        )
      : -1;

  if (mounted) {
    setState(() {
      _selectedTimeZone = _availableTimeZones[
      detectedIndex >= 0 ? detectedIndex : fallbackIndex
    ].ianaId;

      _loadingTimeZones = false;
    });
  }
}

  @override
  void dispose() {
    _businessNameController.dispose();
    super.dispose();
  }

  bool get _canContinue {
    return _selectedBusinessType != null &&
        _businessNameController.text.trim().isNotEmpty &&
        _openingTime != null &&
        _closingTime != null &&
        _selectedTimeZone != null &&
        _isClosingAfterOpening();
  }

  bool _isClosingAfterOpening() {
    if (_openingTime == null || _closingTime == null) return false;
    final openMin = _openingTime!.hour * 60 + _openingTime!.minute;
    final closeMin = _closingTime!.hour * 60 + _closingTime!.minute;
    return closeMin > openMin;
  }

  String _formatTimeOfDay(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  String _formatTimeForDisplay(TimeOfDay t) {
    final hour = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final minute = t.minute.toString().padLeft(2, '0');
    final period = t.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  Future<void> _pickOpeningTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _openingTime ?? const TimeOfDay(hour: 9, minute: 0),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            timePickerTheme: TimePickerThemeData(
              backgroundColor: card,
              hourMinuteTextColor: textPrimary,
              hourMinuteColor: background,
              dayPeriodTextColor: textPrimary,
              dayPeriodColor: background,
              dialHandColor: primary,
              dialBackgroundColor: background,
              entryModeIconColor: primary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && mounted) {
      setState(() => _openingTime = picked);
    }
  }

  Future<void> _pickClosingTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _closingTime ?? const TimeOfDay(hour: 18, minute: 0),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            timePickerTheme: TimePickerThemeData(
              backgroundColor: card,
              hourMinuteTextColor: textPrimary,
              hourMinuteColor: background,
              dayPeriodTextColor: textPrimary,
              dayPeriodColor: background,
              dialHandColor: primary,
              dialBackgroundColor: background,
              entryModeIconColor: primary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && mounted) {
      setState(() => _closingTime = picked);
    }
  }

  Future<void> _continue() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final userProvider = context.read<UserProvider>();

    final success = await userProvider.saveBusinessInfo(
      businessName: _businessNameController.text.trim(),
      businessType: _selectedBusinessType!,
      businessOpeningTime: _formatTimeOfDay(_openingTime!),
      businessClosingTime: _formatTimeOfDay(_closingTime!),
      businessTimeZone: _selectedTimeZone!,
    );

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            userProvider.error ?? 'Failed to save business info.',
          ),
        ),
      );
      return;
    }

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LanguageSelectionScreen()),
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
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTitle(),
                      const SizedBox(height: 28),
                      _buildBusinessNameField(),
                      const SizedBox(height: 20),
                      _buildBusinessTypeField(),
                      const SizedBox(height: 20),
                      _buildBusinessHoursField(),
                      const SizedBox(height: 20),
                      _buildTimeZoneField(),
                      const SizedBox(height: 24),
                    ],
                  ),
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
                      builder: (_) => const AiPersonalityScreen(),
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
                '3 of 8',
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
                  widthFactor: 0.375,
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
          'Tell us about your business',
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
          'This helps Vexa understand your business and personalize your AI receptionist.',
          style: TextStyle(
            color: textSecondary,
            fontSize: 15,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildBusinessNameField() {
    return AppTextField(
      controller: _businessNameController,
      label: 'Business Name',
      hint: 'Acme Inc.',
      prefixIcon: Icons.storefront_outlined,
      textInputAction: TextInputAction.next,
      validator: (v) {
        if (v == null || v.trim().isEmpty) {
          return 'Business name is required';
        }
        if (v.trim().length < 2) {
          return 'Enter a valid business name';
        }
        return null;
      },
    );
  }

  Widget _buildBusinessTypeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Business Type',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.1,
            color: textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: _selectedBusinessType,
          decoration: InputDecoration(
            hintText: 'Select business type',
            prefixIcon: const Icon(
              Icons.category_outlined,
              size: 20,
              color: textSecondary,
            ),
            filled: true,
            fillColor: card,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.055)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: primary, width: 1.2),
            ),
            hintStyle: TextStyle(
              color: textSecondary.withOpacity(0.55),
              fontSize: 15,
            ),
          ),
          dropdownColor: card,
          style: const TextStyle(
            fontSize: 15,
            color: textPrimary,
          ),
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: textSecondary,
          ),
          items: _businessTypes
              .map(
                (type) => DropdownMenuItem(
                  value: type,
                  child: Text(type),
                ),
              )
              .toList(),
          onChanged: (value) {
            setState(() => _selectedBusinessType = value);
          },
          validator: (v) {
            if (v == null || v.isEmpty) return 'Please select a business type';
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildBusinessHoursField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Business Hours',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.1,
            color: textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            // Opening Time
            Expanded(
              child: GestureDetector(
                onTap: _pickOpeningTime,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    color: card,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.055),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        size: 20,
                        color: textSecondary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Opening',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: textSecondary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _openingTime != null
                                  ? _formatTimeForDisplay(_openingTime!)
                                  : '--:--',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w400,
                                color: textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: textSecondary,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // "to" label
            Text(
              'to',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: textSecondary,
              ),
            ),
            const SizedBox(width: 12),
            // Closing Time
            Expanded(
              child: GestureDetector(
                onTap: _pickClosingTime,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    color: card,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.055),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        size: 20,
                        color: textSecondary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Closing',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: textSecondary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _closingTime != null
                                  ? _formatTimeForDisplay(_closingTime!)
                                  : '--:--',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w400,
                                color: textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: textSecondary,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        if (!_isClosingAfterOpening() && _openingTime != null && _closingTime != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Closing time must be after opening time',
              style: TextStyle(
                fontSize: 12,
                color: Colors.redAccent,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTimeZoneField() {
    if (_loadingTimeZones) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Business Time Zone',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.1,
              color: textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: card,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: Colors.white.withOpacity(0.055),
              ),
            ),
            child: Row(
              children: [
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(width: 12),
                Text(
                  'Loading time zones...',
                  style: TextStyle(
                    fontSize: 15,
                    color: textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Business Time Zone',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.1,
            color: textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: _selectedTimeZone,
          decoration: InputDecoration(
            hintText: 'Select time zone',
            prefixIcon: const Icon(
              Icons.language_outlined,
              size: 20,
              color: textSecondary,
            ),
            filled: true,
            fillColor: card,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.055)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: primary, width: 1.2),
            ),
            hintStyle: TextStyle(
              color: textSecondary.withOpacity(0.55),
              fontSize: 15,
            ),
          ),
          dropdownColor: card,
          style: const TextStyle(
            fontSize: 15,
            color: textPrimary,
          ),
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: textSecondary,
          ),
          isExpanded: true,
          items: _availableTimeZones
              .map(
                (tz) => DropdownMenuItem<String>(
                  value: tz.ianaId,
                  child: Text(tz.displayName),
                ),
              )
              .toList(),
          onChanged: (value) {
            setState(() => _selectedTimeZone = value);
          },
          validator: (v) {
            if (v == null || v.isEmpty) return 'Please select a time zone';
            return null;
          },
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