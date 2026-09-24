import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/product_repository.dart';
import 'product_event.dart';
import 'product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final ProductRepository _repo;

  ProductBloc({required ProductRepository repository})
      : _repo = repository,
        super(const ProductInitial()) {
    on<ProductsFetchRequested>(_onFetch);
    on<ProductSearchRequested>(_onSearch);
    on<ProductsByCategoryRequested>(_onCategory);
  }

  Future<void> _onFetch(
      ProductsFetchRequested e,
      Emitter<ProductState> emit,
      ) async {
    if (e.refresh) emit(const ProductLoading());
    try {
      final list = await _repo.getProducts(limit: e.limit, skip: e.skip);
      if (list.isEmpty) {
        emit(const ProductEmpty());
      } else {
        emit(ProductLoaded(list, hasMore: list.length == e.limit));
      }
    } catch (err) {
      emit(ProductError('Failed to load products: $err'));
    }
  }

  Future<void> _onSearch(
      ProductSearchRequested e,
      Emitter<ProductState> emit,
      ) async {
    emit(const ProductLoading());
    try {
      final list = await _repo.search(e.query);
      if (list.isEmpty) {
        emit(const ProductEmpty());
      } else {
        emit(ProductLoaded(list, hasMore: false));
      }
    } catch (err) {
      emit(ProductError('Search failed: $err'));
    }
  }

  Future<void> _onCategory(
      ProductsByCategoryRequested e,
      Emitter<ProductState> emit,
      ) async {
    emit(const ProductLoading());
    try {
      final list = await _repo.getByCategory(e.category);
      if (list.isEmpty) {
        emit(const ProductEmpty());
      } else {
        emit(ProductLoaded(list, hasMore: false));
      }
    } catch (err) {
      emit(ProductError('Failed to load category: $err'));
    }
  }
}