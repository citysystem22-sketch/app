import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../presentation/bloc/product_bloc.dart';
import '../../../home/presentation/widgets/product_grid.dart';

class ProductListPage extends StatefulWidget {
  final bool isSearch;

  const ProductListPage({super.key, this.isSearch = false});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  final _searchController = TextEditingController();
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    if (widget.isSearch) {
      // Don't load products until search is triggered
    } else {
      context.read<ProductBloc>().add(const LoadProducts());
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch() {
    final query = _searchController.text.trim();
    if (query.isNotEmpty) {
      context.read<ProductBloc>().add(SearchProducts(query));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: widget.isSearch
            ? TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Szukaj produktów...',
                  border: InputBorder.none,
                ),
                onSubmitted: (_) => _onSearch(),
              )
            : const Text('Produkty'),
        actions: widget.isSearch
            ? [
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _onSearch,
                ),
              ]
            : null,
      ),
      body: BlocBuilder<ProductBloc, ProductState>(
        builder: (context, state) {
          if (state is ProductLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ProductsLoaded) {
            if (state.products.isEmpty) {
              return const Center(
                child: Text('Brak produktów'),
              );
            }

            return NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                if (notification is ScrollEndNotification &&
                    notification.metrics.extentAfter < 200 &&
                    !state.hasReachedMax &&
                    !widget.isSearch) {
                  context.read<ProductBloc>().add(LoadMoreProducts());
                }
                return false;
              },
              child: ProductGrid(products: state.products),
            );
          }

          if (state is ProductError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Błąd: ${state.message}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<ProductBloc>().add(const LoadProducts());
                    },
                    child: const Text('Spróbuj ponownie'),
                  ),
                ],
              ),
            );
          }

          if (widget.isSearch) {
            return const Center(
              child: Text('Wpisz nazwę produktu'),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}