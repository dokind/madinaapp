import 'package:equatable/equatable.dart';
import 'package:madinaapp/models/models.dart';

abstract class ProductsEvent extends Equatable {
  const ProductsEvent();

  @override
  List<Object?> get props => [];
}

class ProductsLoaded extends ProductsEvent {
  const ProductsLoaded();
}

class ProductAdded extends ProductsEvent {
  const ProductAdded(this.product);

  final Product product;

  @override
  List<Object> get props => [product];
}

class ProductUpdated extends ProductsEvent {
  const ProductUpdated(this.product);

  final Product product;

  @override
  List<Object> get props => [product];
}

class ProductDeleted extends ProductsEvent {
  const ProductDeleted(this.productId);

  final String productId;

  @override
  List<Object> get props => [productId];
}

class ProductsFiltered extends ProductsEvent {
  const ProductsFiltered(this.filters);

  final Map<String, dynamic> filters;

  @override
  List<Object> get props => [filters];
}

class ProductsSearched extends ProductsEvent {
  const ProductsSearched(this.query);

  final String query;

  @override
  List<Object> get props => [query];
}
