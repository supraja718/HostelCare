import 'package:flutter/material.dart';

class ComplaintItem {
  final String id;
  final String studentName;
  final String roomNumber;
  final String hostelId; // 'GH1', 'GH2', 'BH1', 'BH2'
  final String title;
  final String category;
  final String description;
  final String date;
  String status; // 'Reported', 'New', 'Pending', 'Assigned', 'In Progress', 'Repair Completed', 'Verified', 'Resolved', 'Reopened', 'Overdue', 'Escalated', 'Under Review'
  String priority; // 'Low', 'Medium', 'High', 'Urgent'
  String? assignedStaff;
  String? assignmentDate;
  String? expectedCompletionDate;
  String? workPerformed;
  String? staffRemarks;
  String? materialsUsed;
  String? resolutionProof; // Uploaded repair photo / proof
  bool isVerifiedByWarden;
  bool isConfirmedByStudent;
  final bool isSensitive;

  // Student Care Welfare Specific Fields
  String? welfareOfficerNotes;
  String? welfareConfidentialNotes;
  String? followUpScheduledDate;

  List<String> timeline;
  List<String> updates;

  ComplaintItem({
    required this.id,
    required this.studentName,
    required this.roomNumber,
    this.hostelId = 'BH1',
    required this.title,
    required this.category,
    required this.description,
    required this.date,
    required this.status,
    this.priority = 'Medium',
    this.assignedStaff,
    this.assignmentDate,
    this.expectedCompletionDate,
    this.workPerformed,
    this.staffRemarks,
    this.materialsUsed,
    this.resolutionProof,
    this.isVerifiedByWarden = false,
    this.isConfirmedByStudent = false,
    this.isSensitive = false,
    this.welfareOfficerNotes,
    this.welfareConfidentialNotes,
    this.followUpScheduledDate,
    List<String>? timeline,
    List<String>? updates,
  })  : timeline = timeline ?? ['Reported on $date'],
        updates = updates ?? [];
}

class HostelNotificationItem {
  final String id;
  final String title;
  final String description;
  final String date;
  final String type; // 'New', 'Staff', 'Urgent', 'Sensitive', 'Announcement', 'SLA', 'Student'

  HostelNotificationItem({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.type,
  });
}

class HostelAnnouncementItem {
  final String id;
  final String title;
  final String content;
  final String date;
  final String time;
  final String postedBy;
  final String targetRole; // 'All', 'Student', 'Warden', 'Service Staff', 'Student Care', 'Electrician', 'Plumber', 'Carpenter', 'Wi-Fi Technician', 'Cleaning Staff'

  HostelAnnouncementItem({
    required this.id,
    required this.title,
    required this.content,
    required this.date,
    required this.time,
    this.postedBy = 'Management',
    this.targetRole = 'All',
  });
}

class ComplaintRepository extends ChangeNotifier {
  static final ComplaintRepository instance = ComplaintRepository._internal();
  ComplaintRepository._internal();

