import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/product_model.dart';
import '../../logic/auth/auth_bloc.dart';
import '../../logic/auth/auth_state.dart';
import '../../logic/cart/cart_bloc.dart';
import '../../logic/cart/cart_event.dart';
import '../../logic/review/review_bloc.dart';
import '../../logic/review/review_event.dart';
import '../../logic/review/review_state.dart';
import '../../logic/theme/theme_bloc.dart';
import 'add_review_screen.dart';
import 'cart_screen.dart';
import 'reviews_screen.dart';

class ProductDetailsScreen extends StatefulWidget {
  final ProductModel product;
  final bool isDarkMode;
  const ProductDetailsScreen({
    super.key,
    required this.product,
    this.isDarkMode = false,
  });

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  static const List<String> _sizes = ['S', 'M', 'L', 'XL', '2XL'];
  static const Color _purple = Color(0xFF9775FA);

  String _selectedSize = 'M';
  int _selectedImageIndex = 0;
  bool _isAdding = false;

  List<String> get _images {
    final list = widget.product.images;
    if (list.isEmpty) return [widget.product.thumbnail];
    return list;
  }

  @override
  void initState() {
    super.initState();
    // Subscribe to reviews for this product
    context
        .read<ReviewBloc>()
        .add(ReviewsSubscribed(widget.product.id));
  }

