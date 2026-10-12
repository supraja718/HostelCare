import 'package:flutter/material.dart';
import 'announcement_repository.dart';
import 'async_view_wrapper.dart';
import 'auth_service.dart';
import 'complaint_repository.dart';
import 'digital_outpass_page.dart';
import 'hospital_visit_repository.dart';
import 'hospital_visit_request_page.dart';
import 'mess_repository.dart';
import 'outpass_repository.dart';
import 'outpass_request_page.dart';
import 'report_issue_page.dart';
import 'role_selection_page.dart';
import 'weekly_mess_menu_page.dart';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  int _currentIndex = 0;
  String _selectedFilter = 'Total Issues';
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() {
      _isLoading = false;
    });
  }

  List<ComplaintItem> get _studentIssues {
    final currentName = AuthService.instance.currentUser?.name ?? 'Student User';
    return ComplaintRepository.instance.complaints
        .where((c) => c.studentName == currentName || c.studentName == 'Student User' || c.roomNumber == 'Room 204')
        .toList();
  }

  int get totalIssuesCount => _studentIssues.length;
  int get pendingCount => _studentIssues.where((i) => i.status == 'Pending' || i.status == 'New' || i.status == 'Reported').length;
  int get inProgressCount => _studentIssues.where((i) => i.status == 'In Progress' || i.status == 'Assigned' || i.status == 'Repair Completed' || i.status == 'Verified' || i.status == 'Reopened').length;
  int get resolvedCount => _studentIssues.where((i) => i.status == 'Resolved').length;

  List<ComplaintItem> get filteredIssues {
    final issues = _studentIssues;
    if (_selectedFilter == 'Pending') {
      return issues.where((i) => i.status == 'Pending' || i.status == 'New' || i.status == 'Reported').toList();
    } else if (_selectedFilter == 'In Progress') {
      return issues.where((i) => i.status == 'In Progress' || i.status == 'Assigned' || i.status == 'Repair Completed' || i.status == 'Verified' || i.status == 'Reopened').toList();
    } else if (_selectedFilter == 'Resolved') {
      return issues.where((i) => i.status == 'Resolved').toList();
    } else {
      return issues;
    }
  }

  void _openReportIssuePage() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ReportIssuePage()),
    );
    _loadData();
  }

  void _openStudentComplaintDetailSheet(ComplaintItem issue) {
    final reasonController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Container(
          height: MediaQuery.of(context).size.height * 0.85,
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStatusBadge(issue.status),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Text(issue.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
              const SizedBox(height: 2),
              Text('${issue.category} • ${issue.roomNumber} • Date: ${issue.date}', style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
              const SizedBox(height: 14),

              // Details Box
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
                    Text(issue.description, style: const TextStyle(fontSize: 13, color: Color(0xFF334155))),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Assigned Staff: ${issue.assignedStaff ?? "Unassigned"}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF15803D))),
                        Text('Expected: ${issue.expectedCompletionDate ?? "Pending Schedule"}', style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                      ],
                    ),
                    if (issue.workPerformed != null) ...[
                      const SizedBox(height: 8),
                      Text('Work Performed: ${issue.workPerformed}', style: const TextStyle(fontSize: 12, color: Color(0xFF15803D))),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Uploaded Photo Verification Display
              if (issue.resolutionProof != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCFCE7),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF86EFAC)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.verified, color: Color(0xFF15803D), size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Verified Repair Photo Proof:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF15803D))),
                            Text(issue.resolutionProof!, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF14532D))),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // Timeline Progress List
              const Text('Complaint Timeline:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF86EFAC)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: issue.timeline.map((step) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2.0),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle_rounded, color: Color(0xFF15803D), size: 16),
                          const SizedBox(width: 8),
                          Expanded(child: Text(step, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF14532D)))),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 20),

              // Resolution Confirmation or Reopen Actions
              if (issue.status == 'Repair Completed' || issue.status == 'Verified' || issue.status == 'Resolved') ...[
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF15803D),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () {
                          ComplaintRepository.instance.studentConfirmResolution(issue.id, true);
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Thank you! Complaint marked as Confirmed Resolved.'), backgroundColor: Color(0xFF15803D)),
                          );
                        },
                        icon: const Icon(Icons.check_circle, size: 18),
                        label: const Text('Confirm Resolved', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.red, width: 1.5),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          foregroundColor: Colors.red,
                        ),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Reopen Complaint', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              content: TextField(
                                controller: reasonController,
                                decoration: const InputDecoration(hintText: 'State reason for reopening...'),
                              ),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                  onPressed: () {
                                    ComplaintRepository.instance.studentConfirmResolution(issue.id, false, reopenReason: reasonController.text.trim());
                                    Navigator.pop(ctx);
                                    Navigator.pop(context);
                                  },
                                  child: const Text('Reopen', style: TextStyle(color: Colors.white)),
                                ),
                              ],
                            ),
                          );
                        },
                        icon: const Icon(Icons.replay, size: 18),
                        label: const Text('Reopen Issue', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
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
        content: const Text('Are you sure you want to log out of HostelCare?'),
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

  Widget _buildProfileDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF15803D), size: 20),
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

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([ComplaintRepository.instance, OutpassRepository.instance, MessRepository.instance, WardenAnnouncementRepository.instance, HospitalVisitRepository.instance]),
      builder: (context, _) {
        final currentUser = AuthService.instance.currentUser;
        final studentName = currentUser?.name ?? 'Student User';
        final roomNumber = currentUser?.roomNumber ?? 'Room 204';

        return Scaffold(
          backgroundColor: const Color(0xFFF5F6F8),
          floatingActionButton: _currentIndex == 0 || _currentIndex == 1
              ? FloatingActionButton.extended(
                  onPressed: _openReportIssuePage,
                  backgroundColor: const Color(0xFFDCFCE7),
                  foregroundColor: const Color(0xFF15803D),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: const BorderSide(color: Color(0xFF86EFAC), width: 1.5),
                  ),
                  icon: const Icon(Icons.add_rounded, color: Color(0xFF15803D)),
                  label: const Text(
                    'Report Issue',
                    style: TextStyle(color: Color(0xFF15803D), fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                )
              : null,
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
              selectedItemColor: const Color(0xFF15803D),
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
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.assignment_outlined),
                  activeIcon: Icon(Icons.assignment_rounded),
                  label: 'Complaints',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.notifications_outlined),
                  activeIcon: Icon(Icons.notifications_rounded),
                  label: 'Notification',
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
                _buildHomeTab(studentName, roomNumber),
                _buildComplaintsTab(),
                _buildNotificationsTab(),
                _buildProfileTab(currentUser, studentName, roomNumber),
              ],
            ),
          ),
        );
      },
    );
  }

  // -------------------------------------------------------------
  // HOME TAB
  // -------------------------------------------------------------
  Widget _buildHomeTab(String studentName, String roomNumber) {
    final displayedList = filteredIssues;
    final announcements = WardenAnnouncementRepository.instance.announcements;
    final latestAnnouncement = announcements.isNotEmpty ? announcements.first : null;
    final todaysMenu = MessRepository.instance.getTodaysMenu();
    final studentOutpasses = OutpassRepository.instance.outpasses.where((o) => o.studentName == studentName || o.studentId == 'STU01').toList();
    final approvedPass = studentOutpasses.where((o) => o.status == 'Approved').isNotEmpty ? studentOutpasses.firstWhere((o) => o.status == 'Approved') : null;
    final studentVisits = HospitalVisitRepository.instance.visits.where((v) => v.studentName == studentName || v.studentId == 'STU01').toList();
    final latestVisit = studentVisits.isNotEmpty ? studentVisits.first : null;

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 80.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Light Green Profile Header Banner
          Container(
            margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
            decoration: BoxDecoration(
              color: const Color(0xFFDCFCE7),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF86EFAC), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const CircleAvatar(
                    radius: 24,
                    backgroundColor: Color(0xFF86EFAC),
                    child: Icon(Icons.person, color: Color(0xFF14532D), size: 28),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        studentName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF14532D),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        roomNumber,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF166534),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _currentIndex = 2; // Jump to Notification tab
                    });
                  },
                  icon: const Badge(
                    label: Text('3'),
                    child: Icon(Icons.notifications_outlined, color: Color(0xFF14532D), size: 24),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Interactive Stat Cards
                Row(
                  children: [
                    _buildStatCard('Total Issues', '$totalIssuesCount', Icons.assignment, const Color(0xFFE0F2FE), const Color(0xFF0284C7)),
                    _buildStatCard('Pending', '$pendingCount', Icons.access_time_filled, const Color(0xFFFEF3C7), const Color(0xFFD97706)),
                    _buildStatCard('In Progress', '$inProgressCount', Icons.autorenew_rounded, const Color(0xFFF3E8FF), const Color(0xFF7E22CE)),
                    _buildStatCard('Resolved', '$resolvedCount', Icons.check_circle, const Color(0xFFDCFCE7), const Color(0xFF15803D)),
                  ],
                ),
                const SizedBox(height: 18),

                // Outpass & Digital Outpass Quick Banner
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF86EFAC), width: 1.5),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: const BoxDecoration(color: Color(0xFFDCFCE7), shape: BoxShape.circle),
                        child: const Icon(Icons.confirmation_number_outlined, color: Color(0xFF15803D), size: 24),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Outpass Management', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                            const SizedBox(height: 2),
                            Text(approvedPass != null ? 'Digital Outpass Approved!' : 'Apply for One-Day Outing or Home Visit.', style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                          ],
                        ),
                      ),
                      Column(
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFDCFCE7), foregroundColor: const Color(0xFF15803D), elevation: 0),
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => const OutpassRequestPage()));
                            },
                            child: const Text('Request', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                          ),
                          if (approvedPass != null) ...[
                            const SizedBox(height: 4),
                            TextButton(
                              style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(50, 20)),
                              onPressed: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => DigitalOutpassPage(outpass: approvedPass)));
                              },
                              child: const Text('View Pass 🎫', style: TextStyle(fontSize: 11, color: Color(0xFF15803D), fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Hospital Visit Quick Banner
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF86EFAC), width: 1.5),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: const BoxDecoration(color: Color(0xFFDCFCE7), shape: BoxShape.circle),
                        child: const Icon(Icons.local_hospital, color: Color(0xFF15803D), size: 24),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Hospital Visit Assistance', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                            const SizedBox(height: 2),
                            Text(
                              latestVisit != null
                                  ? (latestVisit.status == 'Arranged'
                                      ? 'Visit arranged for ${latestVisit.arrangedDate} at ${latestVisit.arrangedTime}'
                                      : 'Status: ${latestVisit.status}')
                                  : 'Request permission for medical visit.',
                              style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFDCFCE7), foregroundColor: const Color(0xFF15803D), elevation: 0),
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const HospitalVisitRequestPage()));
                        },
                        child: const Text('Request', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // Today's Mess Card (Weekly Repeating Schedule)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.restaurant_menu, color: Color(0xFF15803D), size: 20),
                              const SizedBox(width: 8),
                              Text(
                                MessRepository.instance.getTodayName() == 'Friday'
                                    ? "Today's Mess (Friday - FULL VEG 🌿)"
                                    : "Today's Mess (${MessRepository.instance.getTodayName()})",
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                              ),
                            ],
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => const WeeklyMessMenuPage()));
                            },
                            child: const Text('Weekly Menu >', style: TextStyle(fontSize: 12, color: Color(0xFF15803D), fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      todaysMenu.isEmpty
                          ? const Text("Today's menu has not been updated yet.", style: TextStyle(fontSize: 12, color: Colors.grey))
                          : Column(
                              children: todaysMenu.map((m) {
                                final isNonVeg = m.foodType == 'NON-VEG';
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        width: 80,
                                        child: Text(
                                          m.mealType,
                                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isNonVeg ? Colors.red.shade800 : const Color(0xFF15803D)),
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(m.items, style: const TextStyle(fontSize: 12, color: Color(0xFF334155))),
                                      ),
                                      const SizedBox(width: 4),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: isNonVeg ? Colors.red.shade50 : const Color(0xFFDCFCE7),
                                          borderRadius: BorderRadius.circular(4),
                                          border: Border.all(color: isNonVeg ? Colors.red.shade200 : const Color(0xFF86EFAC)),
                                        ),
                                        child: Text(
                                          isNonVeg ? 'NON-VEG' : 'VEG',
                                          style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: isNonVeg ? Colors.red.shade700 : const Color(0xFF15803D)),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // Recent Complaints Section Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Recent Complaints',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _currentIndex = 1; // Switch to Complaints tab
                        });
                      },
                      child: const Text(
                        'View All >',
                        style: TextStyle(fontSize: 13, color: Color(0xFF15803D), fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                // Filtered Issues Container (Using AsyncViewWrapper)
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: AsyncViewWrapper<ComplaintItem>(
                    isLoading: _isLoading,
                    errorMessage: _errorMessage,
                    items: displayedList,
                    emptyMessage: 'No complaints found.',
                    onRetry: _loadData,
                    onSuccess: (items) => Column(
                      children: items.map((issue) {
                        return Column(
                          children: [
                            GestureDetector(
                              onTap: () => _openStudentComplaintDetailSheet(issue),
                              child: _buildIssueListItem(issue),
                            ),
                            if (issue != items.last) const Divider(height: 1, color: Color(0xFFF1F5F9)),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Official Announcement Container
                if (latestAnnouncement != null) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: Color(0xFFFEF3C7),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.campaign, color: Color(0xFFD97706), size: 22),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              latestAnnouncement.isImportant ? 'Important Announcement 📢' : 'Warden Announcement',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: latestAnnouncement.isImportant ? const Color(0xFFFEF2F2) : const Color(0xFFDCFCE7),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: latestAnnouncement.isImportant ? const Color(0xFFFCA5A5) : const Color(0xFF86EFAC)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                latestAnnouncement.title,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: latestAnnouncement.isImportant ? Colors.red.shade800 : const Color(0xFF14532D),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                latestAnnouncement.message,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF166534),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // COMPLAINTS TAB
  // -------------------------------------------------------------
  Widget _buildComplaintsTab() {
    final list = filteredIssues;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'My Complaints',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
          ),
          const SizedBox(height: 4),
          const Text(
            'Track and view status of all reported hostel issues',
            style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 14),

          // Filter Choice Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ['Total Issues', 'Pending', 'In Progress', 'Resolved'].map((filter) {
                bool isSel = (_selectedFilter == filter);
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: FilterChip(
                    label: Text(filter),
                    selected: isSel,
                    selectedColor: const Color(0xFFDCFCE7),
                    checkmarkColor: const Color(0xFF15803D),
                    labelStyle: TextStyle(
                      fontSize: 12,
                      fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                      color: isSel ? const Color(0xFF15803D) : const Color(0xFF64748B),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isSel ? const Color(0xFF86EFAC) : Colors.grey.shade300,
                        width: isSel ? 1.5 : 1.0,
                      ),
                    ),
                    onSelected: (bool selected) {
                      setState(() {
                        _selectedFilter = filter;
                      });
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),

          Expanded(
            child: AsyncViewWrapper<ComplaintItem>(
              isLoading: _isLoading,
              errorMessage: _errorMessage,
              items: list,
              emptyMessage: 'No complaints found.',
              onRetry: _loadData,
              onSuccess: (items) => ListView.separated(
                itemCount: items.length,
                separatorBuilder: (context, index) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final issue = items[index];
                  return GestureDetector(
                    onTap: () => _openStudentComplaintDetailSheet(issue),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: _getCategoryBgColor(issue.category),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  _getCategoryIcon(issue.category),
                                  color: _getCategoryColor(issue.category),
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      issue.title,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF1E293B),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${issue.category} • ${issue.date}',
                                      style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                                    ),
                                  ],
                                ),
                              ),
                              _buildStatusBadge(issue.status),
                            ],
                          ),
                          if (issue.description.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              issue.description,
                              style: const TextStyle(fontSize: 11, color: Color(0xFF475569)),
                            ),
                          ],
                          if (issue.assignedStaff != null) ...[
                            const SizedBox(height: 6),
                            Text(
                              'Assigned Staff: ${issue.assignedStaff}',
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF15803D)),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // NOTIFICATIONS TAB
  // -------------------------------------------------------------
  Widget _buildNotificationsTab() {
    final annList = WardenAnnouncementRepository.instance.announcements;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Student Announcements & Alerts',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
          ),
          const SizedBox(height: 4),
          const Text(
            'Official announcements broadcasted by Warden',
            style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 16),

          Expanded(
            child: AsyncViewWrapper<WardenAnnouncementItem>(
              isLoading: _isLoading,
              errorMessage: _errorMessage,
              items: annList,
              emptyMessage: 'No announcements found.',
              onRetry: _loadData,
              onSuccess: (items) => ListView.separated(
                itemCount: items.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final announcement = items[index];
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: announcement.isImportant ? const Color(0xFFFCA5A5) : const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: announcement.isImportant ? const Color(0xFFFEF2F2) : const Color(0xFFDCFCE7),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(Icons.campaign, color: announcement.isImportant ? Colors.red : const Color(0xFF15803D), size: 24),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    announcement.title,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: announcement.isImportant ? Colors.red.shade800 : const Color(0xFF1E293B),
                                    ),
                                  ),
                                  Text(
                                    announcement.createdAt,
                                    style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                announcement.message,
                                style: const TextStyle(fontSize: 12, color: Color(0xFF334155)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // PROFILE TAB
  // -------------------------------------------------------------
  Widget _buildProfileTab(UserAccount? currentUser, String studentName, String roomNumber) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'My Profile',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
          ),
          const SizedBox(height: 4),
          const Text(
            'View and manage your hostel account profile details',
            style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 20),

          // Profile Main Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              children: [
                // Profile Avatar
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCFCE7),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF86EFAC), width: 2),
                  ),
                  child: const CircleAvatar(
                    radius: 36,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, color: Color(0xFF15803D), size: 44),
                  ),
                ),
                const SizedBox(height: 12),

                Text(
                  studentName,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                ),
                const SizedBox(height: 2),
                Text(
                  '$roomNumber • Block B',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF15803D)),
                ),
                const SizedBox(height: 20),

                // Details Container
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    children: [
                      _buildProfileDetailRow(Icons.badge_outlined, 'Roll Number', 'HC2024-8902'),
                      Divider(height: 20, color: Colors.grey.shade200),
                      _buildProfileDetailRow(Icons.apartment_outlined, 'Hostel Block', 'Block B - 2nd Floor'),
                      Divider(height: 20, color: Colors.grey.shade200),
                      _buildProfileDetailRow(Icons.email_outlined, 'Email ID', currentUser?.email ?? 'student@institution.edu'),
                      Divider(height: 20, color: Colors.grey.shade200),
                      _buildProfileDetailRow(Icons.phone_outlined, 'Contact No', '+91 98765 43210'),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Log Out Button
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
                    label: const Text(
                      'Log Out',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // HELPER WIDGETS
  // -------------------------------------------------------------
  Widget _buildStatCard(String label, String value, IconData icon, Color bgColor, Color textColor) {
    bool isSelected = (_selectedFilter == label);

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedFilter = label;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? textColor : Colors.transparent,
              width: 2.5,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: textColor.withValues(alpha: 0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    )
                  ]
                : [],
          ),
          child: Column(
            children: [
              Icon(icon, color: textColor, size: 20),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: textColor,
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

  Widget _buildIssueListItem(ComplaintItem issue) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Icon(
            _getCategoryIcon(issue.category),
            color: _getCategoryColor(issue.category),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  issue.title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                Text(
                  issue.category,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          _buildStatusBadge(issue.status),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bg;
    Color fg;

    switch (status) {
      case 'In Progress':
        bg = const Color(0xFFFEF3C7);
        fg = const Color(0xFFD97706);
        break;
      case 'Pending':
      case 'New':
      case 'Reported':
        bg = const Color(0xFFE0F2FE);
        fg = const Color(0xFF0284C7);
        break;
      case 'Repair Completed':
      case 'Verified':
        bg = const Color(0xFFE0E7FF);
        fg = const Color(0xFF4338CA);
        break;
      case 'Resolved':
      default:
        bg = const Color(0xFFDCFCE7);
        fg = const Color(0xFF15803D);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: fg,
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Electrical':
        return Icons.flash_on;
      case 'Plumbing':
        return Icons.water_drop;
      case 'Furniture':
        return Icons.chair;
      case 'Cleanliness':
        return Icons.cleaning_services;
      case 'Wi-Fi / Internet':
        return Icons.wifi;
      case 'Food / Mess':
        return Icons.restaurant;
      default:
        return Icons.build;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Electrical':
        return const Color(0xFFDC2626);
      case 'Plumbing':
        return const Color(0xFF2563EB);
      case 'Furniture':
        return const Color(0xFFD97706);
      case 'Cleanliness':
        return const Color(0xFF0D9488);
      case 'Wi-Fi / Internet':
        return const Color(0xFF9333EA);
      case 'Food / Mess':
        return const Color(0xFF15803D);
      default:
        return const Color(0xFF475569);
    }
  }

  Color _getCategoryBgColor(String category) {
    switch (category) {
      case 'Electrical':
        return const Color(0xFFFEE2E2);
      case 'Plumbing':
        return const Color(0xFFDBEAFE);
      case 'Furniture':
        return const Color(0xFFFEF3C7);
      case 'Cleanliness':
        return const Color(0xFFCCFBF1);
      case 'Wi-Fi / Internet':
        return const Color(0xFFF3E8FF);
      case 'Food / Mess':
        return const Color(0xFFDCFCE7);
      default:
        return const Color(0xFFF1F5F9);
    }
  }
}
