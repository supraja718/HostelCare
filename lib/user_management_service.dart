import 'package:flutter/material.dart';

class StudentRecord {
  final String uid;
  String name;
  String registerNumber;
  String email;
  String phone;
  String department;
  String year;
  String hostelId; // 'GH1', 'GH2', 'BH1', 'BH2'
  String block;
  String floor;
  String roomNumber;
  String bedNumber;
  String parentName;
  String parentPhone;
  String status; // 'ACTIVE', 'INACTIVE'

  StudentRecord({
    required this.uid,
    required this.name,
    required this.registerNumber,
    required this.email,
    required this.phone,
    required this.department,
    required this.year,
    required this.hostelId,
    required this.block,
    required this.floor,
    required this.roomNumber,
    required this.bedNumber,
    required this.parentName,
    required this.parentPhone,
    required this.status,
  });

  Map<String, dynamic> toMap() => {
        'uid': uid,
        'name': name,
        'registerNumber': registerNumber,
        'email': email,
        'phone': phone,
        'department': department,
        'year': year,
        'hostelId': hostelId,
        'block': block,
        'floor': floor,
        'roomNumber': roomNumber,
        'bedNumber': bedNumber,
        'parentName': parentName,
        'parentPhone': parentPhone,
        'status': status,
      };

  factory StudentRecord.fromMap(Map<String, dynamic> map) => StudentRecord(
        uid: map['uid'] ?? '',
        name: map['name'] ?? '',
        registerNumber: map['registerNumber'] ?? '',
        email: map['email'] ?? '',
        phone: map['phone'] ?? '',
        department: map['department'] ?? '',
        year: map['year'] ?? '',
        hostelId: map['hostelId'] ?? 'GH1',
        block: map['block'] ?? 'Block A',
        floor: map['floor'] ?? '1st Floor',
        roomNumber: map['roomNumber'] ?? 'Room 204',
        bedNumber: map['bedNumber'] ?? 'Bed A',
        parentName: map['parentName'] ?? '',
        parentPhone: map['parentPhone'] ?? '',
        status: map['status'] ?? 'ACTIVE',
      );
}

class WardenRecord {
  final String uid;
  String name;
  String email;
  String phone;
  String? hostelId; // 'GH1', 'GH2', 'BH1', 'BH2' or null if inactive
  String status; // 'ACTIVE', 'INACTIVE'

  WardenRecord({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    this.hostelId,
    required this.status,
  });

  Map<String, dynamic> toMap() => {
        'uid': uid,
        'name': name,
        'email': email,
        'phone': phone,
        'hostelId': hostelId,
        'status': status,
      };

  factory WardenRecord.fromMap(Map<String, dynamic> map) => WardenRecord(
        uid: map['uid'] ?? '',
        name: map['name'] ?? '',
        email: map['email'] ?? '',
        phone: map['phone'] ?? '',
        hostelId: map['hostelId'],
        status: map['status'] ?? 'ACTIVE',
      );
}

class StudentCareRecord {
  final String uid;
  String name;
  String email;
  String phone;
  String gender; // 'Female' -> GH1, GH2; 'Male' -> BH1, BH2
  List<String> hostelAccess; // ['GH1', 'GH2'] or ['BH1', 'BH2']
  String status; // 'ACTIVE', 'INACTIVE'

  StudentCareRecord({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    required this.gender,
    required this.hostelAccess,
    required this.status,
  });

  Map<String, dynamic> toMap() => {
        'uid': uid,
        'name': name,
        'email': email,
        'phone': phone,
        'gender': gender,
        'hostelAccess': hostelAccess.join(','),
        'status': status,
      };

  factory StudentCareRecord.fromMap(Map<String, dynamic> map) => StudentCareRecord(
        uid: map['uid'] ?? '',
        name: map['name'] ?? '',
        email: map['email'] ?? '',
        phone: map['phone'] ?? '',
        gender: map['gender'] ?? 'Female',
        hostelAccess: map['hostelAccess'] != null && (map['hostelAccess'] as String).isNotEmpty
            ? (map['hostelAccess'] as String).split(',')
            : ['GH1', 'GH2'],
        status: map['status'] ?? 'ACTIVE',
      );
}

class ServiceStaffRecord {
  final String uid;
  String name;
  String email;
  String phone;
  String specialization; // 'Plumbing', 'Electrical', 'Carpentry', 'Cleaning', 'Wi-Fi', 'Water', 'Furniture', 'General Maintenance'
  List<String> assignedHostels; // ['GH1', 'GH2', 'BH1', 'BH2']
  String status; // 'ACTIVE', 'INACTIVE'

