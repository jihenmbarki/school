import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../widgets/menu_item_card.dart';
import 'add_homework_screen.dart';
import 'my_homework_screen.dart';
import 'grades_management_screen.dart';
import 'student_list_screen.dart';

class ProfessorDashboard extends StatelessWidget {
  const ProfessorDashboard({super.key});

  Future<void> _signOut(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => _ConfirmLogout(),
    );
    if (ok == true && context.mounted) {
      final auth = context.read<AuthProvider>();
      final nav  = Navigator.of(context);
      await auth.signOut();
      nav.pushReplacementNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: Stack(
          children: [
            Positioned(top: -80, right: -80,
              child: _orb(260, AppColors.cyan.withValues(alpha: 0.14))),
            Positioned(bottom: -60, left: -40,
              child: _orb(200, AppColors.primary.withValues(alpha: 0.12))),

            SafeArea(
              child: CustomScrollView(
                slivers: [
                  // Header card
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Bonjour,',
                                  style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.5))),
                                Text(user?.name ?? 'Professeur',
                                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                                const SizedBox(height: 4),
                                _roleBadge('Professeur', AppColors.cyan),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () => _signOut(context),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppColors.error.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                                  ),
                                  child: const Icon(Icons.logout_rounded, color: AppColors.error, size: 22),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Profile glass card
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(22),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  AppColors.cyan.withValues(alpha: 0.18),
                                  AppColors.primary.withValues(alpha: 0.10),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(22),
                              border: Border.all(color: AppColors.cyan.withValues(alpha: 0.25)),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 56, height: 56,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: AppColors.cyanGradient,
                                    boxShadow: [BoxShadow(color: AppColors.cyan.withValues(alpha: 0.4), blurRadius: 14)],
                                  ),
                                  child: Center(
                                    child: Text(
                                      user?.name.isNotEmpty == true ? user!.name[0].toUpperCase() : '?',
                                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(user?.email ?? '',
                                        style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                                      if (user?.subject != null) ...[
                                        const SizedBox(height: 4),
                                        Row(children: [
                                          const Icon(Icons.book_rounded, size: 13, color: AppColors.cyan),
                                          const SizedBox(width: 4),
                                          Text(user!.subject!,
                                            style: const TextStyle(fontSize: 12, color: AppColors.cyan, fontWeight: FontWeight.w600)),
                                        ]),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Menu
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 28, 20, 32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Menu', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                          const SizedBox(height: 14),
                          MenuItemCard(title: 'Publier un devoir', subtitle: 'Créer et publier un nouveau devoir',
                            icon: Icons.assignment_rounded, color: AppColors.primary,
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddHomeworkScreen()))),
                          MenuItemCard(title: 'Mes devoirs', subtitle: 'Voir les devoirs publiés',
                            icon: Icons.list_alt_rounded, color: AppColors.cyan,
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MyHomeworkScreen()))),
                          MenuItemCard(title: 'Affecter des notes', subtitle: 'Saisir et gérer les notes',
                            icon: Icons.grade_rounded, color: AppColors.violet,
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GradesManagementScreen()))),
                          MenuItemCard(title: 'Liste des étudiants', subtitle: 'Voir les élèves de vos classes',
                            icon: Icons.people_rounded, color: AppColors.pink,
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StudentListScreen()))),
                        ],
                      ),
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

  Widget _orb(double size, Color color) => Container(
    width: size, height: size,
    decoration: BoxDecoration(shape: BoxShape.circle, color: color));

  Widget _roleBadge(String label, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.15),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: color.withValues(alpha: 0.3)),
    ),
    child: Text(label, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
  );
}

class _ConfirmLogout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.bg2.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.glassBorder),
            ),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Text('Déconnexion', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              const SizedBox(height: 12),
              const Text('Voulez-vous vraiment vous déconnecter ?',
                style: TextStyle(color: AppColors.textSecondary), textAlign: TextAlign.center),
              const SizedBox(height: 24),
              Row(children: [
                Expanded(child: OutlinedButton(
                  onPressed: () => Navigator.pop(context, false),
                  style: OutlinedButton.styleFrom(foregroundColor: AppColors.textSecondary,
                    side: const BorderSide(color: AppColors.glassBorder),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  child: const Text('Annuler'),
                )),
                const SizedBox(width: 12),
                Expanded(child: ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  child: const Text('Déconnexion'),
                )),
              ]),
            ]),
          ),
        ),
      ),
    );
  }
}
