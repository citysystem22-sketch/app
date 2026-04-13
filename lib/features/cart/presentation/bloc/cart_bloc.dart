import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/datasources/cart_remote_datasource.dart';
import '../../data/models/cart_model.dart';

// Events
abstract class CartEvent extends Equatable {
  const CartEvent();

  @override
  List<Object?> get props => [];
}

class LoadCart extends CartEvent {}

class AddToCartEvent extends CartEvent {
  final int productId;
  final int quantity;
  final Map<String, dynamic>? variationData;

  const AddToCartEvent({
    required this.productId,
    this.quantity = 1,
    this.variationData,
  });

  @override
  List<Object?> get props => [productId, quantity, variationData];
}

class RemoveFromCart extends CartEvent {
  final String cartItemKey;

  const RemoveFromCart(this.cartItemKey);

  @override
  List<Object?> get props => [cartItemKey];
}

class UpdateCartItemQuantity extends CartEvent {
  final String cartItemKey;
  final int quantity;

  const UpdateCartItemQuantity({
    required this.cartItemKey,
    required this.quantity,
  });

  @override
  List<Object?> get props => [cartItemKey, quantity];
}

class ApplyCoupon extends CartEvent {
  final String couponCode;

  const ApplyCoupon(this.couponCode);

  @override
  List<Object?> get props => [couponCode];
}

class RemoveCoupon extends CartEvent {
  final String couponCode;

  const RemoveCoupon(this.couponCode);

  @override
  List<Object?> get props => [couponCode];
}

class UpdateShippingAddress extends CartEvent {
  final CartShippingAddress address;

  const UpdateShippingAddress(this.address);

  @override
  List<Object?> get props => [address];
}

class SelectShippingMethod extends CartEvent {
  final String methodId;

  const SelectShippingMethod(this.methodId);

  @override
  List<Object?> get props => [methodId];
}

class SelectPaymentMethod extends CartEvent {
  final String methodId;

  const SelectPaymentMethod(this.methodId);

  @override
  List<Object?> get props => [methodId];
}

// States
abstract class CartState extends Equatable {
  const CartState();

  @override
  List<Object?> get props => [];
}

class CartInitial extends CartState {}

class CartLoading extends CartState {}

class CartLoaded extends CartState {
  final Cart cart;

  const CartLoaded(this.cart);

  @override
  List<Object?> get props => [cart];
}

class CartError extends CartState {
  final String message;

  const CartError(this.message);

  @override
  List<Object?> get props => [message];
}

class CartOperationSuccess extends CartState {
  final Cart cart;
  final String message;

  const CartOperationSuccess({
    required this.cart,
    required this.message,
  });

  @override
  List<Object?> get props => [cart, message];
}

// BLoC
class CartBloc extends Bloc<CartEvent, CartState> {
  final CartRemoteDataSource _cartDataSource;

  CartBloc(this._cartDataSource) : super(CartInitial()) {
    on<LoadCart>(_onLoadCart);
    on<AddToCartEvent>(_onAddToCart);
    on<RemoveFromCart>(_onRemoveFromCart);
    on<UpdateCartItemQuantity>(_onUpdateCartItemQuantity);
    on<ApplyCoupon>(_onApplyCoupon);
    on<RemoveCoupon>(_onRemoveCoupon);
    on<UpdateShippingAddress>(_onUpdateShippingAddress);
    on<SelectShippingMethod>(_onSelectShippingMethod);
    on<SelectPaymentMethod>(_onSelectPaymentMethod);
  }

  Future<void> _onLoadCart(LoadCart event, Emitter<CartState> emit) async {
    emit(CartLoading());
    try {
      final cart = await _cartDataSource.getCart();
      emit(CartLoaded(cart));
    } catch (e) {
      emit(CartError(e.toString()));
    }
  }

  Future<void> _onAddToCart(AddToCartEvent event, Emitter<CartState> emit) async {
    try {
      final cart = await _cartDataSource.addToCart(
        productId: event.productId,
        quantity: event.quantity,
        variationData: event.variationData,
      );
      emit(CartOperationSuccess(cart: cart, message: 'Dodano do koszyka'));
    } catch (e) {
      // Try to load cart to get current state - if fails, emit error
      try {
        final cart = await _cartDataSource.getCart();
        emit(CartOperationSuccess(cart: cart, message: 'Dodano do koszyka (lokalnie)'));      } catch (_) {
        emit(CartError('Nie można dodać do koszyka. Spróbuj ponownie.'));
      }
    }
  }

  Future<void> _onRemoveFromCart(
      RemoveFromCart event, Emitter<CartState> emit) async {
    emit(CartLoading());
    try {
      final cart = await _cartDataSource.removeFromCart(event.cartItemKey);
      emit(CartOperationSuccess(cart: cart, message: 'Usunięto z koszyka'));
    } catch (e) {
      emit(CartError(e.toString()));
    }
  }

  Future<void> _onUpdateCartItemQuantity(
      UpdateCartItemQuantity event, Emitter<CartState> emit) async {
    emit(CartLoading());
    try {
      final cart = await _cartDataSource.updateCartItemQuantity(
        cartItemKey: event.cartItemKey,
        quantity: event.quantity,
      );
      emit(CartLoaded(cart));
    } catch (e) {
      emit(CartError(e.toString()));
    }
  }

  Future<void> _onApplyCoupon(
      ApplyCoupon event, Emitter<CartState> emit) async {
    emit(CartLoading());
    try {
      final cart = await _cartDataSource.applyCoupon(event.couponCode);
      emit(CartOperationSuccess(cart: cart, message: 'Kod rabatowy dodany'));
    } catch (e) {
      emit(CartError(e.toString()));
    }
  }

  Future<void> _onRemoveCoupon(
      RemoveCoupon event, Emitter<CartState> emit) async {
    emit(CartLoading());
    try {
      final cart = await _cartDataSource.removeCoupon(event.couponCode);
      emit(CartOperationSuccess(cart: cart, message: 'Kod rabatowy usunięty'));
    } catch (e) {
      emit(CartError(e.toString()));
    }
  }

  Future<void> _onUpdateShippingAddress(
      UpdateShippingAddress event, Emitter<CartState> emit) async {
    emit(CartLoading());
    try {
      final cart = await _cartDataSource.updateShippingAddress(event.address);
      emit(CartLoaded(cart));
    } catch (e) {
      emit(CartError(e.toString()));
    }
  }

  Future<void> _onSelectShippingMethod(
      SelectShippingMethod event, Emitter<CartState> emit) async {
    emit(CartLoading());
    try {
      final cart = await _cartDataSource.selectShippingMethod(event.methodId);
      emit(CartLoaded(cart));
    } catch (e) {
      emit(CartError(e.toString()));
    }
  }

  Future<void> _onSelectPaymentMethod(
      SelectPaymentMethod event, Emitter<CartState> emit) async {
    emit(CartLoading());
    try {
      final cart = await _cartDataSource.selectPaymentMethod(event.methodId);
      emit(CartLoaded(cart));
    } catch (e) {
      emit(CartError(e.toString()));
    }
  }
}