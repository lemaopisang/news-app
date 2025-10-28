import 'dart:async';
import 'dart:math';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:news_app/models/news_article.dart';
import 'package:news_app/services/news_service.dart';
import 'package:news_app/utils/constants.dart';

class NewsController extends GetxController {
  NewsController({
    NewsService? service,
    Connectivity? connectivity,
  })  : _service = service ?? NewsService(),
        _connectivity = connectivity ?? Connectivity();

  final NewsService _service;
  final Connectivity _connectivity;
  static const String _offlineMessage =
      'No internet connection. Please check your network and try again.';
  StreamSubscription<dynamic>? _connectivitySubscription;

  final RxBool _isLoading = false.obs;
  final RxBool _isLoadingMore = false.obs;
  final RxString _error = ''.obs;
  final RxList<NewsArticle> _articles = <NewsArticle>[].obs;
  final RxInt _visibleCount = 0.obs;
  final RxInt _totalResults = 0.obs;
  final RxString _selectedCategory = (Constants.categories.isNotEmpty
          ? Constants.categories.first
          : 'general')
      .obs;
  final RxBool _isSearching = false.obs;
  final RxBool _isOffline = false.obs;

  String? _currentQuery;
  int _currentPage = 1;
  int _currentSearchPage = 1;
  final int _pageSize = 20;
  final int _visibleStep = 5;

  Timer? _searchDebounce;

  final TextEditingController searchController = TextEditingController();

  bool get isLoading => _isLoading.value;
  bool get isLoadingMore => _isLoadingMore.value;
  String get error => _error.value;
  List<NewsArticle> get articles => _articles;
  int get visibleCount => _visibleCount.value;
  bool get hasMore => _visibleCount.value < _totalResults.value;
  List<String> get categories => Constants.categories;
  String get selectedCategory => _selectedCategory.value;
  bool get isSearching => _isSearching.value;
  String? get currentQuery => _currentQuery;
  bool get isOffline => _isOffline.value;

  @override
  void onInit() {
    super.onInit();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen((dynamic result) {
      final bool hasConnection = _hasConnectivity(result);
      _isOffline.value = !hasConnection;
    }, onError: (_) {
      _isOffline.value = false;
    });
    fetchTopHeadlines(category: _selectedCategory.value);
  }

  @override
  void onClose() {
    _cancelDebounce();
    _connectivitySubscription?.cancel();
    searchController.dispose();
    super.onClose();
  }

  Future<void> fetchTopHeadlines({
    String country = Constants.defaultCountry,
    String? category,
  }) async {
    _cancelDebounce();
    _currentPage = 1;
    _currentSearchPage = 1;
    _isSearching.value = false;
    _currentQuery = null;
    await _wrapWithLoader(() async {
      await _updateConnectivityStatus();
      final response = await _service.getTopHeadlines(
        country: country,
        category: category,
        page: _currentPage,
        pageSize: _pageSize,
      );
      _articles.assignAll(response.articles);
      _totalResults.value = response.totalResults;
      _updateVisibleCount();
    });
  }

  void selectCategory(String category) {
    if (category.isEmpty || _selectedCategory.value == category) {
      refreshNews();
      return;
    }

    _selectedCategory.value = category;
    fetchTopHeadlines(category: category);
  }

