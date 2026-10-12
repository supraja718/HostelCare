import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'complaint_repository.dart';
import 'hostel_database.dart';

class HospitalVisitItem {
  final String visitId;
  final String studentId;
  final String studentName;
  final String roomNumber;
  final String reason;
  final String description;
  final String preferredDate;
  final String preferredTime;
  final String urgency; // 'Normal', 'Urgent'
  final String guardianName;
  final String guardianPhone;
  String status; // 'Pending', 'Approved', 'Rejected', 'Arranged', 'Completed', 'Cancelled'
  String? rejectionReason;
  String? arrangedDate;
  String? arrangedTime;
  final String createdAt;

  HospitalVisitItem({
    required this.visitId,
    required this.studentId,
    required this.studentName,
    required this.roomNumber,
    required this.reason,
    required this.description,
    required this.preferredDate,
    required this.preferredTime,
    required this.urgency,
    required this.guardianName,
    required this.guardianPhone,
    required this.status,
    this.rejectionReason,
    this.arrangedDate,
    this.arrangedTime,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'visitId': visitId,
        'studentId': studentId,
        'studentName': studentName,
        'roomNumber': roomNumber,
        'reason': reason,
        'description': description,
        'preferredDate': preferredDate,
        'preferredTime': preferredTime,
        'urgency': urgency,
        'guardianName': guardianName,
        'guardianPhone': guardianPhone,
        'status': status,
        'rejectionReason': rejectionReason,
        'arrangedDate': arrangedDate,
        'arrangedTime': arrangedTime,
        'createdAt': createdAt,
      };

  factory HospitalVisitItem.fromMap(Map<String, dynamic> map) => HospitalVisitItem(
        visitId: map['visitId'],
        studentId: map['studentId'],
        studentName: map['studentName'],
        roomNumber: map['roomNumber'],
        reason: map['reason'],
        description: map['description'],
        preferredDate: map['preferredDate'],
        preferredTime: map['preferredTime'],
        urgency: map['urgency'],
        guardianName: map['guardianName'] ?? '',
        guardianPhone: map['guardianPhone'] ?? '',
        status: map['status'],
        rejectionReason: map['rejectionReason'],
        arrangedDate: map['arrangedDate'],
        arrangedTime: map['arrangedTime'],
        createdAt: map['createdAt'],
      );
}

class HospitalVisitRepository extends ChangeNotifier {
  static final HospitalVisitRepository instance = HospitalVisitRepository._internal();
  HospitalVisitRepository._internal() {
    _loadFromDB();
  }

  final List<HospitalVisitItem> _visits = [];
  List<HospitalVisitItem> get visits => List.unmodifiable(_visits);

  Future<void> _loadFromDB() async {
    try {
      final db = await HostelDatabase.instance.database;
      await db.execute('''
        CREATE TABLE IF NOT EXISTS hospital_visits (
          visitId TEXT PRIMARY KEY,
          studentId TEXT NOT NULL,
          studentName TEXT NOT NULL,
          roomNumber TEXT NOT NULL,
          reason TEXT NOT NULL,
          description TEXT NOT NULL,
          preferredDate TEXT NOT NULL,
          preferredTime TEXT NOT NULL,
          urgency TEXT NOT NULL,
          guardianName TEXT NOT NULL,
          guardianPhone TEXT NOT NULL,
          status TEXT NOT NULL,
          rejectionReason TEXT,
          arrangedDate TEXT,
          arrangedTime TEXT,
          createdAt TEXT NOT NULL
        )
      ''');

      final maps = await db.query('hospital_visits');
      _visits.clear();
      for (var m in maps) {
        _visits.add(HospitalVisitItem.fromMap(m));
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading hospital visits: $e');
    }
  }

  Future<void> createVisitRequest(HospitalVisitItem item) async {
    _visits.insert(0, item);
    try {
      final db = await HostelDatabase.instance.database;
      await db.insert('hospital_visits', item.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    } catch (e) {
      debugPrint('Error inserting hospital visit: $e');
    }

    ComplaintRepository.instance.notifications.insert(
      0,
      HostelNotificationItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: 'Hospital Visit Request Submitted',
        description: 'Hospital visit request submitted successfully for ${item.reason}.',
        date: 'Just now',
        type: 'New',
      ),
    );

    notifyListeners();
  }

  Future<void> reviewVisit({
    required String visitId,
    required bool isApproved,
    String? rejectionReason,
  }) async {
    final idx = _visits.indexWhere((v) => v.visitId == visitId);
    if (idx != -1) {
      final v = _visits[idx];
      v.status = isApproved ? 'Approved' : 'Rejected';
      v.rejectionReason = rejectionReason;

      try {
        final db = await HostelDatabase.instance.database;
        await db.update('hospital_visits', v.toMap(), where: 'visitId = ?', whereArgs: [visitId]);
      } catch (e) {
        debugPrint('Error updating hospital visit: $e');
      }

      ComplaintRepository.instance.notifications.insert(
        0,
        HostelNotificationItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: isApproved ? 'Hospital Visit Approved 🏥' : 'Hospital Visit Rejected ❌',
          description: isApproved
              ? 'Your hospital visit request has been approved.'
              : 'Your hospital visit request has been rejected. Reason: ${rejectionReason ?? "Not specified"}',
          date: 'Just now',
          type: isApproved ? 'Student' : 'Urgent',
        ),
      );

      notifyListeners();
    }
  }

  Future<void> arrangeVisit({
    required String visitId,
    required String date,
    required String time,
  }) async {
    final idx = _visits.indexWhere((v) => v.visitId == visitId);
    if (idx != -1) {
      final v = _visits[idx];
      v.status = 'Arranged';
      v.arrangedDate = date;
      v.arrangedTime = time;

      try {
        final db = await HostelDatabase.instance.database;
        await db.update('hospital_visits', v.toMap(), where: 'visitId = ?', whereArgs: [visitId]);
      } catch (e) {
        debugPrint('Error arranging hospital visit: $e');
      }

      ComplaintRepository.instance.notifications.insert(
        0,
        HostelNotificationItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: 'Hospital Visit Arranged 🚗',
          description: 'Your hospital visit has been arranged for $date at $time.',
          date: 'Just now',
          type: 'Student',
        ),
      );

      notifyListeners();
    }
  }

  Future<void> markCompleted(String visitId) async {
    final idx = _visits.indexWhere((v) => v.visitId == visitId);
    if (idx != -1) {
      final v = _visits[idx];
      v.status = 'Completed';

      try {
        final db = await HostelDatabase.instance.database;
        await db.update('hospital_visits', v.toMap(), where: 'visitId = ?', whereArgs: [visitId]);
      } catch (e) {
        debugPrint('Error completing hospital visit: $e');
      }

      notifyListeners();
    }
  }
}
