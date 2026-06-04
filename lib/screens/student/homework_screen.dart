import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/homework_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/firestore_service.dart';
import '../../core/constants/app_colors.dart';

class HomeworkScreen extends StatelessWidget {
  const HomeworkScreen({super.key});

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
                  const Text('Mes devoirs', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                ]),
              ),
              const SizedBox(height: 8),
              if (user.classId == null)
                const Expanded(child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.warning_amber_rounded, size: 56, color: AppColors.warning),
                  SizedBox(height: 12),
                  Text('Vous n\'êtes pas assigné à une classe.',
                    style: TextStyle(color: AppColors.textSecondary), textAlign: TextAlign.center),
                ])))
              else
                Expanded(
                  child: StreamBuilder<List<HomeworkModel>>(
                    stream: fs.streamHomeworkByClass(user.classId!),
                    builder: (ctx, snap) {
                      if (snap.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                      }
                      final list = snap.data ?? [];
                      if (list.isEmpty) {
                        return const Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                          Icon(Icons.assignment_outlined, size: 56, color: AppColors.textHint),
                          SizedBox(height: 12),
                          Text('Aucun devoir pour le moment.',
                            style: TextStyle(color: AppColors.textSecondary, fontSize: 15)),
                        ]));
                      }
                      return ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: list.length,
                        itemBuilder: (c, i) => _HwCard(hw: list[i], uid: user.uid, fs: fs),
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

class _HwCard extends StatelessWidget {
  final HomeworkModel hw;
  final String uid;
  final FirestoreService fs;
  const _HwCard({required this.hw, required this.uid, required this.fs});

  @override
  Widget build(BuildContext context) {
    final done    = hw.isCompletedBy(uid);
    final overdue = hw.isOverdue;
    final color   = done ? AppColors.success : (overdue ? AppColors.error : AppColors.primary);

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft, end: Alignment.bottomRight,
                colors: [color.withValues(alpha: 0.12), color.withValues(alpha: 0.04)],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: color.withValues(alpha: 0.25)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Expanded(child: Text(hw.title,
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15,
                      color: AppColors.textPrimary,
                      decoration: done ? TextDecoration.lineThrough : null))),
                  _statusBadge(done, overdue),
                ]),
                const SizedBox(height: 6),
                Text(hw.description, maxLines: 2, overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                const SizedBox(height: 12),
                Row(children: [
                  Icon(Icons.person_outline_rounded, size: 13, color: color),
                  const SizedBox(width: 4),
                  Text(hw.professorName, style: TextStyle(fontSize: 11, color: color)),
                  const SizedBox(width: 12),
                  Icon(Icons.calendar_today_rounded, size: 13, color: color),
                  const SizedBox(width: 4),
                  Text(DateFormat('dd/MM/yyyy').format(hw.dueDate),
                    style: TextStyle(fontSize: 11, color: color, fontWeight: overdue ? FontWeight.w700 : FontWeight.normal)),
                  const Spacer(),
                  GestureDetector(
                    onTap: () async {
                      if (done) {
                        await fs.unmarkHomeworkDone(hw.id, uid);
                      } else {
                        await fs.markHomeworkDone(hw.id, uid);
                      }
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: done ? AppColors.successGradient : AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [BoxShadow(color: color.withValues(alpha: 0.35), blurRadius: 8)],
                      ),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(done ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                          color: Colors.white, size: 14),
                        const SizedBox(width: 5),
                        Text(done ? 'Annuler' : 'Marquer fait',
                          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
                      ]),
                    ),
                  ),
                ]),
              ]),
            ),
          ),
        ),
      ),
    );
  }

  Widget _statusBadge(bool done, bool overdue) {
    if (done) return _badge('Fait', AppColors.success);
    if (overdue) return _badge('Expiré', AppColors.error);
    return _badge('Actif', AppColors.primary);
  }

  Widget _badge(String label, Color c) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(color: c.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8),
      border: Border.all(color: c.withValues(alpha: 0.3))),
    child: Text(label, style: TextStyle(fontSize: 10, color: c, fontWeight: FontWeight.w700)),
  );
}
