import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/user_model.dart';
import '../../core/constants/app_colors.dart';
import '../../widgets/gradient_button.dart';
import '../../widgets/custom_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _formKey    = GlobalKey<FormState>();
  final _emailCtrl  = TextEditingController();
  final _passCtrl   = TextEditingController();
  late AnimationController _ctrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _fadeAnim  = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final ok   = await auth.signIn(email: _emailCtrl.text, password: _passCtrl.text);
    if (!mounted) return;
    if (ok) {
      switch (auth.currentUser?.role) {
        case UserRole.admin:     Navigator.pushReplacementNamed(context, '/admin');     break;
        case UserRole.professor: Navigator.pushReplacementNamed(context, '/professor'); break;
        case UserRole.student:
        case null:               Navigator.pushReplacementNamed(context, '/student');   break;
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(auth.error ?? 'Erreur de connexion'),
        backgroundColor: AppColors.error,
      ));
    }
  }

  Future<void> _forgotPassword() async {
    if (_emailCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Entrez votre email d\'abord.'),
      ));
      return;
    }
    final auth      = context.read<AuthProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final ok        = await auth.resetPassword(_emailCtrl.text.trim());
    messenger.showSnackBar(SnackBar(
      content: Text(ok ? 'Email de réinitialisation envoyé.' : (auth.error ?? 'Erreur.')),
      backgroundColor: ok ? AppColors.success : AppColors.error,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: Stack(
          children: [
            // Orbs
            Positioned(top: -100, right: -80,
              child: _orb(300, AppColors.primary.withValues(alpha: 0.18))),
            Positioned(bottom: -80, left: -80,
              child: _orb(260, AppColors.violet.withValues(alpha: 0.15))),

            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                  child: FadeTransition(
                    opacity: _fadeAnim,
                    child: SlideTransition(
                      position: _slideAnim,
                      child: Column(
                        children: [
                          // Logo
                          Container(
                            width: 86,
                            height: 86,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: AppColors.primaryGradient,
                              boxShadow: [
                                BoxShadow(color: AppColors.primary.withValues(alpha: 0.5), blurRadius: 32, spreadRadius: 2),
                              ],
                            ),
                            child: const Icon(Icons.school_rounded, color: Colors.white, size: 42),
                          ),
                          const SizedBox(height: 20),
                          ShaderMask(
                            shaderCallback: (b) => AppColors.primaryGradient.createShader(b),
                            child: const Text('School Manager',
                              style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Colors.white),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text('Connectez-vous à votre espace',
                            style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.5))),
                          const SizedBox(height: 36),

                          // Glass card
                          ClipRRect(
                            borderRadius: BorderRadius.circular(28),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                              child: Container(
                                padding: const EdgeInsets.all(28),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.07),
                                  borderRadius: BorderRadius.circular(28),
                                  border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
                                ),
                                child: Form(
                                  key: _formKey,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('Connexion',
                                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                                      const SizedBox(height: 4),
                                      Text('Votre rôle est détecté automatiquement',
                                        style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.4))),
                                      const SizedBox(height: 24),

                                      CustomTextField(
                                        label: 'Email',
                                        hint: 'exemple@ecole.fr',
                                        controller: _emailCtrl,
                                        prefixIcon: Icons.email_outlined,
                                        keyboardType: TextInputType.emailAddress,
                                        validator: (v) {
                                          if (v == null || v.isEmpty) return 'Champ requis';
                                          if (!v.contains('@')) return 'Email invalide';
                                          return null;
                                        },
                                      ),
                                      const SizedBox(height: 16),

                                      CustomTextField(
                                        label: 'Mot de passe',
                                        controller: _passCtrl,
                                        prefixIcon: Icons.lock_outline_rounded,
                                        obscureText: true,
                                        validator: (v) {
                                          if (v == null || v.isEmpty) return 'Champ requis';
                                          if (v.length < 6) return 'Minimum 6 caractères';
                                          return null;
                                        },
                                      ),
                                      const SizedBox(height: 8),

                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: TextButton(
                                          onPressed: _forgotPassword,
                                          style: TextButton.styleFrom(padding: EdgeInsets.zero),
                                          child: Text('Mot de passe oublié ?',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: AppColors.cyan,
                                              fontWeight: FontWeight.w500,
                                            )),
                                        ),
                                      ),
                                      const SizedBox(height: 20),

                                      Consumer<AuthProvider>(
                                        builder: (context, auth, _) => GradientButton(
                                          label: 'Se connecter',
                                          onPressed: _login,
                                          isLoading: auth.isLoading,
                                          icon: Icons.login_rounded,
                                          gradient: AppColors.primaryGradient,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 32),
                          // Role badges
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _badge('Admin', Icons.admin_panel_settings_outlined, AppColors.primary),
                              const SizedBox(width: 10),
                              _badge('Professeur', Icons.person_outline_rounded, AppColors.cyan),
                              const SizedBox(width: 10),
                              _badge('Élève', Icons.school_outlined, AppColors.violet),
                            ],
                          ),
                        ],
                      ),
                    ),
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
  );

  Widget _badge(String label, IconData icon, Color color) => ClipRRect(
    borderRadius: BorderRadius.circular(20),
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
          Text(label, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
        ]),
      ),
    ),
  );
}
