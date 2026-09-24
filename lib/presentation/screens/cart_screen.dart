import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/cart_item_model.dart';
import '../../data/models/order_model.dart';
import '../../logic/auth/auth_bloc.dart';
import '../../logic/auth/auth_state.dart';
import '../../logic/cart/cart_bloc.dart';
import '../../logic/cart/cart_event.dart';
import '../../logic/cart/cart_state.dart';
import '../../logic/order/order_bloc.dart';
import '../../logic/order/order_event.dart';
import '../../logic/theme/theme_bloc.dart';
import 'address_screen.dart';
import 'checkout_confirmed_screen.dart';
import 'payment_screen.dart';

class CartScreen extends StatefulWidget {
  final bool isDarkMode;
  const CartScreen({super.key, this.isDarkMode = false});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  String? _deliveryAddress;
  String? _paymentMethod;

  static const Color _purple = Color(0xFF9775FA);

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthBloc>().state;
    if (auth is Authenticated) {
      context.read<CartBloc>().add(CartSubscribed(auth.user.uid));
    }
  }

  Future<void> _handleCheckout(CartLoaded cart) async {
    if (_deliveryAddress == null || _paymentMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Add a delivery address and payment method first.')),
      );
      return;
    }
    final auth = context.read<AuthBloc>().state;
    if (auth is! Authenticated) return;

    final order = OrderModel(
      orderId: '',
      items: cart.items
          .map((i) => OrderItem(
        productId: i.productId,
        title: i.title,
        price: i.price,
        quantity: i.quantity,
        thumbnail: i.thumbnail,
      ))
          .toList(),
      totalAmount: cart.total,
      deliveryAddress: _deliveryAddress!,
      paymentMethod: _paymentMethod!,
      createdAt: DateTime.now(),
    );

    context.read<OrderBloc>().add(OrderPlaceRequested(auth.user.uid, order));
    context.read<CartBloc>().add(CartClearRequested(auth.user.uid));

    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CheckoutConfirmedScreen(isDarkMode: widget.isDarkMode),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeBloc>().state.isDark;
    final bg = isDark ? const Color(0xFF1B262C) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1B262C);
    final subTextColor = isDark ? Colors.white70 : const Color(0xFF6B6B6B);
    final cardBg = isDark ? const Color(0xFF25333A) : const Color(0xFFF7F7F7);
    final imageBg =
    isDark ? const Color(0xFF2E3D45) : const Color(0xFFF0F0F0);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: BlocBuilder<CartBloc, CartState>(
          builder: (context, state) {
            final items = state is CartLoaded ? state.items : <CartItemModel>[];
            final cart = state is CartLoaded ? state : null;

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.white.withOpacity(0.08)
                                : const Color(0xFFF2F2F2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.arrow_back,
                              color: textColor, size: 20),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text('Cart',
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: textColor)),
                    ],
                  ),
                ),
                Expanded(
                  child: items.isEmpty
                      ? Center(
                    child: Text('Your cart is empty',
                        style: TextStyle(color: subTextColor)),
                  )
                      : ListView(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    children: [
                      ...items.map((item) => Padding(
                        padding:
                        const EdgeInsets.only(bottom: 16),
                        child: _CartItemTile(
                          item: item,
                          imageBg: imageBg,
                          textColor: textColor,
                          subTextColor: subTextColor,
                          onIncrement: () {
                            final auth = context
                                .read<AuthBloc>()
                                .state;
                            if (auth is! Authenticated) return;
                            context.read<CartBloc>().add(
                              CartUpdateQtyRequested(
                                auth.user.uid,
                                item.productId,
                                item.quantity + 1,
                              ),
                            );
                          },
                          onDecrement: () {
                            final auth = context
                                .read<AuthBloc>()
                                .state;
                            if (auth is! Authenticated) return;
                            context.read<CartBloc>().add(
                              CartUpdateQtyRequested(
                                auth.user.uid,
                                item.productId,
                                item.quantity - 1,
                              ),
                            );
                          },
                          onDelete: () {
                            final auth = context
                                .read<AuthBloc>()
                                .state;
                            if (auth is! Authenticated) return;
                            context.read<CartBloc>().add(
                              CartRemoveRequested(
                                auth.user.uid,
                                item.productId,
                              ),
                            );
                          },
                        ),
                      )),
                      const SizedBox(height: 8),

                      _SectionRow(
                        label: 'Delivery Address',
                        textColor: textColor,
                        subTextColor: subTextColor,
                        onTap: () async {
                          final r = await Navigator.push<String>(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AddressScreen(
                                  isDarkMode: isDark),
                            ),
                          );
                          if (r != null) {
                            setState(() => _deliveryAddress = r);
                          }
                        },
                      ),
                      const SizedBox(height: 10),
                      _InfoCard(
                        cardBg: cardBg,
                        leading: const Icon(Icons.location_on,
                            color: Color(0xFFFF7A45), size: 20),
                        title: _deliveryAddress ??
                            'Add a delivery address',
                        subtitle: 'Sylhet',
                        textColor: textColor,
                        subTextColor: subTextColor,
                      ),
                      const SizedBox(height: 20),

                      _SectionRow(
                        label: 'Payment Method',
                        textColor: textColor,
                        subTextColor: subTextColor,
                        onTap: () async {
                          final r = await Navigator.push<String>(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PaymentScreen(
                                  isDarkMode: isDark),
                            ),
                          );
                          if (r != null) {
                            setState(() => _paymentMethod = r);
                          }
                        },
                      ),
                      const SizedBox(height: 10),
                      _InfoCard(
                        cardBg: cardBg,
                        leading: const Icon(Icons.credit_card,
                            color: _purple, size: 20),
                        title: _paymentMethod ?? 'Add a payment method',
                        subtitle: null,
                        textColor: textColor,
                        subTextColor: subTextColor,
                      ),
                      const SizedBox(height: 20),

                      Text('Order Info',
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: textColor)),
                      const SizedBox(height: 12),
                      if (cart != null) ...[
                        _row(
                          'Subtotal',
                          '\$${cart.subtotal.toStringAsFixed(0)}',
                          textColor,
                          subTextColor,
                        ),
                        const SizedBox(height: 8),
                        _row(
                          'Shipping cost',
                          '\$${cart.shipping.toStringAsFixed(0)}',
                          textColor,
                          subTextColor,
                        ),
                        const SizedBox(height: 8),
                        Divider(
                            color: isDark
                                ? Colors.white12
                                : const Color(0xFFEFEFEF)),
                        const SizedBox(height: 8),
                        _row(
                          'Total',
                          '\$${cart.total.toStringAsFixed(0)}',
                          textColor,
                          subTextColor,
                          bold: true,
                        ),
                      ],
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          child: SizedBox(
            height: 54,
            child: BlocBuilder<CartBloc, CartState>(
              builder: (context, state) {
                return ElevatedButton(
                  onPressed: state is CartLoaded && state.items.isNotEmpty
                      ? () => _handleCheckout(state)
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _purple,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: const Text('Checkout',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600)),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _row(String label, String value, Color textColor, Color subTextColor,
      {bool bold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: 13,
                color: bold ? textColor : subTextColor,
                fontWeight: bold ? FontWeight.w700 : FontWeight.w400)),
        Text(value,
            style: TextStyle(
                fontSize: 14,
                color: textColor,
                fontWeight: bold ? FontWeight.w700 : FontWeight.w600)),
      ],
    );
  }
}

