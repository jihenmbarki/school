import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/grade_model.dart';
import '../../models/class_model.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/firestore_service.dart';
import '../../core/constants/app_colors.dart';

class GradesManagementScreen extends StatefulWidget {
  const GradesManagementScreen({super.key});
  @override
  State<GradesManagementScreen> createState() => _GradesManagementScreenState();
}

class _GradesManagementScreenState extends State<GradesManagementScreen> {
  final FirestoreService _fs = FirestoreService();
  List<ClassModel> _classes  = [];
  ClassModel? _selectedClass;
  List<UserModel> _students  = [];
  bool _loading = false;

  @override
  void initState() { super.initState(); _loadClasses(); }

  Future<void> _loadClasses() async {
    setState(() => _loading = true);
    final c = await _fs.getClasses();
    if (mounted) setState(() { _classes = c; _loading = false; });
  }

  Future<void> _loadStudents(String classId) async {
    final all = await _fs.getUsersByRole(UserRole.student);
    if (mounted) setState(() => _students = all.where((s) => s.classId == classId).toList());
  }

  void _showAddGradeDialog(UserModel student) {
    final gradeCtrl   = TextEditingController();
    final commentCtrl = TextEditingController();
    final user = context.read<AuthProvider>().currentUser!;

    showDialog(
      context: context,
      builder: (dCtx) => Dialog(
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
              child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Note pour ${student.name}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                const SizedBox(height: 16),
                _gField(gradeCtrl, 'Note /20', Icons.grade_rounded, type: const TextInputType.numberWithOptions(decimal: true)),
                const SizedBox(height: 12),
                _gField(commentCtrl, 'Commentaire (optionnel)', Icons.comment_outlined),
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
                      onPressed: () async {
                        final g = double.tryParse(gradeCtrl.text);
                        if (g == null || g < 0 || g > 20) return;
                        final messenger = ScaffoldMessenger.of(context);
                        await _fs.addGrade(GradeModel(
                          id: '', studentId: student.uid, studentName: student.name,
                          subjectId: user.subject ?? '', subjectName: user.subject ?? '',
                          classId: _selectedClass!.id, grade: g, coefficient: 1.0,
                          comment: commentCtrl.text.isEmpty ? null : commentCtrl.text,
                          professorId: user.uid, createdAt: DateTime.now(),
                        ));
                        if (dCtx.mounted) Navigator.pop(dCtx);
                        messenger.showSnackBar(const SnackBar(
                          content: Text('Note ajoutée ✓'), backgroundColor: AppColors.success));
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent, foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                      child: const Text('Enregistrer', style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ),
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                  const Text('Affecter des notes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                ]),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: _loading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                  : Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        // Class picker
                        ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                            child: DropdownButtonFormField<ClassModel>(
                              initialValue: _selectedClass,
                              dropdownColor: AppColors.bg2,
                              style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                              decoration: InputDecoration(
                                labelText: 'Sélectionner une classe',
                                labelStyle: const TextStyle(color: AppColors.textSecondary),
                                prefixIcon: const Icon(Icons.class_rounded, size: 20, color: AppColors.textSecondary),
                                filled: true, fillColor: AppColors.glassWhite,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.glassBorder)),
                                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.glassBorder)),
                                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
                              ),
                              items: _classes.map((c) => DropdownMenuItem(value: c,
                                child: Text(c.name, style: const TextStyle(color: AppColors.textPrimary)))).toList(),
                              onChanged: (c) {
                                setState(() { _selectedClass = c; _students = []; });
                                if (c != null) _loadStudents(c.id);
                              },
                            ),
                          ),
                        ),
                        if (_selectedClass != null) ...[
                          const SizedBox(height: 16),
                          Expanded(
                            child: _students.isEmpty
                              ? const Center(child: Text('Aucun élève dans cette classe.',
                                  style: TextStyle(color: AppColors.textSecondary)))
                              : ListView.builder(
                                  itemCount: _students.length,
                                  itemBuilder: (ctx, i) {
                                    final s = _students[i];
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 10),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(16),
                                        child: BackdropFilter(
                                          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                            decoration: BoxDecoration(color: AppColors.glassWhite,
                                              borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.glassBorder)),
                                            child: Row(children: [
                                              Container(
                                                width: 40, height: 40,
                                                decoration: BoxDecoration(shape: BoxShape.circle, gradient: AppColors.primaryGradient,
                                                  boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 8)]),
                                                child: Center(child: Text(
                                                  s.name.isNotEmpty ? s.name[0].toUpperCase() : '?',
                                                  style: const TextStyle(fontWeight: FontWeight.w800, color: Colors.white))),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                                Text(s.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.textPrimary)),
                                                Text(s.email, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                                              ])),
                                              GestureDetector(
                                                onTap: () => _showAddGradeDialog(s),
                                                child: Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                                                  decoration: BoxDecoration(
                                                    gradient: AppColors.cyanGradient,
                                                    borderRadius: BorderRadius.circular(10),
                                                    boxShadow: [BoxShadow(color: AppColors.cyan.withValues(alpha: 0.3), blurRadius: 6)],
                                                  ),
                                                  child: const Row(mainAxisSize: MainAxisSize.min, children: [
                                                    Icon(Icons.add_rounded, color: Colors.white, size: 14),
                                                    SizedBox(width: 4),
                                                    Text('Note', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
                                                  ]),
                                                ),
                                              ),
                                            ]),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                          ),
                        ],
                      ]),
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _gField(TextEditingController c, String label, IconData icon, {TextInputType type = TextInputType.text}) =>
    TextField(
      controller: c, keyboardType: type,
      style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
      decoration: InputDecoration(
        labelText: label, labelStyle: const TextStyle(color: AppColors.textSecondary),
        prefixIcon: Icon(icon, size: 18, color: AppColors.textSecondary),
        filled: true, fillColor: AppColors.glassWhite,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.glassBorder)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.glassBorder)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    );
}