  final List<ComplaintItem> _complaints = [
    ComplaintItem(
      id: '00124',
      studentName: 'Student User',
      roomNumber: 'Room 204',
      hostelId: 'BH1',
      title: 'Fan speed regulator broken',
      category: 'Electrical',
      description: 'The ceiling fan in Room 204 is stuck on maximum speed and making loud noise.',
      date: 'Today, 09:15 AM',
      status: 'In Progress',
      priority: 'High',
      assignedStaff: 'Ramesh - Electrician',
      assignmentDate: 'Today, 09:30 AM',
      expectedCompletionDate: 'Today, 05:00 PM',
      timeline: ['Reported on Today, 09:15 AM', 'Assigned to Ramesh - Electrician', 'Work In Progress'],
      updates: ['Staff Ramesh assigned for electrical repair work.'],
    ),
    ComplaintItem(
      id: '00125',
      studentName: 'Priya Sharma',
      roomNumber: 'Room 112',
      hostelId: 'GH1',
      title: 'Water tap leaking continuously',
      category: 'Plumbing',
      description: 'Water leaking continuously from the bathroom tap in 2nd floor washroom.',
      date: 'Yesterday, 04:30 PM',
      status: 'Pending',
      priority: 'Medium',
      timeline: ['Reported on Yesterday, 04:30 PM'],
      updates: ['Complaint received and logged into system.'],
    ),
    ComplaintItem(
      id: '00126',
      studentName: 'Amit Patel',
      roomNumber: 'Room 305',
      hostelId: 'BH2',
      title: 'Confidential room dispute',
      category: 'Welfare / Misconduct',
      description: 'Private complaint regarding roommate friction and late night disturbance.',
      date: '2 Oct, 11:00 AM',
      status: 'Under Review',
      priority: 'High',
      isSensitive: true,
      followUpScheduledDate: 'Tomorrow, 10:00 AM',
      welfareOfficerNotes: 'Initial discussion held with student.',
      welfareConfidentialNotes: 'Strictly private counselor notes regarding room reassignment request.',
      timeline: ['Reported on 2 Oct, 11:00 AM', 'Under Review by Student Care Officer'],
      updates: ['Warden and Student Care Officer review requested.'],
    ),
    ComplaintItem(
      id: '00127',
      studentName: 'Ananya Verma',
      roomNumber: 'Room 108',
      hostelId: 'GH2',
      title: 'Corridor light fixture damaged',
      category: 'Electrical',
      description: 'Corridor light fixture flickering continuously.',
      date: '29 Sep, 10:00 AM',
      status: 'Overdue',
      priority: 'Urgent',
      expectedCompletionDate: '30 Sep, 12:00 PM',
      timeline: ['Reported on 29 Sep, 10:00 AM', 'Marked Overdue'],
      updates: ['Passed expected resolution time limit.'],
    ),
  ];

  final List<HostelNotificationItem> _notifications = [
    HostelNotificationItem(
      id: 'n1',
      title: 'Complaint Assigned',
      description: 'Your complaint HC-00124 has been assigned to Ramesh - Electrician.',
      date: 'Today, 09:30 AM',
      type: 'Student',
    ),
    HostelNotificationItem(
      id: 'n2',
      title: 'New Plumbing Complaint',
      description: 'New plumbing complaint received: Water tap leaking continuously (Room 112).',
      date: 'Yesterday, 04:30 PM',
      type: 'New',
    ),
    HostelNotificationItem(
      id: 'n3',
      title: 'New Repair Task Assigned',
      description: 'New repair task assigned: Fan speed regulator broken (Room 204).',
      date: 'Today, 09:30 AM',
      type: 'Staff',
    ),
    HostelNotificationItem(
      id: 'n4',
      title: 'SLA Exceeded Alert',
      description: 'Complaint HC-00127 exceeded SLA and requires management review.',
      date: '2 days ago',
      type: 'SLA',
    ),
    HostelNotificationItem(
      id: 'n5',
      title: 'Sensitive Case Alert',
      description: 'New sensitive case requires attention: Confidential room dispute (Room 305).',
      date: '2 Oct',
      type: 'Sensitive',
    ),
  ];

  final List<HostelAnnouncementItem> _announcements = [
    HostelAnnouncementItem(
      id: 'a1',
      title: 'Electrical Substation Audit',
      content: 'Power grid substation maintenance audit scheduled for Electricians on Saturday.',
      date: 'Today',
      time: '11:00 AM',
      postedBy: 'Management',
      targetRole: 'Electrician',
    ),
    HostelAnnouncementItem(
      id: 'a2',
      title: 'Main Water Tank Chlorination',
      content: 'Overhead water tank cleaning and pipe pressure audit scheduled for Plumbers.',
      date: 'Today',
      time: '10:30 AM',
      postedBy: 'Management',
      targetRole: 'Plumber',
    ),
    HostelAnnouncementItem(
      id: 'a3',
      title: 'Hostel Mess Timings Extension',
      content: 'Dinner hours extended up to 10:00 PM during examination week.',
      date: 'Yesterday',
      time: '08:00 PM',
      postedBy: 'Management',
      targetRole: 'Student',
    ),
    HostelAnnouncementItem(
      id: 'a4',
      title: 'Monthly Warden Operational Briefing',
      content: 'All block wardens requested to submit monthly complaint resolution logs by Friday.',
      date: 'Yesterday',
      time: '04:00 PM',
      postedBy: 'Management',
      targetRole: 'Warden',
    ),
    HostelAnnouncementItem(
      id: 'a5',
      title: 'Student Care Mental Health Workshop',
      content: 'Annual student welfare and counseling session for Student Care Officers.',
      date: '2 days ago',
      time: '03:00 PM',
      postedBy: 'Management',
      targetRole: 'Student Care',
    ),
    HostelAnnouncementItem(
      id: 'a6',
      title: 'Annual Hostel Sports & Cultural Meet',
      content: 'Annual hostel sports and cultural events open for all students and staff.',
      date: '3 days ago',
      time: '12:00 PM',
      postedBy: 'Management',
      targetRole: 'All',
    ),
  ];

