import 'package:cloud_firestore/cloud_firestore.dart';

class OrderItem {
  final int productId;
  final String title;
  final double price;
  final int quantity;
  final String thumbnail;

  OrderItem({
    required this.productId,
    required this.title,
    required this.price,
    required this.quantity,
    required this.thumbnail,
  });

  factory OrderItem.fromMap(Map<String, dynamic> m) => OrderItem(
    productId: m['productId'] ?? 0,
    title: m['title'] ?? '',
    price: (m['price'] ?? 0).toDouble(),
    quantity: m['quantity'] ?? 1,
    thumbnail: m['thumbnail'] ?? '',
  );

  Map<String, dynamic> toMap() => {
    'productId': productId,
    'title': title,
    'price': price,
    'quantity': quantity,
    'thumbnail': thumbnail,
  };
}

class OrderModel {
  final String orderId;
  final List<OrderItem> items;
  final double totalAmount;
  final String status;
  final String deliveryAddress;
  final String paymentMethod;
  final DateTime createdAt;

  OrderModel({
    required this.orderId,
    required this.items,
    required this.totalAmount,
    this.status = 'pending',
    required this.deliveryAddress,
    required this.paymentMethod,
    required this.createdAt,
  });

  factory OrderModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return OrderModel(
      orderId: doc.id,
      items: (d['items'] as List<dynamic>? ?? [])
          .map((i) => OrderItem.fromMap(i as Map<String, dynamic>))
          .toList(),
      totalAmount: (d['totalAmount'] ?? 0).toDouble(),
      status: d['status'] ?? 'pending',
      deliveryAddress: d['deliveryAddress'] ?? '',
      paymentMethod: d['paymentMethod'] ?? '',
      createdAt: d['createdAt'] != null
          ? (d['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'items': items.map((i) => i.toMap()).toList(),
    'totalAmount': totalAmount,
    'status': status,
    'deliveryAddress': deliveryAddress,
    'paymentMethod': paymentMethod,
    'createdAt': Timestamp.fromDate(createdAt),
  };
}