class _CartItemTile extends StatelessWidget {
  final CartItemModel item;
  final Color imageBg, textColor, subTextColor;
  final VoidCallback onIncrement, onDecrement, onDelete;

  const _CartItemTile({
    required this.item,
    required this.imageBg,
    required this.textColor,
    required this.subTextColor,
    required this.onIncrement,
    required this.onDecrement,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
              color: imageBg, borderRadius: BorderRadius.circular(14)),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.network(item.thumbnail,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    Icon(Icons.checkroom, color: subTextColor)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: textColor)),
              const SizedBox(height: 4),
              Text('\$${item.price.toStringAsFixed(0)}',
                  style: TextStyle(fontSize: 11, color: subTextColor)),
              const SizedBox(height: 8),
              Row(
                children: [
                  _step(Icons.keyboard_arrow_down, onDecrement, subTextColor),
                  const SizedBox(width: 10),
                  Text('${item.quantity}',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: textColor)),
                  const SizedBox(width: 10),
                  _step(Icons.keyboard_arrow_up, onIncrement, subTextColor),
                ],
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: onDelete,
          icon: Icon(Icons.delete_outline, color: subTextColor, size: 20),
        ),
      ],
    );
  }

  Widget _step(IconData icon, VoidCallback onTap, Color color) {
    return GestureDetector(
        onTap: onTap, child: Icon(icon, size: 18, color: color));
  }
}

class _SectionRow extends StatelessWidget {
  final String label;
  final Color textColor, subTextColor;
  final VoidCallback onTap;
  const _SectionRow({
    required this.label,
    required this.textColor,
    required this.subTextColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 15, fontWeight: FontWeight.w700, color: textColor)),
          Icon(Icons.chevron_right, color: subTextColor, size: 20),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final Color cardBg, textColor, subTextColor;
  final Widget leading;
  final String title;
  final String? subtitle;
  const _InfoCard({
    required this.cardBg,
    required this.leading,
    required this.title,
    required this.subtitle,
    required this.textColor,
    required this.subTextColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: cardBg, borderRadius: BorderRadius.circular(14)),
      child: Row(
        children: [
          leading,
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: textColor)),
                if (subtitle != null)
                  Text(subtitle!,
                      style: TextStyle(fontSize: 11, color: subTextColor)),
              ],
            ),
          ),
          const Icon(Icons.check_circle, color: Color(0xFF4CAF50), size: 20),
        ],
      ),
    );
  }
}