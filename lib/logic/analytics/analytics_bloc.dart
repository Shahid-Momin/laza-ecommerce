import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/analytics_model.dart';
import '../../data/models/cart_item_model.dart';
import '../../data/models/order_model.dart';
import '../../data/models/review_model.dart';
import '../../data/models/wishlist_item_model.dart';
import 'analytics_event.dart';
import 'analytics_state.dart';

class AnalyticsBloc extends Bloc<AnalyticsEvent, AnalyticsState> {
  AnalyticsBloc() : super(const AnalyticsInitial()) {
    on<AnalyticsRefreshRequested>(_onRefresh);
  }

  void _onRefresh(
      AnalyticsRefreshRequested event,
      Emitter<AnalyticsState> emit,
      ) {
  }

  /// Compute analytics from already-loaded collections.
  AnalyticsModel build({
    required List<OrderModel> orders,
    required List<WishlistItemModel> wishlist,
    required List<CartItemModel> cart,
    required List<ReviewModel> reviews,
  }) {
    return AnalyticsModel.fromData(
      orders: orders,
      wishlist: wishlist,
      cart: cart,
      reviews: reviews,
    );
  }
}