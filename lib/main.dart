import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'core/theme/app_theme.dart';
import 'core/api/api_client.dart';
import 'features/product/data/datasources/product_remote_datasource.dart';
import 'features/product/presentation/bloc/product_bloc.dart';
import 'features/cart/data/datasources/cart_remote_datasource.dart';
import 'features/cart/presentation/bloc/cart_bloc.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/home/data/datasources/home_datasource.dart';
import 'features/home/presentation/bloc/home_bloc.dart';
import 'features/home/presentation/pages/dynamic_home_page.dart';
import 'features/product/presentation/pages/product_list_page.dart';
import 'features/product/presentation/pages/product_details_page.dart';
import 'features/cart/presentation/pages/cart_page.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/register_page.dart';
import 'features/account/presentation/pages/account_page.dart';
import 'features/checkout/presentation/pages/checkout_page.dart';
import 'features/checkout/presentation/bloc/checkout_bloc.dart';
import 'features/checkout/data/datasources/checkout_remote_datasource.dart';

void main() {
  runApp(const MegaOutletApp());
}

class MegaOutletApp extends StatefulWidget {
  const MegaOutletApp({super.key});

  @override
  State<MegaOutletApp> createState() => _MegaOutletAppState();
}

class _MegaOutletAppState extends State<MegaOutletApp> {
  late final ApiClient _apiClient;
  late final ProductRemoteDataSource _productDataSource;
  late final CartRemoteDataSource _cartDataSource;
  late final CheckoutRemoteDataSource _checkoutDataSource;
  late final HomeDataSource _homeDataSource;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _apiClient = ApiClient();
    _productDataSource = ProductRemoteDataSource(_apiClient);
    _cartDataSource = CartRemoteDataSource(_apiClient);
    _checkoutDataSource = CheckoutRemoteDataSource();
    _homeDataSource = HomeDataSource();
    _router = _createRouter();
  }

  GoRouter _createRouter() {
    return GoRouter(
      initialLocation: '/',
      routes: [
        ShellRoute(
          builder: (context, state, child) {
            return MainScaffold(child: child);
          },
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) => const HomePage(),
            ),
            GoRoute(
              path: '/products',
              builder: (context, state) => const ProductListPage(),
            ),
            GoRoute(
              path: '/products/:id',
              builder: (context, state) {
                final id = int.parse(state.pathParameters['id']!);
                return ProductDetailsPage(productId: id);
              },
            ),
            GoRoute(
              path: '/search',
              builder: (context, state) => const ProductListPage(isSearch: true),
            ),
            GoRoute(
              path: '/cart',
              builder: (context, state) => const CartPage(),
            ),
            GoRoute(
              path: '/account',
              builder: (context, state) => const AccountPage(),
            ),
          ],
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginPage(),
        ),
        GoRoute(
          path: '/register',
          builder: (context, state) => const RegisterPage(),
        ),
        GoRoute(
          path: '/checkout',
          builder: (context, state) => const CheckoutPage(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<HomeBloc>(
          create: (context) => HomeBloc(dataSource: _homeDataSource),
        ),
        BlocProvider<ProductBloc>(
          create: (context) => ProductBloc(_productDataSource),
        ),
        BlocProvider<CartBloc>(
          create: (context) => CartBloc(_cartDataSource),
        ),
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(),
        ),
        BlocProvider<CheckoutBloc>(
          create: (context) => CheckoutBloc(dataSource: _checkoutDataSource),
        ),
      ],
      child: MaterialApp.router(
        title: 'Mega Outlet',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.light,
        routerConfig: _router,
      ),
    );
  }
}

class MainScaffold extends StatefulWidget {
  final Widget child;

  const MainScaffold({super.key, required this.child});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        
        final navigator = Navigator.of(context);
        if (navigator.canPop()) {
          navigator.pop();
          return;
        }
        
        if (_currentIndex != 0) {
          setState(() {
            _currentIndex = 0;
          });
          context.go('/');
        }
      },
      child: Scaffold(
        body: widget.child,
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
            switch (index) {
              case 0:
                context.go('/');
                break;
              case 1:
                context.go('/products');
                break;
              case 2:
                context.go('/search');
                break;
              case 3:
                context.go('/cart');
                break;
              case 4:
                context.go('/account');
                break;
            }
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_bag_outlined),
              activeIcon: Icon(Icons.shopping_bag),
              label: 'Sklep',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search),
              activeIcon: Icon(Icons.search),
              label: 'Szukaj',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart_outlined),
              activeIcon: Icon(Icons.shopping_cart),
              label: 'Koszyk',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Konto',
            ),
          ],
        ),
      ),
    );
  }
}