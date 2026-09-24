import 'package:equatable/equatable.dart';
import '../../data/models/order_model.dart';

abstract class OrderEvent extends Equatable {
  const OrderEvent();
  @override
  List<Object?> get props => [];
}

class OrdersSubscribed extends OrderEvent {
  final String uid;
  const OrdersSubscribed(this.uid);
  @override
  List<Object?> get props => [uid];
}

class OrderPlaceRequested extends OrderEvent {
  final String uid;
  final OrderModel order;
  const OrderPlaceRequested(this.uid, this.order);
  @override
  List<Object?> get props => [uid];
}