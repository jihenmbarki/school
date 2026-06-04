import 'dart:ui';
import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../models/grade_model.dart';
import '../../services/firestore_service.dart';
import '../../core/constants/app_colors.dart';

class StudentListScreen extends StatelessWidget {
  const StudentListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final fs = FirestoreService();
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
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
                  const Text('Liste des étudiants', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                ]),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: StreamBuilder<List<UserModel>>(
                  stream: fs.streamUsersByRole(UserRole.student),
                  builder: (ctx, snap) {
                    if (snap.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                    }
                    final students = snap.data ?? [];
                    if (students.isEmpty) {
                      return const Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                        Icon(Icons.people_outline_rounded, size: 56, color: AppColors.textHint),
                        SizedBox(height: 12),
                        Text('Aucun étudiant inscrit.', style: TextStyle(color: AppColors.textSecondary, fontSize: 15)),
                      ]));
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: students.length,
                      itemBuilder: (c, i) => _StudentTile(student: students[i], fs: fs),
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
}

class _StudentTile extends StatelessWidget {
  final UserModel student;
  final FirestoreService fs;
  const _StudentTile({required this.student, required this.fs});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              leading: Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(colors: [AppColors.pink, AppColors.violet]),
                  boxShadow: [BoxShadow(color: AppColors.pink.withValues(alpha: 0.35), blurRadius: 8)],
                ),
                child: Center(child: Text(
                  student.name.isNotEmpty ? student.name[0].toUpperCase() : '?',
                  style: const TextStyle(fontWeight: FontWeight.w800, color: Colors.white),
                )),
              ),
              title: Text(student.name.isNotEmpty ? student.name : 'Sans nom',
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.textPrimary)),
              subtitle: Text(student.email, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              iconColor: AppColors.textSecondary,
              collapsedIconColor: AppColors.textHint,
              backgroundColor: AppColors.glassWhite,
              collapsedBackgroundColor: AppColors.glassWhite,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: AppColors.glassBorder)),
              collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: AppColors.glassBorder)),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                  child: StreamBuilder<List<GradeModel>>(
                    stream: fs.streamGradesByStudent(student.uid),
                    builder: (ctx, snap) {
                      if (snap.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary));
                      }
                      if (snap.hasError) {
                        return Text('Erreur: ${snap.error}',
                          style: const TextStyle(color: AppColors.error, fontSize: 12));
                      }
                      final grades = snap.data ?? [];
                      if (grades.isEmpty) {
                        return const Text('Aucune note disponible.',
                          style: TextStyle(color: AppColors.textHint, fontSize: 12));
                      }
                      final avg = calculateAverage(grades);
                      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        ...grades.map((g) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 3),
                          child: Row(children: [
                            Expanded(child: Text(g.subjectName,
                              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary))),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                              decoration: BoxDecoration(
                                color: _gradeColor(g.grade).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: _gradeColor(g.grade).withValues(alpha: 0.3)),
                              ),
                              child: Text('${g.grade}/20',
                                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: _gradeColor(g.grade))),
                            ),
                          ]),
                        )),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Divider(color: AppColors.divider),
                        ),
                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          const Text('Moyenne', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(colors: [_gradeColor(avg), _gradeColor(avg).withValues(alpha: 0.65)]),
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [BoxShadow(color: _gradeColor(avg).withValues(alpha: 0.35), blurRadius: 6)],
                            ),
                            child: Text(avg.toStringAsFixed(2),
                              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Colors.white)),
                          ),
                        ]),
                      ]);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _gradeColor(double g) {
    if (g >= 14) return AppColors.success;
    if (g >= 10) return AppColors.warning;
    return AppColors.error;
  }
}
