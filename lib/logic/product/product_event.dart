import 'package:equatable/equatable.dart';

abstract class ProductEvent extends Equatable {
  const ProductEvent();
  @override
  List<Object?> get props => [];
}

class ProductsFetchRequested extends ProductEvent {
  final int limit;
  final int skip;
  final bool refresh;
  const ProductsFetchRequested({
    this.limit = 20,
    this.skip = 0,
    this.refresh = false,
  });
  @override
  List<Object?> get props => [limit, skip, refresh];
}

class ProductSearchRequested extends ProductEvent {
  final String query;
  const ProductSearchRequested(this.query);
  @override
  List<Object?> get props => [query];
}

class ProductsByCategoryRequested extends ProductEvent {
  final String category;
  const ProductsByCategoryRequested(this.category);
  @override
  List<Object?> get props => [category];
}