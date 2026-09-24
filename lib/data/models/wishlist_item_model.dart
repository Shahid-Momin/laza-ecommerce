import 'package:cloud_firestore/cloud_firestore.dart';

class WishlistItemModel {
  final int productId;
  final String title;
  final double price;
  final String thumbnail;
  final String brand;
  final double rating;

  const WishlistItemModel({
    required this.productId,
    required this.title,
    required this.price,
    required this.thumbnail,
    this.brand = '',
    this.rating = 0,
  });

  factory WishlistItemModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return WishlistItemModel(
      productId: d['productId'] ?? 0,
      title: d['title'] ?? '',
      price: (d['price'] ?? 0).toDouble(),
      thumbnail: d['thumbnail'] ?? '',
      brand: d['brand'] ?? '',
      rating: (d['rating'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'productId': productId,
    'title': title,
    'price': price,
    'thumbnail': thumbnail,
    'brand': brand,
    'rating': rating,
  };
}