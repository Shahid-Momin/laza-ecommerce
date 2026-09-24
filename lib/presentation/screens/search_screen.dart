import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../logic/product/product_bloc.dart';
import '../../logic/product/product_event.dart';
import '../../logic/product/product_state.dart';
import '../../logic/theme/theme_bloc.dart';
import 'product_details_screen.dart';

class SearchScreen extends StatefulWidget {
  final bool isDarkMode;
  const SearchScreen({super.key, this.isDarkMode = false});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  Timer? _debounce;

  void _onChanged(String q) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      if (q.trim().isEmpty) return;
      context.read<ProductBloc>().add(ProductSearchRequested(q.trim()));
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeBloc>().state.isDark;
    final bg = isDark ? const Color(0xFF1B262C) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1B262C);
    final subTextColor = isDark ? Colors.white70 : const Color(0xFF6B6B6B);
    final fieldBg =
    isDark ? Colors.white.withOpacity(0.06) : const Color(0xFFF2F2F2);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back + search bar
              Row(
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
                      child:
                      Icon(Icons.arrow_back, color: textColor, size: 20),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      height: 48,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: fieldBg,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.search, color: subTextColor, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _controller,
                              onChanged: _onChanged,
                              style: TextStyle(
                                  color: textColor, fontSize: 14),
                              decoration: InputDecoration(
                                hintText: 'Search products...',
                                hintStyle: TextStyle(color: subTextColor),
                                border: InputBorder.none,
                                isDense: true,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Results
              Expanded(
                child: BlocBuilder<ProductBloc, ProductState>(
                  builder: (context, state) {
                    if (state is ProductLoading) {
                      return const Center(
                          child: CircularProgressIndicator());
                    }
                    if (state is ProductError) {
                      return Center(
                        child: Text(state.message,
                            style: TextStyle(color: subTextColor)),
                      );
                    }
                    if (state is ProductEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_off,
                                size: 64, color: subTextColor),
                            const SizedBox(height: 12),
                            Text('No products found',
                                style: TextStyle(color: subTextColor)),
                          ],
                        ),
                      );
                    }
                    if (state is ProductLoaded) {
                      return GridView.builder(
                        itemCount: state.products.length,
                        gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio: 0.72,
                        ),
                        itemBuilder: (_, i) {
                          final p = state.products[i];
                          return GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ProductDetailsScreen(
                                  product: p,
                                  isDarkMode: isDark,
                                ),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: Image.network(
                                      p.thumbnail,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      errorBuilder: (_, __, ___) =>
                                          Container(
                                            color: fieldBg,
                                            child: Icon(
                                                Icons.image_not_supported,
                                                color: subTextColor),
                                          ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(p.title,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        fontSize: 13,
                                        color: textColor,
                                        fontWeight: FontWeight.w500)),
                                const SizedBox(height: 4),
                                Text('\$${p.price.toStringAsFixed(0)}',
                                    style: TextStyle(
                                        fontSize: 13,
                                        color: subTextColor,
                                        fontWeight: FontWeight.w600)),
                              ],
                            ),
                          );
                        },
                      );
                    }
                    return Center(
                      child: Text('Type to search',
                          style: TextStyle(color: subTextColor)),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}