  Future<void> searchNews(
    String query, {
    String? sortBy,
  }) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      await clearSearch();
      return;
    }

    _cancelDebounce();
    _isSearching.value = true;
    _currentQuery = trimmed;
    _currentSearchPage = 1;
    _currentPage = 1;

    await _wrapWithLoader(() async {
      await _updateConnectivityStatus();
      final response = await _service.searchNews(
        query: trimmed,
        page: _currentSearchPage,
        pageSize: _pageSize,
        sortBy: sortBy,
      );
      _articles.assignAll(response.articles);
      _totalResults.value = response.totalResults;
      _updateVisibleCount();
    });
  }

  Future<void> refreshNews() async {
    if (_isSearching.value && (_currentQuery?.isNotEmpty ?? false)) {
      return searchNews(_currentQuery!);
    }

    return fetchTopHeadlines(category: _selectedCategory.value);
  }

  Future<void> loadMoreArticles() async {
    if (_isLoadingMore.value || !hasMore) {
      return;
    }

    _isLoadingMore.value = true;
    try {
      if (_isOffline.value) {
        final bool backOnline = await _updateConnectivityStatus();
        if (!backOnline) {
          _error.value = _offlineMessage;
          return;
        }
      }

      if (_visibleCount.value < _articles.length) {
        _visibleCount.value =
            min(_visibleCount.value + _visibleStep, _articles.length);
      } else if (_articles.length < _totalResults.value) {
        if (_isSearching.value && (_currentQuery?.isNotEmpty ?? false)) {
          await _fetchMoreSearchResults();
        } else {
          await _fetchMoreHeadlines();
        }
        _visibleCount.value =
            min(_visibleCount.value + _visibleStep, _articles.length);
      }
    } catch (e) {
      _handleError(e);
    } finally {
      _isLoadingMore.value = false;
    }
  }

  void onSearchChanged(String query) {
    _cancelDebounce();

    if (query.trim().isEmpty) {
      _searchDebounce =
          Timer(const Duration(milliseconds: 400), () => clearSearch());
      return;
    }

    _searchDebounce = Timer(
      const Duration(milliseconds: 500),
      () {
        final trimmed = query.trim();
        if (trimmed.isEmpty || trimmed == _currentQuery) {
          return;
        }
        searchNews(trimmed);
      },
    );
  }

  Future<void> submitSearch(String query) async {
    _cancelDebounce();
    await searchNews(query);
  }

  Future<void> clearSearch() async {
    if (searchController.text.isNotEmpty) {
      searchController.clear();
    }

    if (!_isSearching.value) {
      return fetchTopHeadlines(category: _selectedCategory.value);
    }

    _isSearching.value = false;
    _currentQuery = null;
    return fetchTopHeadlines(category: _selectedCategory.value);
  }

  void _updateVisibleCount() {
    if (_articles.isEmpty) {
      _visibleCount.value = 0;
      if (!_isLoading.value) {
        _totalResults.value = 0;
      }
      return;
    }

    _visibleCount.value = min(_visibleStep, _articles.length);
    if (_totalResults.value == 0) {
      _totalResults.value = _articles.length;
    }
  }

  Future<void> _fetchMoreHeadlines() async {
    final nextPage = _currentPage + 1;
    await _updateConnectivityStatus();
    final response = await _service.getTopHeadlines(
      country: Constants.defaultCountry,
      category: _selectedCategory.value,
      page: nextPage,
      pageSize: _pageSize,
    );

    if (response.articles.isNotEmpty) {
      _articles.addAll(response.articles);
      _articles.refresh();
    }
    _totalResults.value = response.totalResults;
    _currentPage = nextPage;
  }

  Future<void> _fetchMoreSearchResults() async {
    final nextPage = _currentSearchPage + 1;
    await _updateConnectivityStatus();
    final response = await _service.searchNews(
      query: _currentQuery ?? '',
      page: nextPage,
      pageSize: _pageSize,
    );

    if (response.articles.isNotEmpty) {
      _articles.addAll(response.articles);
      _articles.refresh();
    }
    _totalResults.value = response.totalResults;
    _currentSearchPage = nextPage;
  }

  Future<void> _wrapWithLoader(Future<void> Function() action) async {
    if (_isLoading.value) {
      return;
    }

    _error.value = '';
    _isLoading.value = true;
    final bool hadArticles = _articles.isNotEmpty;

    try {
      await action();
    } catch (e) {
      _handleError(e);
      if (!hadArticles) {
        _articles.clear();
        _visibleCount.value = 0;
        _totalResults.value = 0;
      } else {
        _visibleCount.value = min(_visibleCount.value, _articles.length);
      }
    } finally {
      _isLoading.value = false;
    }
  }

  void _cancelDebounce() {
    _searchDebounce?.cancel();
    _searchDebounce = null;
  }

  void _handleError(Object error) {
    String message = error.toString();
    if (error is Exception && message.startsWith('Exception: ')) {
      message = message.substring('Exception: '.length);
    }
    if (message == _offlineMessage || message.contains('SocketException')) {
      _isOffline.value = true;
      message = _offlineMessage;
    }
    _error.value = message;
  }

  Future<bool> _updateConnectivityStatus() async {
    if (kIsWeb) {
      // Web builds rely on browser navigator status; assume online and
      // let network calls surface actual errors to avoid unsupported bindings.
      _isOffline.value = false;
      return true;
    }

    try {
      final dynamic connectivityResult =
          await _connectivity.checkConnectivity();
      final bool hasConnection = _hasConnectivity(connectivityResult);
      _isOffline.value = !hasConnection;

      return hasConnection;
    } on MissingPluginException {
      _isOffline.value = false;
      return true;
    } on PlatformException {
      _isOffline.value = false;
      return true;
    }
  }

  bool _hasConnectivity(dynamic result) {
    if (result is ConnectivityResult) {
      return result != ConnectivityResult.none;
    }

    if (result is Iterable<ConnectivityResult>) {
      return result.any((status) => status != ConnectivityResult.none);
    }

    return true;
  }
}
