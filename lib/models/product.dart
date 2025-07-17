import 'package:equatable/equatable.dart';

class Product extends Equatable {
  const Product({
    required this.id,
    required this.name,
    required this.price,
    required this.imagePath,
    required this.description,
    this.tag,
    this.inStock = true,
    this.category = 'Шелковая ткань',
    this.color = 'Белый',
    this.size = 'M',
    this.rating = 5.0,
    this.images = const [],
    this.availableColors = const [],
    this.unit = 'двор',
    this.isFavorite = false,
  });

  final String id;
  final String name;
  final double price;
  final String imagePath;
  final String description;
  final String? tag;
  final bool inStock;
  final String category;
  final String color;
  final String size;
  final double rating;
  final List<String> images; // Additional images for gallery
  final List<ProductColor> availableColors; // Available color variants
  final String unit; // Unit of measurement (meter, yard, etc.)
  final bool isFavorite;

  @override
  List<Object?> get props => [
        id,
        name,
        price,
        imagePath,
        description,
        tag,
        inStock,
        category,
        color,
        size,
        rating,
        images,
        availableColors,
        unit,
        isFavorite,
      ];
}

class ProductColor extends Equatable {
  const ProductColor({
    required this.name,
    required this.colorValue,
    this.isSelected = false,
  });

  final String name;
  final int colorValue; // Color as hex value
  final bool isSelected;

  @override
  List<Object?> get props => [name, colorValue, isSelected];
}

class Order extends Equatable {
  const Order({
    required this.id,
    required this.customerName,
    required this.status,
    required this.products,
    this.description,
    this.timeAgo,
    this.date,
    this.totalAmount,
    this.customerAddress,
    this.shopName,
    this.category,
    this.priceRange,
    this.customerRating = 5.0,
  });

  final String id;
  final String customerName;
  final String? description;
  final String? timeAgo;
  final DateTime? date;
  final double? totalAmount;
  final String? customerAddress;
  final String? shopName;
  final OrderStatus status;
  final List<Product> products;
  final String? category;
  final String? priceRange;
  final double customerRating;

  @override
  List<Object?> get props => [
        id,
        customerName,
        description,
        timeAgo,
        date,
        totalAmount,
        customerAddress,
        shopName,
        status,
        products,
        category,
        priceRange,
        customerRating
      ];
}

enum OrderStatus {
  actionRequired,
  refundRequested,
  completed,
  processing,
  pending,
}
