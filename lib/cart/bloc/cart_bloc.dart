import 'package:bloc/bloc.dart';
import 'package:madinaapp/cart/bloc/cart_event.dart';
import 'package:madinaapp/cart/bloc/cart_state.dart';
import 'package:madinaapp/models/models.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  CartBloc() : super(const CartState()) {
    on<CartLoaded>(_onCartLoaded);
    on<CartItemAdded>(_onCartItemAdded);
    on<CartItemUpdated>(_onCartItemUpdated);
    on<CartItemRemoved>(_onCartItemRemoved);
    on<CartCleared>(_onCartCleared);
  }

  Future<void> _onCartLoaded(
    CartLoaded event,
    Emitter<CartState> emit,
  ) async {
    emit(state.copyWith(status: CartStatus.loading));
    try {
      // Load cart items from local storage if needed
      emit(state.copyWith(status: CartStatus.success));
    } catch (error) {
      emit(state.copyWith(
        status: CartStatus.failure,
        error: error.toString(),
      ));
    }
  }

  Future<void> _onCartItemAdded(
    CartItemAdded event,
    Emitter<CartState> emit,
  ) async {
    try {
      final items = List<CartItem>.from(state.items);

      // Check if product already exists in cart
      final existingIndex = items.indexWhere(
        (item) =>
            item.product.id == event.product.id &&
            item.selectedColor?.name == event.selectedColor?.name,
      );

      if (existingIndex != -1) {
        // Update quantity if product already exists
        final existingItem = items[existingIndex];
        items[existingIndex] = existingItem.copyWith(
          quantity: existingItem.quantity + event.quantity,
        );
      } else {
        // Add new item
        items.add(CartItem(
          product: event.product,
          quantity: event.quantity,
          selectedColor: event.selectedColor,
        ));
      }

      emit(state.copyWith(
        status: CartStatus.success,
        items: items,
      ));
    } catch (error) {
      emit(state.copyWith(
        status: CartStatus.failure,
        error: error.toString(),
      ));
    }
  }

  Future<void> _onCartItemUpdated(
    CartItemUpdated event,
    Emitter<CartState> emit,
  ) async {
    try {
      final items = List<CartItem>.from(state.items);
      final index = items.indexWhere(
        (item) => item.product.id == event.productId,
      );

      if (index != -1) {
        if (event.quantity <= 0) {
          items.removeAt(index);
        } else {
          items[index] = items[index].copyWith(quantity: event.quantity);
        }

        emit(state.copyWith(
          status: CartStatus.success,
          items: items,
        ));
      }
    } catch (error) {
      emit(state.copyWith(
        status: CartStatus.failure,
        error: error.toString(),
      ));
    }
  }

  Future<void> _onCartItemRemoved(
    CartItemRemoved event,
    Emitter<CartState> emit,
  ) async {
    try {
      final items = List<CartItem>.from(state.items);
      items.removeWhere((item) => item.product.id == event.productId);

      emit(state.copyWith(
        status: CartStatus.success,
        items: items,
      ));
    } catch (error) {
      emit(state.copyWith(
        status: CartStatus.failure,
        error: error.toString(),
      ));
    }
  }

  Future<void> _onCartCleared(
    CartCleared event,
    Emitter<CartState> emit,
  ) async {
    try {
      emit(state.copyWith(
        status: CartStatus.success,
        items: [],
      ));
    } catch (error) {
      emit(state.copyWith(
        status: CartStatus.failure,
        error: error.toString(),
      ));
    }
  }
}
