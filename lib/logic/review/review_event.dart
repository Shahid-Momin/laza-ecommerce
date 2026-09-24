import 'package:equatable/equatable.dart';

abstract class ReviewEvent extends Equatable {
  const ReviewEvent();
  @override
  List<Object?> get props => [];
}

class ReviewsSubscribed extends ReviewEvent {
  final int productId;
  const ReviewsSubscribed(this.productId);
  @override
  List<Object?> get props => [productId];
}

class ReviewSubmitRequested extends ReviewEvent {
  final int productId;
  final String uid;
  final String name;
  final String text;
  final double rating;

  const ReviewSubmitRequested({
    required this.productId,
    required this.uid,
    required this.name,
    required this.text,
    required this.rating,
  });

  @override
  List<Object?> get props => [productId, uid, name, text, rating];
}