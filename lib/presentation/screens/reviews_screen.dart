import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/review_model.dart';
import '../../logic/review/review_bloc.dart';
import '../../logic/review/review_event.dart';
import '../../logic/review/review_state.dart';
import '../../logic/theme/theme_bloc.dart';
import 'add_review_screen.dart';

class ReviewsScreen extends StatefulWidget {
  final bool isDarkMode;
  final int productId;
  final String productTitle;

  const ReviewsScreen({
    super.key,
    this.isDarkMode = false,
    required this.productId,
    this.productTitle = '',
  });

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  static const Color _orange = Color(0xFFFF7A45);


  @override
  void initState() {
    super.initState();
    context.read<ReviewBloc>().add(ReviewsSubscribed(widget.productId));
  }

  Future<void> _handleAddReview() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddReviewScreen(
          isDarkMode: widget.isDarkMode,
          productId: widget.productId,
        ),
      ),
    );
    if (result == true && mounted) {
      // ReviewBloc stream auto-updates
    }
  }

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
          children: [
            // Header
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
                          color: iconBg, shape: BoxShape.circle),
                      child: Icon(Icons.arrow_back,
                          color: textColor, size: 20),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text('Reviews',
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: textColor)),
                    ),
                  ),
                  const SizedBox(width: 40), // symmetry
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Body
            Expanded(
              child: BlocBuilder<ReviewBloc, ReviewState>(
                builder: (context, state) {
                  if (state is ReviewLoading) {
                    return const Center(
                        child: CircularProgressIndicator());
                  }
                  if (state is ReviewError) {
                    return Center(
                        child: Text(state.message,
                            style: TextStyle(color: subTextColor)));
                  }
                  final reviews =
                  state is ReviewLoaded ? state.reviews : [];

                  // Empty state
                  if (reviews.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.rate_review_outlined,
                                size: 64,
                                color: subTextColor.withOpacity(0.5)),
                            const SizedBox(height: 16),
                            Text('No reviews yet',
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: textColor)),
                            const SizedBox(height: 6),
                            Text(
                                'Be the first to share your experience.',
                                style: TextStyle(
                                    fontSize: 12, color: subTextColor),
                                textAlign: TextAlign.center),
                            const SizedBox(height: 20),
                            ElevatedButton.icon(
                              onPressed: _handleAddReview,
                              icon: const Icon(Icons.edit,
                                  size: 16, color: Colors.white),
                              label: const Text('Add Review',
                                  style: TextStyle(color: Colors.white)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _orange,
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                    BorderRadius.circular(10)),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final avg = (state as ReviewLoaded).averageRating;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header card
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Text('${reviews.length} Reviews',
                                    style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: textColor)),
                                const SizedBox(height: 4),
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
                                        color:
                                        const Color(0xFFFFC44D),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      avg.toStringAsFixed(1),
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: subTextColor),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            ElevatedButton.icon(
                              onPressed: _handleAddReview,
                              icon: const Icon(Icons.edit,
                                  size: 16, color: Colors.white),
                              label: const Text('Add Review',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 13)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _orange,
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                    BorderRadius.circular(10)),
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 10),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Reviews list
                      Expanded(
                        child: ListView.separated(
                          padding: const EdgeInsets.fromLTRB(
                              20, 0, 20, 20),
                          itemCount: reviews.length,
                          separatorBuilder: (_, __) =>
                          const SizedBox(height: 20),
                          itemBuilder: (_, i) => _ReviewTile(
                            review: reviews[i],
                            isDarkMode: isDark,
                          ),
                        ),
                      ),
                    ],
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

class _ReviewTile extends StatelessWidget {
  final ReviewModel review;
  final bool isDarkMode;

  const _ReviewTile({required this.review, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    final textColor = isDarkMode ? Colors.white : const Color(0xFF1B262C);
    final subTextColor =
    isDarkMode ? Colors.white70 : const Color(0xFF6B6B6B);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CircleAvatar(
          radius: 20,
          backgroundColor: Color(0xFFE0E0E0),
          child: Icon(Icons.person, color: Colors.white, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(review.name,
                      style: TextStyle(
                          fontSize: 14,
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
              Row(
                children: [
                  Icon(Icons.access_time,
                      size: 12, color: subTextColor),
                  const SizedBox(width: 4),
                  Text(_formatDate(review.createdAt),
                      style: TextStyle(
                          fontSize: 11, color: subTextColor)),
                ],
              ),
              const SizedBox(height: 6),
              Text(review.text,
                  style: TextStyle(
                      fontSize: 12,
                      height: 1.5,
                      color: subTextColor)),
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