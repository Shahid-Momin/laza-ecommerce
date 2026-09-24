import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/review_model.dart';

class ReviewService {
  final FirebaseFirestore _fs = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _col(int productId) => _fs
      .collection('products')
      .doc(productId.toString())
      .collection('reviews');

  Future<void> addReview({
    required int productId,
    required String uid,
    required String name,
    required String text,
    required double rating,
  }) async {
    await _col(productId).add({
      'productId': productId,
      'uid': uid,
      'name': name,
      'text': text,
      'rating': rating,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<ReviewModel>> stream(int productId) {
    return _col(productId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map(ReviewModel.fromFirestore).toList());
  }
}