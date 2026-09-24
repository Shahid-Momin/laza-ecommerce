import 'package:flutter/material.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import 'add_card_screen.dart';

class SavedCard {
  final String owner;
  final String last4;
  final double balance;

  const SavedCard({required this.owner, required this.last4, required this.balance});
}

class PaymentScreen extends StatefulWidget {
  final bool isDarkMode;
  const PaymentScreen({super.key, this.isDarkMode = false});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _ownerController = TextEditingController();
  final _numberController = TextEditingController();
  final _expController = TextEditingController();
  final _cvvController = TextEditingController();
  bool _saveCardInfo = true;
  bool _isSubmitting = false;


  static const Color _lightBgColor = Colors.white;
  static const Color _darkBgColor = Color(0xFF1B262C);
  static const Color _purple = Color(0xFF9775FA);

  // Make this non-static to allow updates
  List<SavedCard> _savedCards = [
    const SavedCard(owner: 'Mrh Raju', last4: '7690', balance: 3763.87),
    const SavedCard(owner: 'Mrh Raju', last4: '5432', balance: 1200.00),
  ];

  @override
  void dispose() {
    _ownerController.dispose();
    _numberController.dispose();
    _expController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  Future<void> _handleSaveCard() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    setState(() => _isSubmitting = false);

    final last4 = _numberController.text.replaceAll(' ', '');
    Navigator.pop(
      context,
      'Visa Classic **** ${last4.length >= 4 ? last4.substring(last4.length - 4) : last4}',
    );
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
                    Text('Payment', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: textColor)),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 160,
                  child: PageView.builder(
                    controller: PageController(viewportFraction: 0.88),
                    onPageChanged: (_) {},
                    itemCount: _savedCards.length,
                    itemBuilder: (context, index) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: _CardVisual(card: _savedCards[index]),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      // --- Flow to AddCardScreen ---
                      final result = await Navigator.push<String>(
                        context,
                        MaterialPageRoute(builder: (_) => AddCardScreen(isDarkMode: isDark)),
                      );
                      if (result != null) {
                        // Add the new card to the list
                        setState(() {
                          _savedCards.insert(0, SavedCard(owner: 'New User', last4: result.split(' ').last, balance: 0.0));
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Added: $result')),
                        );
                      }
                    },
                    icon: const Icon(Icons.add, size: 18, color: _purple),
                    label: const Text('Add new card', style: TextStyle(color: _purple, fontWeight: FontWeight.w600)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: _purple),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                CustomTextField(
                  label: 'Card Owner',
                  controller: _ownerController,
                  isDarkMode: isDark,
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter the card owner name' : null,
                ),
                const SizedBox(height: 20),
                CustomTextField(
                  label: 'Card Number',
                  controller: _numberController,
                  keyboardType: TextInputType.number,
                  isDarkMode: isDark,
                  validator: (v) => (v == null || v.replaceAll(' ', '').length < 12) ? 'Enter a valid card number' : null,
                ),
                const SizedBox(height: 20),
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
                    const SizedBox(width: 16),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Save card info', style: TextStyle(fontSize: 14, color: textColor)),
                    Switch(
                      value: _saveCardInfo,
                      activeColor: _purple,
                      onChanged: (v) => setState(() => _saveCardInfo = v),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                CustomButton(
                  label: 'Save Card',
                  isLoading: _isSubmitting,
                  onPressed: _handleSaveCard,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CardVisual extends StatelessWidget {
  final SavedCard card;

  const _CardVisual({required this.card});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFC44D), Color(0xFFFF7A45), Color(0xFFE84C4C)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(card.owner, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
              const Text('VISA', style: TextStyle(color: Colors.white, fontSize: 16, fontStyle: FontStyle.italic, fontWeight: FontWeight.w900)),
            ],
          ),
          const Spacer(),
          const Text('Visa Classic', style: TextStyle(color: Colors.white70, fontSize: 12)),
          const SizedBox(height: 4),
          Text('5254  ****  ****  ${card.last4}',
              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: 1.2)),
          const SizedBox(height: 8),
          Text('\$${card.balance.toStringAsFixed(2)}',
              style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}