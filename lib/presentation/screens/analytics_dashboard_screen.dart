import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/analytics_model.dart';
import '../../data/models/cart_item_model.dart';
import '../../data/models/order_model.dart';
import '../../data/models/review_model.dart';
import '../../data/models/wishlist_item_model.dart';
import '../../logic/cart/cart_bloc.dart';
import '../../logic/cart/cart_state.dart';
import '../../logic/order/order_bloc.dart';
import '../../logic/order/order_state.dart';
import '../../logic/review/review_bloc.dart';
import '../../logic/review/review_state.dart';
import '../../logic/theme/theme_bloc.dart';
import '../../logic/wishlist/wishlist_bloc.dart';
import '../../logic/wishlist/wishlist_state.dart';

class AnalyticsDashboardScreen extends StatefulWidget {
  final bool isDarkMode;
  const AnalyticsDashboardScreen({super.key, this.isDarkMode = false});

  @override
  State<AnalyticsDashboardScreen> createState() =>
      _AnalyticsDashboardScreenState();
}

class _AnalyticsDashboardScreenState
    extends State<AnalyticsDashboardScreen> {
  static const Color _purple = Color(0xFF9775FA);
  static const Color _orange = Color(0xFFFF7A45);
  static const Color _amber = Color(0xFFFFC44D);
  static const Color _green = Color(0xFF4CAF50);
  static const Color _red = Color(0xFFE84C4C);
  static const Color _blue = Color(0xFF1DA1F2);

  bool _showDonut = true;

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeBloc>().state.isDark;
    final bg = isDark ? const Color(0xFF1B262C) : Colors.white;
    final cardBg =
    isDark ? const Color(0xFF25333A) : const Color(0xFFF7F7F7);
    final textColor = isDark ? Colors.white : const Color(0xFF1B262C);
    final subTextColor = isDark ? Colors.white70 : const Color(0xFF6B6B6B);
    final iconBg =
    isDark ? Colors.white.withOpacity(0.08) : const Color(0xFFF2F2F2);


    final orders = _orders(context);
    final wishlist = _wishlist(context);
    final cart = _cart(context);
    final reviews = _reviews(context);

    final data = AnalyticsModel.fromData(
      orders: orders,
      wishlist: wishlist,
      cart: cart,
      reviews: reviews,
    );

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            // ─── Header ───
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
                          color: iconBg, shape: BoxShape.circle),
                      child: Icon(Icons.arrow_back,
                          color: textColor, size: 20),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text('Analytics',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: textColor)),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: _purple.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Live',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: _purple),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                children: [
                  // ─── KPI cards ───
                  _sectionTitle('Overview', textColor),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _kpiCard(
                          label: 'Orders',
                          value: '${data.totalOrders}',
                          icon: Icons.shopping_bag_outlined,
                          color: _purple,
                          isDark: isDark,
                          textColor: textColor,
                          subTextColor: subTextColor,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _kpiCard(
                          label: 'Spent',
                          value: '\$${data.totalSpent.toStringAsFixed(0)}',
                          icon: Icons.attach_money,
                          color: _green,
                          isDark: isDark,
                          textColor: textColor,
                          subTextColor: subTextColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _kpiCard(
                          label: 'Wishlist',
                          value: '${data.totalWishlistItems}',
                          icon: Icons.favorite_border,
                          color: _red,
                          isDark: isDark,
                          textColor: textColor,
                          subTextColor: subTextColor,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _kpiCard(
                          label: 'Cart',
                          value: '${data.totalCartItems}',
                          icon: Icons.shopping_cart_outlined,
                          color: _blue,
                          isDark: isDark,
                          textColor: textColor,
                          subTextColor: subTextColor,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // ─── Sales Trend (line chart) ───
                  _sectionTitle('Sales – Last 7 Days', textColor),
                  const SizedBox(height: 12),
                  _chartCard(
                    height: 220,
                    isDark: isDark,
                    cardBg: cardBg,
                    child: _salesLineChart(
                      data: data,
                      textColor: textColor,
                      subTextColor: subTextColor,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ─── Order status pie / donut ───
                  _sectionTitle('Order Status', textColor),
                  const SizedBox(height: 12),
                  _chartCard(
                    height: 240,
                    isDark: isDark,
                    cardBg: cardBg,
                    child: data.orderStatusBreakdown.isEmpty
                        ? _emptyChartState(subTextColor)
                        : Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: PieChart(
                            PieChartData(
                              sectionsSpace: 3,
                              centerSpaceRadius:
                              _showDonut ? 40 : 0,
                              sections: _pieSections(data),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: _pieLegend(
                            data: data,
                            textColor: textColor,
                            subTextColor: subTextColor,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ─── Top products (horizontal bar) ───
                  _sectionTitle('Top Products', textColor),
                  const SizedBox(height: 12),
                  _chartCard(
                    height: 240,
                    isDark: isDark,
                    cardBg: cardBg,
                    child: data.topProducts.isEmpty
                        ? _emptyChartState(subTextColor)
                        : _topProductsChart(
                      data: data,
                      textColor: textColor,
                      subTextColor: subTextColor,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ─── Orders by weekday ───
                  _sectionTitle('Activity by Day', textColor),
                  const SizedBox(height: 12),
                  _chartCard(
                    height: 200,
                    isDark: isDark,
                    cardBg: cardBg,
                    child: _weekdayBarChart(
                      data: data,
                      textColor: textColor,
                      subTextColor: subTextColor,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ─── Recent activity ───
                  _sectionTitle('Recent Activity', textColor),
                  const SizedBox(height: 12),
                  if (data.recentActivity.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text('No recent activity yet',
                          style: TextStyle(
                              fontSize: 13, color: subTextColor)),
                    )
                  else
                    ...data.recentActivity.map((e) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _activityTile(
                        event: e,
                        isDark: isDark,
                        textColor: textColor,
                        subTextColor: subTextColor,
                      ),
                    )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Data helpers — read live BLoC states
  List<OrderModel> _orders(BuildContext c) {
    final s = c.watch<OrderBloc>().state;
    return s is OrderLoaded ? s.orders : [];
  }

  List<WishlistItemModel> _wishlist(BuildContext c) {
    final s = c.watch<WishlistBloc>().state;
    return s is WishlistLoaded ? s.items : [];
  }

  List<CartItemModel> _cart(BuildContext c) {
    final s = c.watch<CartBloc>().state;
    return s is CartLoaded ? s.items : [];
  }

  List<ReviewModel> _reviews(BuildContext c) {
    final s = c.watch<ReviewBloc>().state;
    return s is ReviewLoaded ? s.reviews : [];
  }


  // UI helpers
  Widget _sectionTitle(String title, Color textColor) => Text(
    title,
    style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: textColor),
  );

  Widget _chartCard({
    required double height,
    required bool isDark,
    required Color cardBg,
    required Widget child,
  }) =>
      Container(
        height: height,
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
        ),
        child: child,
      );

  Widget _emptyChartState(Color subTextColor) => Center(
    child: Text('Not enough data yet',
        style: TextStyle(fontSize: 12, color: subTextColor)),
  );

  Widget _kpiCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
    required bool isDark,
    required Color textColor,
    required Color subTextColor,
  }) =>
      Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF25333A) : const Color(0xFFF7F7F7),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(height: 10),
            Text(value,
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: textColor)),
            const SizedBox(height: 2),
            Text(label,
                style: TextStyle(fontSize: 12, color: subTextColor)),
          ],
        ),
      );

  // Sales line chart
  Widget _salesLineChart({
    required AnalyticsModel data,
    required Color textColor,
    required Color subTextColor,
  }) {
    final maxY = (data.salesLast7Days.isEmpty
        ? 100
        : data.salesLast7Days.reduce((a, b) => a > b ? a : b)) *
        1.2;

    return LineChart(
      LineChartData(
        minY: 0,
        maxY: maxY == 0 ? 100 : maxY,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: (maxY == 0 ? 100 : maxY) / 4,
          getDrawingHorizontalLine: (value) => FlLine(
            color: textColor.withOpacity(0.06),
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              interval: (maxY == 0 ? 100 : maxY) / 4,
              getTitlesWidget: (v, _) => Text(
                '\$${v.toStringAsFixed(0)}',
                style: TextStyle(fontSize: 10, color: subTextColor),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              getTitlesWidget: (v, _) {
                final i = v.toInt();
                if (i < 0 || i >= data.salesLast7DayLabels.length) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    data.salesLast7DayLabels[i],
                    style: TextStyle(fontSize: 10, color: subTextColor),
                  ),
                );
              },
            ),
          ),
          rightTitles: const AxisTitles(),
          topTitles: const AxisTitles(),
        ),
        lineBarsData: [
          LineChartBarData(
            isCurved: true,
            color: _purple,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(
                radius: 4,
                color: _purple,
                strokeWidth: 2,
                strokeColor: Colors.white,
              ),
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  _purple.withOpacity(0.3),
                  _purple.withOpacity(0.0),
                ],
              ),
            ),
            spots: List.generate(
              data.salesLast7Days.length,
                  (i) => FlSpot(i.toDouble(), data.salesLast7Days[i]),
            ),
          ),
        ],
      ),
    );
  }

  // Pie / donut chart sections
  List<PieChartSectionData> _pieSections(AnalyticsModel data) {
    final colors = [_purple, _orange, _green, _blue, _amber, _red];
    final entries = data.orderStatusBreakdown.entries.toList();
    final total = entries.fold<int>(0, (s, e) => s + e.value);

    return List.generate(entries.length, (i) {
      final percent = (entries[i].value / total * 100).toStringAsFixed(0);
      return PieChartSectionData(
        color: colors[i % colors.length],
        value: entries[i].value.toDouble(),
        title: '$percent%',
        radius: 60,
        titleStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      );
    });
  }

  Widget _pieLegend({
    required AnalyticsModel data,
    required Color textColor,
    required Color subTextColor,
  }) {
    final colors = [_purple, _orange, _green, _blue, _amber, _red];
    final entries = data.orderStatusBreakdown.entries.toList();

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(entries.length, (i) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: colors[i % colors.length],
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  '${entries[i].key} (${entries[i].value})',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: textColor),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  // Top products bar chart
  Widget _topProductsChart({
    required AnalyticsModel data,
    required Color textColor,
    required Color subTextColor,
  }) {
    final entries = data.topProducts.entries.toList();
    final maxVal =
    entries.map((e) => e.value).reduce((a, b) => a > b ? a : b);

    return Column(
      children: List.generate(entries.length, (i) {
        final e = entries[i];
        final fraction = maxVal == 0 ? 0.0 : e.value / maxVal;

        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        e.key,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: textColor),
                      ),
                    ),
                    Text('${e.value}',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: _purple)),
                  ],
                ),
                const SizedBox(height: 4),
                Stack(
                  children: [
                    Container(
                      height: 6,
                      decoration: BoxDecoration(
                        color: textColor.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: fraction.toDouble(),
                      child: Container(
                        height: 6,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [_purple, _blue],
                          ),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  // Weekday bar chart
  Widget _weekdayBarChart({
    required AnalyticsModel data,
    required Color textColor,
    required Color subTextColor,
  }) {
    const labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final values = data.ordersByWeekday;
    final maxVal = values.isEmpty
        ? 1
        : values.reduce((a, b) => a > b ? a : b);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(7, (i) {
        final v = values[i];
        final factor = maxVal == 0 ? 0.0 : v / maxVal;

        return Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text('$v',
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: v > 0 ? _purple : subTextColor)),
              const SizedBox(height: 4),
              FractionallySizedBox(
                heightFactor: factor == 0 ? 0.04 : factor.toDouble(),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        _purple,
                        _purple.withOpacity(0.5),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(labels[i],
                  style: TextStyle(fontSize: 10, color: subTextColor)),
            ],
          ),
        );
      }),
    );
  }

  // Recent activity tile
  Widget _activityTile({
    required ActivityEvent event,
    required bool isDark,
    required Color textColor,
    required Color subTextColor,
  }) {
    IconData icon;
    Color color;
    switch (event.icon) {
      case 'order':
        icon = Icons.shopping_bag_outlined;
        color = _purple;
        break;
      case 'wishlist':
        icon = Icons.favorite_border;
        color = _red;
        break;
      case 'review':
        icon = Icons.rate_review_outlined;
        color = _amber;
        break;
      default:
        icon = Icons.circle;
        color = _blue;
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF25333A) : const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(event.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: textColor)),
                const SizedBox(height: 2),
                Text(event.subtitle,
                    style: TextStyle(
                        fontSize: 11, color: subTextColor)),
              ],
            ),
          ),
          Text(
            _timeAgo(event.timestamp),
            style: TextStyle(fontSize: 10, color: subTextColor),
          ),
        ],
      ),
    );
  }

  String _timeAgo(DateTime t) {
    final diff = DateTime.now().difference(t);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    return '${diff.inDays}d';
  }
}