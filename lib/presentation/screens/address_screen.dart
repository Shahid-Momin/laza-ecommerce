import 'package:flutter/material.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';

class AddressScreen extends StatefulWidget {
  final bool isDarkMode;

  const AddressScreen({super.key, this.isDarkMode = false});

  @override
  State<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _countryController = TextEditingController();
  final _cityController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  bool _isPrimary = true;
  bool _isSubmitting = false;

  static const Color _lightBgColor = Colors.white;
  static const Color _darkBgColor = Color(0xFF1B262C);
  static const Color _purple = Color(0xFF9775FA);

  @override
  void dispose() {
    _nameController.dispose();
    _countryController.dispose();
    _cityController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _handleSaveAddress() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(milliseconds: 700));

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    Navigator.pop(context, _addressController.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = widget.isDarkMode;
    final Color backgroundColor = isDark ? _darkBgColor : _lightBgColor;
    final Color textColor = isDark ? Colors.white : const Color(0xFF1B262C);
    final Color backButtonBg = isDark ? Colors.white.withOpacity(0.08) : const Color(0xFFF2F2F2);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(color: backButtonBg, shape: BoxShape.circle),
                        child: Icon(Icons.arrow_back, color: textColor, size: 20),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text('Address',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: textColor)),
                  ],
                ),

                const SizedBox(height: 28),

                CustomTextField(
                  label: 'Name',
                  controller: _nameController,
                  isDarkMode: isDark,
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter a name' : null,
                ),
                const SizedBox(height: 20),

                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        label: 'Country',
                        controller: _countryController,
                        isDarkMode: isDark,
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: CustomTextField(
                        label: 'City',
                        controller: _cityController,
                        isDarkMode: isDark,
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                CustomTextField(
                  label: 'Phone Number',
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  isDarkMode: isDark,
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter a phone number' : null,
                ),
                const SizedBox(height: 20),

                CustomTextField(
                  label: 'Address',
                  controller: _addressController,
                  isDarkMode: isDark,
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter an address' : null,
                ),

                const Spacer(),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Save as primary address',
                        style: TextStyle(fontSize: 14, color: textColor)),
                    Switch(
                      value: _isPrimary,
                      activeColor: _purple,
                      onChanged: (v) => setState(() => _isPrimary = v),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                CustomButton(
                  label: 'Save Address',
                  isLoading: _isSubmitting,
                  onPressed: _handleSaveAddress,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}