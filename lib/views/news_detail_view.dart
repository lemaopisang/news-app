import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:share_plus/share_plus.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:url_launcher/url_launcher.dart';
import 'package:news_app/models/news_article.dart';
import 'package:news_app/utils/app_colors.dart';

class NewsDetailView extends StatelessWidget {
  const NewsDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final NewsArticle article = Get.arguments as NewsArticle;
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFC),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: Colors.white,
            elevation: 0,
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.95),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_back_rounded,
                  color: AppColors.textPrimary,
                  size: 24,
                ),
                onPressed: () => Get.back(),
              ),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.95),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.share_rounded,
                    color: AppColors.primary,
                    size: 24,
                  ),
                  onPressed: () => _shareArticle(article),
                ),
              ),
              Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.95),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: PopupMenuButton<String>(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  onSelected: (value) {
                    switch (value) {
                      case 'copy_link':
                        _copyLink(article);
                        break;
                      case 'open_browser':
                        _openInBrowser(article);
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'copy_link',
                      child: Row(
                        children: [
                          Icon(
                            Icons.copy_rounded,
                            color: AppColors.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Copy Link',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'open_browser',
                      child: Row(
                        children: [
                          Icon(
                            Icons.open_in_browser_rounded,
                            color: AppColors.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Open in Browser',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  icon: const Icon(
                    Icons.more_vert_rounded,
                    color: AppColors.textPrimary,
                    size: 24,
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: article.urlToImage != null
                  ? CachedNetworkImage(
                      imageUrl: article.urlToImage!,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: AppColors.divider,
                        child: const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: AppColors.divider,
                        child: const Icon(
                          Icons.image_not_supported,
                          size: 50,
                          color: AppColors.textHint,
                        ),
                      ),
                    )
                  : Container(
                      color: AppColors.divider,
                      child: const Icon(
                        Icons.newspaper,
                        size: 50,
                        color: AppColors.textHint,
                      ),
                    ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Source Badge
                  if (article.source?.name != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        article.source!.name!,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),

                  // Title
                  if (article.title != null)
                    Text(
                      article.title!,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        height: 1.4,
                      ),
                    ),
                  const SizedBox(height: 16),

                  // Date
                  Row(
                    children: [
                      Icon(
                        Icons.schedule_rounded,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 6),
                      if (article.publishedAt != null)
                        Text(
                          timeago.format(
                            DateTime.parse(article.publishedAt!),
                          ),
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Divider
                  Container(
                    height: 1,
                    color: AppColors.divider.withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: 24),

                  // Description
                  if (article.description != null)
                    Text(
                      article.description!,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                        height: 1.6,
                      ),
                    ),
                  const SizedBox(height: 24),

                  // Content
                  if (article.content != null)
                    Text(
                      article.content!,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textSecondary,
                        height: 1.8,
                      ),
                    ),
                  const SizedBox(height: 40),

                  // Read More Button
                  if (article.url != null)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _openInBrowser(article),
                        icon: const Icon(Icons.open_in_new_rounded),
                        label: const Text('Read Full Article'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 60),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _shareArticle(NewsArticle article) {
    HapticFeedback.mediumImpact();
    // Create a simple share message
    final String shareMessage = 'Check out this article:\n\n${article.title}\n${article.description}\n\nRead more: ${article.url}';
    // Use share_plus to share the article
    SharePlus.instance.share(
      ShareParams(
        text: shareMessage,
        subject: article.title,
      ),
    );
  }

  void _copyLink(NewsArticle article) {
    HapticFeedback.lightImpact();
    Clipboard.setData(ClipboardData(text: article.url ?? ''));
    Get.snackbar(
      'Link Copied',
      'Article link has been copied to clipboard',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.success,
      colorText: Colors.white,
      borderRadius: 12,
      margin: const EdgeInsets.all(16),
      animationDuration: const Duration(milliseconds: 400),
    );
  }

  Future<void> _openInBrowser(NewsArticle article) async {
    HapticFeedback.mediumImpact();
    if (article.url != null && article.url!.isNotEmpty) {
      try {
        await launchUrl(
          Uri.parse(article.url!),
          mode: LaunchMode.externalApplication,
        );
      } catch (e) {
        Get.snackbar(
          'Error',
          'Could not open article',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.error,
          colorText: Colors.white,
          borderRadius: 12,
          margin: const EdgeInsets.all(16),
        );
      }
    }
  }
}
