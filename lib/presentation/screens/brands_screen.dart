import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/product_model.dart';
import '../../logic/product/product_bloc.dart';
import '../../logic/product/product_event.dart';
import '../../logic/product/product_state.dart';
import '../../logic/theme/theme_bloc.dart';
import 'product_details_screen.dart';

class BrandsScreen extends StatefulWidget {
  final bool isDarkMode;
  const BrandsScreen({super.key, this.isDarkMode = false});

  @override
  State<BrandsScreen> createState() => _BrandsScreenState();
}

class _BrandsScreenState extends State<BrandsScreen> {
  static const Color _purple = Color(0xFF9775FA);

  static const List<String> _brands = [
    'Adidas',
    'Nike',
    'Fila',
    'Puma',
    'Essence',
    'Apple',
    'Samsung',
    'Gucci',
    'Chanel',
    'Dior',
    'Calvin Klein',
    'Annibale Colombo',
  ];

  String? _selectedBrand;

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeBloc>().state.isDark;
    final bg = isDark ? const Color(0xFF1B262C) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1B262C);
    final subTextColor = isDark ? Colors.white70 : const Color(0xFF6B6B6B);
    final iconBg =
    isDark ? Colors.white.withOpacity(0.08) : const Color(0xFFF2F2F2);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: iconBg,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.arrow_back,
                          color: textColor, size: 20),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text('Brands',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: textColor)),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Brand chips
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _brands.map((brand) {
                  final selected = _selectedBrand == brand;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedBrand = selected ? null : brand;
                      });
                      if (!selected) {
                        // Load products; filter by brand client-side
                        context.read<ProductBloc>().add(
                          const ProductsFetchRequested(
                              limit: 100, skip: 0, refresh: true),
                        );
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: selected
                            ? _purple
                            : (isDark
                            ? const Color(0xFF25333A)
                            : const Color(0xFFF2F2F2)),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        brand,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: selected ? Colors.white : textColor,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 16),

            // Products
            Expanded(
              child: BlocBuilder<ProductBloc, ProductState>(
                builder: (context, state) {
                  if (state is ProductLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state is ProductError) {
                    return Center(
                        child: Text(state.message,
                            style: TextStyle(color: subTextColor)));
                  }
                  if (state is ProductEmpty) {
                    return Center(
                        child: Text('No products',
                            style: TextStyle(color: subTextColor)));
                  }

                  final products = state is ProductLoaded
                      ? state.products
                      : <ProductModel>[];

                  final filtered = _selectedBrand == null
                      ? products
                      : products
                      .where((p) => p.brand
                      .toLowerCase()
                      .contains(_selectedBrand!.toLowerCase()))
                      .toList();

                  if (filtered.isEmpty) {
                    return Center(
                        child: Text('No products for this brand',
                            style: TextStyle(color: subTextColor)));
                  }

                  return GridView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                    itemCount: filtered.length,
                    gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 0.72,
                    ),
                    itemBuilder: (_, i) {
                      final p = filtered[i];
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
                              child: Container(
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? const Color(0xFF25333A)
                                      : const Color(0xFFF6F6F6),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                clipBehavior: Clip.antiAlias,
                                child: Image.network(
                                  p.thumbnail,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  errorBuilder: (_, __, ___) => Icon(
                                      Icons.checkroom,
                                      color: subTextColor),
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
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}