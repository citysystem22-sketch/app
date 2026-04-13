import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../data/models/home_model.dart';
import '../bloc/home_bloc.dart';
import '../../../product/data/models/product_model.dart';
import '../../../product/presentation/bloc/product_bloc.dart';
import '../../../cart/presentation/bloc/cart_bloc.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    // Start loading homepage data
    context.read<HomeBloc>().add(LoadHomePage());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          if (state is HomeLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is HomeError) {
            return _buildErrorView(state.message);
          }

          if (state is HomeLoaded) {
            return _buildHomeContent(state.data);
          }

          // Fallback to simple loading
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('Mega Outlet'),
      actions: [
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () => context.go('/search'),
        ),
        Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.shopping_cart_outlined),
              onPressed: () => context.go('/cart'),
            ),
            BlocBuilder<CartBloc, CartState>(
              builder: (context, state) {
                if (state is CartLoaded && state.cart.itemCount > 0) {
                  return Positioned(
                    right: 6,
                    top: 6,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${state.cart.itemCount}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildErrorView(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(message),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              context.read<HomeBloc>().add(LoadHomePage());
            },
            child: const Text('Spróbuj ponownie'),
          ),
        ],
      ),
    );
  }

  Widget _buildHomeContent(HomePageData data) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<HomeBloc>().add(RefreshHomePage());
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero/Banner Section
            if (data.hero != null) _buildHeroSection(data.hero!),

            // Benefits Section
            if (data.benefits != null) _buildBenefitsSection(data.benefits!),

            // Categories Section
            if (data.categories != null) _buildCategoriesSection(data.categories!),

            // Product Sections (Carousels/Grids)
            ...data.productSections.map((section) => _buildProductSection(section)),

            // Banner Sections
            ...data.banners.map((banner) => _buildBannerSection(banner)),

            // Blog Section
            if (data.blog != null) _buildBlogSection(data.blog!),

            // Info Section
            if (data.info != null) _buildInfoSection(data.info!),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ============ HERO SECTION ============
  Widget _buildHeroSection(HeroSection section) {
    // Use first banner or default
    final banner = section.banners.isNotEmpty ? section.banners.first : null;

    return Container(
      width: double.infinity,
      height: 200,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: banner?.imageUrl == null
            ? Theme.of(context).colorScheme.primary
            : null,
        image: banner?.imageUrl != null
            ? DecorationImage(
                image: CachedNetworkImageProvider(banner!.imageUrl!),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.black.withOpacity(0.3),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              section.headline ?? banner?.title ?? 'Mega Outlet',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (section.subtitle != null || banner?.subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                section.subtitle ?? banner?.subtitle ?? '',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ],
            if (banner?.buttonText != null) ...[
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (banner?.buttonLink != null) {
                    context.go(banner!.buttonLink!);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Theme.of(context).colorScheme.primary,
                ),
                child: Text(banner!.buttonText!),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ============ BENEFITS SECTION ============
  Widget _buildBenefitsSection(BenefitsSection section) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: section.benefits.map((benefit) {
          return _buildBenefitItem(benefit);
        }).toList(),
      ),
    );
  }

  Widget _buildBenefitItem(BenefitItem benefit) {
    IconData iconData;
    switch (benefit.iconClass) {
      case 'price':
        iconData = Icons.local_offer;
        break;
      case 'lock':
        iconData = Icons.lock;
        break;
      case 'shipping':
        iconData = Icons.local_shipping;
        break;
      case 'info':
        iconData = Icons.info;
        break;
      default:
        iconData = Icons.star;
    }

    return Expanded(
      child: GestureDetector(
        onTap: () {
          // Could navigate to more info
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(iconData, size: 28, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                benefit.title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============ CATEGORIES SECTION ============
  Widget _buildCategoriesSection(FeaturedCategoriesSection section) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
          child: Text(
            section.title,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        SizedBox(
          height: 140,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: section.categories.length,
            itemBuilder: (context, index) {
              final category = section.categories[index];
              return _buildCategoryCard(category);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryCard(CategoryItem category) {
    return GestureDetector(
      onTap: () {
        if (category.link != null) {
          context.go(category.link!);
        }
      },
      child: Container(
        width: 120,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey[200],
                ),
                clipBehavior: Clip.antiAlias,
                child: category.imageUrl != null
                    ? CachedNetworkImage(
                        imageUrl: category.imageUrl!,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        errorWidget: (_, __, ___) => const Icon(Icons.image),
                      )
                    : const Icon(Icons.category, size: 40),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              category.name,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  // ============ PRODUCT SECTION ============
  Widget _buildProductSection(ProductSection section) {
    if (section.products.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  section.title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              TextButton(
                onPressed: () {
                  // View all products in this category
                },
                child: const Text('Zobacz wszystkie'),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 280,
          child: section.viewType == 'carousel'
              ? ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: section.products.length,
                  itemBuilder: (context, index) {
                    return _buildProductCard(section.products[index]);
                  },
                )
              : GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.7,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: section.products.length,
                  itemBuilder: (context, index) {
                    return _buildProductCard(section.products[index]);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildProductCard(Product product) {
    return GestureDetector(
      onTap: () => context.go('/products/${product.id}'),
      child: Container(
        width: 160,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: Card(
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product image
              Expanded(
                flex: 3,
                child: Container(
                  width: double.infinity,
                  color: Colors.grey[100],
                  child: product.mainImage != null
                      ? CachedNetworkImage(
                          imageUrl: product.mainImage!,
                          fit: BoxFit.contain,
                          placeholder: (_, __) => const Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          errorWidget: (_, __, ___) =>
                              const Icon(Icons.image, size: 48),
                        )
                      : const Icon(Icons.shopping_bag, size: 48),
                ),
              ),
              // Product info
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      // Price
                      Row(
                        children: [
                          if (product.isOnSale &&
                              product.prices.regularPrice != null) ...[
                            Text(
                              product.formattedRegularPrice,
                              style: TextStyle(
                                fontSize: 10,
                                decoration: TextDecoration.lineThrough,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(width: 4),
                          ],
                          Expanded(
                            child: Text(
                              product.formattedPrice,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: product.isOnSale
                                    ? Colors.red
                                    : Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============ BANNER SECTION ============
  Widget _buildBannerSection(BannerSection section) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: section.backgroundColor != null
            ? Color(int.tryParse(section.backgroundColor!.replaceFirst('#', '0xFF')) ?? 0)
            : Colors.orange[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (section.bannerTitle != null)
            Text(
              section.bannerTitle!,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          if (section.bannerSubtitle != null) ...[
            const SizedBox(height: 8),
            Text(
              section.bannerSubtitle!,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
          if (section.buttonText != null) ...[
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (section.buttonLink != null) {
                  context.go(section.buttonLink!);
                }
              },
              child: Text(section.buttonText!),
            ),
          ],
        ],
      ),
    );
  }

  // ============ BLOG SECTION ============
  Widget _buildBlogSection(BlogSection section) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
          child: Text(
            section.title,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: section.posts.length,
            itemBuilder: (context, index) {
              return _buildBlogPostCard(section.posts[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBlogPostCard(BlogPost post) {
    return GestureDetector(
      onTap: () {
        if (post.link != null) {
          context.go(post.link!);
        }
      },
      child: Container(
        width: 200,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: Card(
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (post.imageUrl != null)
                Expanded(
                  child: Container(
                    width: double.infinity,
                    color: Colors.grey[200],
                    child: CachedNetworkImage(
                      imageUrl: post.imageUrl!,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                    if (post.excerpt != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        post.excerpt!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============ INFO SECTION ============
  Widget _buildInfoSection(InfoSection section) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            section.title,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          if (section.content != null) ...[
            const SizedBox(height: 12),
            Text(
              section.content!,
              style: TextStyle(color: Colors.grey[700]),
            ),
          ],
          if (section.linkText != null) ...[
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                if (section.linkUrl != null) {
                  context.go(section.linkUrl!);
                }
              },
              child: Text(section.linkText!),
            ),
          ],
        ],
      ),
    );
  }
}