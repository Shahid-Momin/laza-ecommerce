import 'package:flutter/material.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';

class AddCardScreen extends StatefulWidget {
  final bool isDarkMode;

  const AddCardScreen({super.key, this.isDarkMode = false});

  @override
  State<AddCardScreen> createState() => _AddCardScreenState();
}

class _AddCardScreenState extends State<AddCardScreen> {
  final _formKey = GlobalKey<FormState>();
  final _ownerController = TextEditingController();
  final _numberController = TextEditingController();
  final _expController = TextEditingController();
  final _cvvController = TextEditingController();

  // 0 = Visa, 1 = PayPal, 2 = Bank
  int _selectedCardType = 0;
  bool _isSubmitting = false;

  static const Color _lightBgColor = Colors.white;
  static const Color _darkBgColor = Color(0xFF1B262C);
  static const Color _purple = Color(0xFF9775FA);
  static const Color _visaRed = Color(0xFFFF4D4D); // Red for the Visa selection

  @override
  void dispose() {
    _ownerController.dispose();
    _numberController.dispose();
    _expController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  Future<void> _handleAddCard() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(milliseconds: 800));

    if (!mounted) return;
    setState(() => _isSubmitting = false);


    final last4 = _numberController.text.replaceAll(' ', '');
    final last4Digits = last4.length >= 4 ? last4.substring(last4.length - 4) : last4;
    Navigator.pop(context, 'Visa Classic **** $last4Digits');
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
                // --- Header ---
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
                    Text(
                      'Add New Card',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: textColor),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // --- Card Type Selector ---
                Row(
                  children: [
                    // Visa Box (Selected by default)
                    _buildCardTypeBox(
                      index: 0,
                      isDark: isDark,
                      icon: Icons.credit_card,
                      selectedColor: _visaRed,
                      iconColor: Colors.white,
                    ),
                    const SizedBox(width: 16),
                    // PayPal Box
                    _buildCardTypeBox(
                      index: 1,
                      isDark: isDark,
                      icon: Icons.paypal,
                      selectedColor: const Color(0xFF1DA1F2),
                      iconColor: const Color(0xFF1DA1F2),
                    ),
                    const SizedBox(width: 16),
                    // Bank Box
                    _buildCardTypeBox(
                      index: 2,
                      isDark: isDark,
                      icon: Icons.account_balance,
                      selectedColor: _purple,
                      iconColor: _purple,
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // --- Form Fields ---
                CustomTextField(
                  label: 'Card Owner',
                  controller: _ownerController,
                  isDarkMode: isDark,
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter card owner name' : null,
                ),
                const SizedBox(height: 24),

                CustomTextField(
                  label: 'Card Number',
                  controller: _numberController,
                  keyboardType: TextInputType.number,
                  isDarkMode: isDark,
                  validator: (v) => (v == null || v.replaceAll(' ', '').length < 12) ? 'Enter a valid card number' : null,
                ),
                const SizedBox(height: 24),

                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        label: 'EXP',
                        controller: _expController,
                        hintText: 'MM/YY',
                        isDarkMode: isDark,
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: CustomTextField(
                        label: 'CVV',
                        controller: _cvvController,
                        keyboardType: TextInputType.number,
                        obscureText: true,
                        isDarkMode: isDark,
                        validator: (v) => (v == null || v.trim().length < 3) ? 'Required' : null,
                      ),
                    ),
                  ],
                ),

                const Spacer(),

                // --- Bottom Action Button ---
                CustomButton(
                  label: 'Add Card',
                  isLoading: _isSubmitting,
                  onPressed: _handleAddCard,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the selectable card type boxes
  Widget _buildCardTypeBox({
    required int index,
    required bool isDark,
    required IconData icon,
    required Color selectedColor,
    required Color iconColor,
  }) {
    final bool isSelected = _selectedCardType == index;
    final Color bgColor = isSelected
        ? selectedColor
        : (isDark ? Colors.white.withOpacity(0.06) : const Color(0xFFF2F2F2));
    final Color finalIconColor = isSelected ? Colors.white : iconColor;
    final Color borderColor = isSelected ? selectedColor : Colors.transparent;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedCardType = index),
        child: Container(
          height: 60,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor, width: 1.5),
          ),
          child: Center(
            child: Icon(icon, color: finalIconColor, size: 28),
          ),
        ),
      ),
    );
  }
}