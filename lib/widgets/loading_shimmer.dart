import 'package:flutter/material.dart';
import 'package:news_app/utils/app_colors.dart';

class LoadingShimmer extends StatefulWidget {
  const LoadingShimmer({super.key});

  @override
  LoadingShimmerState createState() => LoadingShimmerState();
}

class LoadingShimmerState extends State<LoadingShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat();

    _animation = Tween<double>(begin: -2.0, end: 2.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOutCubic),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
  padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image shimmer
              AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return Container(
                    height: 200,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                      gradient: LinearGradient(
                        begin: Alignment(_animation.value, 0),
                        end: Alignment(_animation.value + 1, 0),
                        colors: const [
                          Color(0xFFE0E0E0),
                          Color(0xFFF5F5F5),
                          Color(0xFFE0E0E0),
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      ),
                    ),
                  );
                },
              ),

              Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Source shimmer
                    AnimatedBuilder(
                      animation: _animation,
                      builder: (context, child) {
                        return Container(
                          height: 12,
                          width: 100,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6),
                            color: AppColors.divider,
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 12),

                    // Title shimmer
                    AnimatedBuilder(
                      animation: _animation,
                      builder: (context, child) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 16,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: AppColors.divider,
                              ),
                            ),
                            SizedBox(height: 8),
                            Container(
                              height: 16,
                              width: MediaQuery.of(context).size.width * 0.7,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: AppColors.divider,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    SizedBox(height: 12),

                    // Description shimmer
                    AnimatedBuilder(
                      animation: _animation,
                      builder: (context, child) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 14,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(7),
                                color: AppColors.divider,
                              ),
                            ),
                            SizedBox(height: 6),
                            Container(
                              height: 14,
                              width: MediaQuery.of(context).size.width * 0.5,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(7),
                                color: AppColors.divider,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
