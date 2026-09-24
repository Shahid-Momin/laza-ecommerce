import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/cart_item_model.dart';
import '../models/product_model.dart';

class CartService {
  final FirebaseFirestore _fs = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _col(String uid) =>
      _fs.collection('users').doc(uid).collection('cart');

  Future<void> addProduct(String uid, ProductModel p, {int qty = 1}) async {
    final ref = _col(uid).doc(p.id.toString());
    final doc = await ref.get();
    if (doc.exists) {
      final current = doc.data()?['quantity'] ?? 1;
      await ref.update({'quantity': current + qty});
    } else {
      await ref.set({
        'productId': p.id,
        'title': p.title,
        'price': p.price,
        'thumbnail': p.thumbnail,
        'brand': p.brand,
        'quantity': qty,
        'addedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<void> updateQuantity(String uid, int productId, int qty) async {
    if (qty <= 0) {
      await _col(uid).doc(productId.toString()).delete();
    } else {
      await _col(uid).doc(productId.toString()).update({'quantity': qty});
    }
  }

  Future<void> remove(String uid, int productId) async {
    await _col(uid).doc(productId.toString()).delete();
  }

  Future<void> clear(String uid) async {
    final snap = await _col(uid).get();
    final batch = _fs.batch();
    for (final d in snap.docs) {
      batch.delete(d.reference);
    }
    await batch.commit();
  }

  Stream<List<CartItemModel>> stream(String uid) {
    return _col(uid)
        .orderBy('addedAt', descending: false)
        .snapshots()
        .map((s) => s.docs.map(CartItemModel.fromFirestore).toList());
  }
}