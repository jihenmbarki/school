import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/homework_model.dart';
import '../models/grade_model.dart';
import '../models/class_model.dart';
import '../models/subject_model.dart';
import '../models/notification_model.dart';
import '../models/exam_model.dart';
import '../models/schedule_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- Users ---
  Future<List<UserModel>> getUsersByRole(UserRole role) async {
    final snap = await _db
        .collection('users')
        .where('role', isEqualTo: role.name)
        .get();
    return snap.docs.map((d) => UserModel.fromFirestore(d)).toList();
  }

  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    await _db.collection('users').doc(uid).update(data);
  }

  Future<void> deleteUser(String uid) async {
    await _db.collection('users').doc(uid).delete();
  }

  Stream<List<UserModel>> streamUsersByRole(UserRole role) {
    return _db
        .collection('users')
        .where('role', isEqualTo: role.name)
        .snapshots()
        .map((s) => s.docs.map((d) => UserModel.fromFirestore(d)).toList());
  }

  // --- Classes ---
  Future<List<ClassModel>> getClasses() async {
    final snap = await _db.collection('classes').get();
    return snap.docs.map((d) => ClassModel.fromFirestore(d)).toList();
  }

  Future<ClassModel?> getClassById(String classId) async {
    final doc = await _db.collection('classes').doc(classId).get();
    if (!doc.exists) return null;
    return ClassModel.fromFirestore(doc);
  }

  Stream<List<ClassModel>> streamClasses() {
    return _db.collection('classes').snapshots().map(
          (s) => s.docs.map((d) => ClassModel.fromFirestore(d)).toList(),
        );
  }

  Future<String> addClass(ClassModel cls) async {
    final doc = await _db.collection('classes').add(cls.toFirestore());
    return doc.id;
  }

  Future<void> updateClass(String id, Map<String, dynamic> data) async {
    await _db.collection('classes').doc(id).update(data);
  }

  Future<void> deleteClass(String id) async {
    await _db.collection('classes').doc(id).delete();
  }

  // --- Subjects ---
  Future<List<SubjectModel>> getSubjects() async {
    final snap = await _db.collection('subjects').get();
    return snap.docs.map((d) => SubjectModel.fromFirestore(d)).toList();
  }

  Future<String> addSubject(SubjectModel subject) async {
    final doc = await _db.collection('subjects').add(subject.toFirestore());
    return doc.id;
  }

  // --- Homework ---
  Stream<List<HomeworkModel>> streamHomeworkByClass(String classId) {
    return _db
        .collection('homework')
        .where('classId', isEqualTo: classId)
        .snapshots()
        .map((s) {
          final list = s.docs.map((d) => HomeworkModel.fromFirestore(d)).toList();
          list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return list;
        });
  }

  Stream<List<HomeworkModel>> streamHomeworkByProfessor(String professorId) {
    return _db
        .collection('homework')
        .where('professorId', isEqualTo: professorId)
        .snapshots()
        .map((s) {
          final list = s.docs.map((d) => HomeworkModel.fromFirestore(d)).toList();
          list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return list;
        });
  }

  Future<String> addHomework(HomeworkModel hw) async {
    final doc = await _db.collection('homework').add(hw.toFirestore());
    return doc.id;
  }

  Future<void> deleteHomework(String id) async {
    await _db.collection('homework').doc(id).delete();
  }

  Future<void> markHomeworkDone(String homeworkId, String studentId) async {
    await _db.collection('homework').doc(homeworkId).update({
      'completedByStudents': FieldValue.arrayUnion([studentId]),
    });
  }

  Future<void> unmarkHomeworkDone(String homeworkId, String studentId) async {
    await _db.collection('homework').doc(homeworkId).update({
      'completedByStudents': FieldValue.arrayRemove([studentId]),
    });
  }

  // --- Grades ---
  Stream<List<GradeModel>> streamGradesByStudent(String studentId) {
    return _db
        .collection('grades')
        .where('studentId', isEqualTo: studentId)
        .snapshots()
        .map((s) {
          final list = s.docs.map((d) => GradeModel.fromFirestore(d)).toList();
          list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return list;
        });
  }

  Stream<List<GradeModel>> streamGradesByClass(String classId) {
    return _db
        .collection('grades')
        .where('classId', isEqualTo: classId)
        .snapshots()
        .map((s) => s.docs.map((d) => GradeModel.fromFirestore(d)).toList());
  }

  Future<String> addGrade(GradeModel grade) async {
    final doc = await _db.collection('grades').add(grade.toFirestore());
    return doc.id;
  }

  Future<void> deleteGrade(String id) async {
    await _db.collection('grades').doc(id).delete();
  }

  // --- Exams ---
  Stream<List<ExamModel>> streamExamsByClass(String classId) {
    return _db
        .collection('exams')
        .where('classId', isEqualTo: classId)
        .snapshots()
        .map((s) {
          final list = s.docs.map((d) => ExamModel.fromFirestore(d)).toList();
          list.sort((a, b) => a.examDate.compareTo(b.examDate));
          return list;
        });
  }

  Future<String> addExam(ExamModel exam) async {
    final doc = await _db.collection('exams').add(exam.toFirestore());
    return doc.id;
  }

  // --- Schedules ---
  Stream<List<ScheduleModel>> streamSchedulesByClass(String classId) {
    return _db
        .collection('schedules')
        .where('classId', isEqualTo: classId)
        .snapshots()
        .map((s) {
          final list = s.docs.map((d) => ScheduleModel.fromFirestore(d)).toList();
          list.sort((a, b) => a.dayOfWeek.compareTo(b.dayOfWeek));
          return list;
        });
  }

  Future<String> addSchedule(ScheduleModel schedule) async {
    final doc = await _db.collection('schedules').add(schedule.toFirestore());
    return doc.id;
  }

  // --- Notifications ---
  Stream<List<NotificationModel>> streamNotifications(String userId, UserRole role) {
    return _db
        .collection('notifications')
        .where('targetUserId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => NotificationModel.fromFirestore(d)).toList());
  }

  Future<void> sendNotification(NotificationModel notif) async {
    await _db.collection('notifications').add(notif.toFirestore());
  }

  Future<void> markNotificationRead(String id) async {
    await _db.collection('notifications').doc(id).update({'isRead': true});
  }

  // --- Stats for Admin ---
  Future<Map<String, int>> getDashboardStats() async {
    final results = await Future.wait([
      _db.collection('users').where('role', isEqualTo: 'student').get(),
      _db.collection('users').where('role', isEqualTo: 'professor').get(),
      _db.collection('classes').get(),
      _db.collection('subjects').get(),
    ]);
    return {
      'students': results[0].size,
      'professors': results[1].size,
      'classes': results[2].size,
      'subjects': results[3].size,
    };
  }
}
