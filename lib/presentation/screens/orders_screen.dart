import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../logic/auth/auth_bloc.dart';
import '../../logic/auth/auth_state.dart';
import '../../logic/order/order_bloc.dart';
import '../../logic/order/order_event.dart';
import '../../logic/order/order_state.dart';
import '../../logic/theme/theme_bloc.dart';

class OrdersScreen extends StatefulWidget {
  final bool isDarkMode;
  const OrdersScreen({super.key, this.isDarkMode = false});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthBloc>().state;
    if (auth is Authenticated) {
      context.read<OrderBloc>().add(OrdersSubscribed(auth.user.uid));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeBloc>().state.isDark;
    final bg = isDark ? const Color(0xFF1B262C) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1B262C);
    final subTextColor = isDark ? Colors.white70 : const Color(0xFF6B6B6B);
    final cardBg = isDark ? const Color(0xFF25333A) : const Color(0xFFF7F7F7);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
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
                  Text('My Orders',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: textColor)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: BlocBuilder<OrderBloc, OrderState>(
                builder: (context, state) {
                  if (state is OrderLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state is OrderError) {
                    return Center(
                        child: Text(state.message,
                            style: TextStyle(color: subTextColor)));
                  }
                  final orders = state is OrderLoaded ? state.orders : [];
                  if (orders.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.shopping_bag_outlined,
                              size: 72,
                              color: subTextColor.withOpacity(0.5)),
                          const SizedBox(height: 16),
                          Text('No orders yet',
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: textColor)),
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    itemCount: orders.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, i) {
                      final o = orders[i];
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                    'Order #${o.orderId.substring(0, 6)}',
                                    style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: textColor)),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF9775FA)
                                        .withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(o.status.toUpperCase(),
                                      style: const TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF9775FA))),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text('${o.items.length} items',
                                style: TextStyle(
                                    fontSize: 12, color: subTextColor)),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${o.createdAt.day}/${o.createdAt.month}/${o.createdAt.year}',
                                  style: TextStyle(
                                      fontSize: 12, color: subTextColor),
                                ),
                                Text('\$${o.totalAmount.toStringAsFixed(2)}',
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: textColor)),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}