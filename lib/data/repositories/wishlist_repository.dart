import '../models/product_model.dart';
import '../models/wishlist_item_model.dart';
import '../services/wishlist_service.dart';

class WishlistRepository {
  final WishlistService _svc;
  WishlistRepository({WishlistService? service})
      : _svc = service ?? WishlistService();

  Future<void> add(String uid, ProductModel p) => _svc.add(uid, p);
  Future<void> remove(String uid, int pid) => _svc.remove(uid, pid);
  Stream<List<WishlistItemModel>> stream(String uid) => _svc.stream(uid);
  Future<bool> contains(String uid, int pid) => _svc.contains(uid, pid);
}