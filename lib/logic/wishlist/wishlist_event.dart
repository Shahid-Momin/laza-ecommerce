import 'package:equatable/equatable.dart';
import '../../data/models/product_model.dart';

abstract class WishlistEvent extends Equatable {
  const WishlistEvent();
  @override
  List<Object?> get props => [];
}

class WishlistSubscribed extends WishlistEvent {
  final String uid;
  const WishlistSubscribed(this.uid);
  @override
  List<Object?> get props => [uid];
}

class WishlistAddRequested extends WishlistEvent {
  final String uid;
  final ProductModel product;
  const WishlistAddRequested(this.uid, this.product);
  @override
  List<Object?> get props => [uid, product.id];
}

class WishlistRemoveRequested extends WishlistEvent {
  final String uid;
  final int productId;
  const WishlistRemoveRequested(this.uid, this.productId);
  @override
  List<Object?> get props => [uid, productId];
}