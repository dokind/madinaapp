import 'package:bloc/bloc.dart';
import 'package:madinaapp/products/bloc/products_event.dart';
import 'package:madinaapp/products/bloc/products_state.dart';
import 'package:madinaapp/models/models.dart';
import 'package:madinaapp/repositories/repositories.dart';

class ProductsBloc extends Bloc<ProductsEvent, ProductsState> {
  ProductsBloc({
    required ProductsRepository productsRepository,
  })  : _productsRepository = productsRepository,
        super(const ProductsState()) {
    on<ProductsLoaded>(_onProductsLoaded);
    on<ProductAdded>(_onProductAdded);
    on<ProductUpdated>(_onProductUpdated);
    on<ProductDeleted>(_onProductDeleted);
    on<ProductsFiltered>(_onProductsFiltered);
    on<ProductsSearched>(_onProductsSearched);
  }

  final ProductsRepository _productsRepository;

  Future<void> _onProductsLoaded(
    ProductsLoaded event,
    Emitter<ProductsState> emit,
  ) async {
    emit(state.copyWith(status: ProductsStatus.loading));

    try {
      // Get products and orders from repository
      final products = await _productsRepository.getProducts();
      final featuredProducts = await _productsRepository.getFeaturedProducts();
      final orders = await _productsRepository.getOrders();

      emit(state.copyWith(
        status: ProductsStatus.success,
        products: products,
        filteredProducts: products,
        featuredProducts: featuredProducts,
        orders: orders,
      ));
    } catch (error) {
      emit(state.copyWith(
        status: ProductsStatus.failure,
        error: error.toString(),
      ));
    }
  }

  Future<void> _onProductAdded(
    ProductAdded event,
    Emitter<ProductsState> emit,
  ) async {
    print(
        'DEBUG: ProductAdded event received for product: ${event.product.name}');
    try {
      // Add product to repository
      await _productsRepository.addProduct(event.product);
      print('DEBUG: Product added to repository successfully');

      // Get updated products and orders
      final products = await _productsRepository.getProducts();
      final featuredProducts = await _productsRepository.getFeaturedProducts();
      final orders = await _productsRepository.getOrders();

      print('DEBUG: Total products after add: ${products.length}');

      final filteredProducts = _applyFiltersAndSearch(
        products,
        state.filters,
        state.searchQuery,
      );

      print('DEBUG: Filtered products after add: ${filteredProducts.length}');
      print('DEBUG: Current filters: ${state.filters}');
      print('DEBUG: Current search query: "${state.searchQuery}"');

      emit(state.copyWith(
        products: products,
        filteredProducts: filteredProducts,
        featuredProducts: featuredProducts,
        orders: orders,
      ));

      print(
          'DEBUG: State emitted with ${filteredProducts.length} filtered products');
    } catch (error) {
      print('DEBUG: Error in ProductAdded: $error');
      emit(state.copyWith(
        status: ProductsStatus.failure,
        error: error.toString(),
      ));
    }
  }

  Future<void> _onProductUpdated(
    ProductUpdated event,
    Emitter<ProductsState> emit,
  ) async {
    try {
      // Update product in repository
      await _productsRepository.updateProduct(event.product);

      // Get updated products and orders
      final products = await _productsRepository.getProducts();
      final featuredProducts = await _productsRepository.getFeaturedProducts();
      final orders = await _productsRepository.getOrders();

      final filteredProducts = _applyFiltersAndSearch(
        products,
        state.filters,
        state.searchQuery,
      );

      emit(state.copyWith(
        products: products,
        filteredProducts: filteredProducts,
        featuredProducts: featuredProducts,
        orders: orders,
      ));
    } catch (error) {
      emit(state.copyWith(
        status: ProductsStatus.failure,
        error: error.toString(),
      ));
    }
  }

  Future<void> _onProductDeleted(
    ProductDeleted event,
    Emitter<ProductsState> emit,
  ) async {
    try {
      // Delete product from repository
      await _productsRepository.deleteProduct(event.productId);

      // Get updated products and orders
      final products = await _productsRepository.getProducts();
      final featuredProducts = await _productsRepository.getFeaturedProducts();
      final orders = await _productsRepository.getOrders();

      final filteredProducts = _applyFiltersAndSearch(
        products,
        state.filters,
        state.searchQuery,
      );

      emit(state.copyWith(
        products: products,
        filteredProducts: filteredProducts,
        featuredProducts: featuredProducts,
        orders: orders,
      ));
    } catch (error) {
      emit(state.copyWith(
        status: ProductsStatus.failure,
        error: error.toString(),
      ));
    }
  }

  Future<void> _onProductsFiltered(
    ProductsFiltered event,
    Emitter<ProductsState> emit,
  ) async {
    try {
      final filteredProducts = _applyFiltersAndSearch(
        state.products,
        event.filters,
        state.searchQuery,
      );

      emit(state.copyWith(
        filters: event.filters,
        filteredProducts: filteredProducts,
      ));
    } catch (error) {
      emit(state.copyWith(
        status: ProductsStatus.failure,
        error: error.toString(),
      ));
    }
  }

  Future<void> _onProductsSearched(
    ProductsSearched event,
    Emitter<ProductsState> emit,
  ) async {
    try {
      final filteredProducts = _applyFiltersAndSearch(
        state.products,
        state.filters,
        event.query,
      );

      emit(state.copyWith(
        searchQuery: event.query,
        filteredProducts: filteredProducts,
      ));
    } catch (error) {
      emit(state.copyWith(
        status: ProductsStatus.failure,
        error: error.toString(),
      ));
    }
  }

  List<Product> _applyFiltersAndSearch(
    List<Product> products,
    Map<String, dynamic> filters,
    String searchQuery,
  ) {
    var filtered = products;

    // Apply search query
    if (searchQuery.isNotEmpty) {
      filtered = filtered.where((product) {
        return product.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
            product.description
                .toLowerCase()
                .contains(searchQuery.toLowerCase()) ||
            product.category.toLowerCase().contains(searchQuery.toLowerCase());
      }).toList();
    }

    // Apply filters
    if (filters.isNotEmpty) {
      if (filters['category'] != null) {
        filtered = filtered.where((product) {
          return product.category == filters['category'];
        }).toList();
      }

      if (filters['priceRange'] != null) {
        final priceRange = filters['priceRange'] as Map<String, double>;
        filtered = filtered.where((product) {
          return product.price >= priceRange['min']! &&
              product.price <= priceRange['max']!;
        }).toList();
      }

      if (filters['color'] != null) {
        filtered = filtered.where((product) {
          return product.color == filters['color'];
        }).toList();
      }

      if (filters['size'] != null) {
        filtered = filtered.where((product) {
          return product.size == filters['size'];
        }).toList();
      }

      if (filters['rating'] != null) {
        final minRating = filters['rating'] as double;
        filtered = filtered.where((product) {
          return product.rating >= minRating;
        }).toList();
      }
    }

    return filtered;
  }
}
