import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../cart/presentation/bloc/cart_bloc.dart';
import '../../../cart/data/models/cart_model.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../data/models/order_model.dart';
import '../bloc/checkout_bloc.dart';
import '../../data/datasources/checkout_remote_datasource.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers for billing form
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _postCodeController = TextEditingController();
  final _companyController = TextEditingController();
  
  bool _billingSameAsShipping = true;
  
  // Shipping controllers
  final _shippingFirstNameController = TextEditingController();
  final _shippingLastNameController = TextEditingController();
  final _shippingAddressController = TextEditingController();
  final _shippingCityController = TextEditingController();
  final _shippingPostCodeController = TextEditingController();
  
  // Selected methods
  String? _selectedShippingMethodId;
  String? _selectedPaymentMethodId;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _postCodeController.dispose();
    _companyController.dispose();
    _shippingFirstNameController.dispose();
    _shippingLastNameController.dispose();
    _shippingAddressController.dispose();
    _shippingCityController.dispose();
    _shippingPostCodeController.dispose();
    super.dispose();
  }

  void _placeOrder() {
    if (_formKey.currentState!.validate()) {
      final billingAddress = BillingAddress(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        address: _addressController.text.trim(),
        city: _cityController.text.trim(),
        postCode: _postCodeController.text.trim(),
        company: _companyController.text.trim(),
      );
      
      // Create shipping address
        ShippingAddress shippingAddress;
        if (_billingSameAsShipping) {
          shippingAddress = ShippingAddress(
            firstName: _firstNameController.text.trim(),
            lastName: _lastNameController.text.trim(),
            address: _addressController.text.trim(),
            city: _cityController.text.trim(),
            postCode: _postCodeController.text.trim(),
          );
        } else {
          shippingAddress = ShippingAddress(
            firstName: _shippingFirstNameController.text.trim(),
            lastName: _shippingLastNameController.text.trim(),
            address: _shippingAddressController.text.trim(),
            city: _shippingCityController.text.trim(),
            postCode: _shippingPostCodeController.text.trim(),
          );
        }

        // Get cart items for the order
        final cartState = context.read<CartBloc>().state;
        final orderLineItems = <OrderLineItem>[];
        if (cartState is CartLoaded) {
          for (final item in cartState.cart.items) {
            orderLineItems.add(OrderLineItem(
              productId: item.productId,
              quantity: item.quantity,
            ));
          }
        }
      
      context.read<CheckoutBloc>().add(PlaceOrderEvent(
        billingAddress: billingAddress,
        shippingAddress: shippingAddress,
        lineItems: orderLineItems,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kasa'),
      ),
      body: BlocBuilder<CheckoutBloc, CheckoutState>(
        builder: (context, state) {
          if (state is CheckoutLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (state is CheckoutSuccess) {
            return _buildSuccessView(state);
          }
          
          if (state is CheckoutError) {
            return _buildErrorView(state);
          }
          
          return _buildForm();
        },
      ),
    );
  }

  Widget _buildForm() {
    return BlocBuilder<CartBloc, CartState>(
      builder: (context, cartState) {
        final cart = cartState is CartLoaded ? cartState.cart : null;
        final cartItems = cart?.items ?? [];
        
        if (cartItems.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                const Text('Koszyk jest pusty'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => context.go('/'),
                  child: const Text('Przejdź do sklepu'),
                ),
              ],
            ),
          );
        }
        
        return Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Order Summary
              _buildOrderSummary(cartItems, cart),
              const SizedBox(height: 24),
              
              // Billing Form
              _buildBillingForm(),
              const SizedBox(height: 24),
              
              // Shipping Form
              _buildShippingForm(),
              const SizedBox(height: 24),
              
              // Shipping Method Selection
              if (cart?.shippingOptions.isNotEmpty ?? false)
                _buildShippingMethodSelection(cart!),
              const SizedBox(height: 24),
              
              // Payment Method Selection
              if (cart?.paymentMethods.isNotEmpty ?? false)
                _buildPaymentMethodSelection(cart!),
              const SizedBox(height: 32),
              
              // Place Order Button
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _placeOrder,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text(
                    'Złóż zamówienie',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOrderSummary(List<CartItem> items, Cart? cart) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Podsumowanie zamówienia',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            // Items
            ...items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  if (item.image != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: CachedNetworkImage(
                        imageUrl: item.image!,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      ),
                    ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'Ilość: ${item.quantity}',
                          style: TextStyle(color: Colors.grey[600], fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    CurrencyFormatter.formatDouble(item.priceAsDouble, currencySymbol: 'zł'),
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildBillingForm() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dane do faktury',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _firstNameController,
                    decoration: const InputDecoration(
                      labelText: 'Imię *',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Wymagane';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _lastNameController,
                    decoration: const InputDecoration(
                      labelText: 'Nazwisko *',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Wymagane';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email *',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Wymagane';
                }
                if (!value.contains('@')) {
                  return 'Nieprawidłowy email';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Telefon *',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Wymagane';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'Adres *',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Wymagane';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _postCodeController,
                    decoration: const InputDecoration(
                      labelText: 'Kod pocztowy *',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Wymagane';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _cityController,
                    decoration: const InputDecoration(
                      labelText: 'Miasto *',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Wymagane';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _companyController,
              decoration: const InputDecoration(
                labelText: 'Firma (opcjonalnie)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShippingForm() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Adres dostawy',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _billingSameAsShipping = !_billingSameAsShipping;
                    });
                  },
                  child: Text(_billingSameAsShipping 
                    ? 'Zmień' 
                    : 'Tak samo jak faktura'),
                ),
              ],
            ),
            if (!_billingSameAsShipping) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _shippingFirstNameController,
                      decoration: const InputDecoration(
                        labelText: 'Imię *',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Wymagane';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _shippingLastNameController,
                      decoration: const InputDecoration(
                        labelText: 'Nazwisko *',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Wymagane';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _shippingAddressController,
                decoration: const InputDecoration(
                  labelText: 'Adres dostawy *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Wymagane';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _shippingPostCodeController,
                      decoration: const InputDecoration(
                        labelText: 'Kod pocztowy *',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Wymagane';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _shippingCityController,
                      decoration: const InputDecoration(
                        labelText: 'Miasto *',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Wymagane';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
            ] else
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text('Dostawa na adres z faktury'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildShippingMethodSelection(Cart cart) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Metoda dostawy',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            ...cart.shippingOptions.map((method) => RadioListTile<String>(
              title: Text(method.name),
              subtitle: method.description != null ? Text(method.description!) : null,
              value: method.id,
              groupValue: _selectedShippingMethodId ?? method.id,
              onChanged: (value) {
                setState(() {
                  _selectedShippingMethodId = value;
                });
                context.read<CartBloc>().add(SelectShippingMethod(method.id));
              },
              secondary: method.price != null && method.price != '0'
                  ? Text(CurrencyFormatter.formatDouble(
                      (int.tryParse(method.price!) ?? 0) / 100,
                      currencySymbol: 'zł'))
                  : const Text('Gratisy'),
              dense: true,
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodSelection(Cart cart) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Metoda płatności',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            ...cart.paymentMethods
                .where((p) => p.isEnabled)
                .map((method) => RadioListTile<String>(
              title: Text(method.title),
              subtitle: method.description != null
                  ? Text(method.description!)
                  : null,
              value: method.id,
              groupValue: _selectedPaymentMethodId ?? method.id,
              onChanged: (value) {
                setState(() {
                  _selectedPaymentMethodId = value;
                });
                context.read<CartBloc>().add(SelectPaymentMethod(method.id));
              },
              dense: true,
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessView(CheckoutSuccess state) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.check_circle,
              size: 80,
              color: Colors.green,
            ),
            const SizedBox(height: 24),
            Text(
              'Zamówienie przyjęte!',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Numer zamówienia: #${state.orderId}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Potwierdzenie zostało wysłane na Twój adres email.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                context.read<CartBloc>().add(LoadCart());
                context.go('/');
              },
              child: const Text('Wróć do sklepu'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView(CheckoutError state) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 80,
              color: Colors.red,
            ),
            const SizedBox(height: 24),
            Text(
              'Błąd zamówienia',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Text(
              state.message,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                context.read<CheckoutBloc>().add(ResetCheckoutEvent());
              },
              child: const Text('Spróbuj ponownie'),
            ),
          ],
        ),
      ),
    );
  }
}