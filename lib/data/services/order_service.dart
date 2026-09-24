import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/order_model.dart';

class OrderService {
  final FirebaseFirestore _fs = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _col(String uid) =>
      _fs.collection('users').doc(uid).collection('orders');

  Future<String> placeOrder(String uid, OrderModel order) async {
    final ref = await _col(uid).add(order.toFirestore());
    return ref.id;
  }

  Stream<List<OrderModel>> stream(String uid) {
    return _col(uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map(OrderModel.fromFirestore).toList());
  }
}