  List<ComplaintItem> get complaints => List.unmodifiable(_complaints);
  List<HostelNotificationItem> get notifications => List.unmodifiable(_notifications);
  List<HostelAnnouncementItem> get announcements => List.unmodifiable(_announcements);

  List<HostelAnnouncementItem> getAnnouncementsForRole(String role) {
    return getAnnouncementsForRoleAndDept(role);
  }

  List<HostelAnnouncementItem> getAnnouncementsForRoleAndDept(String role, {String? department}) {
    return _announcements.where((a) {
      if (a.targetRole == 'All' || a.targetRole == role) return true;
      if (department != null && (a.targetRole == department || a.targetRole.contains(department))) return true;
      return false;
    }).toList();
  }

  void addComplaint(ComplaintItem item) {
    _complaints.insert(0, item);

    _notifications.insert(
      0,
      HostelNotificationItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: item.isSensitive ? 'New Sensitive Case' : 'New ${item.category} Complaint',
        description: item.isSensitive
            ? 'New sensitive case requires attention: ${item.title} (${item.roomNumber}).'
            : 'New ${item.category.toLowerCase()} complaint received from ${item.studentName} (${item.roomNumber}).',
        date: item.date,
        type: item.isSensitive ? 'Sensitive' : 'New',
      ),
    );

