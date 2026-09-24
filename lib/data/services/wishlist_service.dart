import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';
import '../models/wishlist_item_model.dart';

class WishlistService {
  final FirebaseFirestore _fs = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _col(String uid) =>
      _fs.collection('users').doc(uid).collection('wishlist');

  Future<void> add(String uid, ProductModel p) async {
    await _col(uid).doc(p.id.toString()).set({
      ...p.toFirestore(),
      'addedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> remove(String uid, int productId) async {
    await _col(uid).doc(productId.toString()).delete();
  }

  Stream<List<WishlistItemModel>> stream(String uid) {
    return _col(uid)
        .orderBy('addedAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map(WishlistItemModel.fromFirestore).toList());
  }

  Future<bool> contains(String uid, int productId) async {
    final d = await _col(uid).doc(productId.toString()).get();
    return d.exists;
  }
}