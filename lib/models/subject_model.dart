import 'package:cloud_firestore/cloud_firestore.dart';

class SubjectModel {
  final String id;
  final String name;
  final String code;
  final double coefficient;
  final String? professorId;

  SubjectModel({
    required this.id,
    required this.name,
    required this.code,
    required this.coefficient,
    this.professorId,
  });

  factory SubjectModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SubjectModel(
      id: doc.id,
      name: data['name'] ?? '',
      code: data['code'] ?? '',
      coefficient: (data['coefficient'] ?? 1.0).toDouble(),
      professorId: data['professorId'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'code': code,
      'coefficient': coefficient,
      'professorId': professorId,
    };
  }
}
