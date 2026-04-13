import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../data/models/product_model.dart';
import '../../presentation/bloc/product_bloc.dart';
import '../../../cart/presentation/bloc/cart_bloc.dart';

/// Strip HTML tags from string
String stripHtml(String htmlString) {
  return htmlString.replaceAll(RegExp(r'<[^>]*>'), '').trim();
}

class ProductDetailsPage extends StatefulWidget {
  final int productId;

  const ProductDetailsPage({super.key, required this.productId});

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  int _currentImageIndex = 0;
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    context.read<ProductBloc>().add(LoadProductDetails(widget.productId));
  }

  void _addToCart(Product product) {
    context.read<CartBloc>().add(AddToCartEvent(
          productId: product.id,
          quantity: _quantity,
        ));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Dodano do koszyka'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Widget _buildBottomBar(Product product) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Quantity selector
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: _quantity > 1
                        ? () => setState(() => _quantity--)
                        : null,
                  ),
                  Text(
                    '$_quantity',
                    style: const TextStyle(fontSize: 16),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () => setState(() => _quantity++),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // Add to cart button
            Expanded(
              child: ElevatedButton(
                onPressed: product.isInStock
                    ? () => _addToCart(product)
                    : null,
                child: Text(
                  product.isInStock ? 'Dodaj do koszyka' : 'Niedostępny',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<ProductBloc, ProductState>(
        builder: (context, state) {
          if (state is ProductLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ProductDetailsLoaded) {
            return _buildProductDetails(context, state.product, state.relatedProducts);
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
                      context
                          .read<ProductBloc>()
                          .add(LoadProductDetails(widget.productId));
                    },
                    child: const Text('Spróbuj ponownie'),
                  ),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildProductDetails(BuildContext context, Product product, List<Product> relatedProducts) {
    return Stack(
      children: [
        CustomScrollView(
          slivers: [
            // App Bar with image
            SliverAppBar(
              expandedHeight: 300,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  children: [
                    if (product.images.isNotEmpty)
                      PageView.builder(
                        onPageChanged: (index) {
                          setState(() => _currentImageIndex = index);
                        },
                        itemCount: product.images.length,
                        itemBuilder: (context, index) {
                          return CachedNetworkImage(
                            imageUrl: product.images[index].src,
                            fit: BoxFit.contain,
                            placeholder: (context, url) => Container(
                              color: Colors.grey[200],
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: Colors.grey[200],
                              child: const Icon(Icons.image, size: 64),
                            ),
                          );
                        },
                      )
                    else
                      Container(
                        color: Colors.grey[200],
                        child: const Icon(Icons.shopping_bag, size: 64),
                      ),
                    // Image indicator
                    if (product.images.length > 1)
                      Positioned(
                        bottom: 16,
                        left: 0,
                        right: 0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            product.images.length,
                            (index) => Container(
                              width: 8,
                              height: 8,
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _currentImageIndex == index
                                    ? Colors.white
                                    : Colors.white.withOpacity(0.5),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Product details
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Categories
                    if (product.categories.isNotEmpty)
                      Wrap(
                        spacing: 8,
                        children: product.categories
                            .map((cat) => Chip(
                                  label: Text(
                                    cat.name,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  visualDensity: VisualDensity.compact,
                                ))
                            .toList(),
                      ),
                    const SizedBox(height: 12),

                    // Name
                    Text(
                      product.name,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),

                    // SKU
                    if (product.sku != null && product.sku!.isNotEmpty)
                      Text(
                        'SKU: ${product.sku}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    const SizedBox(height: 16),

                    // Price
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (product.isOnSale)
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Text(
                              product.formattedRegularPrice,
                              style: TextStyle(
                                fontSize: 18,
                                decoration: TextDecoration.lineThrough,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                        Text(
                          product.formattedPrice,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: product.isOnSale
                                ? Theme.of(context).colorScheme.error
                                : Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Stock status
                    Row(
                      children: [
                        Icon(
                          product.isInStock ? Icons.check_circle : Icons.cancel,
                          size: 16,
                          color: product.isInStock ? Colors.green : Colors.red,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          product.stockAvailability?.text ??
                              (product.isInStock ? 'Dostępny' : 'Niedostępny'),
                          style: TextStyle(
                            color:
                                product.isInStock ? Colors.green : Colors.red,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Attributes
                    if (product.attributes.isNotEmpty) ...[
                      Text(
                        'Parametry',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      ...product.attributes.map((attr) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: 100,
                                  child: Text(
                                    attr.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Wrap(
                                    spacing: 4,
                                    children: attr.terms
                                        .map((term) => Chip(
                                              label: Text(
                                                term.name,
                                                style:
                                                    const TextStyle(fontSize: 12),
                                              ),
                                              visualDensity:
                                                  VisualDensity.compact,
                                            ))
                                        .toList(),
                                  ),
                                ),
                              ],
                            ),
                          )),
                      const SizedBox(height: 16),
                    ],

                    // Description
                    if (product.description != null &&
                        product.description!.isNotEmpty) ...[
                      Text(
                        'Opis',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        stripHtml(product.description!),
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Related products
                    if (relatedProducts.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      Text(
                        'Produkty powiązane',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                    ],
                  ],
                ),
              ),
            ),

            // Related products grid
            if (relatedProducts.isNotEmpty)
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.8,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final related = relatedProducts[index];
                      return GestureDetector(
                        onTap: () => context.go('/products/${related.id}'),
                        child: Card(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Container(
                                  width: double.infinity,
                                  color: Colors.grey[200],
                                  child: related.mainImage != null
                                      ? CachedNetworkImage(
                                          imageUrl: related.mainImage!,
                                          fit: BoxFit.cover,
                                        )
                                      : const Icon(Icons.image),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8),
                                child: Text(
                                  related.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 8, right: 8, bottom: 8),
                                child: Text(
                                  related.formattedPrice,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    childCount: relatedProducts.length,
                  ),
                ),
              ),

            // Bottom padding for add to cart button
            const SliverToBoxAdapter(
              child: SizedBox(height: 100),
            ),
          ],
        ),
        // Bottom bar
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: _buildBottomBar(product),
        ),
      ],
    );
  }
}