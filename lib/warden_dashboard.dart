import 'package:flutter/material.dart';
import 'announcement_repository.dart';
import 'auth_service.dart';
import 'complaint_repository.dart';
import 'hospital_visit_repository.dart';
import 'outpass_repository.dart';
import 'role_selection_page.dart';
import 'warden_hospital_visit_page.dart';
import 'warden_outpass_page.dart';

class WardenDashboard extends StatefulWidget {
  const WardenDashboard({super.key});

  @override
  State<WardenDashboard> createState() => _WardenDashboardState();
}

class _WardenDashboardState extends State<WardenDashboard> {
  int _currentIndex = 0;
  String _selectedFilter = 'New';
  String _searchQuery = '';
  String _selectedCategoryFilter = 'All';
  final String _selectedPriorityFilter = 'All';
  final String _selectedStaffFilter = 'All';
  final String _selectedSortBy = 'Newest';

  final List<String> _serviceStaffList = [
    'Ramesh - Electrician',
    'Suresh - Plumber',
    'Vikram - Carpenter',
    'Mahesh - Maintenance/Repair',
    'Rajesh - IT Support',
  ];

  List<ComplaintItem> get _allComplaints => ComplaintRepository.instance.complaints;
  List<HostelNotificationItem> get _allNotifications => ComplaintRepository.instance.notifications;

  int get newCount => _allComplaints.where((c) => c.status == 'New' || c.status == 'Reported').length;
  int get pendingCount => _allComplaints.where((c) => c.status == 'Pending').length;
  int get inProgressCount => _allComplaints.where((c) => c.status == 'In Progress' || c.status == 'Assigned' || c.status == 'Repair Completed' || c.status == 'Verified').length;
  int get overdueCount => _allComplaints.where((c) => c.status == 'Overdue' || c.status == 'Urgent' || c.status == 'Escalated').length;

  List<ComplaintItem> get filteredComplaints {
    var list = _allComplaints.where((c) {
      bool matchesFilter = true;
      if (_selectedFilter == 'New') {
        matchesFilter = c.status == 'New' || c.status == 'Reported';
      } else if (_selectedFilter == 'Pending') {
        matchesFilter = c.status == 'Pending';
      } else if (_selectedFilter == 'In Progress') {
        matchesFilter = c.status == 'In Progress' || c.status == 'Assigned' || c.status == 'Repair Completed' || c.status == 'Verified';
      } else if (_selectedFilter == 'Overdue') {
        matchesFilter = c.status == 'Overdue' || c.status == 'Urgent' || c.status == 'Escalated';
      } else if (_selectedFilter == 'Resolved') {
        matchesFilter = c.status == 'Resolved';
      } else if (_selectedFilter == 'Sensitive') {
        matchesFilter = c.isSensitive;
      }

      bool matchesCategory = true;
      if (_selectedCategoryFilter != 'All') {
        matchesCategory = c.category == _selectedCategoryFilter;
      }

      bool matchesPriority = true;
      if (_selectedPriorityFilter != 'All') {
        matchesPriority = c.priority == _selectedPriorityFilter;
      }

      bool matchesStaff = true;
      if (_selectedStaffFilter != 'All') {
        if (_selectedStaffFilter == 'Unassigned') {
          matchesStaff = c.assignedStaff == null;
        } else {
          matchesStaff = c.assignedStaff != null && c.assignedStaff!.contains(_selectedStaffFilter);
        }
      }

      bool matchesSearch = true;
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        matchesSearch = c.id.toLowerCase().contains(query) ||
            c.title.toLowerCase().contains(query) ||
            c.studentName.toLowerCase().contains(query) ||
            c.roomNumber.toLowerCase().contains(query) ||
            c.category.toLowerCase().contains(query) ||
            (c.assignedStaff != null && c.assignedStaff!.toLowerCase().contains(query));
      }

      return matchesFilter && matchesCategory && matchesPriority && matchesStaff && matchesSearch;
    }).toList();

