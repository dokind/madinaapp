import 'package:equatable/equatable.dart';
import 'package:madinaapp/models/models.dart';

enum ProductsStatus {
  initial,
  loading,
  success,
  failure,
}

class ProductsState extends Equatable {
  const ProductsState({
    this.status = ProductsStatus.initial,
    this.products = const [],
    this.filteredProducts = const [],
    this.featuredProducts = const [],
    this.orders = const [],
    this.filters = const {},
    this.searchQuery = '',
    this.error,
  });

  final ProductsStatus status;
  final List<Product> products;
  final List<Product> filteredProducts;
  final List<Product> featuredProducts;
  final List<Order> orders;
  final Map<String, dynamic> filters;
  final String searchQuery;
  final String? error;

  ProductsState copyWith({
    ProductsStatus? status,
    List<Product>? products,
    List<Product>? filteredProducts,
    List<Product>? featuredProducts,
    List<Order>? orders,
    Map<String, dynamic>? filters,
    String? searchQuery,
    String? error,
  }) {
    return ProductsState(
      status: status ?? this.status,
      products: products ?? this.products,
      filteredProducts: filteredProducts ?? this.filteredProducts,
      featuredProducts: featuredProducts ?? this.featuredProducts,
      orders: orders ?? this.orders,
      filters: filters ?? this.filters,
      searchQuery: searchQuery ?? this.searchQuery,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [
        status,
        products,
        filteredProducts,
        featuredProducts,
        orders,
        filters,
        searchQuery,
        error,
      ];
}
