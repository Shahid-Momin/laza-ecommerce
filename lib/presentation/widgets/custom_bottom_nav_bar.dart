import 'package:flutter/material.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;
  final bool isDarkMode;

  const CustomBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
    this.isDarkMode = false,
  });

  static const Color _purple = Color(0xFF9775FA);

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor = isDarkMode ? const Color(0xFF25333A) : Colors.white;
    final Color inactiveColor = isDarkMode ? Colors.white70 : const Color(0xFF9B9B9B);

    // Shadow to make it pop off the page
    final BoxShadow shadow = BoxShadow(
      color: Colors.black.withOpacity(0.1),
      blurRadius: 20,
      spreadRadius: 2,
      offset: const Offset(0, 5),
    );

    return Container(
      // 1. Add margin to float it above the bottom edge
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      decoration: BoxDecoration(
        color: backgroundColor,
        // 2. Add rounded corners for a modern floating look
        borderRadius: BorderRadius.circular(30),
        boxShadow: [shadow],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: Padding(
          // 3. Comfortable padding inside the bar
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                index: 0,
                icon: Icons.home_outlined,
                label: 'Home',
                inactiveColor: inactiveColor,
              ),
              _buildNavItem(
                index: 1,
                icon: Icons.favorite_border,
                label: 'Wishlist',
                inactiveColor: inactiveColor,
              ),
              _buildNavItem(
                index: 2,
                icon: Icons.shopping_bag_outlined,
                label: 'Cart',
                inactiveColor: inactiveColor,
              ),
              _buildNavItem(
                index: 3,
                icon: Icons.account_balance_wallet_outlined,
                label: 'Wallet',
                inactiveColor: inactiveColor,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required String label,
    required Color inactiveColor,
  }) {
    final bool isSelected = selectedIndex == index;

    return GestureDetector(
      onTap: () => onItemTapped(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        // Add a subtle background color to the active item for better UX
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? _purple.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: isSelected
              ? Text(
            label,
            key: ValueKey('text_$index'),
            style: const TextStyle(
              color: _purple,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          )
              : Icon(
            icon,
            key: ValueKey('icon_$index'),
            color: inactiveColor,
            size: 24,
          ),
        ),
      ),
    );
  }
}