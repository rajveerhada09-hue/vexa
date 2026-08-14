import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/phone_number.dart';

import '../theme/app_colors.dart';

class PhoneNumberField extends StatelessWidget {
  const PhoneNumberField({
    super.key,
    required this.controller,
    this.focusNode,
    this.onChanged,
    this.onSaved,
    this.validator,
    this.enabled = true,
    this.initialCountryCode = 'IN',
    this.hintText = '9876543210',
    this.labelText = 'Phone Number',
    this.textInputAction = TextInputAction.next,
  });

  final TextEditingController controller;
  final FocusNode? focusNode;
  final ValueChanged<PhoneNumber>? onChanged;
  final FormFieldSetter<PhoneNumber>? onSaved;
  final FormFieldValidator<PhoneNumber>? validator;
  final bool enabled;
  final String initialCountryCode;
  final String hintText;
  final String labelText;
  final TextInputAction textInputAction;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labelText,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.1,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        IntlPhoneField(
          controller: controller,
          focusNode: focusNode,
          enabled: enabled,
          initialCountryCode: initialCountryCode,
          textInputAction: textInputAction,
          disableLengthCheck: false,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: AppColors.textPrimary,
          ),
          dropdownTextStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: AppColors.textPrimary,
          ),
          cursorColor: AppColors.primary,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
            ),
            counter: const Offstage(),
          ),
          dropdownIcon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppColors.iconSecondary,
            size: 20,
          ),
          flagsButtonPadding: EdgeInsets.zero,
          onChanged: onChanged,
          onSaved: onSaved,
          validator: validator ??
              (PhoneNumber? phone) {
                if (phone == null || phone.number.isEmpty) {
                  return 'Phone number is required';
                }
                if (!phone.isValidNumber()) {
                  return 'Enter a valid phone number';
                }
                return null;
              },
        ),
      ],
    );
  }
}