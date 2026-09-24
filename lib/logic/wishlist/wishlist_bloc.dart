import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/wishlist_item_model.dart';
import '../../data/repositories/wishlist_repository.dart';
import 'wishlist_event.dart';
import 'wishlist_state.dart';

/// Internal events — dispatched from the Firestore stream listener
/// so emit goes through the BLoC's event pipeline (not the closed emitter).
class _WishlistItemsReceived extends WishlistEvent {
  final List<WishlistItemModel> items;
  const _WishlistItemsReceived(this.items);
  @override
  List<Object?> get props => [items];
}

class _WishlistStreamError extends WishlistEvent {
  final String message;
  const _WishlistStreamError(this.message);
  @override
  List<Object?> get props => [message];
}

class WishlistBloc extends Bloc<WishlistEvent, WishlistState> {
  final WishlistRepository _repo;
  StreamSubscription<List<WishlistItemModel>>? _sub;

  WishlistBloc({required WishlistRepository repository})
      : _repo = repository,
        super(const WishlistInitial()) {
    on<WishlistSubscribed>(_onSub);
    on<WishlistAddRequested>(_onAdd);
    on<WishlistRemoveRequested>(_onRemove);
    on<_WishlistItemsReceived>(_onItems);
    on<_WishlistStreamError>(_onStreamError);
  }

  Future<void> _onSub(
      WishlistSubscribed e,
      Emitter<WishlistState> emit,
      ) async {
    emit(const WishlistLoading());
    await _sub?.cancel();

    // Dispatch events instead of emitting directly from the stream.
    _sub = _repo.stream(e.uid).listen(
          (items) => add(_WishlistItemsReceived(items)),
      onError: (err) => add(_WishlistStreamError(err.toString())),
    );
  }

  void _onItems(_WishlistItemsReceived e, Emitter<WishlistState> emit) {
    emit(WishlistLoaded(e.items));
  }

  void _onStreamError(_WishlistStreamError e, Emitter<WishlistState> emit) {
    emit(WishlistError(e.message));
  }

  Future<void> _onAdd(
      WishlistAddRequested e,
      Emitter<WishlistState> emit,
      ) async {
    try {
      await _repo.add(e.uid, e.product);
    } catch (err) {
      emit(WishlistError('Add failed: $err'));
    }
  }

  Future<void> _onRemove(
      WishlistRemoveRequested e,
      Emitter<WishlistState> emit,
      ) async {
    try {
      await _repo.remove(e.uid, e.productId);
    } catch (err) {
      emit(WishlistError('Remove failed: $err'));
    }
  }

  @override
  Future<void> close() async {
    await _sub?.cancel();
    return super.close();
  }
}