    notifyListeners();
  }

  void addAnnouncement({
    required String title,
    required String content,
    String targetRole = 'All',
  }) {
    final newAnn = HostelAnnouncementItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      content: content,
      date: 'Today',
      time: 'Just now',
      postedBy: 'Management',
      targetRole: targetRole,
    );
    _announcements.insert(0, newAnn);

    _notifications.insert(
      0,
      HostelNotificationItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: 'Official Announcement ($targetRole)',
        description: content,
        date: 'Just now',
        type: 'Announcement',
      ),
    );

    notifyListeners();
  }

  void assignStaff(String complaintId, String staffName, {String? expectedCompletionDate}) {
    final complaint = _complaints.firstWhere((c) => c.id == complaintId);
    complaint.assignedStaff = staffName;
    complaint.assignmentDate = 'Just now';
    if (expectedCompletionDate != null) {
      complaint.expectedCompletionDate = expectedCompletionDate;
    } else {
      complaint.expectedCompletionDate = 'Tomorrow, 05:00 PM';
    }

    if (complaint.status == 'New' || complaint.status == 'Pending' || complaint.status == 'Reported') {
      complaint.status = 'In Progress';
    }
    complaint.timeline.add('Assigned to $staffName');
    complaint.updates.insert(0, 'Assigned staff: $staffName');

    _notifications.insert(
      0,
      HostelNotificationItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: 'Complaint Assigned',
        description: 'Your complaint HC-${complaint.id} has been assigned to $staffName.',
        date: 'Just now',
        type: 'Student',
      ),
    );

    _notifications.insert(
      0,
      HostelNotificationItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: 'New Repair Task Assigned',
        description: 'New repair task assigned: ${complaint.title} (${complaint.roomNumber}).',
        date: 'Just now',
        type: 'Staff',
      ),
    );

    notifyListeners();
  }

  void submitWorkByStaff({
    required String complaintId,
    required String photoProof,
    String? workPerformed,
    String? remarks,
    String? materialsUsed,
  }) {
    final complaint = _complaints.firstWhere((c) => c.id == complaintId);
    complaint.workPerformed = workPerformed ?? 'Issue fixed & photo verified';
    complaint.staffRemarks = remarks ?? 'Photo proof uploaded';
    complaint.materialsUsed = materialsUsed;
    complaint.resolutionProof = photoProof;
    complaint.status = 'Resolved';
    complaint.timeline.add('Issue Fixed & Photo Verified');
    complaint.updates.insert(0, 'Photo proof uploaded. Issue resolved.');

    _notifications.insert(
      0,
      HostelNotificationItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: 'Issue Resolved (Photo Verified)',
        description: 'Your complaint HC-${complaint.id} is resolved with image proof uploaded by service staff.',
        date: 'Just now',
        type: 'Student',
      ),
    );

    notifyListeners();
  }

  void verifyByWarden(String complaintId) {
    final complaint = _complaints.firstWhere((c) => c.id == complaintId);
    complaint.isVerifiedByWarden = true;
    complaint.status = 'Verified';
    complaint.timeline.add('Verified by Warden');
    complaint.updates.insert(0, 'Warden inspected and verified repair work.');

    notifyListeners();
  }

  void studentConfirmResolution(String complaintId, bool isResolved, {String? reopenReason}) {
    final complaint = _complaints.firstWhere((c) => c.id == complaintId);
    if (isResolved) {
      complaint.isConfirmedByStudent = true;
      complaint.status = 'Resolved';
      complaint.timeline.add('Confirmed Resolved by Student');
      complaint.updates.insert(0, 'Student confirmed issue is fully resolved.');
    } else {
      complaint.status = 'Reopened';
      complaint.timeline.add('Complaint Reopened by Student');
      complaint.updates.insert(0, 'Reopened by Student: ${reopenReason ?? "Issue persists"}');
    }

    notifyListeners();
  }

  void escalateToManagement(String complaintId, String reason) {
    final complaint = _complaints.firstWhere((c) => c.id == complaintId);
    complaint.status = 'Escalated';
    complaint.priority = 'Urgent';
    complaint.timeline.add('Escalated to Management');
    complaint.updates.insert(0, 'Escalated to Management: $reason');

    _notifications.insert(
      0,
      HostelNotificationItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: 'SLA Exceeded / Escalation',
        description: 'Complaint HC-${complaint.id} exceeded SLA and requires management review.',
        date: 'Just now',
        type: 'SLA',
      ),
    );

    notifyListeners();
  }

  void updateWelfareCase({
    required String complaintId,
    required String status,
    String? followUpDate,
    String? officerNotes,
    String? confidentialNotes,
  }) {
    final complaint = _complaints.firstWhere((c) => c.id == complaintId);
    complaint.status = status;
    if (followUpDate != null) complaint.followUpScheduledDate = followUpDate;
    if (officerNotes != null) complaint.welfareOfficerNotes = officerNotes;
    if (confidentialNotes != null) complaint.welfareConfidentialNotes = confidentialNotes;

    complaint.timeline.add('Welfare status updated to $status');
    complaint.updates.insert(0, 'Student Care Officer updated case: $status');

    notifyListeners();
  }

  void updateStatus(String complaintId, String newStatus, String? note) {
    final complaint = _complaints.firstWhere((c) => c.id == complaintId);
    complaint.status = newStatus;
    if (note != null && note.isNotEmpty) {
      complaint.updates.insert(0, note);
    } else {
      complaint.updates.insert(0, 'Status updated to "$newStatus"');
    }

    _notifications.insert(
      0,
      HostelNotificationItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: 'Complaint Status Updated',
        description: '"${complaint.title}" status changed to $newStatus',
        date: 'Just now',
        type: 'New',
      ),
    );

    notifyListeners();
  }
}
