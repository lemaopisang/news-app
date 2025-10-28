import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:news_app/controllers/news_controller.dart';
import 'package:news_app/models/news_article.dart';
import 'package:news_app/routes/app_pages.dart';
import 'package:news_app/utils/app_colors.dart';
import 'package:news_app/widgets/category_chip.dart';
import 'package:news_app/widgets/headline_card.dart';
import 'package:news_app/widgets/loading_shimmer.dart';
import 'package:news_app/widgets/news_card.dart';
import 'package:news_app/widgets/app_footer.dart';

class HomeView extends GetView<NewsController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFC),
      body: Obx(() {
        if (controller.isLoading && controller.articles.isEmpty) {
          return const SafeArea(child: LoadingShimmer());
        }

        if (controller.error.isNotEmpty) {
          return _buildErrorState(context);
        }

        if (controller.articles.isEmpty) {
          return _buildEmptyState(context);
        }

    final List<NewsArticle> articles = controller.articles;
    final int requestedCount = controller.visibleCount;
    final int safeVisibleCount = articles.isEmpty
      ? 0
      : requestedCount <= 0
        ? 1
        : (requestedCount > articles.length
          ? articles.length
          : requestedCount);
    final List<NewsArticle> visibleArticles =
      articles.take(safeVisibleCount).toList();

    if (visibleArticles.isEmpty) {
      return _buildEmptyState(context);
    }

    final NewsArticle headline = visibleArticles.first;
    final List<NewsArticle> others = visibleArticles.length > 1
      ? visibleArticles.sublist(1)
      : <NewsArticle>[];

        return SafeArea(
          child: RefreshIndicator(
            color: AppColors.primary,
            backgroundColor: Colors.white,
            displacement: 40,
            strokeWidth: 2.5,
            onRefresh: controller.refreshNews,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              slivers: [
                // App Bar
                SliverAppBar(
                  floating: true,
                  snap: true,
                  backgroundColor: Colors.white,
                  elevation: 0,
                  scrolledUnderElevation: 0.5,
                  title: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.newspaper_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'News',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                  actions: [
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: IconButton(
                        tooltip: 'Notifications',
                        splashRadius: 24,
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.backgroundDark,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: Icon(
                          Icons.notifications_none_rounded,
                          color: AppColors.textPrimary,
                          size: 22,
                        ),
                        onPressed: () {
                          Get.snackbar(
                            'Notifications',
                            "You're all caught up!",
                            snackPosition: SnackPosition.TOP,
                            backgroundColor:
                                AppColors.primary.withValues(alpha: 0.9),
                            colorText: Colors.white,
                            margin: const EdgeInsets.all(16),
                            borderRadius: 14,
                          );
                        },
                      ),
                    ),
                  ],
                ),

                // Main Content
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (controller.isOffline)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: AnimatedOpacity(
                              duration: const Duration(milliseconds: 250),
                              opacity: controller.isOffline ? 1 : 0,
                              child: _buildOfflineBanner(context),
                            ),
                          ),

                        // Search Bar
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Container(
                            height: 52,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: AppColors.divider.withValues(alpha: 0.3),
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.03),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  child: Icon(
                                    Icons.search_rounded,
                                    color: AppColors.textTertiary,
                                    size: 20,
                                  ),
                                ),
                                Expanded(
                                  child: ValueListenableBuilder<
                                      TextEditingValue>(
                                    valueListenable:
                                        controller.searchController,
                                    builder: (context, value, _) {
                                      final List<Widget> suffixActions = [];

                                      if (controller.isSearching &&
                                          controller.isLoading) {
                                        suffixActions.add(
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              right: 12,
                                            ),
                                            child: SizedBox(
                                              width: 18,
                                              height: 18,
                                              child:
                                                  CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: AppColors.primary,
                                              ),
                                            ),
                                          ),
                                        );
                                      }

                                      if (value.text.isNotEmpty) {
                                        suffixActions.add(
                                          IconButton(
                                            icon: Icon(
                                              Icons.close_rounded,
                                              color: AppColors.textSecondary,
                                            ),
                                            splashRadius: 20,
                                            tooltip: 'Clear search',
                                            onPressed: () =>
                                                controller.clearSearch(),
                                          ),
                                        );
                                      }

                                      return TextField(
                                        controller:
                                            controller.searchController,
                                        onChanged: controller.onSearchChanged,
                                        onSubmitted: (query) {
                                          FocusScope.of(context).unfocus();
                                          controller.submitSearch(query);
                                        },
                                        textInputAction: TextInputAction.search,
                                        autocorrect: false,
                                        decoration: InputDecoration(
                                          hintText: 'Search news...',
                                          hintStyle: theme.textTheme.bodyMedium
                                              ?.copyWith(
                                            color: AppColors.textTertiary,
                                          ),
                                          border: InputBorder.none,
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                            vertical: 12,
                                          ),
                                          suffixIcon: suffixActions.isEmpty
                                              ? null
                                              : Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: suffixActions,
                                                ),
                                        ),
                                        style: theme.textTheme.bodyMedium,
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Categories
                        Text(
                          'Categories',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 44,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            physics:
                                const BouncingScrollPhysics(),
                            children: [
                              CategoryChip(
                                label: 'All',
                                isSelected:
                                    controller.selectedCategory ==
                                        'general',
                                onTap: () =>
                                    controller.selectCategory('general'),
                              ),
                              const SizedBox(width: 10),
                              CategoryChip(
                                label: 'Technology',
                                isSelected:
                                    controller.selectedCategory ==
                                        'technology',
                                onTap: () => controller
                                    .selectCategory('technology'),
                              ),
                              const SizedBox(width: 10),
                              CategoryChip(
                                label: 'Business',
                                isSelected:
                                    controller.selectedCategory ==
                                        'business',
                                onTap: () =>
                                    controller.selectCategory('business'),
                              ),
                              const SizedBox(width: 10),
                              CategoryChip(
                                label: 'Health',
                                isSelected:
                                    controller.selectedCategory ==
                                        'health',
                                onTap: () =>
                                    controller.selectCategory('health'),
                              ),
                              const SizedBox(width: 10),
                              CategoryChip(
                                label: 'Sports',
                                isSelected:
                                    controller.selectedCategory ==
                                        'sports',
                                onTap: () =>
                                    controller.selectCategory('sports'),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 28),

                        // Top Story
                        Text(
                          'Top Story',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 12),
                        HeadlineCard(
                          article: headline,
                          onTap: () => Get.toNamed(
                            Routes.NEWS_DETAIL,
                            arguments: headline,
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Latest Updates
                        Text(
                          'Latest Updates',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),

                // News List
                if (others.isNotEmpty)
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final article = others[index];
                          return NewsCard(
                            article: article,
                            index: index,
                            onTap: () => Get.toNamed(
                              Routes.NEWS_DETAIL,
                              arguments: article,
                            ),
                          );
                        },
                        childCount: others.length,
                      ),
                    ),
                  )
                else
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _buildSingleFeedPlaceholder(context),
                    ),
                  ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
            child: controller.isLoadingMore
              ? _buildLoadMoreLoader(context)
              : controller.hasMore
                ? _buildLoadMoreButton(context)
                : _buildEndOfFeedBadge(context),
                    ),
                  ),
                ),

                // Footer
                SliverToBoxAdapter(
                  child: const AppFooter(),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildSingleFeedPlaceholder(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: 150,
      decoration: BoxDecoration(
        color: AppColors.backgroundDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.divider.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.article_outlined,
              size: 48,
              color: AppColors.textTertiary,
            ),
            const SizedBox(height: 12),
            Text(
              'No more articles',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 80,
              color: AppColors.textTertiary,
            ),
            const SizedBox(height: 16),
            Text(
              'No News Available',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try refreshing or check your connection',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: controller.refreshNews,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Refresh'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 80,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Oops! Something went wrong',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                controller.error,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: controller.refreshNews,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadMoreButton(BuildContext context) {
    final bool offline = controller.isOffline;
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        icon: Icon(
          offline ? Icons.wifi_off_rounded : Icons.add_circle_outline_rounded,
        ),
        onPressed: controller.loadMoreArticles,
        label: Text(offline ? 'Retry connection' : 'Load more'),
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          textStyle: Theme.of(context)
              .textTheme
              .labelLarge
              ?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildLoadMoreLoader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.divider.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 16),
          Text(
            'Loading more articles...',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildEndOfFeedBadge(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.backgroundDark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.divider.withValues(alpha: 0.25),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle_outline_rounded,
            color: AppColors.success,
            size: 22,
          ),
          const SizedBox(width: 12),
          Text(
            "You're all caught up",
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildOfflineBanner(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFf97316), Color(0xFFef4444)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.wifi_off_rounded,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'You\'re offline',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'We\'ll keep your latest headlines here. Reconnect to refresh.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
            ),
            onPressed: controller.refreshNews,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
