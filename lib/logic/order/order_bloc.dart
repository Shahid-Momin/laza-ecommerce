import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/order_model.dart';
import '../../data/repositories/order_repository.dart';
import 'order_event.dart';
import 'order_state.dart';

class _OrdersReceived extends OrderEvent {
  final List<OrderModel> orders;
  const _OrdersReceived(this.orders);
  @override
  List<Object?> get props => [orders];
}

class _OrdersStreamError extends OrderEvent {
  final String message;
  const _OrdersStreamError(this.message);
  @override
  List<Object?> get props => [message];
}

class OrderBloc extends Bloc<OrderEvent, OrderState> {
  final OrderRepository _repo;
  StreamSubscription<List<OrderModel>>? _sub;

  OrderBloc({required OrderRepository repository})
      : _repo = repository,
        super(const OrderInitial()) {
    on<OrdersSubscribed>(_onSub);
    on<OrderPlaceRequested>(_onPlace);
    on<_OrdersReceived>(_onOrders);
    on<_OrdersStreamError>(_onStreamError);
  }

  Future<void> _onSub(OrdersSubscribed e, Emitter<OrderState> emit) async {
    emit(const OrderLoading());
    await _sub?.cancel();

    _sub = _repo.stream(e.uid).listen(
          (orders) => add(_OrdersReceived(orders)),
      onError: (err) => add(_OrdersStreamError(err.toString())),
    );
  }

  void _onOrders(_OrdersReceived e, Emitter<OrderState> emit) {
    emit(OrderLoaded(e.orders));
  }

  void _onStreamError(_OrdersStreamError e, Emitter<OrderState> emit) {
    emit(OrderError(e.message));
  }

  Future<void> _onPlace(OrderPlaceRequested e, Emitter<OrderState> emit) async {
    try {
      final id = await _repo.placeOrder(e.uid, e.order);
      emit(OrderPlaced(id));
    } catch (err) {
      emit(OrderError('Place order failed: $err'));
    }
  }

  @override
  Future<void> close() async {
    await _sub?.cancel();
    return super.close();
  }
}



