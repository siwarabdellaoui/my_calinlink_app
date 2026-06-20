import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/router/app_router.dart';
import '../../../core/network/auth_service.dart';

export 'splash_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController
      _logoController; //contrôle la durée et le déroulement de l'animation.
  late AnimationController _textController;
  late AnimationController _dotsController;

  late Animation<double> _logoScale;
  late Animation<double> _logoFade;
  late Animation<double> _textFade;
  late Animation<Offset> _textSlide;
  late Animation<double> _dotsFade;

  int _currentDot = 0;

  @override
  void initState() {
    super.initState();

    // Logo animation
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _logoScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );

    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    // Text animation
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _textFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeIn),
    );

    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOut),
    );

    // Dots animation
    _dotsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _dotsFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _dotsController, curve: Curves.easeIn),
    );

    _startAnimations();
  }

  Future<void> _startAnimations() async {
    //attendre la fin d'une animation avant de passer à la suivante
    // Lance le logo
    await _logoController.forward();

    // Lance le texte
    await Future.delayed(const Duration(milliseconds: 200));
    await _textController.forward();

    // Lance les dots
    await Future.delayed(const Duration(milliseconds: 300));
    _dotsController.forward();

    // Anime les dots
    _animateDots();

    // Navigue vers login ou home après 2 secondes
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      try {
        final isLoggedIn = await AuthService.isLoggedIn();
        if (isLoggedIn) {
          context.go(AppRoutes.home);
        } else {
          context.go(AppRoutes.login);
        }
      } catch (e) {
        context.go(AppRoutes.login);
      }
    }
  }

  void _animateDots() async {
    for (int i = 0; i < 3; i++) {
      await Future.delayed(const Duration(milliseconds: 400));
      if (mounted) {
        setState(() => _currentDot = i);
      }
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _dotsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Zone logo — centre de l'écran
            Expanded(
              flex: 6,
              child: Center(
                child: FadeTransition(
                  opacity: _logoFade,
                  child: ScaleTransition(
                    scale: _logoScale,
                    child: _buildLogoCircle(),
                  ),
                ),
              ),
            ),

            // Zone texte
            Expanded(
              flex: 3,
              child: FadeTransition(
                opacity: _textFade,
                child: SlideTransition(
                  position: _textSlide,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Nom de l'app
                      RichText(
                        text: const TextSpan(
                          children: [
                            TextSpan(
                              text: 'Câlin',
                              style: TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primaryDark,
                                fontFamily: 'Poppins',
                              ),
                            ),
                            TextSpan(
                              text: 'Link',
                              style: TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primary,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Slogan
                      Text(
                        'Ton bébé dort, tu souffles.',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.secondary,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Zone dots + badge
            Expanded(
              flex: 2,
              child: FadeTransition(
                opacity: _dotsFade,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Dots indicateurs
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(3, (i) {
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: _currentDot == i ? 24 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _currentDot == i
                                ? AppColors.primary
                                : AppColors.primary.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 24),
                    // Badge sécurité
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.shield_outlined,
                          size: 14,
                          color: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.color
                                  ?.withValues(alpha: 0.6) ??
                              context.textSecondary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'MONITORING SÉCURISÉ',
                          style: TextStyle(
                            fontSize: 11,
                            letterSpacing: 1.5,
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.color
                                    ?.withValues(alpha: 0.6) ??
                                context.textSecondary,
                            fontFamily: 'Poppins',
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
    );
  }

  Widget _buildLogoCircle() {
    return Container(
      width: 220,
      height: 220,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.primary.withOpacity(0.12),
      ),
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Étoiles décoratives
            Positioned(
              top: 35,
              right: 45,
              child: _buildStar(AppColors.secondary, 18),
            ),
            Positioned(
              top: 55,
              left: 38,
              child: _buildStar(context.textSecondary, 13),
            ),
            Positioned(
              bottom: 45,
              left: 42,
              child: _buildStar(AppColors.success, 16),
            ),
            // Icône landau bébé
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.baby_changing_station_rounded,
                  size: 80,
                  color: AppColors.primary,
                ),
                const SizedBox(height: 4),
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.secondary,
                  ),
                  child: const Icon(
                    Icons.face_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStar(Color color, double size) {
    return Icon(Icons.star_rounded, color: color, size: size);
  }
}

