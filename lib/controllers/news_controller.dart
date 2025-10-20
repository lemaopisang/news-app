import 'dart:math';

import 'package:get/get.dart';
import 'package:news_app/models/news_article.dart';
import 'package:news_app/services/news_service.dart';
import 'package:news_app/utils/constants.dart';

class NewsController extends GetxController {
  NewsController({NewsService? service}) : _service = service ?? NewsService();

  final NewsService _service;

  final RxBool _isLoading = false.obs;
  final RxString _error = ''.obs;
  final RxList<NewsArticle> _articles = <NewsArticle>[].obs;
  final RxInt _visibleCount = 0.obs;
  final RxBool _isLoadingMore = false.obs;
  final RxString _selectedCategory = (Constants.categories.isNotEmpty
          ? Constants.categories.first
          : 'general')
      .obs;
  final RxBool _isSearching = false.obs;
  String? _currentQuery;

  bool get isLoading => _isLoading.value;
  String get error => _error.value;
  List<NewsArticle> get articles => _articles;
  int get visibleCount => _visibleCount.value;
  bool get hasMore => _articles.length > _visibleCount.value;
  bool get isLoadingMore => _isLoadingMore.value;
  List<String> get categories => Constants.categories;
  String get selectedCategory => _selectedCategory.value;
  bool get isSearching => _isSearching.value;
  String? get currentQuery => _currentQuery;

  @override
  void onInit() {
    super.onInit();
    fetchTopHeadlines();
  }

  Future<void> fetchTopHeadlines({
    String country = Constants.defaultCountry,
    String? category,
    int page = 1,
    int pageSize = 20,
  }) async {
    await _wrapWithLoader(() async {
      final response = await _service.getTopHeadlines(
        country: country,
        category: category,
        page: page,
        pageSize: pageSize,
      );
      _articles.assignAll(response.articles);
      _updateVisibleCount();
    });
  }

  void selectCategory(String category) {
    if (category.isEmpty || _selectedCategory.value == category) {
      refreshNews();
      return;
    }

    _selectedCategory.value = category;
    _isSearching.value = false;
    _currentQuery = null;
    fetchTopHeadlines(category: category);
  }

  Future<void> searchNews(
    String query, {
    int page = 1,
    int pageSize = 20,
    String? sortBy,
  }) async {
    _currentQuery = query;
    _isSearching.value = true;
    await _wrapWithLoader(() async {
      final response = await _service.searchNews(
        query: query,
        page: page,
        pageSize: pageSize,
        sortBy: sortBy,
      );
      _articles.assignAll(response.articles);
      _updateVisibleCount();
    });
  }

  Future<void> refreshNews() async {
    if (_isSearching.value && (_currentQuery?.isNotEmpty ?? false)) {
      return searchNews(_currentQuery!);
    }

    return fetchTopHeadlines(category: _selectedCategory.value);
  }

  Future<void> _wrapWithLoader(Future<void> Function() action) async {
    _error.value = '';
    _isLoading.value = true;
    try {
      await action();
    } catch (e) {
      _error.value = e.toString();
      _articles.clear();
      _visibleCount.value = 0;
    } finally {
      _isLoading.value = false;
      _isLoadingMore.value = false;
    }
  }

  Future<void> loadMoreArticles({int step = 5}) async {
    if (!hasMore || _isLoadingMore.value) {
      return;
    }

    _isLoadingMore.value = true;
    try {
      await Future.delayed(const Duration(milliseconds: 600));
      final nextCount = min(_visibleCount.value + step, _articles.length);
      _visibleCount.value = nextCount;
    } finally {
      _isLoadingMore.value = false;
    }
  }

  void _updateVisibleCount() {
    if (_articles.isEmpty) {
      _visibleCount.value = 0;
      return;
    }

    _visibleCount.value = min(5, _articles.length);
  }
}