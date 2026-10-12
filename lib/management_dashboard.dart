import 'package:flutter/material.dart';
import 'auth_service.dart';
import 'complaint_repository.dart';
import 'mess_repository.dart';
import 'role_selection_page.dart';
import 'user_management_service.dart';
import 'weekly_mess_menu_page.dart';

class ManagementDashboard extends StatefulWidget {
  const ManagementDashboard({super.key});

  @override
  State<ManagementDashboard> createState() => _ManagementDashboardState();
}

class _ManagementDashboardState extends State<ManagementDashboard> {
  int _currentIndex = 0;
  String? _selectedHostelCode; // null = Overview (2x2 Grid), 'GH1', 'GH2', 'BH1', 'BH2'
  String _selectedSection = 'Overview'; // 'Overview', 'Students', 'Warden', 'Service Staff', 'Student Care', 'Complaints', 'Mess Menu'
  String _studentSearchQuery = '';
  String _complaintSearchQuery = '';

  void _openComplaintDetailSheet(ComplaintItem complaint) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.88,
        padding: const EdgeInsets.all(22),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F9FF),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFBAE6FD)),
                    ),
                    child: Text(
                      complaint.status,
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF0284C7)),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                '#${complaint.id} • ${complaint.title}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
              ),
              const SizedBox(height: 4),
              Text(
                'Student: ${complaint.studentName} (${complaint.roomNumber} - Hostel ${complaint.hostelId})',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0284C7)),
              ),
              Text('Category: ${complaint.category} • Priority: ${complaint.priority} • Date: ${complaint.date}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
              const SizedBox(height: 14),

              // Description Box
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Description:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                    const SizedBox(height: 4),
                    Text(complaint.description, style: const TextStyle(fontSize: 13, color: Color(0xFF334155))),
                    const SizedBox(height: 10),
                    Text('Assigned Staff: ${complaint.assignedStaff ?? "Unassigned"}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF15803D))),
                    Text('Expected Resolution: ${complaint.expectedCompletionDate ?? "Pending Schedule"}', style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Uploaded Photo Proof
              if (complaint.resolutionProof != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCFCE7),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF86EFAC)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.verified, color: Color(0xFF15803D), size: 22),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Uploaded Repair Photo Proof:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF15803D))),
                            Text(complaint.resolutionProof!, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF14532D))),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
              ],

              // Timeline Progress List
              const Text('Complaint Timeline:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F9FF),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFBAE6FD)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: complaint.timeline.map((step) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2.0),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle_rounded, color: Color(0xFF0284C7), size: 16),
                          const SizedBox(width: 8),
                          Expanded(child: Text(step, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF0369A1)))),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _postAnnouncementDialog() {
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    String targetRole = 'All Roles';
    String targetHostel = 'All Hostels';
    String priority = 'Normal';

    final rolesList = ['All Roles', 'Wardens', 'Students', 'Service Staff', 'Student Care Officers', 'Management'];
    final hostelsList = ['All Hostels', 'GH1', 'GH2', 'BH1', 'BH2'];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.campaign, color: Color(0xFF0284C7)),
              SizedBox(width: 8),
              Text('Create Announcement', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: titleController,
                    validator: (val) => val == null || val.trim().isEmpty ? 'Enter title' : null,
                    decoration: InputDecoration(
                      labelText: 'Announcement Title',
                      isDense: true,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 12),

                  TextFormField(
                    controller: contentController,
                    maxLines: 3,
                    validator: (val) => val == null || val.trim().isEmpty ? 'Enter message' : null,
                    decoration: InputDecoration(
                      labelText: 'Announcement Message',
                      isDense: true,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 12),

                  const Text('Recipient Role:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  DropdownButtonFormField<String>(
                    initialValue: targetRole,
                    items: rolesList.map((r) => DropdownMenuItem(value: r, child: Text(r, style: const TextStyle(fontSize: 13)))).toList(),
                    onChanged: (val) => setDialogState(() => targetRole = val!),
                    decoration: InputDecoration(isDense: true, border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                  ),
                  const SizedBox(height: 12),

                  const Text('Target Hostel Scope:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  DropdownButtonFormField<String>(
                    initialValue: targetHostel,
                    items: hostelsList.map((h) => DropdownMenuItem(value: h, child: Text(h, style: const TextStyle(fontSize: 13)))).toList(),
                    onChanged: (val) => setDialogState(() => targetHostel = val!),
                    decoration: InputDecoration(isDense: true, border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                  ),
                  const SizedBox(height: 12),

                  const Text('Priority:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  Row(
                    children: ['Normal', 'Important'].map((p) {
                      bool isSel = priority == p;
                      return Expanded(
                        child: ChoiceChip(
                          label: Text(p),
                          selected: isSel,
                          onSelected: (selected) {
                            if (selected) setDialogState(() => priority = p);
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0284C7)),
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  ComplaintRepository.instance.addAnnouncement(
                    title: '${priority == 'Important' ? '⚠️ ' : ''}${titleController.text.trim()} ($targetHostel)',
                    content: contentController.text.trim(),
                    targetRole: targetRole,
                  );
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Announcement published for $targetRole in $targetHostel!'),
                      backgroundColor: const Color(0xFF0284C7),
                    ),
                  );
                }
              },
              child: const Text('Publish Announcement', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  void _openAddStudentDialog() {
    final nameController = TextEditingController();
    final regController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    final roomController = TextEditingController(text: 'Room 204');
    final bedController = TextEditingController(text: 'Bed A');
    String autoHostel = _selectedHostelCode ?? 'GH1';
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Add New Student ($autoHostel)', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(controller: nameController, validator: (v) => v!.isEmpty ? 'Required' : null, decoration: const InputDecoration(labelText: 'Full Name', isDense: true)),
                  const SizedBox(height: 8),
                  TextFormField(controller: regController, validator: (v) => v!.isEmpty ? 'Required' : null, decoration: const InputDecoration(labelText: 'Register Number', isDense: true)),
                  const SizedBox(height: 8),
                  TextFormField(controller: emailController, validator: (v) => v!.isEmpty ? 'Required' : null, decoration: const InputDecoration(labelText: 'Email Address (Hostel App Login)', isDense: true)),
                  const SizedBox(height: 8),
                  TextFormField(controller: phoneController, validator: (v) => v!.isEmpty ? 'Required' : null, decoration: const InputDecoration(labelText: 'Phone Number', isDense: true)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: autoHostel,
                    items: ['GH1', 'GH2', 'BH1', 'BH2'].map((h) => DropdownMenuItem(value: h, child: Text('Hostel $h'))).toList(),
                    onChanged: (val) => setDialogState(() => autoHostel = val!),
                    decoration: const InputDecoration(labelText: 'Assigned Hostel', isDense: true),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(child: TextFormField(controller: roomController, decoration: const InputDecoration(labelText: 'Room Number', isDense: true))),
                      const SizedBox(width: 8),
                      Expanded(child: TextFormField(controller: bedController, decoration: const InputDecoration(labelText: 'Bed Number', isDense: true))),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0284C7)),
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  UserManagementService.instance.addStudent(
                    StudentRecord(
                      uid: 'STU-${DateTime.now().millisecondsSinceEpoch}',
                      name: nameController.text.trim(),
                      registerNumber: regController.text.trim(),
                      email: emailController.text.trim(),
                      phone: phoneController.text.trim(),
                      department: 'Engineering',
                      year: '1st Year',
                      hostelId: autoHostel,
                      block: 'Block A',
                      floor: '1st Floor',
                      roomNumber: roomController.text.trim(),
                      bedNumber: bedController.text.trim(),
                      parentName: 'Guardian',
                      parentPhone: '+91 9876543210',
                      status: 'ACTIVE',
                    ),
                  );
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Student profile created for $autoHostel!'), backgroundColor: const Color(0xFF0284C7)));
                }
              },
              child: const Text('Add Student', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _openAddWardenDialog() {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    String autoHostel = _selectedHostelCode ?? 'GH1';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Add / Replace Warden ($autoHostel)', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Warden Name', isDense: true)),
                const SizedBox(height: 8),
                TextField(controller: emailController, decoration: const InputDecoration(labelText: 'Email ID', isDense: true)),
                const SizedBox(height: 8),
                TextField(controller: phoneController, decoration: const InputDecoration(labelText: 'Phone Number', isDense: true)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: autoHostel,
                  items: ['GH1', 'GH2', 'BH1', 'BH2'].map((h) => DropdownMenuItem(value: h, child: Text('Assign Hostel $h'))).toList(),
                  onChanged: (val) => setDialogState(() => autoHostel = val!),
                  decoration: const InputDecoration(labelText: 'Assigned Hostel', isDense: true),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0284C7)),
              onPressed: () {
                if (nameController.text.trim().isNotEmpty) {
                  UserManagementService.instance.addWarden(
                    WardenRecord(
                      uid: 'WARDEN-${DateTime.now().millisecondsSinceEpoch}',
                      name: nameController.text.trim(),
                      email: emailController.text.trim(),
                      phone: phoneController.text.trim(),
                      hostelId: autoHostel,
                      status: 'ACTIVE',
                    ),
                  );
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('New Warden assigned to $autoHostel! (Old warden set INACTIVE)'), backgroundColor: const Color(0xFF0284C7)));
                }
              },
              child: const Text('Assign Warden', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _openAddServiceStaffDialog() {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    String selectedSpec = 'Plumbing';
    String autoHostel = _selectedHostelCode ?? 'GH1';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Add Service Staff ($autoHostel)', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Staff Name', isDense: true)),
                const SizedBox(height: 8),
                TextField(controller: emailController, decoration: const InputDecoration(labelText: 'Email ID', isDense: true)),
                const SizedBox(height: 8),
                TextField(controller: phoneController, decoration: const InputDecoration(labelText: 'Phone Number', isDense: true)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: selectedSpec,
                  items: ['Plumbing', 'Electrical', 'Carpentry', 'Cleaning', 'Wi-Fi'].map((sp) => DropdownMenuItem(value: sp, child: Text(sp))).toList(),
                  onChanged: (val) => setDialogState(() => selectedSpec = val!),
                  decoration: const InputDecoration(labelText: 'Specialization', isDense: true),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0284C7)),
              onPressed: () {
                if (nameController.text.trim().isNotEmpty) {
                  UserManagementService.instance.addServiceStaff(
                    ServiceStaffRecord(
                      uid: 'STAFF-${DateTime.now().millisecondsSinceEpoch}',
                      name: nameController.text.trim(),
                      email: emailController.text.trim(),
                      phone: phoneController.text.trim(),
                      specialization: selectedSpec,
                      assignedHostels: [autoHostel],
                      status: 'ACTIVE',
                    ),
                  );
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Service Staff assigned to $autoHostel!'), backgroundColor: const Color(0xFF0284C7)));
                }
              },
              child: const Text('Add Staff', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _openAddStudentCareDialog() {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    String gender = 'Female';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Add Student Care Officer', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Officer Name', isDense: true)),
                const SizedBox(height: 8),
                TextField(controller: emailController, decoration: const InputDecoration(labelText: 'Email ID', isDense: true)),
                const SizedBox(height: 8),
                TextField(controller: phoneController, decoration: const InputDecoration(labelText: 'Phone Number', isDense: true)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: gender,
                  items: ['Female', 'Male'].map((g) => DropdownMenuItem(value: g, child: Text(g == 'Female' ? 'Female (GH1, GH2)' : 'Male (BH1, BH2)'))).toList(),
                  onChanged: (val) => setDialogState(() => gender = val!),
                  decoration: const InputDecoration(labelText: 'Gender & Access Scope', isDense: true),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0284C7)),
              onPressed: () {
                if (nameController.text.trim().isNotEmpty) {
                  UserManagementService.instance.addStudentCareOfficer(
                    StudentCareRecord(
                      uid: 'CARE-${DateTime.now().millisecondsSinceEpoch}',
                      name: nameController.text.trim(),
                      email: emailController.text.trim(),
                      phone: phoneController.text.trim(),
                      gender: gender,
                      hostelAccess: gender == 'Female' ? ['GH1', 'GH2'] : ['BH1', 'BH2'],
                      status: 'ACTIVE',
                    ),
                  );
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Student Care Officer added!'), backgroundColor: Color(0xFF0284C7)));
                }
              },
              child: const Text('Add Officer', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Confirm Logout', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Are you sure you want to log out of Management Portal?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              final navigator = Navigator.of(context);
              Navigator.pop(context);
              await AuthService.instance.logout();
              navigator.pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const RoleSelectionPage()),
                (route) => false,
              );
            },
            child: const Text('Logout', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([
        ComplaintRepository.instance,
        MessRepository.instance,
        UserManagementService.instance,
      ]),
      builder: (context, _) {
        final mgmtUser = AuthService.instance.currentUser;
        final mgmtName = mgmtUser?.name ?? 'Management Board';

        return Scaffold(
          backgroundColor: const Color(0xFFF5F6F8),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey.shade200, width: 1)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              selectedItemColor: const Color(0xFF0284C7),
              unselectedItemColor: const Color(0xFF64748B),
              backgroundColor: Colors.white,
              elevation: 0,
              selectedFontSize: 12,
              unselectedFontSize: 12,
              type: BottomNavigationBarType.fixed,
              onTap: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined),
                  activeIcon: Icon(Icons.home_rounded),
                  label: 'Hostel Overview',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.restaurant_menu_outlined),
                  activeIcon: Icon(Icons.restaurant_menu_rounded),
                  label: 'Weekly Menu',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.campaign_outlined),
                  activeIcon: Icon(Icons.campaign_rounded),
                  label: 'Announcements',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person_outline),
                  activeIcon: Icon(Icons.person_rounded),
                  label: 'Profile',
                ),
              ],
            ),
          ),
          body: SafeArea(
            child: IndexedStack(
              index: _currentIndex,
              children: [
                _buildManagementOverviewTab(mgmtName),
                const WeeklyMessMenuPage(),
                _buildAnnouncementsTab(),
                _buildProfileTab(mgmtName),
              ],
            ),
          ),
        );
      },
    );
  }

  // -------------------------------------------------------------
  // TAB 1: MANAGEMENT OVERVIEW (2x2 Grid of 4 Hostels or Isolated View)
  // -------------------------------------------------------------
  Widget _buildManagementOverviewTab(String mgmtName) {
    if (_selectedHostelCode != null) {
      return _buildHostelDetailedView(_selectedHostelCode!);
    }

    final allStudentsCount = UserManagementService.instance.students.length;
    final activeWardensCount = UserManagementService.instance.wardens.where((w) => w.status == 'ACTIVE').length;
    final allComplaints = ComplaintRepository.instance.complaints;
    final openComplaintsCount = allComplaints.where((c) => c.status != 'Resolved' && c.status != 'Closed').length;

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 80.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Banner
          Container(
            margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F9FF),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFBAE6FD), width: 1.5),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  child: const CircleAvatar(radius: 22, backgroundColor: Color(0xFFBAE6FD), child: Icon(Icons.business_center, color: Color(0xFF0284C7), size: 24)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(mgmtName, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF0369A1))),
                      const SizedBox(height: 2),
                      const Text('Central Management • GH1, GH2, BH1, BH2 Authority', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF0284C7))),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Executive Summary Counters
                Row(
                  children: [
                    _buildStatCard('Total Students', '$allStudentsCount', Icons.groups, const Color(0xFFEFF6FF), const Color(0xFF0284C7)),
                    _buildStatCard('Active Wardens', '$activeWardensCount', Icons.badge, const Color(0xFFFEF3C7), const Color(0xFFD97706)),
                    _buildStatCard('Open Complaints', '$openComplaintsCount', Icons.report_problem, const Color(0xFFF3E8FF), const Color(0xFF7E22CE)),
                  ],
                ),
                const SizedBox(height: 16),

                // Quick Section Banners: Announcements & Weekly Menu
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: _postAnnouncementDialog,
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFBAE6FD), width: 1.5)),
                          child: const Row(
                            children: [
                              Icon(Icons.campaign, color: Color(0xFF0284C7), size: 22),
                              SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Announcements', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                                    Text('Broadcast notice', style: TextStyle(fontSize: 10, color: Color(0xFF64748B))),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _currentIndex = 1; // Open Single-Screen Weekly Mess Menu
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFBAE6FD), width: 1.5)),
                          child: const Row(
                            children: [
                              Icon(Icons.restaurant_menu, color: Color(0xFF0284C7), size: 22),
                              SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Weekly Menu', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                                    Text('Single-screen view', style: TextStyle(fontSize: 10, color: Color(0xFF64748B))),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),

                // 2x2 Grid of 4 Hostel Cards
                const Text('Institutional Hostels (Tap to Manage):', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                const SizedBox(height: 12),

                Column(
                  children: [
                    Row(
                      children: [
                        _buildHostelGridCard('GH1', 'Girls Hostel 1', Icons.apartment, const Color(0xFFFDF2F8), const Color(0xFFDB2777)),
                        const SizedBox(width: 12),
                        _buildHostelGridCard('GH2', 'Girls Hostel 2', Icons.apartment, const Color(0xFFFDF2F8), const Color(0xFFDB2777)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _buildHostelGridCard('BH1', 'Boys Hostel 1', Icons.apartment, const Color(0xFFEFF6FF), const Color(0xFF0284C7)),
                        const SizedBox(width: 12),
                        _buildHostelGridCard('BH2', 'Boys Hostel 2', Icons.apartment, const Color(0xFFEFF6FF), const Color(0xFF0284C7)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHostelGridCard(String code, String name, IconData icon, Color bgColor, Color themeColor) {
    final studentsCount = UserManagementService.instance.students.where((s) => s.hostelId == code).length;
    final wardensList = UserManagementService.instance.wardens.where((w) => w.hostelId == code && w.status == 'ACTIVE').toList();
    final wardenName = wardensList.isNotEmpty ? wardensList.first.name : 'Vacant';
    final openComplaints = ComplaintRepository.instance.complaints.where((c) => (c.hostelId == code || (c.roomNumber.contains('204') && code == 'BH1')) && c.status != 'Resolved' && c.status != 'Closed').length;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedHostelCode = code;
            _selectedSection = 'Overview';
          });
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: themeColor.withValues(alpha: 0.3), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
                    child: Icon(icon, color: themeColor, size: 20),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: themeColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                    child: Text(code, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: themeColor)),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
              const SizedBox(height: 6),
              Text('Students: $studentsCount', style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
              Text('Warden: $wardenName', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: wardenName != 'Vacant' ? const Color(0xFF15803D) : Colors.red.shade700)),
              Text('Open Issues: $openComplaints', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: openComplaints > 0 ? Colors.red.shade700 : const Color(0xFF15803D))),
            ],
          ),
        ),
      ),
    );
  }

  // Isolated Detailed Hostel View with Back Button
  Widget _buildHostelDetailedView(String code) {
    final students = UserManagementService.instance.students.where((s) => s.hostelId == code).toList();
    final wardens = UserManagementService.instance.wardens.where((w) => w.hostelId == code && w.status == 'ACTIVE').toList();
    final activeWarden = wardens.isNotEmpty ? wardens.first : null;
    final careOfficers = UserManagementService.instance.studentCareOfficers.where((c) => c.hostelAccess.contains(code)).toList();

    final staff = UserManagementService.instance.serviceStaff.where((s) {
      if (!s.assignedHostels.contains(code)) return false;
      if (s.specialization == 'Cleaning') {
        if (code.startsWith('GH') && s.email.contains('female')) return true;
        if (code.startsWith('BH') && !s.email.contains('female')) return true;
      }
      return true;
    }).toList();

    final complaints = ComplaintRepository.instance.complaints.where((c) => c.hostelId == code || (c.roomNumber.contains('204') && code == 'BH1')).toList();

    final openC = complaints.where((c) => c.status == 'New' || c.status == 'Reported').length;
    final inProgressC = complaints.where((c) => c.status == 'In Progress' || c.status == 'Assigned').length;
    final verificationC = complaints.where((c) => c.status == 'Repair Completed' || c.status == 'Verified').length;
    final resolvedC = complaints.where((c) => c.status == 'Resolved').length;
    final closedC = complaints.where((c) => c.status == 'Closed').length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Back Button
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF0284C7),
              elevation: 1,
              side: const BorderSide(color: Color(0xFFBAE6FD)),
            ),
            onPressed: () {
              setState(() {
                _selectedHostelCode = null; // Return to Management Overview
              });
            },
            icon: const Icon(Icons.arrow_back, size: 16),
            label: const Text('Back to Management Overview', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          ),
          const SizedBox(height: 14),

          // Hostel Header Container - Shown ONLY on Overview Tab
          if (_selectedSection == 'Overview') ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFBAE6FD), width: 1.5)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Hostel $code Management View', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0369A1))),
                  const SizedBox(height: 4),
                  Text('Isolated administrative view for $code only', style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      _buildInteractiveStatCard('Students', '${students.length}', Icons.groups, const Color(0xFFEFF6FF), const Color(0xFF0284C7), () => setState(() => _selectedSection = 'Students')),
                      _buildInteractiveStatCard('Warden', activeWarden != null ? 'Active' : 'Vacant', Icons.badge, const Color(0xFFFEF3C7), const Color(0xFFD97706), () => setState(() => _selectedSection = 'Warden')),
                      _buildInteractiveStatCard('Complaints', '${complaints.length}', Icons.assignment, const Color(0xFFF3E8FF), const Color(0xFF7E22CE), () => setState(() => _selectedSection = 'Complaints')),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
          ],

          // Section Selector Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ['Overview', 'Students', 'Warden', 'Service Staff', 'Student Care', 'Complaints'].map((sec) {
                bool isSel = (_selectedSection == sec);
                return Padding(
                  padding: const EdgeInsets.only(right: 6.0),
                  child: ChoiceChip(
                    label: Text(sec),
                    selected: isSel,
                    selectedColor: const Color(0xFF0284C7),
                    labelStyle: TextStyle(fontSize: 11, fontWeight: isSel ? FontWeight.bold : FontWeight.normal, color: isSel ? Colors.white : const Color(0xFF0284C7)),
                    onSelected: (selected) {
                      if (selected) setState(() => _selectedSection = sec);
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 14),

          // Render Isolated Section
          _buildIsolatedSectionContent(
            hostelCode: code,
            students: students,
            activeWarden: activeWarden,
            staff: staff,
            careOfficers: careOfficers,
            complaints: complaints,
            openC: openC,
            inProgressC: inProgressC,
            verificationC: verificationC,
            resolvedC: resolvedC,
            closedC: closedC,
          ),
        ],
      ),
    );
  }

  Widget _buildIsolatedSectionContent({
    required String hostelCode,
    required List<StudentRecord> students,
    required WardenRecord? activeWarden,
    required List<ServiceStaffRecord> staff,
    required List<StudentCareRecord> careOfficers,
    required List<ComplaintItem> complaints,
    required int openC,
    required int inProgressC,
    required int verificationC,
    required int resolvedC,
    required int closedC,
  }) {
    if (_selectedSection == 'Students') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('$hostelCode Students (${students.length})', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0284C7), foregroundColor: Colors.white, elevation: 0),
                onPressed: _openAddStudentDialog,
                icon: const Icon(Icons.person_add, size: 16),
                label: const Text('Add Student', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextField(
            onChanged: (val) => setState(() => _studentSearchQuery = val),
            decoration: InputDecoration(
              isDense: true,
              hintText: 'Search $hostelCode students...',
              prefixIcon: const Icon(Icons.search, size: 20, color: Color(0xFF0284C7)),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 10),
          students.isEmpty
              ? const Padding(padding: EdgeInsets.all(20), child: Center(child: Text('No students registered in this hostel.')))
              : Column(
                  children: students.where((s) {
                    if (_studentSearchQuery.isNotEmpty) {
                      final q = _studentSearchQuery.toLowerCase();
                      return s.name.toLowerCase().contains(q) || s.registerNumber.toLowerCase().contains(q) || s.roomNumber.toLowerCase().contains(q);
                    }
                    return true;
                  }).map((s) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFE2E8F0))),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('${s.name} (${s.registerNumber})', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(color: s.status == 'ACTIVE' ? const Color(0xFFDCFCE7) : Colors.red.shade50, borderRadius: BorderRadius.circular(6)),
                                child: Text(s.status, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: s.status == 'ACTIVE' ? const Color(0xFF15803D) : Colors.red.shade700)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text('Hostel ${s.hostelId} • ${s.block} • ${s.roomNumber} (${s.bedNumber})', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0284C7))),
                          Text('Email: ${s.email} • Phone: ${s.phone}', style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              OutlinedButton(
                                style: OutlinedButton.styleFrom(side: BorderSide(color: s.status == 'ACTIVE' ? Colors.red : Colors.green)),
                                onPressed: () => UserManagementService.instance.toggleStudentStatus(s.uid),
                                child: Text(s.status == 'ACTIVE' ? 'Deactivate / Remove' : 'Reactivate', style: TextStyle(fontSize: 11, color: s.status == 'ACTIVE' ? Colors.red : Colors.green)),
                              ),
                              const SizedBox(width: 8),
                              OutlinedButton(
                                style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.red)),
                                onPressed: () => UserManagementService.instance.removeStudent(s.uid),
                                child: const Text('Delete Account', style: TextStyle(fontSize: 11, color: Colors.red)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
        ],
      );
    } else if (_selectedSection == 'Warden') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Active $hostelCode Warden', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0284C7), foregroundColor: Colors.white, elevation: 0),
                onPressed: _openAddWardenDialog,
                icon: const Icon(Icons.badge_outlined, size: 16),
                label: const Text('Replace Warden', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          activeWarden == null
              ? const Padding(padding: EdgeInsets.all(20), child: Center(child: Text('No active Warden currently assigned to this hostel.')))
              : Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFBAE6FD))),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const CircleAvatar(radius: 20, backgroundColor: Color(0xFFBAE6FD), child: Icon(Icons.person, color: Color(0xFF0284C7))),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(activeWarden.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                                Text('Hostel Overseer: $hostelCode', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0284C7))),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text('Email ID: ${activeWarden.email}', style: const TextStyle(fontSize: 12, color: Color(0xFF475569))),
                      Text('Phone Number: ${activeWarden.phone}', style: const TextStyle(fontSize: 12, color: Color(0xFF475569))),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          OutlinedButton(
                            style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.red)),
                            onPressed: () => UserManagementService.instance.toggleWardenStatus(activeWarden.uid),
                            child: const Text('Deactivate Warden', style: TextStyle(fontSize: 11, color: Colors.red)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
        ],
      );
    } else if (_selectedSection == 'Service Staff') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('$hostelCode Assigned Service Staff (${staff.length})', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0284C7), foregroundColor: Colors.white, elevation: 0),
                onPressed: _openAddServiceStaffDialog,
                icon: const Icon(Icons.engineering_outlined, size: 16),
                label: const Text('Add Staff', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          staff.isEmpty
              ? const Padding(padding: EdgeInsets.all(20), child: Center(child: Text('No service staff assigned.')))
              : Column(
                  children: staff.map((st) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFE2E8F0))),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const CircleAvatar(radius: 18, backgroundColor: Color(0xFFF3E8FF), child: Icon(Icons.build, color: Color(0xFF7E22CE), size: 18)),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(st.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                                    Text('Specialization: ${st.specialization}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF0284C7))),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              OutlinedButton(
                                style: OutlinedButton.styleFrom(side: BorderSide(color: st.status == 'ACTIVE' ? Colors.red : Colors.green)),
                                onPressed: () => UserManagementService.instance.toggleServiceStaffStatus(st.uid),
                                child: Text(st.status == 'ACTIVE' ? 'Deactivate' : 'Reactivate', style: TextStyle(fontSize: 11, color: st.status == 'ACTIVE' ? Colors.red : Colors.green)),
                              ),
                              const SizedBox(width: 8),
                              OutlinedButton(
                                style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.red)),
                                onPressed: () => UserManagementService.instance.removeServiceStaff(st.uid),
                                child: const Text('Remove', style: TextStyle(fontSize: 11, color: Colors.red)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
        ],
      );
    } else if (_selectedSection == 'Student Care') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('$hostelCode Permitted Student Care Officer', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0284C7), foregroundColor: Colors.white, elevation: 0),
                onPressed: _openAddStudentCareDialog,
                icon: const Icon(Icons.favorite_outline, size: 16),
                label: const Text('Add Officer', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          careOfficers.isEmpty
              ? const Padding(padding: EdgeInsets.all(20), child: Center(child: Text('No Student Care officer assigned.')))
              : Column(
                  children: careOfficers.map((c) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFE2E8F0))),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const CircleAvatar(radius: 18, backgroundColor: Color(0xFFFDF2F8), child: Icon(Icons.favorite, color: Color(0xFFDB2777), size: 18)),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(c.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                                    Text('Gender Access: ${c.gender} (${c.hostelAccess.join(', ')})', style: const TextStyle(fontSize: 11, color: Color(0xFFDB2777))),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              OutlinedButton(
                                style: OutlinedButton.styleFrom(side: BorderSide(color: c.status == 'ACTIVE' ? Colors.red : Colors.green)),
                                onPressed: () => UserManagementService.instance.toggleStudentCareStatus(c.uid),
                                child: Text(c.status == 'ACTIVE' ? 'Deactivate' : 'Reactivate', style: TextStyle(fontSize: 11, color: c.status == 'ACTIVE' ? Colors.red : Colors.green)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
        ],
      );
    } else if (_selectedSection == 'Complaints') {
      final filteredComplaints = complaints.where((c) {
        if (_complaintSearchQuery.isNotEmpty) {
          final q = _complaintSearchQuery.toLowerCase();
          return c.id.toLowerCase().contains(q) || c.title.toLowerCase().contains(q) || c.studentName.toLowerCase().contains(q);
        }
        return true;
      }).toList();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Complaints Status Breakdown
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFE2E8F0))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$hostelCode Complaints Status Breakdown', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildSummaryBadge('Open', '$openC', Colors.amber.shade50, Colors.amber.shade800),
                    _buildSummaryBadge('In Progress', '$inProgressC', Colors.purple.shade50, Colors.purple.shade800),
                    _buildSummaryBadge('Verification', '$verificationC', Colors.blue.shade50, Colors.blue.shade800),
                    _buildSummaryBadge('Resolved', '$resolvedC', Colors.green.shade50, Colors.green.shade700),
                    _buildSummaryBadge('Closed', '$closedC', Colors.grey.shade100, Colors.grey.shade800),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          TextField(
            onChanged: (val) => setState(() => _complaintSearchQuery = val),
            decoration: InputDecoration(
              isDense: true,
              hintText: 'Search $hostelCode complaints...',
              prefixIcon: const Icon(Icons.search, size: 20, color: Color(0xFF0284C7)),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 10),

          filteredComplaints.isEmpty
              ? const Padding(padding: EdgeInsets.all(20), child: Center(child: Text('No complaints registered for this hostel.')))
              : Column(
                  children: filteredComplaints.map((c) {
                    return GestureDetector(
                      onTap: () => _openComplaintDetailSheet(c),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFE2E8F0))),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('#${c.id} • ${c.studentName} (${c.roomNumber})', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(color: const Color(0xFFF0F9FF), borderRadius: BorderRadius.circular(6)),
                                  child: Text(c.status, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF0284C7))),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(c.title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                            Text('Category: ${c.category} • Priority: ${c.priority}', style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Staff: ${c.assignedStaff ?? "Unassigned"}', style: const TextStyle(fontSize: 11, color: Color(0xFF15803D), fontWeight: FontWeight.bold)),
                                const Text('Tap for full details →', style: TextStyle(fontSize: 11, color: Color(0xFF0284C7), fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
        ],
      );
    } else {
      // Rich Modern Dashboard Overview for the Selected Hostel
      final recentC = complaints.take(3).toList();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Key Personnel & Operations Grid (4 Cards)
          const Text('Key Personnel & Operations', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
          const SizedBox(height: 10),

          Column(
            children: [
              Row(
                children: [
                  _buildRichDashboardTile(
                    'Active Students',
                    '${students.length} Enrolled',
                    Icons.groups_outlined,
                    const Color(0xFFEFF6FF),
                    const Color(0xFF0284C7),
                    () => setState(() => _selectedSection = 'Students'),
                  ),
                  const SizedBox(width: 10),
                  _buildRichDashboardTile(
                    'Hostel Warden',
                    activeWarden?.name ?? 'Vacant Position',
                    Icons.badge_outlined,
                    const Color(0xFFFEF3C7),
                    const Color(0xFFD97706),
                    () => setState(() => _selectedSection = 'Warden'),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  _buildRichDashboardTile(
                    'Service Staff',
                    '${staff.length} Staff Assigned',
                    Icons.engineering_outlined,
                    const Color(0xFFF3E8FF),
                    const Color(0xFF7E22CE),
                    () => setState(() => _selectedSection = 'Service Staff'),
                  ),
                  const SizedBox(width: 10),
                  _buildRichDashboardTile(
                    'Student Care',
                    careOfficers.isNotEmpty ? careOfficers.first.name : 'Unassigned',
                    Icons.favorite_outline,
                    const Color(0xFFFDF2F8),
                    const Color(0xFFDB2777),
                    () => setState(() => _selectedSection = 'Student Care'),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 2. Complaints Resolution Status Breakdown Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0)), boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 8, offset: const Offset(0, 3)),
            ]),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('$hostelCode Complaints Resolution Status', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                    TextButton(
                      onPressed: () => setState(() => _selectedSection = 'Complaints'),
                      child: const Text('View Complaints >', style: TextStyle(fontSize: 12, color: Color(0xFF0284C7), fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _buildSummaryBadge('Open / Pending', '$openC', Colors.amber.shade50, Colors.amber.shade800),
                    _buildSummaryBadge('In Progress', '$inProgressC', Colors.purple.shade50, Colors.purple.shade800),
                    _buildSummaryBadge('Verification', '$verificationC', Colors.blue.shade50, Colors.blue.shade800),
                    _buildSummaryBadge('Resolved', '$resolvedC', Colors.green.shade50, Colors.green.shade700),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 4. Recent Complaints Activity Stream
          if (recentC.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0)), boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 8, offset: const Offset(0, 3)),
              ]),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Recent $hostelCode Complaints', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                  const SizedBox(height: 10),
                  Column(
                    children: recentC.map((c) {
                      return GestureDetector(
                        onTap: () => _openComplaintDetailSheet(c),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(color: Color(0xFFF0F9FF), shape: BoxShape.circle),
                                child: const Icon(Icons.assignment_outlined, color: Color(0xFF0284C7), size: 18),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('#${c.id} • ${c.title}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                                    Text('${c.studentName} (${c.roomNumber}) • ${c.category}', style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6), border: Border.all(color: Colors.grey.shade300)),
                                child: Text(c.status, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF0284C7))),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ],
      );
    }
  }

  Widget _buildRichDashboardTile(String title, String value, IconData icon, Color bgColor, Color themeColor, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: themeColor.withValues(alpha: 0.25), width: 1.5),
            boxShadow: [
              BoxShadow(color: themeColor.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 3)),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
                child: Icon(icon, color: themeColor, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: themeColor), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryBadge(String label, String value, Color bg, Color fg) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
        child: Column(
          children: [
            Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: fg)),
            Text(label, style: TextStyle(fontSize: 8, color: fg), textAlign: TextAlign.center, maxLines: 1),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // TAB 3: NOTIFICATIONS & ANNOUNCEMENTS
  // -------------------------------------------------------------
  Widget _buildAnnouncementsTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Announcements & Alerts', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0284C7), foregroundColor: Colors.white, elevation: 0),
                onPressed: _postAnnouncementDialog,
                icon: const Icon(Icons.campaign, size: 16),
                label: const Text('Create Announcement', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text('Broadcast official announcements across all four hostels', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.separated(
              itemCount: ComplaintRepository.instance.announcements.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final notif = ComplaintRepository.instance.announcements[index];
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFE2E8F0))),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: const Color(0xFFF0F9FF), borderRadius: BorderRadius.circular(12)),
                        child: const Icon(Icons.campaign, color: Color(0xFF0284C7), size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(notif.title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                            const SizedBox(height: 2),
                            Text(notif.content, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                            const SizedBox(height: 4),
                            Text('Target: ${notif.targetRole} • Posted: ${notif.date}', style: const TextStyle(fontSize: 10, color: Color(0xFF0284C7), fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // TAB 4: PROFILE
  // -------------------------------------------------------------
  Widget _buildProfileTab(String mgmtName) {
    final user = AuthService.instance.currentUser;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Management Profile', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
          const SizedBox(height: 4),
          const Text('Manage administrator credentials and institutional settings', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFE2E8F0))),
            child: Column(
              children: [
                const CircleAvatar(radius: 36, backgroundColor: Color(0xFFF0F9FF), child: Icon(Icons.business_center, color: Color(0xFF0284C7), size: 40)),
                const SizedBox(height: 12),
                Text(mgmtName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                const SizedBox(height: 2),
                const Text('Hostel Operations & Administration', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF0284C7))),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
                  child: Column(
                    children: [
                      _buildProfileRow(Icons.badge_outlined, 'Admin ID', 'MGMT-HQ-01'),
                      Divider(height: 20, color: Colors.grey.shade200),
                      _buildProfileRow(Icons.apartment_outlined, 'Institution', 'Central Hostel Administration'),
                      Divider(height: 20, color: Colors.grey.shade200),
                      _buildProfileRow(Icons.email_outlined, 'Email ID', user?.email ?? 'management@institution.edu'),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red, width: 1.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      foregroundColor: Colors.red,
                    ),
                    onPressed: _logout,
                    icon: const Icon(Icons.logout_rounded, size: 20),
                    label: const Text('Log Out', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF0284C7), size: 20),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
            const SizedBox(height: 1),
            Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
          ],
        ),
      ],
    );
  }

  Widget _buildInteractiveStatCard(String label, String value, IconData icon, Color bgColor, Color textColor, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 3, vertical: 2),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: textColor.withValues(alpha: 0.25), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: textColor.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: bgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: textColor, size: 18),
              ),
              const SizedBox(height: 6),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF64748B),
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color bgColor, Color textColor) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 3, vertical: 2),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: textColor.withValues(alpha: 0.25), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: textColor.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: bgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: textColor, size: 18),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.bold,
                color: Color(0xFF64748B),
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
            ),
          ],
        ),
      ),
    );
  }
}
