import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/review_model.dart';
import '../../data/repositories/review_repository.dart';
import 'review_event.dart';
import 'review_state.dart';

class _ReviewsReceived extends ReviewEvent {
  final List<ReviewModel> reviews;
  const _ReviewsReceived(this.reviews);
}

class _ReviewStreamError extends ReviewEvent {
  final String message;
  const _ReviewStreamError(this.message);
}

class ReviewBloc extends Bloc<ReviewEvent, ReviewState> {
  final ReviewRepository _repo;
  StreamSubscription<List<ReviewModel>>? _sub;

  ReviewBloc({required ReviewRepository repository})
      : _repo = repository,
        super(const ReviewInitial()) {
    on<ReviewsSubscribed>(_onSub);
    on<ReviewSubmitRequested>(_onSubmit);
    on<_ReviewsReceived>(_onReceived);
    on<_ReviewStreamError>(_onStreamError);
  }

  Future<void> _onSub(
      ReviewsSubscribed e, Emitter<ReviewState> emit) async {
    emit(const ReviewLoading());
    await _sub?.cancel();
    _sub = _repo.stream(e.productId).listen(
          (reviews) => add(_ReviewsReceived(reviews)),
      onError: (err) => add(_ReviewStreamError(err.toString())),
    );
  }

  void _onReceived(_ReviewsReceived e, Emitter<ReviewState> emit) {
    emit(ReviewLoaded(e.reviews));
  }

  void _onStreamError(_ReviewStreamError e, Emitter<ReviewState> emit) {
    emit(ReviewError(e.message));
  }

  Future<void> _onSubmit(
      ReviewSubmitRequested e, Emitter<ReviewState> emit) async {
    try {
      await _repo.addReview(
        productId: e.productId,
        uid: e.uid,
        name: e.name,
        text: e.text,
        rating: e.rating,
      );
    } catch (err) {
      emit(ReviewError('Submit failed: $err'));
    }
  }

  @override
  Future<void> close() async {
    await _sub?.cancel();
    return super.close();
  }
}