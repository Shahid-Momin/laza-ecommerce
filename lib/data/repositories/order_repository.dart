import '../models/order_model.dart';
import '../services/order_service.dart';

class OrderRepository {
  final OrderService _svc;
  OrderRepository({OrderService? service}) : _svc = service ?? OrderService();

  Future<String> placeOrder(String uid, OrderModel order) =>
      _svc.placeOrder(uid, order);

  Stream<List<OrderModel>> stream(String uid) => _svc.stream(uid);
}