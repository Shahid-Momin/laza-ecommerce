import 'package:cloud_firestore/cloud_firestore.dart';

class CartItemModel {
  final int productId;
  final String title;
  final double price;
  final String thumbnail;
  final String brand;
  int quantity;

  CartItemModel({
    required this.productId,
    required this.title,
    required this.price,
    required this.thumbnail,
    this.brand = '',
    this.quantity = 1,
  });

  double get subtotal => price * quantity;

  factory CartItemModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return CartItemModel(
      productId: d['productId'] ?? 0,
      title: d['title'] ?? '',
      price: (d['price'] ?? 0).toDouble(),
      thumbnail: d['thumbnail'] ?? '',
      brand: d['brand'] ?? '',
      quantity: d['quantity'] ?? 1,
    );
  }

  Map<String, dynamic> toFirestore() => {
    'productId': productId,
    'title': title,
    'price': price,
    'thumbnail': thumbnail,
    'brand': brand,
    'quantity': quantity,
  };

  CartItemModel copyWith({int? quantity}) => CartItemModel(
    productId: productId,
    title: title,
    price: price,
    thumbnail: thumbnail,
    brand: brand,
    quantity: quantity ?? this.quantity,
  );
}