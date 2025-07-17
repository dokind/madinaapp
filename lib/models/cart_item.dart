import 'package:equatable/equatable.dart';
import 'package:madinaapp/models/product.dart';

class CartItem extends Equatable {
  const CartItem({
    required this.product,
    required this.quantity,
    this.selectedColor,
  });

  final Product product;
  final double quantity; // Using double to support decimal quantities (meters)
  final ProductColor? selectedColor;

  double get totalPrice => product.price * quantity;

  CartItem copyWith({
    Product? product,
    double? quantity,
    ProductColor? selectedColor,
  }) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      selectedColor: selectedColor ?? this.selectedColor,
    );
  }

  @override
  List<Object?> get props => [product, quantity, selectedColor];
}