  ServiceStaffRecord({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    required this.specialization,
    required this.assignedHostels,
    required this.status,
  });

  Map<String, dynamic> toMap() => {
        'uid': uid,
        'name': name,
        'email': email,
        'phone': phone,
        'specialization': specialization,
        'assignedHostels': assignedHostels.join(','),
        'status': status,
      };

  factory ServiceStaffRecord.fromMap(Map<String, dynamic> map) => ServiceStaffRecord(
        uid: map['uid'] ?? '',
        name: map['name'] ?? '',
        email: map['email'] ?? '',
        phone: map['phone'] ?? '',
        specialization: map['specialization'] ?? 'Electrical',
        assignedHostels: map['assignedHostels'] != null && (map['assignedHostels'] as String).isNotEmpty
            ? (map['assignedHostels'] as String).split(',')
            : ['GH1', 'GH2', 'BH1', 'BH2'],
        status: map['status'] ?? 'ACTIVE',
      );
}

class UserManagementService extends ChangeNotifier {
  static final UserManagementService instance = UserManagementService._internal();
  UserManagementService._internal() {
    _seedInitialRecords();
  }

  final List<StudentRecord> _students = [];
  final List<WardenRecord> _wardens = [];
  final List<StudentCareRecord> _studentCareOfficers = [];
  final List<ServiceStaffRecord> _serviceStaff = [];

  List<StudentRecord> get students => List.unmodifiable(_students);
  List<WardenRecord> get wardens => List.unmodifiable(_wardens);
  List<StudentCareRecord> get studentCareOfficers => List.unmodifiable(_studentCareOfficers);
  List<ServiceStaffRecord> get serviceStaff => List.unmodifiable(_serviceStaff);

  void _seedInitialRecords() {
    // 1. Initial Students
    _students.addAll([
      StudentRecord(
        uid: 'STU-GH1-01',
        name: 'Priya Sharma',
        registerNumber: 'REG2024-GH101',
        email: 'priya.gh1@hostel.edu',
        phone: '+91 9876543210',
        department: 'Computer Science',
        year: '3rd Year',
        hostelId: 'GH1',
        block: 'Block A',
        floor: '2nd Floor',
        roomNumber: 'Room 204',
        bedNumber: 'Bed A',
        parentName: 'Mr. Rajesh Sharma',
        parentPhone: '+91 9812345678',
        status: 'ACTIVE',
      ),
      StudentRecord(
        uid: 'STU-BH1-01',
        name: 'Student User',
        registerNumber: 'REG2024-BH101',
        email: 'student@hostel.edu',
        phone: '+91 9876543211',
        department: 'Information Technology',
        year: '2nd Year',
        hostelId: 'BH1',
        block: 'Block B',
        floor: '2nd Floor',
        roomNumber: 'Room 204',
        bedNumber: 'Bed B',
        parentName: 'Mr. Suresh Kumar',
        parentPhone: '+91 9812345679',
        status: 'ACTIVE',
      ),
    ]);

    // 2. Initial Wardens (1 per hostel)
    _wardens.addAll([
      WardenRecord(uid: 'WARDEN-GH1', name: 'Dr. Sunita Rao', email: 'warden.gh1@hostel.edu', phone: '+91 9123456701', hostelId: 'GH1', status: 'ACTIVE'),
      WardenRecord(uid: 'WARDEN-GH2', name: 'Prof. Anitha Verma', email: 'warden.gh2@hostel.edu', phone: '+91 9123456702', hostelId: 'GH2', status: 'ACTIVE'),
      WardenRecord(uid: 'WARDEN-BH1', name: 'Warden Administrator', email: 'warden@hostel.edu', phone: '+91 9123456703', hostelId: 'BH1', status: 'ACTIVE'),
      WardenRecord(uid: 'WARDEN-BH2', name: 'Mr. Ramesh Patel', email: 'warden.bh2@hostel.edu', phone: '+91 9123456704', hostelId: 'BH2', status: 'ACTIVE'),
    ]);

    // 3. Initial Student Care Officers (Female -> GH1, GH2; Male -> BH1, BH2)
    _studentCareOfficers.addAll([
      StudentCareRecord(uid: 'CARE-FEMALE', name: 'Dr. Meenakshi Sundaram', email: 'care.female@hostel.edu', phone: '+91 9234567890', gender: 'Female', hostelAccess: ['GH1', 'GH2'], status: 'ACTIVE'),
      StudentCareRecord(uid: 'CARE-MALE', name: 'Student Care Officer', email: 'care@hostel.edu', phone: '+91 9234567891', gender: 'Male', hostelAccess: ['BH1', 'BH2'], status: 'ACTIVE'),
    ]);

    // 4. Initial Service Staff (Specializations + Assigned Hostels)
    _serviceStaff.addAll([
      ServiceStaffRecord(uid: 'STAFF-ELEC', name: 'Ramesh Electrician', email: 'electrician@hostel.edu', phone: '+91 9345678901', specialization: 'Electrical', assignedHostels: ['BH1', 'BH2', 'GH1', 'GH2'], status: 'ACTIVE'),
      ServiceStaffRecord(uid: 'STAFF-PLUMB', name: 'Suresh Plumber', email: 'plumber@hostel.edu', phone: '+91 9345678902', specialization: 'Plumbing', assignedHostels: ['BH1', 'BH2', 'GH1', 'GH2'], status: 'ACTIVE'),
      ServiceStaffRecord(uid: 'STAFF-CARP', name: 'Vikram Carpenter', email: 'carpenter@hostel.edu', phone: '+91 9345678903', specialization: 'Carpentry', assignedHostels: ['BH1', 'BH2'], status: 'ACTIVE'),
    ]);
  }

