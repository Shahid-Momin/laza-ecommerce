import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/cart_item_model.dart';
import '../../data/repositories/cart_repository.dart';
import 'cart_event.dart';
import 'cart_state.dart';

class _CartItemsReceived extends CartEvent {
  final List<CartItemModel> items;
  const _CartItemsReceived(this.items);
  @override
  List<Object?> get props => [items];
}

class _CartStreamError extends CartEvent {
  final String message;
  const _CartStreamError(this.message);
  @override
  List<Object?> get props => [message];
}

class CartBloc extends Bloc<CartEvent, CartState> {
  final CartRepository _repo;
  StreamSubscription<List<CartItemModel>>? _sub;

  CartBloc({required CartRepository repository})
      : _repo = repository,
        super(const CartInitial()) {
    on<CartSubscribed>(_onSub);
    on<CartAddRequested>(_onAdd);
    on<CartUpdateQtyRequested>(_onUpdate);
    on<CartRemoveRequested>(_onRemove);
    on<CartClearRequested>(_onClear);
    on<_CartItemsReceived>(_onItems);
    on<_CartStreamError>(_onStreamError);
  }

  Future<void> _onSub(CartSubscribed e, Emitter<CartState> emit) async {
    emit(const CartLoading());
    await _sub?.cancel();

    // Dispatch events instead of emitting from the stream listener.
    _sub = _repo.stream(e.uid).listen(
          (items) => add(_CartItemsReceived(items)),
      onError: (err) => add(_CartStreamError(err.toString())),
    );
  }

  void _onItems(_CartItemsReceived e, Emitter<CartState> emit) {
    emit(CartLoaded(e.items));
  }

  void _onStreamError(_CartStreamError e, Emitter<CartState> emit) {
    emit(CartError(e.message));
  }

  Future<void> _onAdd(CartAddRequested e, Emitter<CartState> emit) async {
    try {
      await _repo.add(e.uid, e.product, qty: e.quantity);
    } catch (err) {
      emit(CartError('Add to cart failed: $err'));
    }
  }

  Future<void> _onUpdate(
      CartUpdateQtyRequested e,
      Emitter<CartState> emit,
      ) async {
    try {
      await _repo.updateQty(e.uid, e.productId, e.quantity);
    } catch (err) {
      emit(CartError('Update failed: $err'));
    }
  }

  Future<void> _onRemove(CartRemoveRequested e, Emitter<CartState> emit) async {
    try {
      await _repo.remove(e.uid, e.productId);
    } catch (err) {
      emit(CartError('Remove failed: $err'));
    }
  }

  Future<void> _onClear(CartClearRequested e, Emitter<CartState> emit) async {
    try {
      await _repo.clear(e.uid);
    } catch (err) {
      emit(CartError('Clear failed: $err'));
    }
  }

  @override
  Future<void> close() async {
    await _sub?.cancel();
    return super.close();
  }
}