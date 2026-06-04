import 'package:cloud_firestore/cloud_firestore.dart';

class ScheduleModel {
  final String id;
  final String classId;
  final String subjectId;
  final String subjectName;
  final String professorId;
  final String professorName;
  final int dayOfWeek; // 1=Monday ... 5=Friday
  final String startTime;
  final String endTime;
  final String? room;

  ScheduleModel({
    required this.id,
    required this.classId,
    required this.subjectId,
    required this.subjectName,
    required this.professorId,
    required this.professorName,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    this.room,
  });

  factory ScheduleModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ScheduleModel(
      id: doc.id,
      classId: data['classId'] ?? '',
      subjectId: data['subjectId'] ?? '',
      subjectName: data['subjectName'] ?? '',
      professorId: data['professorId'] ?? '',
      professorName: data['professorName'] ?? '',
      dayOfWeek: data['dayOfWeek'] ?? 1,
      startTime: data['startTime'] ?? '',
      endTime: data['endTime'] ?? '',
      room: data['room'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'classId': classId,
      'subjectId': subjectId,
      'subjectName': subjectName,
      'professorId': professorId,
      'professorName': professorName,
      'dayOfWeek': dayOfWeek,
      'startTime': startTime,
      'endTime': endTime,
      'room': room,
    };
  }

  String get dayName {
    const days = ['Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi'];
    return dayOfWeek >= 1 && dayOfWeek <= 6 ? days[dayOfWeek - 1] : '';
  }
}
