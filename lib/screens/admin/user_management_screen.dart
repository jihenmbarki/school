import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user_model.dart';
import '../../services/firestore_service.dart';
import '../../providers/auth_provider.dart';
import '../../core/constants/app_colors.dart';

class UserManagementScreen extends StatefulWidget {
  final String? roleFilter;
  const UserManagementScreen({super.key, this.roleFilter});
  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> with SingleTickerProviderStateMixin {
  late TabController _tab;
  final FirestoreService _fs = FirestoreService();

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
    if (widget.roleFilter == 'professor') _tab.index = 1;
  }

  @override
  void dispose() { _tab.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              // AppBar custom
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.glassWhite,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.glassBorder),
                            ),
                            child: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 18),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(child: Text('Utilisateurs', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary))),
                    GestureDetector(
                      onTap: () => _showAddDialog(context),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              gradient: AppColors.primaryGradient,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.4), blurRadius: 10)],
                            ),
                            child: const Icon(Icons.person_add_rounded, color: Colors.white, size: 20),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Tabs
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.glassWhite,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.glassBorder),
                      ),
                      child: TabBar(
                        controller: _tab,
                        indicator: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.4), blurRadius: 8)],
                        ),
                        labelColor: Colors.white,
                        unselectedLabelColor: AppColors.textSecondary,
                        indicatorSize: TabBarIndicatorSize.tab,
                        dividerColor: Colors.transparent,
                        tabs: const [
                          Tab(text: 'Élèves', icon: Icon(Icons.school_rounded, size: 18)),
                          Tab(text: 'Professeurs', icon: Icon(Icons.person_rounded, size: 18)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              Expanded(
                child: TabBarView(
                  controller: _tab,
                  children: [
                    _UserList(role: UserRole.student,   fs: _fs),
                    _UserList(role: UserRole.professor, fs: _fs),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddDialog(BuildContext ctx) {
    final nameCtrl    = TextEditingController();
    final emailCtrl   = TextEditingController();
    final passCtrl    = TextEditingController();
    final subjectCtrl = TextEditingController();
    var role    = _tab.index == 0 ? UserRole.student : UserRole.professor;
    bool loading = false;

    showDialog(
      context: ctx,
      builder: (dCtx) => StatefulBuilder(
        builder: (dCtx, ss) => Dialog(
          backgroundColor: Colors.transparent,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.bg2.withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.glassBorder),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Nouvel utilisateur',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                      const SizedBox(height: 20),
                      _gField(nameCtrl,  'Nom complet',   Icons.person_outline_rounded),
                      const SizedBox(height: 12),
                      _gField(emailCtrl, 'Email',         Icons.email_outlined, type: TextInputType.emailAddress),
                      const SizedBox(height: 12),
                      _gField(passCtrl,  'Mot de passe',  Icons.lock_outline_rounded, obscure: true),
                      const SizedBox(height: 12),
                      // Role selector
                      Row(children: [
                        Expanded(child: _roleChip('Élève',      UserRole.student,   role, (r) => ss(() => role = r))),
                        const SizedBox(width: 8),
                        Expanded(child: _roleChip('Professeur', UserRole.professor, role, (r) => ss(() => role = r))),
                      ]),
                      if (role == UserRole.professor) ...[
                        const SizedBox(height: 12),
                        _gField(subjectCtrl, 'Matière', Icons.book_outlined),
                      ],
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity, height: 48,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.4), blurRadius: 10)],
                          ),
                          child: ElevatedButton(
                            onPressed: loading ? null : () async {
                              ss(() => loading = true);
                              await ctx.read<AuthProvider>().register(
                                email: emailCtrl.text, password: passCtrl.text,
                                name: nameCtrl.text, role: role,
                                subject: role == UserRole.professor ? subjectCtrl.text : null,
                              );
                              if (dCtx.mounted) Navigator.pop(dCtx);
                              if (ctx.mounted) {
                                ScaffoldMessenger.of(ctx).showSnackBar(
                                  const SnackBar(content: Text('Utilisateur créé ✓')));
                              }
                            },
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent, foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                            child: loading
                              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                              : const Text('Créer', style: TextStyle(fontWeight: FontWeight.w700)),
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
      ),
    );
  }

  Widget _gField(TextEditingController c, String label, IconData icon,
      {TextInputType type = TextInputType.text, bool obscure = false}) =>
    TextField(
      controller: c, keyboardType: type, obscureText: obscure,
      style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 18, color: AppColors.textSecondary),
        filled: true, fillColor: AppColors.glassWhite,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.glassBorder)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.glassBorder)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    );

  Widget _roleChip(String label, UserRole value, UserRole selected, ValueChanged<UserRole> onChange) {
    final isSelected = selected == value;
    return GestureDetector(
      onTap: () => onChange(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          gradient: isSelected ? AppColors.primaryGradient : null,
          color: isSelected ? null : AppColors.glassWhite,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isSelected ? Colors.transparent : AppColors.glassBorder),
        ),
        child: Center(
          child: Text(label, style: TextStyle(
            fontSize: 13, fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : AppColors.textSecondary,
          )),
        ),
      ),
    );
  }
}

class _UserList extends StatelessWidget {
  final UserRole role;
  final FirestoreService fs;
  const _UserList({required this.role, required this.fs});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<UserModel>>(
      stream: fs.streamUsersByRole(role),
      builder: (ctx, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }
        final users = snap.data ?? [];
        if (users.isEmpty) {
          return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(role == UserRole.student ? Icons.school_rounded : Icons.person_rounded,
              size: 56, color: AppColors.textHint),
            const SizedBox(height: 12),
            Text(role == UserRole.student ? 'Aucun élève' : 'Aucun professeur',
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 15)),
          ]));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: users.length,
          itemBuilder: (c, i) => _UserTile(user: users[i], fs: fs),
        );
      },
    );
  }
}

class _UserTile extends StatelessWidget {
  final UserModel user;
  final FirestoreService fs;
  const _UserTile({required this.user, required this.fs});

  Color get _color => user.role == UserRole.student ? AppColors.primary : AppColors.cyan;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.glassWhite,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.glassBorder),
            ),
            child: Row(children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(colors: [_color, _color.withValues(alpha: 0.6)]),
                ),
                child: Center(child: Text(
                  user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                  style: const TextStyle(fontWeight: FontWeight.w800, color: Colors.white, fontSize: 16),
                )),
              ),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(user.name.isNotEmpty ? user.name : 'Sans nom',
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.textPrimary)),
                Text(user.email, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              ])),
              GestureDetector(
                onTap: () => _confirmDelete(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 18),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: AppColors.bg2.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.glassBorder),
              ),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Text('Supprimer', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                const SizedBox(height: 10),
                Text('Supprimer ${user.name} ?', style: const TextStyle(color: AppColors.textSecondary), textAlign: TextAlign.center),
                const SizedBox(height: 20),
                Row(children: [
                  Expanded(child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(foregroundColor: AppColors.textSecondary,
                      side: const BorderSide(color: AppColors.glassBorder),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                    child: const Text('Annuler'),
                  )),
                  const SizedBox(width: 10),
                  Expanded(child: ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(context);
                      await fs.deleteUser(user.uid);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Utilisateur supprimé.')));
                      }
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                    child: const Text('Supprimer'),
                  )),
                ]),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