  // --- Student Management Actions ---
  void addStudent(StudentRecord s) {
    _students.insert(0, s);
    notifyListeners();
  }

  void updateStudent(StudentRecord s) {
    final idx = _students.indexWhere((item) => item.uid == s.uid);
    if (idx != -1) {
      _students[idx] = s;
      notifyListeners();
    }
  }

  void toggleStudentStatus(String uid) {
    final s = _students.firstWhere((item) => item.uid == uid);
    s.status = (s.status == 'ACTIVE') ? 'INACTIVE' : 'ACTIVE';
    notifyListeners();
  }

  void removeStudent(String uid) {
    _students.removeWhere((item) => item.uid == uid);
    notifyListeners();
  }

  // --- Warden Management Actions (Replace / Reassign / Remove) ---
  void assignWardenToHostel({required String wardenUid, required String hostelId}) {
    for (var w in _wardens) {
      if (w.hostelId == hostelId && w.uid != wardenUid) {
        w.status = 'INACTIVE';
        w.hostelId = null;
      }
    }
    final target = _wardens.firstWhere((w) => w.uid == wardenUid);
    target.hostelId = hostelId;
    target.status = 'ACTIVE';
    notifyListeners();
  }

  void addWarden(WardenRecord w) {
    if (w.hostelId != null) {
      assignWardenToHostel(wardenUid: w.uid, hostelId: w.hostelId!);
    } else {
      _wardens.insert(0, w);
    }
    notifyListeners();
  }

  void toggleWardenStatus(String uid) {
    final w = _wardens.firstWhere((item) => item.uid == uid);
    if (w.status == 'ACTIVE') {
      w.status = 'INACTIVE';
      w.hostelId = null;
    } else {
      w.status = 'ACTIVE';
    }
    notifyListeners();
  }

  void removeWarden(String uid) {
    _wardens.removeWhere((item) => item.uid == uid);
    notifyListeners();
  }

  // --- Student Care Officer Actions ---
  void addStudentCareOfficer(StudentCareRecord c) {
    _studentCareOfficers.insert(0, c);
    notifyListeners();
  }

  void toggleStudentCareStatus(String uid) {
    final c = _studentCareOfficers.firstWhere((item) => item.uid == uid);
    c.status = (c.status == 'ACTIVE') ? 'INACTIVE' : 'ACTIVE';
    notifyListeners();
  }

  void removeStudentCareOfficer(String uid) {
    _studentCareOfficers.removeWhere((item) => item.uid == uid);
    notifyListeners();
  }

  // --- Service Staff Actions ---
  void addServiceStaff(ServiceStaffRecord st) {
    _serviceStaff.insert(0, st);
    notifyListeners();
  }

  void toggleServiceStaffStatus(String uid) {
    final st = _serviceStaff.firstWhere((item) => item.uid == uid);
    st.status = (st.status == 'ACTIVE') ? 'INACTIVE' : 'ACTIVE';
    notifyListeners();
  }

  void removeServiceStaff(String uid) {
    _serviceStaff.removeWhere((item) => item.uid == uid);
    notifyListeners();
  }
}