  Future<void> _handleAddToCart() async {
    final auth = context.read<AuthBloc>().state;
    if (auth is! Authenticated) return;

    setState(() => _isAdding = true);
    context
        .read<CartBloc>()
        .add(CartAddRequested(auth.user.uid, widget.product));
    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    setState(() => _isAdding = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Added to cart'),
        backgroundColor: _purple,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeBloc>().state.isDark;
    final bg = isDark ? const Color(0xFF1B262C) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1B262C);
    final subTextColor = isDark ? Colors.white70 : const Color(0xFF6B6B6B);
    final imageBg =
    isDark ? const Color(0xFF25333A) : const Color(0xFFF6F6F6);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            // ─── Header ───
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _circle(Icons.arrow_back, isDark, textColor,
                          () => Navigator.pop(context)),
                  _circle(Icons.shopping_bag_outlined, isDark, textColor,
                          () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CartScreen(isDarkMode: isDark),
                        ),
                      )),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),

                    // ─── Main image ───
                    Container(
                      height: 280,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: imageBg,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.network(
                          _images[_selectedImageIndex],
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Icon(
                              Icons.checkroom,
                              size: 96,
                              color: subTextColor),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ─── Thumbnails ───
                    SizedBox(
                      height: 64,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _images.length,
                        separatorBuilder: (_, __) =>
                        const SizedBox(width: 10),
                        itemBuilder: (_, i) {
                          final selected = i == _selectedImageIndex;
                          return GestureDetector(
                            onTap: () =>
                                setState(() => _selectedImageIndex = i),
                            child: Container(
                              width: 64,
                              decoration: BoxDecoration(
                                color: imageBg,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: selected
                                      ? _purple
                                      : Colors.transparent,
                                  width: 1.5,
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(_images[i],
                                    fit: BoxFit.cover),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ─── Title + Price ───
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(widget.product.brand,
                                  style: TextStyle(
                                      fontSize: 12, color: subTextColor)),
                              const SizedBox(height: 4),
                              Text(widget.product.title,
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                      color: textColor)),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('Price',
                                style: TextStyle(
                                    fontSize: 12, color: subTextColor)),
                            const SizedBox(height: 4),
                            Text(
                                '\$${widget.product.price.toStringAsFixed(0)}',
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: textColor)),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // ─── Rating + stock ───
                    Row(
                      children: [
                        const Icon(Icons.star,
                            size: 16, color: Color(0xFFFFC44D)),
                        const SizedBox(width: 4),
                        Text('${widget.product.rating}',
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: textColor)),
                        const SizedBox(width: 12),
                        Text('${widget.product.stock} in stock',
                            style: TextStyle(
                                fontSize: 12, color: subTextColor)),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // ─── Size selector ───
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Size',
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: textColor)),
                        Text('Size Guide',
                            style: TextStyle(
                                fontSize: 12,
                                color: _purple,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: _sizes.map((s) {
                        final selected = s == _selectedSize;
                        return Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedSize = s),
                            child: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: selected
                                    ? _purple
                                    : (isDark
                                    ? const Color(0xFF25333A)
                                    : const Color(0xFFF2F2F2)),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              alignment: Alignment.center,
                              child: Text(s,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color:
                                    selected ? Colors.white : textColor,
                                  )),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),

                    // ─── Description ───
                    Text('Description',
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: textColor)),
                    const SizedBox(height: 8),
                    RichText(
                      text: TextSpan(
                        style: TextStyle(
                            fontSize: 13, height: 1.5, color: subTextColor),
                        children: [
                          TextSpan(text: widget.product.description),
                          const TextSpan(
                            text: ' Read More..',
                            style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: _purple),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ─── Reviews ───
                    BlocBuilder<ReviewBloc, ReviewState>(
                      builder: (context, state) {
                        final reviews = state is ReviewLoaded
                            ? state.reviews
                            : [];
                        final count = reviews.length;
                        final avg = state is ReviewLoaded
                            ? state.averageRating
                            : widget.product.rating;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header
                            Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Reviews',
                                    style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: textColor)),
                                GestureDetector(
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ReviewsScreen(
                                        isDarkMode: isDark,
                                        productId: widget.product.id,
                                        productTitle:
                                        widget.product.title,
                                      ),
                                    ),
                                  ),
                                  child: Text('View All',
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: subTextColor)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            // Preview card
                            if (count > 0)
                              _ReviewPreview(
                                review: reviews.first,
                                isDarkMode: isDark,
                              )
                            else
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'No reviews yet. Be the first!',
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: subTextColor),
                                    ),
                                  ),
                                ],
                              ),

                            const SizedBox(height: 12),

                            // "See all N Reviews" and "Add Review" row
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => ReviewsScreen(
                                          isDarkMode: isDark,
                                          productId: widget.product.id,
                                          productTitle:
                                          widget.product.title,
                                        ),
                                      ),
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      side: BorderSide(
                                        color: isDark
                                            ? Colors.white24
                                            : const Color(0xFFEFEFEF),
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                        BorderRadius.circular(12),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12),
                                    ),
                                    child: Text(
                                      'See all $count Reviews',
                                      style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: textColor),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () async {
                                      final result =
                                      await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              AddReviewScreen(
                                                isDarkMode: isDark,
                                                productId:
                                                widget.product.id,
                                              ),
                                        ),
                                      );
                                      if (result == true && mounted) {
                                        // ReviewBloc stream auto-updates.
                                      }
                                    },
                                    icon: const Icon(Icons.edit,
                                        size: 14, color: Colors.white),
                                    label: const Text('Add Review',
                                        style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.white)),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                      const Color(0xFFFF7A45),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                        BorderRadius.circular(12),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            // Average rating
                            if (count > 0) ...[
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  ...List.generate(
                                    5,
                                        (i) => Icon(
                                      i < avg.floor()
                                          ? Icons.star
                                          : (i < avg
                                          ? Icons.star_half
                                          : Icons.star_border),
                                      size: 14,
                                      color: const Color(0xFFFFC44D),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '${avg.toStringAsFixed(1)} ($count)',
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: subTextColor),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        );
                      },
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Total Price',
                      style: TextStyle(fontSize: 11, color: subTextColor)),
                  Text('with VAT,SD',
                      style: TextStyle(fontSize: 10, color: subTextColor)),
                  Text(
                      '\$${widget.product.price.toStringAsFixed(0)}',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: textColor)),
                ],
              ),
              const SizedBox(width: 20),
              Expanded(
                child: SizedBox(
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _isAdding ? null : _handleAddToCart,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _purple,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                    child: _isAdding
                        ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                          strokeWidth: 2.4, color: Colors.white),
                    )
                        : const Text('Add to Cart',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _circle(IconData icon, bool isDark, Color fg, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color:
          isDark ? Colors.white.withOpacity(0.08) : const Color(0xFFF2F2F2),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: fg, size: 20),
      ),
    );
  }
}


// Preview card for the latest review

class _ReviewPreview extends StatelessWidget {
  final dynamic review; // ReviewModel
  final bool isDarkMode;

  const _ReviewPreview({required this.review, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    final textColor = isDarkMode ? Colors.white : const Color(0xFF1B262C);
    final subTextColor =
    isDarkMode ? Colors.white70 : const Color(0xFF6B6B6B);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CircleAvatar(
          radius: 18,
          backgroundColor: Color(0xFFE0E0E0),
          child: Icon(Icons.person, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(review.name as String,
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: textColor)),
                  Row(
                    children: [
                      const Icon(Icons.star,
                          size: 14, color: Color(0xFFFFC44D)),
                      const SizedBox(width: 4),
                      Text('${review.rating}',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: textColor)),
                    ],
                  ),
                ],
              ),
              Text(
                _formatDate(review.createdAt),
                style: TextStyle(fontSize: 11, color: subTextColor),
              ),
              const SizedBox(height: 4),
              Text(
                review.text as String,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontSize: 12, height: 1.4, color: subTextColor),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${d.day} ${months[d.month - 1]}, ${d.year}';
  }
}