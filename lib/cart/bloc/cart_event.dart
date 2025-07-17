import 'package:equatable/equatable.dart';
import 'package:madinaapp/models/models.dart';

abstract class CartEvent extends Equatable {
  const CartEvent();

  @override
  List<Object?> get props => [];
}

class CartLoaded extends CartEvent {
  const CartLoaded();
}

class CartItemAdded extends CartEvent {
  const CartItemAdded({
    required this.product,
    required this.quantity,
    this.selectedColor,
  });

  final Product product;
  final double quantity;
  final ProductColor? selectedColor;

  @override
  List<Object?> get props => [product, quantity, selectedColor];
}

class CartItemUpdated extends CartEvent {
  const CartItemUpdated({
    required this.productId,
    required this.quantity,
  });

  final String productId;
  final double quantity;

  @override
  List<Object?> get props => [productId, quantity];
}

class CartItemRemoved extends CartEvent {
  const CartItemRemoved({required this.productId});

  final String productId;

  @override
  List<Object?> get props => [productId];
}

class CartCleared extends CartEvent {
  const CartCleared();
}
