import 'package:madinaapp/models/models.dart';
import 'package:madinaapp/data/dummy_data.dart';

class ProductsRepository {
  ProductsRepository();

  // Internal storage for products and orders
  List<Product> _products = [];
  List<Order> _orders = [];
  bool _isInitialized = false;

  Future<List<Product>> getProducts() async {
    if (!_isInitialized) {
      _products = List.from(DummyData.products);
      _orders =
          List.from(DummyData.orders); // Initialize orders from dummy data
      _isInitialized = true;
      print(
          '🏪 ProductsRepository: Initialized with ${_products.length} products');
    }
    return List.from(
        _products); // Return a copy to prevent external modification
  }

  Future<void> addProduct(Product product) async {
    print(
        '🏪 ProductsRepository: Adding product: ${product.name} (ID: ${product.id})');
    _products.add(product);
    print(
        '🏪 ProductsRepository: Total products after add: ${_products.length}');
  }

  Future<void> updateProduct(Product product) async {
    final index = _products.indexWhere((p) => p.id == product.id);
    if (index != -1) {
      _products[index] = product;
    }
  }

  Future<void> deleteProduct(String productId) async {
    _products.removeWhere((p) => p.id == productId);
  }

  Future<List<Product>> getFeaturedProducts() async {
    final products = await getProducts();
    return products.take(2).toList();
  }

  Future<List<Product>> searchProducts(String query) async {
    final products = await getProducts();
    if (query.isEmpty) return products;

    return products.where((product) {
      return product.name.toLowerCase().contains(query.toLowerCase()) ||
          product.description.toLowerCase().contains(query.toLowerCase()) ||
          product.category.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  Future<List<Product>> filterProducts(Map<String, dynamic> filters) async {
    final products = await getProducts();
    var filtered = products;

    if (filters.isEmpty) return filtered;

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

    return filtered;
  }

  Future<List<Order>> getOrders() async {
    if (!_isInitialized) {
      await getProducts(); // This will initialize both products and orders
    }
    return _orders;
  }

  Future<void> addOrder(Order order) async {
    _orders.add(order);
  }

  Future<void> updateOrder(Order order) async {
    final index = _orders.indexWhere((o) => o.id == order.id);
    if (index != -1) {
      _orders[index] = order;
    }
  }

  Future<void> deleteOrder(String orderId) async {
    _orders.removeWhere((o) => o.id == orderId);
  }
}
