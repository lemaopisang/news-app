import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:news_app/models/news_article.dart';
import 'package:news_app/utils/app_colors.dart';

class NewsCard extends StatefulWidget {
  final NewsArticle article;
  final VoidCallback onTap;
  final int index;

  const NewsCard({
    super.key,
    required this.article,
    required this.onTap,
    this.index = 0,
  });

  @override
  State<NewsCard> createState() => _NewsCardState();
}

class _NewsCardState extends State<NewsCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (_isPressed) {
      return;
    }
    setState(() => _isPressed = true);
    HapticFeedback.lightImpact();
  }

  void _handleTapCancel() {
    if (!_isPressed) {
      return;
    }
    setState(() => _isPressed = false);
  }

  void _handleTap() {
    if (_isPressed) {
      setState(() => _isPressed = false);
    }
    HapticFeedback.mediumImpact();
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    final publishedLabel = widget.article.publishedAt != null
        ? timeago.format(DateTime.parse(widget.article.publishedAt!))
        : 'Recently';

    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(
                  alpha: _isPressed ? 0.15 : 0.08,
                ),
                blurRadius: _isPressed ? 20 : 12,
                offset: Offset(0, _isPressed ? 8 : 4),
                spreadRadius: _isPressed ? 1 : 0,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Material(
              color: Colors.white,
              child: InkWell(
                onTap: _handleTap,
                onTapDown: _handleTapDown,
                onTapCancel: _handleTapCancel,
                splashColor: AppColors.primary.withValues(alpha: 0.12),
                highlightColor: AppColors.primary.withValues(alpha: 0.08),
                child: Row(
                  children: [
                    // Image Section
                    SizedBox(
                      width: 120,
                      height: 120,
                      child: _buildNewsImage(),
                    ),
                    // Content Section
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            if (widget.article.title != null)
                              Text(
                                widget.article.title!,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                  height: 1.3,
                                ),
                              ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    publishedLabel,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.textTertiary,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withValues(
                                      alpha: 0.1,
                                    ),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    widget.article.source?.name ?? 'News',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.primary,
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
          ),
        ),
      ),
    );
  }

  Widget _buildNewsImage() {
    if (widget.article.urlToImage == null ||
        widget.article.urlToImage!.isEmpty) {
      return Container(
        color: AppColors.backgroundDark,
        child: const Center(
          child: Icon(
            Icons.image_not_supported_rounded,
            color: AppColors.textTertiary,
            size: 32,
          ),
        ),
      );
    }

    return CachedNetworkImage(
      imageUrl: widget.article.urlToImage!,
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(
        color: AppColors.backgroundDark,
        child: const Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
        ),
      ),
      errorWidget: (context, url, error) => Container(
        color: AppColors.backgroundDark,
        child: const Center(
          child: Icon(
            Icons.image_not_supported_rounded,
            color: AppColors.textTertiary,
            size: 32,
          ),
        ),
      ),
    );
  }
}
