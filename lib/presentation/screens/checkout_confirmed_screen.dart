import 'package:flutter/material.dart';
import 'orders_screen.dart';
class CheckoutConfirmedScreen extends StatelessWidget {
  final bool isDarkMode;

  const CheckoutConfirmedScreen({super.key, this.isDarkMode = false});

  static const Color _lightBgColor = Colors.white;
  static const Color _darkBgColor = Color(0xFF1B262C);
  static const Color _purple = Color(0xFF9775FA);

  @override
  Widget build(BuildContext context) {
    final bool isDark = isDarkMode;
    final Color backgroundColor = isDark ? _darkBgColor : _lightBgColor;
    final Color textColor = isDark ? Colors.white : const Color(0xFF1B262C);
    final Color subTextColor = isDark ? Colors.white70 : const Color(0xFF6B6B6B);
    final Color backButtonBg =
    isDark ? Colors.white.withOpacity(0.08) : const Color(0xFFF2F2F2);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ─── Back Button ───
              Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: backButtonBg,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.arrow_back, color: textColor, size: 20),
                  ),
                ),
              ),

              const Spacer(flex: 2),

              // ─── Layered Illustration ───
              SizedBox(
                width: 280,
                height: 280,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Layer 1: Background arcs (softened in dark mode)
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Opacity(
                        opacity: isDark ? 0.45 : 1.0,
                        child: Image.asset(
                          'assets/images/MaskGroup.png',
                          width: 280,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                        ),
                      ),
                    ),

                    // Layer 2: Phone illustration
                    Positioned(
                      top: 0,
                      child: Image.asset(
                        'assets/images/Group22.png',
                        width: 200,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => Icon(
                          Icons.check_circle_outline,
                          size: 120,
                          color: _purple.withOpacity(0.5),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // ─── Title ───
              Text(
                'Order Confirmed!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 12),

              // ─── Subtitle ───
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Your order has been confirmed, we will send you confirmation email shortly.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.5,
                    color: subTextColor,
                  ),
                ),
              ),

              const Spacer(flex: 3),

              // ─── "Go to Orders" Outline Button ───
              SizedBox(
                width: double.infinity,
                height: 54,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => OrdersScreen(isDarkMode: isDark),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: isDark ? Colors.white24 : const Color(0xFFEFEFEF),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    backgroundColor:
                    isDark ? Colors.white.withOpacity(0.05) : Colors.white,
                  ),
                  child: Text(
                    'Go to Orders',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ─── "Continue Shopping" Solid Button ───
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () {
                    // Return to Home (unwinds Cart / Checkout screens)
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _purple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Continue Shopping',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}