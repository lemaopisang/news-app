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

  bool get isLoading => _isLoading.value;
  String get error => _error.value;
  List<NewsArticle> get articles => _articles;

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
    });
  }

  Future<void> searchNews(
    String query, {
    int page = 1,
    int pageSize = 20,
    String? sortBy,
  }) async {
    await _wrapWithLoader(() async {
      final response = await _service.searchNews(
        query: query,
        page: page,
        pageSize: pageSize,
        sortBy: sortBy,
      );
      _articles.assignAll(response.articles);
    });
  }

  Future<void> _wrapWithLoader(Future<void> Function() action) async {
    _error.value = '';
    _isLoading.value = true;
    try {
      await action();
    } catch (e) {
      _error.value = e.toString();
      _articles.clear();
    } finally {
      _isLoading.value = false;
    }
  }
}