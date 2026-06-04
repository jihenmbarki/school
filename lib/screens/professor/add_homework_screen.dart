import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/homework_model.dart';
import '../../models/class_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/firestore_service.dart';
import '../../core/constants/app_colors.dart';
import '../../widgets/gradient_button.dart';

class AddHomeworkScreen extends StatefulWidget {
  const AddHomeworkScreen({super.key});
  @override
  State<AddHomeworkScreen> createState() => _AddHomeworkScreenState();
}

class _AddHomeworkScreenState extends State<AddHomeworkScreen> {
  final _formKey  = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl  = TextEditingController();
  final FirestoreService _fs = FirestoreService();

  List<ClassModel> _classes = [];
  String? _selectedClassId;
  DateTime _dueDate = DateTime.now().add(const Duration(days: 7));
  bool _loading = false, _submitting = false;

  @override
  void initState() { super.initState(); _loadClasses(); }

  @override
  void dispose() { _titleCtrl.dispose(); _descCtrl.dispose(); super.dispose(); }

  Future<void> _loadClasses() async {
    setState(() => _loading = true);
    final c = await _fs.getClasses();
    if (mounted) setState(() { _classes = c; _loading = false; });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.dark(primary: AppColors.primary, surface: AppColors.bg2),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedClassId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sélectionnez une classe.')));
      return;
    }
    setState(() => _submitting = true);
    final user = context.read<AuthProvider>().currentUser!;
    try {
      await _fs.addHomework(HomeworkModel(
        id: '', title: _titleCtrl.text.trim(), description: _descCtrl.text.trim(),
        subjectId: user.subject ?? '', subjectName: user.subject ?? '',
        professorId: user.uid, professorName: user.name,
        classId: _selectedClassId!, dueDate: _dueDate,
        createdAt: DateTime.now(), completedByStudents: [],
      ));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Devoir publié ✓'), backgroundColor: AppColors.success));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: AppColors.error));
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  const Text('Publier un devoir', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                ]),
              ),
              const SizedBox(height: 8),

              Expanded(
                child: _loading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Form(
                        key: _formKey,
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          _label('Titre du devoir'),
                          _glassField(child: TextFormField(
                            controller: _titleCtrl,
                            style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                            decoration: _dec('Titre', Icons.title_rounded),
                            validator: (v) => v == null || v.isEmpty ? 'Champ requis' : null,
                          )),
                          const SizedBox(height: 14),
                          _label('Description'),
                          _glassField(child: TextFormField(
                            controller: _descCtrl,
                            maxLines: 4,
                            style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                            decoration: _dec('Description du devoir', Icons.description_outlined),
                            validator: (v) => v == null || v.isEmpty ? 'Champ requis' : null,
                          )),
                          const SizedBox(height: 14),
                          _label('Classe'),
                          _glassField(child: DropdownButtonFormField<String>(
                            initialValue: _selectedClassId,
                            dropdownColor: AppColors.bg2,
                            style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                            decoration: _dec('Sélectionner une classe', Icons.class_rounded),
                            items: _classes.map((c) => DropdownMenuItem(
                              value: c.id,
                              child: Text(c.name, style: const TextStyle(color: AppColors.textPrimary)),
                            )).toList(),
                            onChanged: (v) => setState(() => _selectedClassId = v),
                            validator: (v) => v == null ? 'Sélectionnez une classe' : null,
                          )),
                          const SizedBox(height: 14),
                          _label('Date limite'),
                          GestureDetector(
                            onTap: _pickDate,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                  decoration: BoxDecoration(
                                    color: AppColors.glassWhite,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(color: AppColors.glassBorder),
                                  ),
                                  child: Row(children: [
                                    const Icon(Icons.calendar_today_rounded, color: AppColors.primary, size: 20),
                                    const SizedBox(width: 12),
                                    Text('${_dueDate.day}/${_dueDate.month}/${_dueDate.year}',
                                      style: const TextStyle(fontSize: 14, color: AppColors.textPrimary)),
                                    const Spacer(),
                                    const Icon(Icons.arrow_drop_down_rounded, color: AppColors.textSecondary),
                                  ]),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 28),
                          GradientButton(
                            label: 'Publier le devoir',
                            onPressed: _submit,
                            isLoading: _submitting,
                            icon: Icons.publish_rounded,
                            gradient: AppColors.primaryGradient,
                          ),
                        ]),
                      ),
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String t) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(t, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
  );

  Widget _glassField({required Widget child}) => ClipRRect(
    borderRadius: BorderRadius.circular(14),
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
      child: child,
    ),
  );

  InputDecoration _dec(String hint, IconData icon) => InputDecoration(
    hintText: hint,
    prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
    filled: true, fillColor: AppColors.glassWhite,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.glassBorder)),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.glassBorder)),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
    hintStyle: const TextStyle(color: AppColors.textHint),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  );
}
