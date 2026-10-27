import 'package:equatable/equatable.dart';

import '../../../../core/dummy_data.dart' show Product;

sealed class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {
  const HomeInitial();
}

class HomeLoading extends HomeState {
  const HomeLoading();
}

const Object _unset = Object();

class HomeLoaded extends HomeState {
  const HomeLoaded({
    required this.products,
    required this.categories,
    required this.selectedCategory,
    required this.hasMore,
    this.isLoadingMore = false,
    this.paginationError,
  });

  final List<Product> products;
  final List<String> categories;
  final String selectedCategory;

  final bool hasMore;

  final bool isLoadingMore;

  final String? paginationError;

  HomeLoaded copyWith({bool? isLoadingMore, Object? paginationError = _unset}) {
    return HomeLoaded(
      products: products,
      categories: categories,
      selectedCategory: selectedCategory,
      hasMore: hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      paginationError: identical(paginationError, _unset)
          ? this.paginationError
          : paginationError as String?,
    );
  }

  @override
  List<Object?> get props => [
    products,
    categories,
    selectedCategory,
    hasMore,
    isLoadingMore,
    paginationError,
  ];
}

class HomeEmpty extends HomeState {
  const HomeEmpty({required this.categories, required this.selectedCategory});

  final List<String> categories;
  final String selectedCategory;

  @override
  List<Object?> get props => [categories, selectedCategory];
}

class HomeError extends HomeState {
  const HomeError({
    required this.message,
    required this.categories,
    required this.selectedCategory,
  });

  final String message;
  final List<String> categories;
  final String selectedCategory;

  @override
  List<Object?> get props => [message, categories, selectedCategory];
}
