import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/datasources/product_remote_datasource.dart';
import '../../data/models/product_model.dart';

// Events
abstract class ProductEvent extends Equatable {
  const ProductEvent();

  @override
  List<Object?> get props => [];
}

class LoadProducts extends ProductEvent {
  final int page;
  final String? category;
  final String? search;
  final String? orderBy;
  final String? order;
  final bool refresh;

  const LoadProducts({
    this.page = 1,
    this.category,
    this.search,
    this.orderBy,
    this.order,
    this.refresh = false,
  });

  @override
  List<Object?> get props => [page, category, search, orderBy, order, refresh];
}

class LoadMoreProducts extends ProductEvent {}

class LoadProductDetails extends ProductEvent {
  final int productId;

  const LoadProductDetails(this.productId);

  @override
  List<Object?> get props => [productId];
}

class LoadCategories extends ProductEvent {}

class LoadProductsByCategory extends ProductEvent {
  final int categoryId;

  const LoadProductsByCategory(this.categoryId);

  @override
  List<Object?> get props => [categoryId];
}

class SearchProducts extends ProductEvent {
  final String query;

  const SearchProducts(this.query);

  @override
  List<Object?> get props => [query];
}

// States
abstract class ProductState extends Equatable {
  const ProductState();

  @override
  List<Object?> get props => [];
}

class ProductInitial extends ProductState {}

class ProductLoading extends ProductState {}

class ProductsLoaded extends ProductState {
  final List<Product> products;
  final List<ProductCategory> categories;
  final int currentPage;
  final bool hasReachedMax;
  final String? currentCategory;
  final String? currentSearch;

  const ProductsLoaded({
    required this.products,
    this.categories = const [],
    this.currentPage = 1,
    this.hasReachedMax = false,
    this.currentCategory,
    this.currentSearch,
  });

  ProductsLoaded copyWith({
    List<Product>? products,
    List<ProductCategory>? categories,
    int? currentPage,
    bool? hasReachedMax,
    String? currentCategory,
    String? currentSearch,
  }) {
    return ProductsLoaded(
      products: products ?? this.products,
      categories: categories ?? this.categories,
      currentPage: currentPage ?? this.currentPage,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentCategory: currentCategory ?? this.currentCategory,
      currentSearch: currentSearch ?? this.currentSearch,
    );
  }

  @override
  List<Object?> get props => [
        products,
        categories,
        currentPage,
        hasReachedMax,
        currentCategory,
        currentSearch,
      ];
}

class ProductDetailsLoaded extends ProductState {
  final Product product;
  final List<Product> relatedProducts;

  const ProductDetailsLoaded({
    required this.product,
    this.relatedProducts = const [],
  });

  @override
  List<Object?> get props => [product, relatedProducts];
}

class ProductError extends ProductState {
  final String message;

  const ProductError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final ProductRemoteDataSource _productDataSource;

  List<ProductCategory> _cachedCategories = [];
  String? _currentCategory;
  String? _currentSearch;
  String? _currentOrderBy;
  String? _currentOrder;

  ProductBloc(this._productDataSource) : super(ProductInitial()) {
    on<LoadProducts>(_onLoadProducts);
    on<LoadMoreProducts>(_onLoadMoreProducts);
    on<LoadProductDetails>(_onLoadProductDetails);
    on<LoadCategories>(_onLoadCategories);
    on<LoadProductsByCategory>(_onLoadProductsByCategory);
    on<SearchProducts>(_onSearchProducts);
  }

  Future<void> _onLoadProducts(
      LoadProducts event, Emitter<ProductState> emit) async {
    emit(ProductLoading());
    try {
      _currentCategory = event.category;
      _currentSearch = event.search;
      _currentOrderBy = event.orderBy;
      _currentOrder = event.order;

      final products = await _productDataSource.getProducts(
        page: event.page,
        category: event.category,
        search: event.search,
        orderBy: event.orderBy,
        order: event.order,
      );

      emit(ProductsLoaded(
        products: products,
        categories: _cachedCategories,
        currentPage: event.page,
        hasReachedMax: products.length < 20,
        currentCategory: event.category,
        currentSearch: event.search,
      ));
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  Future<void> _onLoadMoreProducts(
      LoadMoreProducts event, Emitter<ProductState> emit) async {
    final currentState = state;
    if (currentState is ProductsLoaded && !currentState.hasReachedMax) {
      try {
        final nextPage = currentState.currentPage + 1;
        final products = await _productDataSource.getProducts(
          page: nextPage,
          category: _currentCategory,
          search: _currentSearch,
          orderBy: _currentOrderBy,
          order: _currentOrder,
        );

        emit(currentState.copyWith(
          products: [...currentState.products, ...products],
          currentPage: nextPage,
          hasReachedMax: products.length < 20,
        ));
      } catch (e) {
        emit(ProductError(e.toString()));
      }
    }
  }

  Future<void> _onLoadProductDetails(
      LoadProductDetails event, Emitter<ProductState> emit) async {
    emit(ProductLoading());
    try {
      final product =
          await _productDataSource.getProductById(event.productId);
      final relatedProducts =
          await _productDataSource.getRelatedProducts(event.productId);

      emit(ProductDetailsLoaded(
        product: product,
        relatedProducts: relatedProducts,
      ));
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  Future<void> _onLoadCategories(
      LoadCategories event, Emitter<ProductState> emit) async {
    try {
      final categories = await _productDataSource.getCategories();
      _cachedCategories = categories;

      if (state is ProductsLoaded) {
        emit((state as ProductsLoaded).copyWith(categories: categories));
      }
    } catch (e) {
      // Silently fail for categories
    }
  }

  Future<void> _onLoadProductsByCategory(
      LoadProductsByCategory event, Emitter<ProductState> emit) async {
    emit(ProductLoading());
    try {
      final products = await _productDataSource.getProducts(
        category: event.categoryId.toString(),
      );

      emit(ProductsLoaded(
        products: products,
        categories: _cachedCategories,
        currentPage: 1,
        hasReachedMax: true,
        currentCategory: event.categoryId.toString(),
      ));
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  Future<void> _onSearchProducts(
      SearchProducts event, Emitter<ProductState> emit) async {
    emit(ProductLoading());
    try {
      final products = await _productDataSource.searchProducts(event.query);

      emit(ProductsLoaded(
        products: products,
        categories: _cachedCategories,
        currentPage: 1,
        hasReachedMax: true,
        currentSearch: event.query,
      ));
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }
}