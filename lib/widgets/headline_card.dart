import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:news_app/models/news_article.dart';
import 'package:news_app/utils/app_colors.dart';
import 'package:timeago/timeago.dart' as timeago;

class HeadlineCard extends StatefulWidget {
  const HeadlineCard({super.key, required this.article, required this.onTap});

  final NewsArticle article;
  final VoidCallback onTap;

  @override
  State<HeadlineCard> createState() => _HeadlineCardState();
}

class _HeadlineCardState extends State<HeadlineCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    HapticFeedback.lightImpact();
    _scaleController.forward();
  }

  void _onTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _scaleController.reverse();
    HapticFeedback.mediumImpact();
    widget.onTap();
  }

  void _onTapCancel() {
    setState(() => _isPressed = false);
    _scaleController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final headlineTag = widget.article.source?.name?.toUpperCase();
    final publishedLabel = widget.article.publishedAt != null
        ? timeago.format(DateTime.parse(widget.article.publishedAt!))
        : null;

    return ScaleTransition(
      scale: _scaleAnimation,
      child: Hero(
        tag: 'headline_${widget.article.url}',
        child: GestureDetector(
          onTapDown: _onTapDown,
          onTapUp: _onTapUp,
          onTapCancel: _onTapCancel,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 340,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: _isPressed ? 0.25 : 0.12),
                  blurRadius: _isPressed ? 24 : 16,
                  offset: Offset(0, _isPressed ? 12 : 8),
                  spreadRadius: _isPressed ? 2 : 0,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Background Image
                  if (widget.article.urlToImage != null &&
                      widget.article.urlToImage!.isNotEmpty)
                    CachedNetworkImage(
                      imageUrl: widget.article.urlToImage!,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: AppColors.backgroundDark,
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: AppColors.backgroundDark,
                        child: Icon(
                          Icons.image_not_supported_rounded,
                          color: AppColors.textTertiary,
                          size: 48,
                        ),
                      ),
                    )
                  else
                    Container(
                      color: AppColors.backgroundDark,
                      child: Icon(
                        Icons.image_not_supported_rounded,
                        color: AppColors.textTertiary,
                        size: 48,
                      ),
                    ),
                  // Gradient Overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.7),
                        ],
                      ),
                    ),
                  ),
                  // Content
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Badge
                        if (headlineTag != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.95),
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withValues(alpha: 0.4),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              headlineTag,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: Colors.white,
                                letterSpacing: 0.8,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        const Spacer(),
                        // Title and Meta
                        if (widget.article.title != null)
                          Text(
                            widget.article.title!,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.5,
                            ),
                          ),
                        const SizedBox(height: 12),
                        // Meta Information
                        Row(
                          children: [
                            if (publishedLabel != null)
                              Text(
                                publishedLabel,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.8),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
