import 'package:cloud_firestore/cloud_firestore.dart';

class HomeworkModel {
  final String id;
  final String title;
  final String description;
  final String subjectId;
  final String subjectName;
  final String professorId;
  final String professorName;
  final String classId;
  final DateTime dueDate;
  final DateTime createdAt;
  final List<String> completedByStudents;

  HomeworkModel({
    required this.id,
    required this.title,
    required this.description,
    required this.subjectId,
    required this.subjectName,
    required this.professorId,
    required this.professorName,
    required this.classId,
    required this.dueDate,
    required this.createdAt,
    required this.completedByStudents,
  });

  factory HomeworkModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return HomeworkModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      subjectId: data['subjectId'] ?? '',
      subjectName: data['subjectName'] ?? '',
      professorId: data['professorId'] ?? '',
      professorName: data['professorName'] ?? '',
      classId: data['classId'] ?? '',
      dueDate: (data['dueDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      completedByStudents: List<String>.from(data['completedByStudents'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'subjectId': subjectId,
      'subjectName': subjectName,
      'professorId': professorId,
      'professorName': professorName,
      'classId': classId,
      'dueDate': Timestamp.fromDate(dueDate),
      'createdAt': Timestamp.fromDate(createdAt),
      'completedByStudents': completedByStudents,
    };
  }

  bool isCompletedBy(String studentId) => completedByStudents.contains(studentId);

  bool get isOverdue => DateTime.now().isAfter(dueDate);
}
