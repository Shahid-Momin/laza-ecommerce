import 'package:equatable/equatable.dart';
import '../../data/models/product_model.dart';

abstract class CartEvent extends Equatable {
  const CartEvent();
  @override
  List<Object?> get props => [];
}

class CartSubscribed extends CartEvent {
  final String uid;
  const CartSubscribed(this.uid);
  @override
  List<Object?> get props => [uid];
}

class CartAddRequested extends CartEvent {
  final String uid;
  final ProductModel product;
  final int quantity;
  const CartAddRequested(this.uid, this.product, {this.quantity = 1});
  @override
  List<Object?> get props => [uid, product.id, quantity];
}

class CartUpdateQtyRequested extends CartEvent {
  final String uid;
  final int productId;
  final int quantity;
  const CartUpdateQtyRequested(this.uid, this.productId, this.quantity);
  @override
  List<Object?> get props => [uid, productId, quantity];
}

class CartRemoveRequested extends CartEvent {
  final String uid;
  final int productId;
  const CartRemoveRequested(this.uid, this.productId);
  @override
  List<Object?> get props => [uid, productId];
}

class CartClearRequested extends CartEvent {
  final String uid;
  const CartClearRequested(this.uid);
  @override
  List<Object?> get props => [uid];
}