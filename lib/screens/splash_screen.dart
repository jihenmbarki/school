import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../models/user_model.dart';
import '../core/constants/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _mainCtrl;
  late AnimationController _pulseCtrl;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;
  late Animation<double> _slideAnim;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _mainCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400));
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1800))
      ..repeat(reverse: true);

    _fadeAnim  = CurvedAnimation(parent: _mainCtrl, curve: const Interval(0.0, 0.6, curve: Curves.easeOut));
    _scaleAnim = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _mainCtrl, curve: const Interval(0.0, 0.7, curve: Curves.easeOutBack)),
    );
    _slideAnim = Tween<double>(begin: 30, end: 0).animate(
      CurvedAnimation(parent: _mainCtrl, curve: const Interval(0.3, 1.0, curve: Curves.easeOut)),
    );
    _pulseAnim = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );

    _mainCtrl.forward();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(milliseconds: 2600));
    if (!mounted) return;
    final auth = context.read<AuthProvider>();
    await auth.loadCurrentUser();
    if (!mounted) return;
    final user = auth.currentUser;
    if (user == null) { Navigator.pushReplacementNamed(context, '/login'); return; }
    switch (user.role) {
      case UserRole.admin:     Navigator.pushReplacementNamed(context, '/admin');     break;
      case UserRole.professor: Navigator.pushReplacementNamed(context, '/professor'); break;
      case UserRole.student:   Navigator.pushReplacementNamed(context, '/student');   break;
    }
  }

  @override
  void dispose() {
    _mainCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: Stack(
          children: [
            // Orbs décoratifs
            Positioned(top: -80, right: -80,
              child: _orb(280, AppColors.primary.withValues(alpha: 0.18))),
            Positioned(bottom: -60, left: -60,
              child: _orb(240, AppColors.violet.withValues(alpha: 0.15))),
            Positioned(top: 200, left: -40,
              child: _orb(160, AppColors.cyan.withValues(alpha: 0.10))),

            Center(
              child: FadeTransition(
                opacity: _fadeAnim,
                child: ScaleTransition(
                  scale: _scaleAnim,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Logo pulsant
                      ScaleTransition(
                        scale: _pulseAnim,
                        child: Container(
                          width: 110,
                          height: 110,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: AppColors.primaryGradient,
                            boxShadow: [
                              BoxShadow(color: AppColors.primary.withValues(alpha: 0.5), blurRadius: 40, spreadRadius: 4),
                              BoxShadow(color: AppColors.cyan.withValues(alpha: 0.3), blurRadius: 60, spreadRadius: 8),
                            ],
                          ),
                          child: ClipOval(
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
                              child: const Icon(Icons.school_rounded, color: Colors.white, size: 52),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      AnimatedBuilder(
                        animation: _slideAnim,
                        builder: (_, child) => Transform.translate(
                          offset: Offset(0, _slideAnim.value),
                          child: child,
                        ),
                        child: Column(
                          children: [
                            ShaderMask(
                              shaderCallback: (b) => AppColors.primaryGradient.createShader(b),
                              child: const Text('School Manager',
                                style: TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Gestion scolaire intelligente',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withValues(alpha: 0.55),
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 64),
                      _loadingDots(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _orb(double size, Color color) => Container(
    width: size, height: size,
    decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
      child: const SizedBox.expand(),
    ),
  );

  Widget _loadingDots() {
    return AnimatedBuilder(
      animation: _pulseCtrl,
      builder: (context2, x) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final delay = i * 0.33;
            final t = (_pulseCtrl.value - delay).clamp(0.0, 1.0);
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: 0.3 + t * 0.7),
              ),
            );
          }),
        );
      },
    );
  }
}
