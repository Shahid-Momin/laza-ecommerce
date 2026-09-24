import '../models/cart_item_model.dart';
import '../models/product_model.dart';
import '../services/cart_service.dart';

class CartRepository {
  final CartService _svc;
  CartRepository({CartService? service}) : _svc = service ?? CartService();

  Future<void> add(String uid, ProductModel p, {int qty = 1}) =>
      _svc.addProduct(uid, p, qty: qty);

  Future<void> updateQty(String uid, int pid, int qty) =>
      _svc.updateQuantity(uid, pid, qty);

  Future<void> remove(String uid, int pid) => _svc.remove(uid, pid);
  Future<void> clear(String uid) => _svc.clear(uid);
  Stream<List<CartItemModel>> stream(String uid) => _svc.stream(uid);
}