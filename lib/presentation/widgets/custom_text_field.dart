import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class CustomTextField extends StatefulWidget {
  final String label;
  final String? hintText;
  final TextEditingController controller;
  final bool obscureText;
  final bool isDarkMode;
  final bool showObscureToggle;
  final TextInputType keyboardType;
  final Widget? trailing;
  final String? Function(String?)? validator;

  const CustomTextField({
    super.key,
    required this.label,
    required this.controller,
    this.hintText,
    this.obscureText = false,
    this.isDarkMode = false,
    this.showObscureToggle = false,
    this.keyboardType = TextInputType.text,
    this.trailing,
    this.validator,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late bool _obscured = widget.obscureText;

  @override
  Widget build(BuildContext context) {
    final Color labelColor =
    widget.isDarkMode ? Colors.white60 : AppColors.textHint;
    final Color textColor =
    widget.isDarkMode ? Colors.white : AppColors.textPrimary;
    final Color lineColor =
    widget.isDarkMode ? Colors.white24 : AppColors.lightDivider;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              widget.label,
              style: TextStyle(fontSize: 12, color: labelColor),
            ),
            if (widget.trailing != null) widget.trailing!,
          ],
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: widget.controller,
          obscureText: _obscured,
          keyboardType: widget.keyboardType,
          validator: widget.validator,
          style: TextStyle(
            fontSize: 15,
            color: textColor,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: TextStyle(color: labelColor.withOpacity(0.7)),
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(vertical: 8),
            errorStyle: const TextStyle(
              fontSize: 11,
              color: Colors.redAccent,
            ),
            suffixIcon: widget.showObscureToggle
                ? IconButton(
              icon: Icon(
                _obscured
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                size: 18,
                color: labelColor,
              ),
              onPressed: () =>
                  setState(() => _obscured = !_obscured),
            )
                : null,
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: lineColor),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.purple, width: 1.5),
            ),
            errorBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.redAccent),
            ),
          ),
        ),
      ],
    );
  }
}