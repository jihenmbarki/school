import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/grade_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/firestore_service.dart';
import '../../core/constants/app_colors.dart';

class GradesScreen extends StatelessWidget {
  const GradesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthProvider>().currentUser!;
    final fs   = FirestoreService();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              // AppBar
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Row(children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(color: AppColors.glassWhite,
                            borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.glassBorder)),
                          child: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 18),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Text('Mes notes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                ]),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: StreamBuilder<List<GradeModel>>(
                  stream: fs.streamGradesByStudent(user.uid),
                  builder: (ctx, snap) {
                    if (snap.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                    }
                    final grades = snap.data ?? [];
                    if (grades.isEmpty) {
                      return const Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                        Icon(Icons.grade_outlined, size: 56, color: AppColors.textHint),
                        SizedBox(height: 12),
                        Text('Aucune note disponible.', style: TextStyle(color: AppColors.textSecondary, fontSize: 15)),
                      ]));
                    }
                    final avg = calculateAverage(grades);
                    return ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        // Average card
                        ClipRRect(
                          borderRadius: BorderRadius.circular(22),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                            child: Container(
                              padding: const EdgeInsets.all(22),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                                  colors: [_avgColor(avg).withValues(alpha: 0.28), _avgColor(avg).withValues(alpha: 0.10)],
                                ),
                                borderRadius: BorderRadius.circular(22),
                                border: Border.all(color: _avgColor(avg).withValues(alpha: 0.35)),
                              ),
                              child: Row(children: [
                                Container(
                                  width: 64, height: 64,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(colors: [_avgColor(avg), _avgColor(avg).withValues(alpha: 0.6)]),
                                    boxShadow: [BoxShadow(color: _avgColor(avg).withValues(alpha: 0.45), blurRadius: 16)],
                                  ),
                                  child: const Icon(Icons.bar_chart_rounded, color: Colors.white, size: 30),
                                ),
                                const SizedBox(width: 20),
                                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  Text('Moyenne générale',
                                    style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.6))),
                                  Text(avg.toStringAsFixed(2),
                                    style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: _avgColor(avg))),
                                  Text(_avgLabel(avg),
                                    style: TextStyle(fontSize: 13, color: _avgColor(avg), fontWeight: FontWeight.w600)),
                                ]),
                              ]),
                            ),
                          ),
                        ),
                        const SizedBox(height: 22),
                        const Text('Détail des notes',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                        const SizedBox(height: 12),
                        ...grades.map((g) => _GradeTile(grade: g)),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _avgColor(double v) {
    if (v >= 14) return AppColors.success;
    if (v >= 10) return AppColors.warning;
    return AppColors.error;
  }

  String _avgLabel(double v) {
    if (v >= 16) return 'Très Bien';
    if (v >= 14) return 'Bien';
    if (v >= 12) return 'Assez Bien';
    if (v >= 10) return 'Passable';
    return 'Insuffisant';
  }
}

class _GradeTile extends StatelessWidget {
  final GradeModel grade;
  const _GradeTile({required this.grade});

  Color get _c {
    if (grade.grade >= 14) return AppColors.success;
    if (grade.grade >= 10) return AppColors.warning;
    return AppColors.error;
  }

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
                width: 42, height: 42,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: _c.withValues(alpha: 0.15),
                  border: Border.all(color: _c.withValues(alpha: 0.3)),
                ),
                child: Icon(Icons.book_rounded, color: _c, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(grade.subjectName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.textPrimary)),
                if (grade.comment != null && grade.comment!.isNotEmpty)
                  Text(grade.comment!, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              ])),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [_c, _c.withValues(alpha: 0.65)]),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(color: _c.withValues(alpha: 0.35), blurRadius: 8)],
                ),
                child: Text('${grade.grade}/20',
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Colors.white)),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