    if (_selectedSortBy == 'Priority') {
      list.sort((a, b) {
        int weight(String p) {
          if (p == 'Urgent') return 3;
          if (p == 'High') return 2;
          if (p == 'Medium') return 1;
          return 0;
        }
        return weight(b.priority).compareTo(weight(a.priority));
      });
    } else if (_selectedSortBy == 'Status') {
      list.sort((a, b) => a.status.compareTo(b.status));
    } else {
      list.sort((a, b) => b.id.compareTo(a.id));
    }

    return list;
  }

  void _openCreateAnnouncementDialog() {
    final titleController = TextEditingController();
    final messageController = TextEditingController();
    bool isImportant = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.campaign, color: Color(0xFF7E22CE)),
              SizedBox(width: 8),
              Text('Publish Announcement', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(labelText: 'Title', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)), isDense: true),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: messageController,
                maxLines: 3,
                decoration: InputDecoration(labelText: 'Message / Content', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)), isDense: true),
              ),
              const SizedBox(height: 12),
              CheckboxListTile(
                title: const Text('Mark as Important ⚠️', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                value: isImportant,
                onChanged: (val) => setDialogState(() => isImportant = val ?? false),
                contentPadding: EdgeInsets.zero,
                activeColor: const Color(0xFF7E22CE),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(color: Colors.grey))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF7E22CE)),
              onPressed: () {
                if (titleController.text.trim().isNotEmpty && messageController.text.trim().isNotEmpty) {
                  final wardenName = AuthService.instance.currentUser?.name ?? 'Warden Administrator';
                  WardenAnnouncementRepository.instance.createAnnouncement(
                    WardenAnnouncementItem(
                      announcementId: 'AN-${DateTime.now().millisecondsSinceEpoch}',
                      title: titleController.text.trim(),
                      message: messageController.text.trim(),
                      createdBy: wardenName,
                      createdAt: 'Today',
                      isImportant: isImportant,
                      status: 'Published',
                    ),
                  );
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Announcement published to all students!'), backgroundColor: Color(0xFF7E22CE)));
                }
              },
              child: const Text('Publish', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  void _assignStaffDialog(ComplaintItem complaint) {
    String selectedStaff = _serviceStaffList.first;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Assign Service Staff', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Complaint: ${complaint.title}',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
              ),
              Text(
                '${complaint.studentName} (${complaint.roomNumber})',
                style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 16),
              const Text('Select Staff Member:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                initialValue: selectedStaff,
                items: _serviceStaffList.map((staff) {
                  return DropdownMenuItem(value: staff, child: Text(staff, style: const TextStyle(fontSize: 13)));
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setDialogState(() {
                      selectedStaff = val;
                    });
                  }
                },
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7E22CE),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                ComplaintRepository.instance.assignStaff(complaint.id, selectedStaff);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Assigned $selectedStaff to "${complaint.title}"'),
                    backgroundColor: const Color(0xFF7E22CE),
                  ),
                );
              },
              child: const Text('Assign Staff', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  void _openComplaintDetailSheet(ComplaintItem complaint) {
    final noteController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Container(
          height: MediaQuery.of(context).size.height * 0.88,
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sheet Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      _buildWardenStatusBadge(complaint.status),
                      if (complaint.isSensitive) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3E8FF),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.lock, color: Color(0xFF7E22CE), size: 12),
                              SizedBox(width: 4),
                              Text('Sensitive 🔒', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF7E22CE))),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Text(
                complaint.title,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
              ),
              const SizedBox(height: 4),
              Text(
                '${complaint.studentName} • ${complaint.roomNumber} (${complaint.category})',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF7E22CE)),
              ),
              Text('Reported: ${complaint.date} • Priority: ${complaint.priority}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
              const SizedBox(height: 14),

              // Detailed Box
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
                    const SizedBox(height: 2),
                    Text(complaint.description, style: const TextStyle(fontSize: 13, color: Color(0xFF334155))),
                    const SizedBox(height: 8),
                    Text('Assigned Staff: ${complaint.assignedStaff ?? "Unassigned"}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF7E22CE))),
                    Text('Expected Completion: ${complaint.expectedCompletionDate ?? "Not set"}', style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                    if (complaint.workPerformed != null) ...[
                      const SizedBox(height: 6),
                      Text('Work Performed: ${complaint.workPerformed}', style: const TextStyle(fontSize: 12, color: Color(0xFF15803D))),
                      if (complaint.materialsUsed != null) Text('Materials Used: ${complaint.materialsUsed}', style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Uploaded Repair Photo Proof Container
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
                      const Icon(Icons.verified, color: Color(0xFF15803D), size: 20),
                      const SizedBox(width: 8),
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
                const SizedBox(height: 12),
              ],

              // Actions
              Row(
                children: [
                  if (complaint.status == 'Repair Completed' || complaint.status == 'Resolved') ...[
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF15803D), foregroundColor: Colors.white),
                        onPressed: () {
                          ComplaintRepository.instance.verifyByWarden(complaint.id);
                          setSheetState(() {});
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Repair verified by Warden! Student notified.'), backgroundColor: Color(0xFF15803D)));
                        },
                        icon: const Icon(Icons.verified, size: 16),
                        label: const Text('Verify Repair', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.red), foregroundColor: Colors.red),
                      onPressed: () {
                        ComplaintRepository.instance.updateStatus(complaint.id, 'In Progress', 'Rejected by Warden. Reopened for service staff.');
                        setSheetState(() {});
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Repair rejected. Sent back to In Progress.'), backgroundColor: Colors.red));
                      },
                      icon: const Icon(Icons.replay, size: 16),
                      label: const Text('Reject / Reopen', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Staff Assignment & Status Change
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF3E8FF),
                      foregroundColor: const Color(0xFF7E22CE),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: const BorderSide(color: Color(0xFFC084FC))),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      _assignStaffDialog(complaint);
                    },
                    icon: const Icon(Icons.person_add_alt_1, size: 16),
                    label: const Text('Assign / Change Staff', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                  DropdownButton<String>(
                    value: complaint.status == 'Reported' ? 'New' : (['New', 'Pending', 'In Progress', 'Overdue', 'Escalated', 'Resolved'].contains(complaint.status) ? complaint.status : 'In Progress'),
                    items: ['New', 'Pending', 'In Progress', 'Overdue', 'Escalated', 'Resolved'].map((st) {
                      return DropdownMenuItem(value: st, child: Text(st, style: const TextStyle(fontSize: 12)));
                    }).toList(),
                    onChanged: (newStatus) {
                      if (newStatus != null) {
                        ComplaintRepository.instance.updateStatus(complaint.id, newStatus, null);
                        setSheetState(() {});
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Timeline
              const Text('Timeline:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              Expanded(
                child: ListView.builder(
                  itemCount: complaint.timeline.length,
                  itemBuilder: (ctx, idx) => Text('• ${complaint.timeline[idx]}', style: const TextStyle(fontSize: 11, color: Color(0xFF475569))),
                ),
              ),

              // Add Note Input
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: noteController,
                      decoration: InputDecoration(
                        hintText: 'Add warden remark...',
                        hintStyle: const TextStyle(fontSize: 12),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7E22CE),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () {
                      if (noteController.text.trim().isNotEmpty) {
                        ComplaintRepository.instance.updateStatus(complaint.id, complaint.status, noteController.text.trim());
                        setSheetState(() {});
                        noteController.clear();
                      }
                    },
                    child: const Text('Add', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
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
        content: const Text('Are you sure you want to log out of Warden Portal?'),
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
      listenable: Listenable.merge([ComplaintRepository.instance, OutpassRepository.instance, WardenAnnouncementRepository.instance, HospitalVisitRepository.instance]),
      builder: (context, _) {
        final currentUser = AuthService.instance.currentUser;
        final wardenName = currentUser?.name ?? 'Warden Administrator';

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
              selectedItemColor: const Color(0xFF7E22CE),
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
                  label: 'Notifications',
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
                _buildHomeTab(wardenName),
                _buildComplaintsPageTab(),
                _buildNotificationsPageTab(),
                _buildProfileTab(wardenName),
              ],
            ),
          ),
        );
      },
    );
  }

  // -------------------------------------------------------------
  // WARDEN HOME TAB
  // -------------------------------------------------------------
  Widget _buildHomeTab(String wardenName) {
    final displayedList = filteredComplaints;
    final roleAnnouncements = WardenAnnouncementRepository.instance.announcements;
    final latestAnnouncement = roleAnnouncements.isNotEmpty ? roleAnnouncements.first : null;

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 80.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Banner
          Container(
            margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
            decoration: BoxDecoration(
              color: const Color(0xFFF3E8FF),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFC084FC), width: 1.5),
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
                    backgroundColor: Color(0xFFE9D5FF),
                    child: Icon(Icons.person, color: Color(0xFF581C87), size: 28),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        wardenName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF581C87),
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Block B Overseer',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF7E22CE),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _currentIndex = 2;
                    });
                  },
                  icon: Badge(
                    label: Text('${_allNotifications.length}'),
                    child: const Icon(Icons.notifications_outlined, color: Color(0xFF581C87), size: 24),
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
                // Overview Section
                Row(
                  children: [
                    _buildOverviewCard('New', '$newCount', Icons.mark_email_unread_outlined, const Color(0xFFEFF6FF), const Color(0xFF2563EB)),
                    _buildOverviewCard('Pending', '$pendingCount', Icons.access_time_filled, const Color(0xFFFEF3C7), const Color(0xFFD97706)),
                    _buildOverviewCard('In Progress', '$inProgressCount', Icons.build_circle, const Color(0xFFF3E8FF), const Color(0xFF7E22CE)),
                    _buildOverviewCard('Overdue', '$overdueCount', Icons.alarm_off, const Color(0xFFFFEDD5), const Color(0xFFC2410C)),
                  ],
                ),
                const SizedBox(height: 18),

                // Outpass & Hospital Visit Quick Management Banners
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const WardenOutpassPage()));
                        },
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFC084FC), width: 1.5),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.confirmation_number_outlined, color: Color(0xFF7E22CE), size: 22),
                              SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Outpasses', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                                    Text('Review requests', style: TextStyle(fontSize: 10, color: Color(0xFF64748B))),
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
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const WardenHospitalVisitPage()));
                        },
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFC084FC), width: 1.5),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.local_hospital, color: Color(0xFF7E22CE), size: 22),
                              SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Hospital Visits', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                                    Text('Medical permits', style: TextStyle(fontSize: 10, color: Color(0xFF64748B))),
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
                const SizedBox(height: 16),

                // Announcement Action Button
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF3E8FF),
                      foregroundColor: const Color(0xFF7E22CE),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: Color(0xFFC084FC))),
                    ),
                    onPressed: _openCreateAnnouncementDialog,
                    icon: const Icon(Icons.campaign, size: 20),
                    label: const Text('Publish Warden Announcement', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  ),
                ),
                const SizedBox(height: 20),

                // Recent Complaints Header
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
                          _currentIndex = 1;
                        });
                      },
                      child: const Text(
                        'View All →',
                        style: TextStyle(fontSize: 13, color: Color(0xFF7E22CE), fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                // Recent Complaints List Container
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: displayedList.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Center(
                            child: Column(
                              children: [
                                Icon(Icons.inbox_outlined, color: Colors.grey.shade400, size: 36),
                                const SizedBox(height: 8),
                                Text(
                                  'No $_selectedFilter complaints found.',
                                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          ),
                        )
                      : Column(
                          children: displayedList.take(4).map((complaint) {
                            return Column(
                              children: [
                                GestureDetector(
                                  onTap: () => _openComplaintDetailSheet(complaint),
                                  child: _buildWardenComplaintTile(complaint),
                                ),
                                if (complaint != displayedList.take(4).last) const Divider(height: 1, color: Color(0xFFF1F5F9)),
                              ],
                            );
                          }).toList(),
                        ),
                ),
                const SizedBox(height: 20),

                // Official Management Announcement
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
                                color: Color(0xFFF3E8FF),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.campaign, color: Color(0xFF7E22CE), size: 22),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              latestAnnouncement.isImportant ? 'Important Warden Announcement 📢' : 'Warden Announcement',
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
                            color: latestAnnouncement.isImportant ? const Color(0xFFFEF2F2) : const Color(0xFFF3E8FF),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: latestAnnouncement.isImportant ? const Color(0xFFFCA5A5) : const Color(0xFFC084FC)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    latestAnnouncement.title,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: latestAnnouncement.isImportant ? Colors.red.shade800 : const Color(0xFF581C87),
                                    ),
                                  ),
                                  Text(
                                    latestAnnouncement.createdAt,
                                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF7E22CE)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                latestAnnouncement.message,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF6B21A8),
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
  // COMPLAINTS PAGE
  // -------------------------------------------------------------
  Widget _buildComplaintsPageTab() {
    final list = filteredComplaints;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Complaints Management',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.filter_list_rounded, color: Color(0xFF7E22CE)),
                tooltip: 'Advanced Filter & Sort',
              ),
            ],
          ),
          const SizedBox(height: 2),
          const Text(
            'Search, filter by category/priority/staff, and manage complaint lifecycle',
            style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 14),

          // Search Bar
          TextField(
            onChanged: (val) {
              setState(() {
                _searchQuery = val;
              });
            },
            decoration: InputDecoration(
              isDense: true,
              hintText: 'Search ID, title, student, room, category, staff...',
              hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
              prefixIcon: const Icon(Icons.search, color: Color(0xFF7E22CE), size: 20),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF7E22CE), width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Status Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ['All', 'New', 'Pending', 'In Progress', 'Overdue', 'Sensitive', 'Resolved'].map((filter) {
                bool isSel = (_selectedFilter == filter);
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: FilterChip(
                    label: Text(filter == 'Sensitive' ? 'Sensitive 🔒' : filter),
                    selected: isSel,
                    selectedColor: const Color(0xFFF3E8FF),
                    checkmarkColor: const Color(0xFF7E22CE),
                    labelStyle: TextStyle(
                      fontSize: 12,
                      fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                      color: isSel ? const Color(0xFF7E22CE) : const Color(0xFF64748B),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isSel ? const Color(0xFFC084FC) : Colors.grey.shade300,
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
          const SizedBox(height: 8),

          // Category Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ['All Categories', 'Electrical', 'Plumbing', 'Furniture', 'Cleanliness', 'Wi-Fi / Internet', 'Welfare / Misconduct'].map((cat) {
                bool isSel = (_selectedCategoryFilter == (cat == 'All Categories' ? 'All' : cat));
                return Padding(
                  padding: const EdgeInsets.only(right: 6.0),
                  child: ActionChip(
                    label: Text(cat, style: TextStyle(fontSize: 11, color: isSel ? Colors.white : const Color(0xFF475569))),
                    backgroundColor: isSel ? const Color(0xFF7E22CE) : Colors.white,
                    side: BorderSide(color: Colors.grey.shade300),
                    onPressed: () {
                      setState(() {
                        _selectedCategoryFilter = (cat == 'All Categories' ? 'All' : cat);
                      });
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),

          // Complaints List
          Expanded(
            child: list.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inbox_outlined, color: Colors.grey.shade400, size: 48),
                        const SizedBox(height: 12),
                        Text(
                          'No $_selectedFilter complaints found.',
                          style: TextStyle(fontSize: 14, color: Colors.grey.shade600, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    itemCount: list.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final complaint = list[index];
                      return GestureDetector(
                        onTap: () => _openComplaintDetailSheet(complaint),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: complaint.isSensitive ? const Color(0xFFC084FC) : const Color(0xFFE2E8F0),
                              width: complaint.isSensitive ? 1.5 : 1.0,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        '#${complaint.id} • ${complaint.studentName} (${complaint.roomNumber})',
                                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                                      ),
                                      if (complaint.isSensitive) ...[
                                        const SizedBox(width: 6),
                                        const Icon(Icons.lock, color: Color(0xFF7E22CE), size: 14),
                                      ],
                                    ],
                                  ),
                                  _buildWardenStatusBadge(complaint.status),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                complaint.title,
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${complaint.category} • Priority: ${complaint.priority} • ${complaint.date}',
                                style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                              ),
                              const SizedBox(height: 10),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    complaint.assignedStaff != null ? 'Staff: ${complaint.assignedStaff}' : 'Staff: Unassigned',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: complaint.assignedStaff != null ? const Color(0xFF15803D) : Colors.red.shade700,
                                    ),
                                  ),
                                  const Text('Tap for Details →', style: TextStyle(fontSize: 11, color: Color(0xFF7E22CE), fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ],
                          ),
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
  // NOTIFICATIONS PAGE
  // -------------------------------------------------------------
  Widget _buildNotificationsPageTab() {
    final wardenAnnouncements = WardenAnnouncementRepository.instance.announcements;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Warden Notifications & Announcements',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
          ),
          const SizedBox(height: 4),
          const Text(
            'Official announcements broadcasted specifically for Wardens',
            style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 16),

          Expanded(
            child: ListView.separated(
              itemCount: wardenAnnouncements.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final notif = wardenAnnouncements[index];
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3E8FF),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.campaign,
                          color: Color(0xFF7E22CE),
                          size: 22,
                        ),
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
                                  notif.title,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1E293B),
                                  ),
                                ),
                                Text(
                                  notif.createdAt,
                                  style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              notif.message,
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
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // PROFILE TAB
  // -------------------------------------------------------------
  Widget _buildProfileTab(String wardenName) {
    final user = AuthService.instance.currentUser;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Warden Profile',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
          ),
          const SizedBox(height: 4),
          const Text(
            'Manage warden credentials and hostel administration account',
            style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 20),

          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3E8FF),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFC084FC), width: 2),
                  ),
                  child: const CircleAvatar(
                    radius: 36,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, color: Color(0xFF7E22CE), size: 44),
                  ),
                ),
                const SizedBox(height: 12),

                Text(
                  wardenName,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Block B Overseer',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF7E22CE)),
                ),
                const SizedBox(height: 20),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    children: [
                      _buildWardenProfileRow(Icons.badge_outlined, 'Employee ID', 'WARDEN-B-04'),
                      Divider(height: 20, color: Colors.grey.shade200),
                      _buildWardenProfileRow(Icons.apartment_outlined, 'Assigned Hostel', 'Block B - Mens Hostel'),
                      Divider(height: 20, color: Colors.grey.shade200),
                      _buildWardenProfileRow(Icons.email_outlined, 'Email ID', user?.email ?? 'warden.blockb@institution.edu'),
                      Divider(height: 20, color: Colors.grey.shade200),
                      _buildWardenProfileRow(Icons.phone_outlined, 'Emergency Contact', '+91 91234 56789'),
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

  Widget _buildWardenProfileRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF7E22CE), size: 20),
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

  Widget _buildOverviewCard(String label, String value, IconData icon, Color bgColor, Color textColor) {
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

  Widget _buildWardenComplaintTile(ComplaintItem complaint) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: const Color(0xFFF3E8FF),
            child: Text(
              complaint.studentName[0],
              style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF7E22CE), fontSize: 13),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '#${complaint.id} • ${complaint.title}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    if (complaint.isSensitive) ...[
                      const SizedBox(width: 4),
                      const Icon(Icons.lock, color: Color(0xFF7E22CE), size: 12),
                    ],
                  ],
                ),
                Text(
                  '${complaint.studentName} • ${complaint.roomNumber}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          _buildWardenStatusBadge(complaint.status),
        ],
      ),
    );
  }

  Widget _buildWardenStatusBadge(String status) {
    Color bg;
    Color fg;

    switch (status) {
      case 'New':
      case 'Reported':
        bg = const Color(0xFFEFF6FF);
        fg = const Color(0xFF2563EB);
        break;
      case 'Pending':
        bg = const Color(0xFFFEF3C7);
        fg = const Color(0xFFD97706);
        break;
      case 'In Progress':
      case 'Assigned':
        bg = const Color(0xFFF3E8FF);
        fg = const Color(0xFF7E22CE);
        break;
      case 'Overdue':
      case 'Urgent':
      case 'Escalated':
        bg = const Color(0xFFFFEDD5);
        fg = const Color(0xFFC2410C);
        break;
      case 'Repair Completed':
      case 'Verified':
        bg = const Color(0xFFDCFCE7);
        fg = const Color(0xFF15803D);
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
}
