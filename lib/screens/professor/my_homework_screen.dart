import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/homework_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/firestore_service.dart';
import '../../core/constants/app_colors.dart';

class MyHomeworkScreen extends StatelessWidget {
  const MyHomeworkScreen({super.key});

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
              Expanded(
                child: StreamBuilder<List<HomeworkModel>>(
                  stream: fs.streamHomeworkByProfessor(user.uid),
                  builder: (ctx, snap) {
                    if (snap.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                    }
                    final list = snap.data ?? [];
                    if (list.isEmpty) {
                      return const Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                        Icon(Icons.assignment_outlined, size: 56, color: AppColors.textHint),
                        SizedBox(height: 12),
                        Text('Aucun devoir publié.', style: TextStyle(color: AppColors.textSecondary, fontSize: 15)),
                      ]));
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: list.length,
                      itemBuilder: (c, i) => _HwTile(hw: list[i], fs: fs),
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

class _HwTile extends StatelessWidget {
  final HomeworkModel hw;
  final FirestoreService fs;
  const _HwTile({required this.hw, required this.fs});

  @override
  Widget build(BuildContext context) {
    final overdue = hw.isOverdue;
    final color   = overdue ? AppColors.error : AppColors.success;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.glassWhite,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.glassBorder),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(child: Text(hw.title,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.textPrimary))),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                  decoration: BoxDecoration(color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8), border: Border.all(color: color.withValues(alpha: 0.3))),
                  child: Text(overdue ? 'Expiré' : 'Actif',
                    style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w700)),
                ),
              ]),
              const SizedBox(height: 6),
              Text(hw.description, maxLines: 2, overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
              const SizedBox(height: 12),
              Row(children: [
                Icon(Icons.calendar_today_rounded, size: 13, color: AppColors.textHint),
                const SizedBox(width: 4),
                Text(DateFormat('dd/MM/yyyy').format(hw.dueDate),
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                const SizedBox(width: 14),
                Icon(Icons.check_circle_outline_rounded, size: 13, color: AppColors.cyan),
                const SizedBox(width: 4),
                Text('${hw.completedByStudents.length} rendu(s)',
                  style: const TextStyle(fontSize: 11, color: AppColors.cyan)),
                const Spacer(),
                GestureDetector(
                  onTap: () => _confirmDelete(context),
                  child: Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(color: AppColors.error.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 16),
                  ),
                ),
              ]),
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
              decoration: BoxDecoration(color: AppColors.bg2.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.glassBorder)),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Text('Supprimer le devoir', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                const SizedBox(height: 10),
                Text('Supprimer "${hw.title}" ?', style: const TextStyle(color: AppColors.textSecondary), textAlign: TextAlign.center),
                const SizedBox(height: 20),
                Row(children: [
                  Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(foregroundColor: AppColors.textSecondary,
                      side: const BorderSide(color: AppColors.glassBorder),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                    child: const Text('Annuler'))),
                  const SizedBox(width: 10),
                  Expanded(child: ElevatedButton(
                    onPressed: () async { Navigator.pop(context); await fs.deleteHomework(hw.id); },
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                    child: const Text('Supprimer'))),
                ]),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
