import '../models/order_model.dart';
import '../models/wishlist_item_model.dart';
import '../models/cart_item_model.dart';
import '../models/review_model.dart';

class AnalyticsModel {
  final int totalOrders;
  final int totalWishlistItems;
  final int totalCartItems;
  final int totalReviews;
  final double totalSpent;
  final double avgOrderValue;

  /// Order totals per last 7 days (index 0 = 6 days ago, index 6 = today).
  final List<double> salesLast7Days;
  final List<String> salesLast7DayLabels;

  /// Count per order status.
  final Map<String, int> orderStatusBreakdown;

  /// Top products by order frequency: {productTitle: count}
  final Map<String, int> topProducts;

  /// Orders grouped by weekday (Mon..Sun).
  final List<int> ordersByWeekday;

  /// Latest 5 events.
  final List<ActivityEvent> recentActivity;

  AnalyticsModel({
    required this.totalOrders,
    required this.totalWishlistItems,
    required this.totalCartItems,
    required this.totalReviews,
    required this.totalSpent,
    required this.avgOrderValue,
    required this.salesLast7Days,
    required this.salesLast7DayLabels,
    required this.orderStatusBreakdown,
    required this.topProducts,
    required this.ordersByWeekday,
    required this.recentActivity,
  });

  /// Compute analytics from raw Firestore streams.
  factory AnalyticsModel.fromData({
    required List<OrderModel> orders,
    required List<WishlistItemModel> wishlist,
    required List<CartItemModel> cart,
    required List<ReviewModel> reviews,
  }) {
    // ─── Totals ───
    final totalSpent =
    orders.fold<double>(0, (s, o) => s + o.totalAmount);
    final avgOrderValue =
    orders.isEmpty ? 0.0 : totalSpent / orders.length;

    // ─── Sales last 7 days ───
    final now = DateTime.now();
    final List<double> sales = List.filled(7, 0);
    final List<String> labels = [];

    for (int i = 6; i >= 0; i--) {
      final day = DateTime(now.year, now.month, now.day)
          .subtract(Duration(days: i));
      labels.add(_shortDay(day));

      for (final o in orders) {
        final oDay = DateTime(
            o.createdAt.year, o.createdAt.month, o.createdAt.day);
        if (oDay == day) {
          sales[6 - i] += o.totalAmount;
        }
      }
    }

    // ─── Order status breakdown ───
    final Map<String, int> statusBreakdown = {};
    for (final o in orders) {
      statusBreakdown[o.status] =
          (statusBreakdown[o.status] ?? 0) + 1;
    }

    // ─── Top products ───
    final Map<String, int> topProducts = {};
    for (final o in orders) {
      for (final item in o.items) {
        topProducts[item.title] =
            (topProducts[item.title] ?? 0) + item.quantity;
      }
    }
    // Keep only top 5 sorted desc
    final sortedTop = topProducts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topProductsTrimmed = {
      for (final e in sortedTop.take(5)) e.key: e.value
    };

    // ─── Orders by weekday (Mon..Sun) ───
    final List<int> weekday = List.filled(7, 0);
    for (final o in orders) {
      // DateTime.weekday: Mon=1..Sun=7 → map to 0..6
      weekday[o.createdAt.weekday - 1] += 1;
    }

    // ─── Recent activity ───
    final List<ActivityEvent> activity = [];

    for (final o in orders.take(5)) {
      activity.add(ActivityEvent(
        title: 'Placed order #${o.orderId.substring(0, 6)}',
        subtitle: '\$${o.totalAmount.toStringAsFixed(2)}',
        timestamp: o.createdAt,
        icon: 'order',
      ));
    }
    for (final w in wishlist.take(3)) {
      activity.add(ActivityEvent(
        title: 'Saved "${w.title}" to wishlist',
        subtitle: '\$${w.price.toStringAsFixed(2)}',
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
        icon: 'wishlist',
      ));
    }
    for (final r in reviews.take(3)) {
      activity.add(ActivityEvent(
        title: 'Reviewed "${r.name}"',
        subtitle: '${r.rating} stars',
        timestamp: r.createdAt,
        icon: 'review',
      ));
    }
    activity.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return AnalyticsModel(
      totalOrders: orders.length,
      totalWishlistItems: wishlist.length,
      totalCartItems: cart.length,
      totalReviews: reviews.length,
      totalSpent: totalSpent,
      avgOrderValue: avgOrderValue,
      salesLast7Days: sales,
      salesLast7DayLabels: labels,
      orderStatusBreakdown: statusBreakdown,
      topProducts: topProductsTrimmed,
      ordersByWeekday: weekday,
      recentActivity: activity.take(5).toList(),
    );
  }

  static String _shortDay(DateTime d) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[d.weekday - 1];
  }
}

class ActivityEvent {
  final String title;
  final String subtitle;
  final DateTime timestamp;
  final String icon; // "order" | "wishlist" | "review"

  ActivityEvent({
    required this.title,
    required this.subtitle,
    required this.timestamp,
    required this.icon,
  });
}