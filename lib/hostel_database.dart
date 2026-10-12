import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class HostelDatabase {
  static final HostelDatabase instance = HostelDatabase._internal();
  HostelDatabase._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('hostelcare.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    try {
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, filePath);

      return await openDatabase(
        path,
        version: 1,
        onCreate: _createDB,
      );
    } catch (e) {
      debugPrint('SQLite init error (falling back to in-memory): $e');
      return await openDatabase(
        inMemoryDatabasePath,
        version: 1,
        onCreate: _createDB,
      );
    }
  }

  Future<void> _createDB(Database db, int version) async {
    // 1. Users
    await db.execute('''
      CREATE TABLE users (
        userId TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL,
        passwordHash TEXT NOT NULL,
        role TEXT NOT NULL,
        createdAt TEXT NOT NULL
      )
    ''');

    // 2. Students
    await db.execute('''
      CREATE TABLE students (
        studentId TEXT PRIMARY KEY,
        userId TEXT NOT NULL,
        rollNumber TEXT NOT NULL,
        blockName TEXT NOT NULL,
        roomNumber TEXT NOT NULL,
        contactNo TEXT,
        FOREIGN KEY (userId) REFERENCES users (userId) ON DELETE CASCADE
      )
    ''');

    // 3. Hostels
    await db.execute('''
      CREATE TABLE hostels (
        hostelId TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        location TEXT NOT NULL,
        totalRooms INTEGER NOT NULL
      )
    ''');

    // 4. Blocks
    await db.execute('''
      CREATE TABLE blocks (
        blockId TEXT PRIMARY KEY,
        hostelId TEXT NOT NULL,
        blockName TEXT NOT NULL,
        wardenName TEXT NOT NULL,
        FOREIGN KEY (hostelId) REFERENCES hostels (hostelId) ON DELETE CASCADE
      )
    ''');

    // 5. Rooms
    await db.execute('''
      CREATE TABLE rooms (
        roomId TEXT PRIMARY KEY,
        blockId TEXT NOT NULL,
        roomNumber TEXT NOT NULL,
        isOccupied INTEGER NOT NULL,
        FOREIGN KEY (blockId) REFERENCES blocks (blockId) ON DELETE CASCADE
      )
    ''');

    // 6. Complaints
    await db.execute('''
      CREATE TABLE complaints (
        complaintId TEXT PRIMARY KEY,
        studentId TEXT NOT NULL,
        category TEXT NOT NULL,
        room TEXT NOT NULL,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        priority TEXT NOT NULL,
        sensitive INTEGER NOT NULL,
        assignedStaff TEXT,
        status TEXT NOT NULL,
        resolutionProof TEXT,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');

    // 7. ComplaintUpdates
    await db.execute('''
      CREATE TABLE complaint_updates (
        updateId TEXT PRIMARY KEY,
        complaintId TEXT NOT NULL,
        updatedBy TEXT NOT NULL,
        updateNote TEXT NOT NULL,
        timestamp TEXT NOT NULL,
        FOREIGN KEY (complaintId) REFERENCES complaints (complaintId) ON DELETE CASCADE
      )
    ''');

    // 8. ServiceStaff
    await db.execute('''
      CREATE TABLE service_staff (
        staffId TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        department TEXT NOT NULL,
        contactNo TEXT NOT NULL,
        availabilityStatus TEXT NOT NULL
      )
    ''');

    // 9. Assignments
    await db.execute('''
      CREATE TABLE assignments (
        assignmentId TEXT PRIMARY KEY,
        complaintId TEXT NOT NULL,
        staffId TEXT NOT NULL,
        assignedDate TEXT NOT NULL,
        expectedCompletionDate TEXT,
        FOREIGN KEY (complaintId) REFERENCES complaints (complaintId) ON DELETE CASCADE,
        FOREIGN KEY (staffId) REFERENCES service_staff (staffId) ON DELETE CASCADE
      )
    ''');

    // 10. SensitiveCases
    await db.execute('''
      CREATE TABLE sensitive_cases (
        caseId TEXT PRIMARY KEY,
        complaintId TEXT NOT NULL,
        officerId TEXT NOT NULL,
        confidentialNotes TEXT NOT NULL,
        followUpDate TEXT,
        FOREIGN KEY (complaintId) REFERENCES complaints (complaintId) ON DELETE CASCADE
      )
    ''');

    // 11. LeaveRequests
    await db.execute('''
      CREATE TABLE leave_requests (
        leaveId TEXT PRIMARY KEY,
        studentId TEXT NOT NULL,
        reason TEXT NOT NULL,
        fromDate TEXT NOT NULL,
        toDate TEXT NOT NULL,
        status TEXT NOT NULL
      )
    ''');

    // 12. Visitors
    await db.execute('''
      CREATE TABLE visitors (
        visitorId TEXT PRIMARY KEY,
        studentId TEXT NOT NULL,
        visitorName TEXT NOT NULL,
        relation TEXT NOT NULL,
        visitDate TEXT NOT NULL,
        status TEXT NOT NULL
      )
    ''');

    // 13. Notifications
    await db.execute('''
      CREATE TABLE notifications (
        notificationId TEXT PRIMARY KEY,
        recipientRole TEXT NOT NULL,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        timestamp TEXT NOT NULL,
        type TEXT NOT NULL
      )
    ''');

    // 14. Announcements
    await db.execute('''
      CREATE TABLE announcements (
        announcementId TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        targetRole TEXT NOT NULL,
        postedBy TEXT NOT NULL,
        timestamp TEXT NOT NULL
      )
    ''');

    // 15. Mess
    await db.execute('''
      CREATE TABLE mess (
        menuId TEXT PRIMARY KEY,
        dayOfWeek TEXT NOT NULL,
        mealType TEXT NOT NULL,
        items TEXT NOT NULL
      )
    ''');

    // 16. Feedback
    await db.execute('''
      CREATE TABLE feedback (
        feedbackId TEXT PRIMARY KEY,
        studentId TEXT NOT NULL,
        category TEXT NOT NULL,
        comments TEXT NOT NULL,
        rating INTEGER NOT NULL,
        timestamp TEXT NOT NULL
      )
    ''');

    // 17. AuditLogs
    await db.execute('''
      CREATE TABLE audit_logs (
        logId TEXT PRIMARY KEY,
        actor TEXT NOT NULL,
        action TEXT NOT NULL,
        details TEXT NOT NULL,
        timestamp TEXT NOT NULL
      )
    ''');

    // Seed Initial Demo Data
    await _seedInitialData(db);
  }

  Future<void> _seedInitialData(Database db) async {
    // Seed Hostels & Blocks
    await db.insert('hostels', {'hostelId': 'H1', 'name': 'Central Campus Hostel', 'location': 'North Block', 'totalRooms': 120});
    await db.insert('blocks', {'blockId': 'B1', 'hostelId': 'H1', 'blockName': 'Block B', 'wardenName': 'Warden Administrator'});
    await db.insert('rooms', {'roomId': 'R204', 'blockId': 'B1', 'roomNumber': 'Room 204', 'isOccupied': 1});

    // Seed Service Staff
    await db.insert('service_staff', {'staffId': 'ST1', 'name': 'Ramesh', 'department': 'Electrician', 'contactNo': '+91 9812345678', 'availabilityStatus': 'Available'});
    await db.insert('service_staff', {'staffId': 'ST2', 'name': 'Suresh', 'department': 'Plumbing', 'contactNo': '+91 9812345679', 'availabilityStatus': 'Available'});
    await db.insert('service_staff', {'staffId': 'ST3', 'name': 'Vikram', 'department': 'Furniture', 'contactNo': '+91 9812345680', 'availabilityStatus': 'Available'});

    // Seed Complaints
    await db.insert('complaints', {
      'complaintId': '101',
      'studentId': 'STU01',
      'category': 'Electrical',
      'room': 'Room 204',
      'title': 'Fan speed regulator broken',
      'description': 'The ceiling fan in Room 204 is stuck on maximum speed.',
      'priority': 'High',
      'sensitive': 0,
      'assignedStaff': 'Ramesh - Electrician',
      'status': 'In Progress',
      'createdAt': 'Today, 09:15 AM',
      'updatedAt': 'Today, 09:30 AM',
    });

    // Seed Announcements
    await db.insert('announcements', {
      'announcementId': 'a1',
      'title': 'Electrical Substation Audit',
      'content': 'Power grid substation maintenance audit scheduled for Electricians on Saturday.',
      'targetRole': 'Electrician',
      'postedBy': 'Management',
      'timestamp': 'Today, 11:00 AM',
    });

    // Seed Mess Menu
    await db.insert('mess', {
      'menuId': 'm1',
      'dayOfWeek': 'Monday',
      'mealType': 'Breakfast',
      'items': 'Idli, Sambar, Chutney, Tea, Coffee, Fresh Fruit',
    });
  }

  // Generic DB query helpers
  Future<List<Map<String, dynamic>>> queryAll(String table) async {
    final db = await database;
    return await db.query(table);
  }

  Future<int> insert(String table, Map<String, dynamic> values) async {
    final db = await database;
    return await db.insert(table, values, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> update(String table, Map<String, dynamic> values, String whereClause, List<Object> whereArgs) async {
    final db = await database;
    return await db.update(table, values, where: whereClause, whereArgs: whereArgs);
  }

  Future<int> delete(String table, String whereClause, List<Object> whereArgs) async {
    final db = await database;
    return await db.delete(table, where: whereClause, whereArgs: whereArgs);
  }
}
