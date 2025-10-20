import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:news_app/routes/app_pages.dart';
import 'package:news_app/utils/app_colors.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  SplashViewState createState() => SplashViewState();
}

class SplashViewState extends State<SplashView> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _particleController;
  late AnimationController _infiniteRotationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;
  late String _tagline;

  final List<String> _taglines = [
    'Have a great Day, Evening or Night!',
    'Stay informed on the hot news!',
    'Feeling bored? Check this out!',
    'Make sure to stay cozy!',
    'I wonder what\'s on the news today...',
    'Hi!',
    'Oh, you\'re trying to get more text?',
    'Like and subscribe!',
    'Processing images? We don\'t have that!',
    'Looping text!',
  ];

  @override
  void initState() {
    super.initState();

    _tagline = _taglines[Random().nextInt(_taglines.length)];

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    );

    _particleController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    )..repeat();

    _infiniteRotationController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat();

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 0.8, curve: Curves.easeOut),
      ),
    );

    _animationController.forward();

    Future.delayed(const Duration(milliseconds: 3500), () {
      if (mounted) {
        Get.offAllNamed(Routes.HOME);
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _particleController.dispose();
    _infiniteRotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              AppColors.background,
            ],
          ),
        ),
        child: Stack(
          children: [
            AnimatedBuilder(
              animation: _particleController,
              builder: (context, child) {
                return CustomPaint(
                  painter: ParticlePainter(progress: _particleController.value),
                  size: Size.infinite,
                );
              },
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: RotationTransition(
                        turns: _infiniteRotationController,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(32),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.5),
                                blurRadius: 40,
                                offset: const Offset(0, 20),
                                spreadRadius: 8,
                              ),
                              BoxShadow(
                                color: AppColors.accent.withValues(alpha: 0.3),
                                blurRadius: 25,
                                offset: const Offset(0, 10),
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.newspaper_rounded,
                            color: Colors.white,
                            size: 60,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  SlideTransition(
                    position: _slideAnimation,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Column(
                        children: [
                          ShaderMask(
                            shaderCallback: (bounds) =>
                                AppColors.primaryGradient.createShader(
                              Rect.fromLTWH(
                                0,
                                0,
                                bounds.width,
                                bounds.height,
                              ),
                            ),
                            child: const Text(
                              'Welcome to News!',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 56,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: -2,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _tagline,
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.copyWith(
                                  color: AppColors.textSecondary,
                                  letterSpacing: 0.5,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 100),
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      children: [
                        SizedBox(
                          width: 60,
                          height: 60,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              RotationTransition(
                                turns: _particleController,
                                child: Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppColors.primary.withValues(alpha: 0.2),
                                      width: 3,
                                    ),
                                  ),
                                ),
                              ),
                              RotationTransition(
                                turns: _particleController,
                                child: CustomPaint(
                                  size: const Size(60, 60),
                                  painter: GradientCirclePainter(),
                                ),
                              ),
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: AppColors.accentGradient,
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.accent.withValues(alpha: 0.5),
                                      blurRadius: 12,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Loading news...',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ParticlePainter extends CustomPainter {
  ParticlePainter({required this.progress});

  final double progress;
  final Random _random = Random(42);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.05)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 20; i++) {
      final angle = (_random.nextDouble() * 2 * pi) + (progress * 2 * pi);
      final distance = 50 + (_random.nextDouble() * 150);

      final x = size.width / 2 +
          distance * cos(angle + progress * 2 * pi * _random.nextDouble());
      final y = size.height / 2 +
          distance * sin(angle + progress * 2 * pi * _random.nextDouble());

      final radius = 2 + (_random.nextDouble() * 6);

      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant ParticlePainter oldDelegate) => true;
}

class GradientCirclePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final paint = Paint()
      ..shader = AppColors.primaryGradient.createShader(
        Rect.fromCircle(center: center, radius: radius),
      )
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      0,
      pi,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
