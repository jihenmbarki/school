import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole { admin, professor, student }

class UserModel {
  final String uid;
  final String email;
  final String name;
  final UserRole role;
  final String? classId;
  final String? subject;
  final String? department;
  final String? fcmToken;
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.role,
    this.classId,
    this.subject,
    this.department,
    this.fcmToken,
    required this.createdAt,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      role: _parseRole(data['role'] ?? 'student'),
      classId: data['classId'],
      subject: data['subject'],
      department: data['department'],
      fcmToken: data['fcmToken'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'name': name,
      'role': role.name,
      'classId': classId,
      'subject': subject,
      'department': department,
      'fcmToken': fcmToken,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  static UserRole _parseRole(String role) {
    switch (role) {
      case 'admin':
        return UserRole.admin;
      case 'professor':
        return UserRole.professor;
      default:
        return UserRole.student;
    }
  }

  String get roleLabel {
    switch (role) {
      case UserRole.admin:
        return 'Administrateur';
      case UserRole.professor:
        return 'Professeur';
      case UserRole.student:
        return 'Élève';
    }
  }

  UserModel copyWith({
    String? name,
    String? classId,
    String? subject,
    String? department,
    String? fcmToken,
  }) {
    return UserModel(
      uid: uid,
      email: email,
      name: name ?? this.name,
      role: role,
      classId: classId ?? this.classId,
      subject: subject ?? this.subject,
      department: department ?? this.department,
      fcmToken: fcmToken ?? this.fcmToken,
      createdAt: createdAt,
    );
  }
}
