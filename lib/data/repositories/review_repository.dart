import '../models/review_model.dart';
import '../services/review_service.dart';

class ReviewRepository {
  final ReviewService _svc;
  ReviewRepository({ReviewService? service})
      : _svc = service ?? ReviewService();

  Future<void> addReview({
    required int productId,
    required String uid,
    required String name,
    required String text,
    required double rating,
  }) {
    return _svc.addReview(
      productId: productId,
      uid: uid,
      name: name,
      text: text,
      rating: rating,
    );
  }

  Stream<List<ReviewModel>> stream(int productId) =>
      _svc.stream(productId);
}