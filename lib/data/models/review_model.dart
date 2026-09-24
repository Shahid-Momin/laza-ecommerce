import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewModel {
  final String reviewId;
  final int productId;
  final String name;
  final String text;
  final double rating;
  final DateTime createdAt;
  final String uid;

  ReviewModel({
    required this.reviewId,
    required this.productId,
    required this.name,
    required this.text,
    required this.rating,
    required this.createdAt,
    required this.uid,
  });

  factory ReviewModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return ReviewModel(
      reviewId: doc.id,
      productId: d['productId'] ?? 0,
      name: d['name'] ?? '',
      text: d['text'] ?? '',
      rating: (d['rating'] ?? 0).toDouble(),
      createdAt: d['createdAt'] != null
          ? (d['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      uid: d['uid'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() => {
    'productId': productId,
    'name': name,
    'text': text,
    'rating': rating,
    'uid': uid,
    'createdAt': Timestamp.fromDate(createdAt),
  };
}