import 'package:cloud_firestore/cloud_firestore.dart';

class ExamModel {
  final String id;
  final String title;
  final String subjectId;
  final String subjectName;
  final String classId;
  final String professorId;
  final DateTime examDate;
  final String startTime;
  final String endTime;
  final String? room;
  final DateTime createdAt;

  ExamModel({
    required this.id,
    required this.title,
    required this.subjectId,
    required this.subjectName,
    required this.classId,
    required this.professorId,
    required this.examDate,
    required this.startTime,
    required this.endTime,
    this.room,
    required this.createdAt,
  });

  factory ExamModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ExamModel(
      id: doc.id,
      title: data['title'] ?? '',
      subjectId: data['subjectId'] ?? '',
      subjectName: data['subjectName'] ?? '',
      classId: data['classId'] ?? '',
      professorId: data['professorId'] ?? '',
      examDate: (data['examDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      startTime: data['startTime'] ?? '',
      endTime: data['endTime'] ?? '',
      room: data['room'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'subjectId': subjectId,
      'subjectName': subjectName,
      'classId': classId,
      'professorId': professorId,
      'examDate': Timestamp.fromDate(examDate),
      'startTime': startTime,
      'endTime': endTime,
      'room': room,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
