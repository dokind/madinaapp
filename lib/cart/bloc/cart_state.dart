import 'package:equatable/equatable.dart';
import 'package:madinaapp/models/models.dart';

enum CartStatus { initial, loading, success, failure }

class CartState extends Equatable {
  const CartState({
    this.status = CartStatus.initial,
    this.items = const [],
    this.error,
  });

  final CartStatus status;
  final List<CartItem> items;
  final String? error;

  double get totalAmount {
    return items.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  int get totalItems {
    return items.length;
  }

  double get totalQuantity {
    return items.fold(0.0, (sum, item) => sum + item.quantity);
  }

  CartState copyWith({
    CartStatus? status,
    List<CartItem>? items,
    String? error,
  }) {
    return CartState(
      status: status ?? this.status,
      items: items ?? this.items,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [status, items, error];
}
