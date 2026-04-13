import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/models/order_model.dart';
import '../../data/datasources/checkout_remote_datasource.dart';

// Events
abstract class CheckoutEvent extends Equatable {
  const CheckoutEvent();

  @override
  List<Object?> get props => [];
}

class PlaceOrderEvent extends CheckoutEvent {
  final BillingAddress billingAddress;
  final ShippingAddress shippingAddress;
  final List<OrderLineItem>? lineItems;
  final String? customerId;

  const PlaceOrderEvent({
    required this.billingAddress,
    required this.shippingAddress,
    this.lineItems,
    this.customerId,
  });

  @override
  List<Object?> get props => [billingAddress, shippingAddress, lineItems, customerId];
}

class ResetCheckoutEvent extends CheckoutEvent {}

abstract class CheckoutState extends Equatable {
  const CheckoutState();

  @override
  List<Object?> get props => [];
}

class CheckoutInitial extends CheckoutState {}

class CheckoutLoading extends CheckoutState {}

class CheckoutSuccess extends CheckoutState {
  final int orderId;
  final String orderNumber;

  const CheckoutSuccess({
    required this.orderId,
    required this.orderNumber,
  });

  @override
  List<Object?> get props => [orderId, orderNumber];
}

class CheckoutError extends CheckoutState {
  final String message;

  const CheckoutError(this.message);

  @override
  List<Object?> get props => [message];
}

// Bloc
class CheckoutBloc extends Bloc<CheckoutEvent, CheckoutState> {
  final CheckoutRemoteDataSource _dataSource;

  CheckoutBloc({CheckoutRemoteDataSource? dataSource})
      : _dataSource = dataSource ?? CheckoutRemoteDataSource(),
        super(CheckoutInitial()) {
    on<PlaceOrderEvent>(_onPlaceOrder);
    on<ResetCheckoutEvent>(_onReset);
  }

  Future<void> _onPlaceOrder(
    PlaceOrderEvent event,
    Emitter<CheckoutState> emit,
  ) async {
    emit(CheckoutLoading());

    try {
      final result = await _dataSource.createOrder(
        billingAddress: event.billingAddress,
        shippingAddress: event.shippingAddress,
        lineItems: event.lineItems,
        customerId: event.customerId,
      );

      if (result != null) {
        emit(CheckoutSuccess(
          orderId: result.id,
          orderNumber: result.orderNumber,
        ));
      } else {
        emit(const CheckoutError('Nie udało się utworzyć zamówienia'));
      }
    } catch (e) {
      emit(CheckoutError(e.toString()));
    }
  }

  void _onReset(ResetCheckoutEvent event, Emitter<CheckoutState> emit) {
    emit(CheckoutInitial());
  }
}