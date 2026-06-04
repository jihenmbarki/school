import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/firestore_service.dart';
import '../../core/constants/app_colors.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/menu_item_card.dart';
import 'user_management_screen.dart';
import 'class_management_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});
  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final FirestoreService _fs = FirestoreService();
  Map<String, int> _stats = {'students': 0, 'professors': 0, 'classes': 0, 'subjects': 0};
  bool _loading = true;

  @override
  void initState() { super.initState(); _loadStats(); }

  Future<void> _loadStats() async {
    setState(() => _loading = true);
    try {
      final s = await _fs.getDashboardStats();
      if (mounted) setState(() { _stats = s; _loading = false; });
    } catch (_) { if (mounted) setState(() => _loading = false); }
  }

  Future<void> _signOut() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => _ConfirmDialog(
        title: 'Déconnexion',
        message: 'Voulez-vous vraiment vous déconnecter ?',
        confirmLabel: 'Déconnexion',
        confirmColor: AppColors.error,
      ),
    );
    if (ok == true && mounted) {
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
            Positioned(top: -100, right: -80,
              child: _orb(300, AppColors.primary.withValues(alpha: 0.15))),
            Positioned(bottom: -60, left: -60,
              child: _orb(220, AppColors.violet.withValues(alpha: 0.12))),

            SafeArea(
              child: RefreshIndicator(
                onRefresh: _loadStats,
                color: AppColors.primary,
                backgroundColor: AppColors.bg2,
                child: CustomScrollView(
                  slivers: [
                    // Header
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
                                  Text(user?.name ?? 'Administrateur',
                                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                                  const SizedBox(height: 4),
                                  _roleBadge('Administrateur', AppColors.primary),
                                ],
                              ),
                            ),
                            GestureDetector(
                              onTap: _signOut,
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

                    // Stats
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _sectionTitle('Statistiques'),
                            const SizedBox(height: 14),
                            if (_loading)
                              const Center(child: CircularProgressIndicator(color: AppColors.primary))
                            else
                              GridView.count(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                crossAxisCount: 2,
                                mainAxisSpacing: 12,
                                crossAxisSpacing: 12,
                                childAspectRatio: 1.25,
                                children: [
                                  StatCard(title: 'Étudiants',  value: '${_stats['students']}',  icon: Icons.school_rounded,   color: AppColors.primary,
                                    onTap: () => _push(const UserManagementScreen(roleFilter: 'student'))),
                                  StatCard(title: 'Professeurs', value: '${_stats['professors']}', icon: Icons.person_rounded,    color: AppColors.cyan,
                                    onTap: () => _push(const UserManagementScreen(roleFilter: 'professor'))),
                                  StatCard(title: 'Classes',    value: '${_stats['classes']}',  icon: Icons.class_rounded,    color: AppColors.violet,
                                    onTap: () => _push(const ClassManagementScreen())),
                                  StatCard(title: 'Matières',   value: '${_stats['subjects']}', icon: Icons.book_rounded,     color: AppColors.pink),
                                ],
                              ),
                          ],
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
                            _sectionTitle('Gestion'),
                            const SizedBox(height: 14),
                            MenuItemCard(title: 'Gestion des utilisateurs', subtitle: 'Élèves et professeurs',
                              icon: Icons.people_rounded, color: AppColors.cyan,
                              onTap: () => _push(const UserManagementScreen())),
                            MenuItemCard(title: 'Gestion des classes', subtitle: 'Ajouter, modifier, supprimer',
                              icon: Icons.class_rounded, color: AppColors.primary,
                              onTap: () => _push(const ClassManagementScreen())),
                            MenuItemCard(title: 'Notifications', subtitle: 'Envoyer des annonces',
                              icon: Icons.notifications_rounded, color: AppColors.violet,
                              onTap: () => _showNotifSheet()),
                            MenuItemCard(title: 'Actualiser', subtitle: 'Recharger les données',
                              icon: Icons.refresh_rounded, color: AppColors.success,
                              onTap: _loadStats),
                          ],
                        ),
                      ),
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

  void _push(Widget screen) =>
      Navigator.push(context, MaterialPageRoute(builder: (_) => screen));

  void _showNotifSheet() {
    final titleCtrl = TextEditingController();
    final bodyCtrl  = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
            decoration: BoxDecoration(
              color: AppColors.bg2.withValues(alpha: 0.95),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              border: const Border(top: BorderSide(color: AppColors.glassBorder)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: Container(width: 40, height: 4,
                  decoration: BoxDecoration(color: AppColors.glassBorder, borderRadius: BorderRadius.circular(2)))),
                const SizedBox(height: 20),
                const Text('Envoyer une notification',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                const SizedBox(height: 20),
                _sheetField(titleCtrl, 'Titre', Icons.title_rounded),
                const SizedBox(height: 12),
                _sheetField(bodyCtrl, 'Message', Icons.message_rounded, lines: 3),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity, height: 50,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: AppColors.violetGradient,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [BoxShadow(color: AppColors.violet.withValues(alpha: 0.4), blurRadius: 12, offset: const Offset(0, 5))],
                    ),
                    child: ElevatedButton(
                      onPressed: () async {
                        if (titleCtrl.text.isEmpty || bodyCtrl.text.isEmpty) return;
                        final uid = context.read<AuthProvider>().currentUser?.uid ?? '';
                        final messenger = ScaffoldMessenger.of(context);
                        await _fs.sendNotification(_buildNotif(titleCtrl.text, bodyCtrl.text, uid));
                        if (ctx.mounted) Navigator.pop(ctx);
                        messenger.showSnackBar(const SnackBar(content: Text('Notification envoyée ✓')));
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent,
                        foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                      child: const Text('Envoyer', style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _sheetField(TextEditingController c, String label, IconData icon, {int lines = 1}) =>
    TextField(
      controller: c, maxLines: lines,
      style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20, color: AppColors.textSecondary),
        filled: true, fillColor: AppColors.glassWhite,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.glassBorder)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.glassBorder)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
      ),
    );

  dynamic _buildNotif(String title, String body, String uid) => {
    'title': title, 'body': body, 'type': 'general', 'senderId': uid, 'createdAt': DateTime.now(), 'isRead': false,
  };

  Widget _orb(double size, Color color) => Container(width: size, height: size,
    decoration: BoxDecoration(shape: BoxShape.circle, color: color));

  Widget _sectionTitle(String t) => Text(t,
    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary));

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

class _ConfirmDialog extends StatelessWidget {
  final String title, message, confirmLabel;
  final Color confirmColor;
  const _ConfirmDialog({required this.title, required this.message, required this.confirmLabel, required this.confirmColor});

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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                const SizedBox(height: 12),
                Text(message, style: const TextStyle(color: AppColors.textSecondary), textAlign: TextAlign.center),
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
                    style: ElevatedButton.styleFrom(backgroundColor: confirmColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    child: Text(confirmLabel),
                  )),
                ]),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
