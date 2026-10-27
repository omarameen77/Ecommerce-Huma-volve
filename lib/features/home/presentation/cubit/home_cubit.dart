import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/app_exception.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/usecases/get_products_by_category_use_case.dart';
import '../../domain/usecases/get_products_use_case.dart';
import '../mappers/product_display_mapper.dart';
import 'home_state.dart';

const String kAllCategoryLabel = 'All';

const int kHomePageSize = 20;

class _CategoryPage {
  _CategoryPage({
    required this.items,
    required this.offset,
    required this.hasMore,
  });

  List<ProductEntity> items;
  int offset;
  bool hasMore;
}

class HomeCubit extends Cubit<HomeState> {
  HomeCubit({
    required GetProductsUseCase getProductsUseCase,
    required GetProductsByCategoryUseCase getProductsByCategoryUseCase,
  }) : _getProductsUseCase = getProductsUseCase,
       _getProductsByCategoryUseCase = getProductsByCategoryUseCase,
       super(const HomeInitial());

  final GetProductsUseCase _getProductsUseCase;
  final GetProductsByCategoryUseCase _getProductsByCategoryUseCase;

  final Map<String, int> _categoryIds = {};

  final Map<String, _CategoryPage> _pageCache = {};

  bool _isFetching = false;

  int _requestId = 0;

  String get _currentSelectedCategory => switch (state) {
    HomeLoaded(:final selectedCategory) => selectedCategory,
    HomeEmpty(:final selectedCategory) => selectedCategory,
    HomeError(:final selectedCategory) => selectedCategory,
    _ => kAllCategoryLabel,
  };

  Future<void> loadHome() => _fetchFirstPage(kAllCategoryLabel);

  Future<void> selectCategory(String category) {
    if (_currentSelectedCategory == category) return Future.value();
    return _fetchFirstPage(category);
  }

  Future<void> refresh() =>
      _fetchFirstPage(_currentSelectedCategory, forceRefresh: true);

  Future<void> loadNextPage() async {
    final current = state;
    if (current is! HomeLoaded) return;
    if (_isFetching || current.isLoadingMore || !current.hasMore) return;

    final category = current.selectedCategory;
    final page = _pageCache[category];
    if (page == null) return;

    final myRequestId = _requestId;
    emit(current.copyWith(isLoadingMore: true, paginationError: null));
    try {
      final nextItems = await _requestPage(category, offset: page.offset);
      if (!_isCurrent(myRequestId, category)) return;

      final merged = _mergeUnique(page.items, nextItems);
      final hasMore = nextItems.length == kHomePageSize;
      page
        ..items = merged
        ..offset = page.offset + nextItems.length
        ..hasMore = hasMore;
      _learnCategoryIds(nextItems);

      emit(
        HomeLoaded(
          products: merged.map((e) => e.toDisplayProduct()).toList(),
          categories: _categoriesWithAll(),
          selectedCategory: category,
          hasMore: hasMore,
        ),
      );
    } on AppException catch (e) {
      if (!_isCurrent(myRequestId, category)) return;
      emit(current.copyWith(isLoadingMore: false, paginationError: e.message));
    } catch (_) {
      if (!_isCurrent(myRequestId, category)) return;
      emit(
        current.copyWith(
          isLoadingMore: false,
          paginationError: 'Could not load more products. Please try again.',
        ),
      );
    }
  }

  bool _isCurrent(int myRequestId, String category) {
    if (myRequestId != _requestId) return false;
    final s = state;
    return s is HomeLoaded && s.selectedCategory == category;
  }

  Future<void> _fetchFirstPage(
    String category, {
    bool forceRefresh = false,
  }) async {
    if (_isFetching) return;
    _requestId++;
    final myRequestId = _requestId;

    final cached = _pageCache[category];
    if (!forceRefresh && cached != null) {
      _emitResult(cached, category);
      return;
    }

    _isFetching = true;
    emit(const HomeLoading());
    try {
      final items = await _requestPage(category, offset: 0);
      if (myRequestId != _requestId) return;

      final hasMore = items.length == kHomePageSize;
      final page = _CategoryPage(
        items: items,
        offset: items.length,
        hasMore: hasMore,
      );
      _pageCache[category] = page;
      _learnCategoryIds(items);
      _emitResult(page, category);
    } on AppException catch (e) {
      if (myRequestId != _requestId) return;
      emit(
        HomeError(
          message: e.message,
          categories: _categoriesWithAll(),
          selectedCategory: category,
        ),
      );
    } catch (_) {
      if (myRequestId != _requestId) return;
      emit(
        HomeError(
          message: 'Something went wrong. Please try again.',
          categories: _categoriesWithAll(),
          selectedCategory: category,
        ),
      );
    } finally {
      _isFetching = false;
    }
  }

  Future<List<ProductEntity>> _requestPage(
    String category, {
    required int offset,
  }) {
    if (category == kAllCategoryLabel) {
      return _getProductsUseCase(limit: kHomePageSize, offset: offset);
    }
    final categoryId = _categoryIds[category];
    if (categoryId == null) return Future.value(const []);
    return _getProductsByCategoryUseCase(
      categoryId: categoryId,
      limit: kHomePageSize,
      offset: offset,
    );
  }

  List<ProductEntity> _mergeUnique(
    List<ProductEntity> existing,
    List<ProductEntity> incoming,
  ) {
    final seenIds = existing.map((e) => e.id).toSet();
    final deduped = incoming.where((e) => seenIds.add(e.id));
    return [...existing, ...deduped];
  }

  void _emitResult(_CategoryPage page, String category) {
    final categories = _categoriesWithAll();
    if (page.items.isEmpty) {
      emit(HomeEmpty(categories: categories, selectedCategory: category));
    } else {
      emit(
        HomeLoaded(
          products: page.items.map((e) => e.toDisplayProduct()).toList(),
          categories: categories,
          selectedCategory: category,
          hasMore: page.hasMore,
        ),
      );
    }
  }

  List<String> _categoriesWithAll() => [
    kAllCategoryLabel,
    ..._categoryIds.keys,
  ];

  void _learnCategoryIds(List<ProductEntity> products) {
    for (final product in products) {
      _categoryIds.putIfAbsent(
        product.category.name,
        () => product.category.id,
      );
    }
  }
}
