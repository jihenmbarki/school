import 'package:cloud_firestore/cloud_firestore.dart';

class GradeModel {
  final String id;
  final String studentId;
  final String studentName;
  final String subjectId;
  final String subjectName;
  final String classId;
  final double grade;
  final double coefficient;
  final String? comment;
  final String professorId;
  final DateTime createdAt;

  GradeModel({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.subjectId,
    required this.subjectName,
    required this.classId,
    required this.grade,
    required this.coefficient,
    this.comment,
    required this.professorId,
    required this.createdAt,
  });

  factory GradeModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return GradeModel(
      id: doc.id,
      studentId: data['studentId'] ?? '',
      studentName: data['studentName'] ?? '',
      subjectId: data['subjectId'] ?? '',
      subjectName: data['subjectName'] ?? '',
      classId: data['classId'] ?? '',
      grade: (data['grade'] ?? 0.0).toDouble(),
      coefficient: (data['coefficient'] ?? 1.0).toDouble(),
      comment: data['comment'],
      professorId: data['professorId'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'studentId': studentId,
      'studentName': studentName,
      'subjectId': subjectId,
      'subjectName': subjectName,
      'classId': classId,
      'grade': grade,
      'coefficient': coefficient,
      'comment': comment,
      'professorId': professorId,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  String get gradeLabel {
    if (grade >= 16) return 'Très Bien';
    if (grade >= 14) return 'Bien';
    if (grade >= 12) return 'Assez Bien';
    if (grade >= 10) return 'Passable';
    return 'Insuffisant';
  }
}

double calculateAverage(List<GradeModel> grades) {
  if (grades.isEmpty) return 0.0;
  double totalWeighted = 0;
  double totalCoeff = 0;
  for (final g in grades) {
    totalWeighted += g.grade * g.coefficient;
    totalCoeff += g.coefficient;
  }
  return totalCoeff > 0 ? totalWeighted / totalCoeff : 0.0;
}
