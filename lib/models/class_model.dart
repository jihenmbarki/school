import 'package:cloud_firestore/cloud_firestore.dart';

class ClassModel {
  final String id;
  final String name;
  final String level;
  final int capacity;
  final List<String> studentIds;

  ClassModel({
    required this.id,
    required this.name,
    required this.level,
    required this.capacity,
    required this.studentIds,
  });

  factory ClassModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ClassModel(
      id: doc.id,
      name: data['name'] ?? '',
      level: data['level'] ?? '',
      capacity: data['capacity'] ?? 30,
      studentIds: List<String>.from(data['studentIds'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'level': level,
      'capacity': capacity,
      'studentIds': studentIds,
    };
  }

  int get studentCount => studentIds.length;
}
