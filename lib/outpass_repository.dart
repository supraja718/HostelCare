import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'complaint_repository.dart';
import 'hostel_database.dart';

class OutpassItem {
  final String outpassId;
  final String studentId;
  final String studentName;
  final String roomNumber;
  final String outpassType; // 'One-Day Outing' or 'Holiday Home Visit'
  final String outingDate;
  final String? expectedReturnDate;
  final String goingOutTime;
  final String expectedReturnTime;
  final String destination;
  final String reason;
  final String guardianName;
  final String guardianPhone;
  String status; // 'Pending', 'Approved', 'Rejected', 'Completed', 'Expired'
  String? rejectionReason;
  String? approvedBy;
  String? approvalDate;
  final String createdAt;

  OutpassItem({
    required this.outpassId,
    required this.studentId,
    required this.studentName,
    required this.roomNumber,
    required this.outpassType,
    required this.outingDate,
    this.expectedReturnDate,
    required this.goingOutTime,
    required this.expectedReturnTime,
    required this.destination,
    required this.reason,
    required this.guardianName,
    required this.guardianPhone,
    required this.status,
    this.rejectionReason,
    this.approvedBy,
    this.approvalDate,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'outpassId': outpassId,
        'studentId': studentId,
        'studentName': studentName,
        'roomNumber': roomNumber,
        'outpassType': outpassType,
        'outingDate': outingDate,
        'expectedReturnDate': expectedReturnDate,
        'goingOutTime': goingOutTime,
        'expectedReturnTime': expectedReturnTime,
        'destination': destination,
        'reason': reason,
        'guardianName': guardianName,
        'guardianPhone': guardianPhone,
        'status': status,
        'rejectionReason': rejectionReason,
        'approvedBy': approvedBy,
        'approvalDate': approvalDate,
        'createdAt': createdAt,
      };

  factory OutpassItem.fromMap(Map<String, dynamic> map) => OutpassItem(
        outpassId: map['outpassId'],
        studentId: map['studentId'],
        studentName: map['studentName'],
        roomNumber: map['roomNumber'],
        outpassType: map['outpassType'],
        outingDate: map['outingDate'],
        expectedReturnDate: map['expectedReturnDate'],
        goingOutTime: map['goingOutTime'],
        expectedReturnTime: map['expectedReturnTime'],
        destination: map['destination'],
        reason: map['reason'],
        guardianName: map['guardianName'] ?? '',
        guardianPhone: map['guardianPhone'] ?? '',
        status: map['status'],
        rejectionReason: map['rejectionReason'],
        approvedBy: map['approvedBy'],
        approvalDate: map['approvalDate'],
        createdAt: map['createdAt'],
      );
}

class OutpassRepository extends ChangeNotifier {
  static final OutpassRepository instance = OutpassRepository._internal();
  OutpassRepository._internal() {
    _loadFromDB();
  }

  final List<OutpassItem> _outpasses = [];
  List<OutpassItem> get outpasses => List.unmodifiable(_outpasses);

  Future<void> _loadFromDB() async {
    try {
      final db = await HostelDatabase.instance.database;
      await db.execute('''
        CREATE TABLE IF NOT EXISTS outpasses (
          outpassId TEXT PRIMARY KEY,
          studentId TEXT NOT NULL,
          studentName TEXT NOT NULL,
          roomNumber TEXT NOT NULL,
          outpassType TEXT NOT NULL,
          outingDate TEXT NOT NULL,
          expectedReturnDate TEXT,
          goingOutTime TEXT NOT NULL,
          expectedReturnTime TEXT NOT NULL,
          destination TEXT NOT NULL,
          reason TEXT NOT NULL,
          guardianName TEXT NOT NULL,
          guardianPhone TEXT NOT NULL,
          status TEXT NOT NULL,
          rejectionReason TEXT,
          approvedBy TEXT,
          approvalDate TEXT,
          createdAt TEXT NOT NULL
        )
      ''');

      final maps = await db.query('outpasses');
      _outpasses.clear();
      for (var m in maps) {
        _outpasses.add(OutpassItem.fromMap(m));
      }
      if (_outpasses.isEmpty) {
        final demo = OutpassItem(
          outpassId: 'OP-9081',
          studentId: 'STU01',
          studentName: 'Student User',
          roomNumber: 'Room 204',
          outpassType: 'One-Day Outing',
          outingDate: 'Today',
          goingOutTime: '10:00 AM',
          expectedReturnTime: '06:00 PM',
          destination: 'City Center Mall',
          reason: 'Personal shopping and bank visit',
          guardianName: 'Mr. Sharma (Father)',
          guardianPhone: '+91 9876543210',
          status: 'Approved',
          approvedBy: 'Warden Administrator',
          approvalDate: 'Today, 09:00 AM',
          createdAt: 'Today, 08:30 AM',
        );
        await createOutpass(demo);
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading outpasses: $e');
    }
  }

  Future<void> createOutpass(OutpassItem item) async {
    _outpasses.insert(0, item);
    try {
      final db = await HostelDatabase.instance.database;
      await db.insert('outpasses', item.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    } catch (e) {
      debugPrint('Error inserting outpass into DB: $e');
    }

    ComplaintRepository.instance.notifications.insert(
      0,
      HostelNotificationItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: 'New Outpass Request',
        description: '${item.studentName} (${item.roomNumber}) submitted a ${item.outpassType} request.',
        date: 'Just now',
        type: 'New',
      ),
    );

    notifyListeners();
  }

  Future<void> reviewOutpass({
    required String outpassId,
    required bool isApproved,
    String? rejectionReason,
    required String wardenName,
  }) async {
    final idx = _outpasses.indexWhere((o) => o.outpassId == outpassId);
    if (idx != -1) {
      final o = _outpasses[idx];
      o.status = isApproved ? 'Approved' : 'Rejected';
      o.approvedBy = wardenName;
      o.approvalDate = 'Just now';
      o.rejectionReason = rejectionReason;

      try {
        final db = await HostelDatabase.instance.database;
        await db.update('outpasses', o.toMap(), where: 'outpassId = ?', whereArgs: [outpassId]);
      } catch (e) {
        debugPrint('Error updating outpass in DB: $e');
      }

      ComplaintRepository.instance.notifications.insert(
        0,
        HostelNotificationItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: isApproved ? 'Outpass Approved 🎫' : 'Outpass Rejected ❌',
          description: isApproved
              ? 'Your ${o.outpassType} request to ${o.destination} has been approved by $wardenName.'
              : 'Your ${o.outpassType} request was rejected. Reason: ${rejectionReason ?? "Not specified"}',
          date: 'Just now',
          type: 'Student',
        ),
      );

      notifyListeners();
    }
  }
}
