// lib/features/auth/register_screen.dart
import 'package:mobile/services/auth/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/widgets/phone_number_field.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_text_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthServiceImpl();
  final _fullNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _businessNameController = TextEditingController();
  final _phoneController = TextEditingController();

  String? _selectedBusinessType;
  bool _obscurePassword = true;
  bool _isLoading = false;
  


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
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: AppColors.background,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _businessNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _onCreateAccount() async {
  if (!_formKey.currentState!.validate()) return;



if (_selectedBusinessType == null) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('Please select a business type'),
    ),
  );
  return;
}

  try {
    setState(() => _isLoading = true);

    await _authService.registerWithEmail(
      name: _fullNameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );

    if (!mounted) return;

    setState(() => _isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Account Created Successfully"),
      ),
    );

    // TODO:
    // Navigator.pushReplacement(...)
  } on FirebaseAuthException catch (e) {
  if (!mounted) return;

  setState(() => _isLoading = false);

  String message;

  switch (e.code) {
    case 'email-already-in-use':
      message = 'This email is already registered.';
      break;

    case 'invalid-email':
      message = 'Please enter a valid email.';
      break;

    case 'weak-password':
      message = 'Password must be at least 6 characters.';
      break;

    case 'network-request-failed':
      message = 'No internet connection.';
      break;

    case 'too-many-requests':
      message = 'Too many attempts. Please try again later.';
      break;

    default:
      message = e.message ?? 'Account creation failed.';
  }

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message)),
  );
}
}

  Future<void> _onGoogleSignUp() async {
  try {
    setState(() => _isLoading = true);

    await _authService.signInWithGoogle();

    if (!mounted) return;

    setState(() => _isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Google Sign Up Successful"),
      ),
    );
  } on FirebaseAuthException catch (e) {
  if (!mounted) return;

  setState(() => _isLoading = false);

  final message = e.message ?? 'Google Sign-In failed.';

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message)),
  );
}
}

  void _goToLogin() {
  Navigator.pop(context);
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ─────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 20,
                      color: AppColors.iconSecondary,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
                physics: const BouncingScrollPhysics(),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      const Text(
                        'Create account',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.8,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Start answering calls with AI in minutes.',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textSecondary,
                          height: 1.4,
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Full Name
                      AppTextField(
                        controller: _fullNameController,
                        label: 'Full Name',
                        hint: 'John Doe',
                        prefixIcon: Icons.person_outline_rounded,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.name],
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Full name is required';
                          }
                          if (v.trim().length < 2) {
                            return 'Enter a valid name';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),

                      // Username
                      AppTextField(
                        controller: _usernameController,
                        label: 'Username',
                        hint: 'johndoe',
                        prefixIcon: Icons.alternate_email_rounded,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.username],
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'[a-zA-Z0-9._]'),
                          ),
                        ],
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Username is required';
                          }
                          if (v.length < 3) {
                            return 'Minimum 3 characters';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),

                      // Email
                      AppTextField(
                        controller: _emailController,
                        label: 'Email',
                        hint: 'you@company.com',
                        prefixIcon: Icons.mail_outline_rounded,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.email],
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Email is required';
                          }
                          final emailRegex = RegExp(
                            r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                          );
                          if (!emailRegex.hasMatch(v.trim())) {
                            return 'Enter a valid email';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),

                      // Password
                      AppTextField(
                        controller: _passwordController,
                        label: 'Password',
                        hint: 'Min. 8 characters',
                        prefixIcon: Icons.lock_outline_rounded,
                        obscureText: _obscurePassword,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.newPassword],
                        onToggleObscure: () {
                          setState(() => _obscurePassword = !_obscurePassword);
                        },
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return 'Password is required';
                          }
                          if (v.length < 8) {
                            return 'Minimum 8 characters';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),

                      // Business Name
                      AppTextField(
                        controller: _businessNameController,
                        label: 'Business Name',
                        hint: 'Acme Inc.',
                        prefixIcon: Icons.storefront_outlined,
                        textInputAction: TextInputAction.next,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Business name is required';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),

                  PhoneNumberField(
                    controller: _phoneController,
                    initialCountryCode: 'IN',
                  ),

                      // Business Type
                      const Text(
                        'Business Type',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.1,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedBusinessType,
                        decoration: const InputDecoration(
                          hintText: 'Select business type',
                          prefixIcon: Icon(
                            Icons.category_outlined,
                            size: 20,
                            color: AppColors.iconSecondary,
                          ),
                        ),
                        dropdownColor: AppColors.surfaceElevated,
                        style: const TextStyle(
                          fontSize: 15,
                          color: AppColors.textPrimary,
                        ),
                        icon: const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: AppColors.iconSecondary,
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
                          if (v == null) return 'Please select a business type';
                          return null;
                        },
                      ),

                      const SizedBox(height: 32),

                      // Create Account button
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _onCreateAccount,
                          child: _isLoading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.2,
                                    color: AppColors.textOnPrimary,
                                  ),
                                )
                              : const Text('Create Account'),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Divider
                      Row(
                        children: [
                          const Expanded(
                            child: Divider(color: AppColors.divider),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'or',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.textTertiary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const Expanded(
                            child: Divider(color: AppColors.divider),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Google Sign Up
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: OutlinedButton(
                          onPressed: _isLoading ? null : _onGoogleSignUp,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.textPrimary,
                            side: const BorderSide(color: AppColors.border),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Simple Google "G" mark (replace with asset later)
                              Container(
                                width: 20,
                                height: 20,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4),
                                  color: Colors.white,
                                ),
                                child: const Text(
                                  'G',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF4285F4),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'Continue with Google',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 28),

                      // Already have an account
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Already have an account? ',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          GestureDetector(
                            onTap: _goToLogin,
                            child: const Text(
                              'Login',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}