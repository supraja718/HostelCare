import 'package:flutter/material.dart';
import 'auth_service.dart';
import 'complaint_repository.dart';
import 'role_selection_page.dart';

class StudentCareDashboard extends StatefulWidget {
  const StudentCareDashboard({super.key});

  @override
  State<StudentCareDashboard> createState() => _StudentCareDashboardState();
}

class _StudentCareDashboardState extends State<StudentCareDashboard> {
  int _currentIndex = 0;
  String _selectedFilter = 'Active Cases';

  void _openCaseDetailSheet(ComplaintItem caseItem) {
    final officerNotesController = TextEditingController(text: caseItem.welfareOfficerNotes ?? '');
    final confidentialNotesController = TextEditingController(text: caseItem.welfareConfidentialNotes ?? '');
    final followUpController = TextEditingController(text: caseItem.followUpScheduledDate ?? '');
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.88,
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(color: const Color(0xFFFDF2F8), borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFFBCFE8))),
                          child: Text(caseItem.status, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFDB2777))),
                        ),
                        IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                      ],
                    ),
                    const SizedBox(height: 8),

                    Text(caseItem.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                    const SizedBox(height: 4),
                    Text('${caseItem.studentName} • ${caseItem.roomNumber} (Priority: ${caseItem.priority})', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFFDB2777))),
                    Text('Reported on ${caseItem.date}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                    const SizedBox(height: 14),

                    // Details Box
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Student Description:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                          const SizedBox(height: 2),
                          Text(caseItem.description, style: const TextStyle(fontSize: 12, color: Color(0xFF334155))),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Case Timeline Progress
                    const Text('Case Timeline:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: const Color(0xFFFDF2F8), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFFBCFE8))),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: caseItem.timeline.map((step) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2.0),
                            child: Row(
                              children: [
                                const Icon(Icons.check_circle_rounded, color: Color(0xFFDB2777), size: 16),
                                const SizedBox(width: 8),
                                Expanded(child: Text(step, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF9D174D)))),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Officer Notes & Confidential Notes Form
                    const Text('Counselor Notes & Follow-up:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                    const SizedBox(height: 8),

                    TextFormField(
                      controller: followUpController,
                      decoration: InputDecoration(
                        labelText: 'Scheduled Follow-up Date/Time',
                        hintText: 'e.g. Tomorrow, 10:00 AM',
                        isDense: true,
                        prefixIcon: const Icon(Icons.calendar_month, color: Color(0xFFDB2777), size: 20),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    const SizedBox(height: 10),

                    TextFormField(
                      controller: officerNotesController,
                      decoration: InputDecoration(
                        labelText: 'Officer Summary Notes',
                        hintText: 'e.g. Initial counseling session completed.',
                        isDense: true,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Strictly Confidential Notes Box
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: const Color(0xFFFEF2F2), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFFCA5A5))),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.lock, color: Colors.red, size: 16),
                              SizedBox(width: 6),
                              Text('CONFIDENTIAL NOTES (Authorized Officers Only)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.red)),
                            ],
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: confidentialNotesController,
                            maxLines: 2,
                            decoration: const InputDecoration(
                              hintText: 'Enter private counseling & welfare details...',
                              hintStyle: TextStyle(fontSize: 12),
                              isDense: true,
                              border: InputBorder.none,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Status Dropdown & Save Button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        DropdownButton<String>(
                          value: ['Under Review', 'Follow-up Scheduled', 'In Progress', 'Resolved'].contains(caseItem.status) ? caseItem.status : 'Under Review',
                          items: ['Under Review', 'Follow-up Scheduled', 'In Progress', 'Resolved'].map((st) {
                            return DropdownMenuItem(value: st, child: Text(st, style: const TextStyle(fontSize: 12)));
                          }).toList(),
                          onChanged: (newStatus) {
                            if (newStatus != null) {
                              setSheetState(() {
                                caseItem.status = newStatus;
                              });
                            }
                          },
                        ),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFDB2777), foregroundColor: Colors.white),
                          onPressed: () {
                            ComplaintRepository.instance.updateWelfareCase(
                              complaintId: caseItem.id,
                              status: caseItem.status,
                              followUpDate: followUpController.text.trim(),
                              officerNotes: officerNotesController.text.trim(),
                              confidentialNotes: confidentialNotesController.text.trim(),
                            );
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Welfare case details updated securely!'), backgroundColor: Color(0xFFDB2777)));
                          },
                          icon: const Icon(Icons.save, size: 16),
                          label: const Text('Save Confidential Case', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
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
        content: const Text('Are you sure you want to log out of Student Care Portal?'),
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
      listenable: ComplaintRepository.instance,
      builder: (context, _) {
        final careUser = AuthService.instance.currentUser;
        final careName = careUser?.name ?? 'Student Care Officer';

        final welfareList = ComplaintRepository.instance.complaints
            .where((c) => c.isSensitive || c.category.contains('Welfare') || c.category.contains('Misconduct'))
            .toList();

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
              selectedItemColor: const Color(0xFFDB2777),
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
                  icon: Icon(Icons.favorite_outline),
                  activeIcon: Icon(Icons.favorite),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.assignment_outlined),
                  activeIcon: Icon(Icons.assignment_rounded),
                  label: 'Cases',
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
                _buildHomeTab(careName, welfareList),
                _buildCasesTab(welfareList),
                _buildNotificationsTab(),
                _buildProfileTab(careName),
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
  Widget _buildHomeTab(String careName, List<ComplaintItem> welfareList) {
    final careAnnouncements = ComplaintRepository.instance.getAnnouncementsForRoleAndDept('Student Care');
    final latestAnnouncement = careAnnouncements.isNotEmpty ? careAnnouncements.first : null;

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 80.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Light Pink Student Care Profile Banner
          Container(
            margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
            decoration: BoxDecoration(
              color: const Color(0xFFFDF2F8),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFFBCFE8), width: 1.5),
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
                    backgroundColor: Color(0xFFFBCFE8),
                    child: Icon(Icons.favorite, color: Color(0xFFDB2777), size: 26),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        careName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF9D174D),
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Student Welfare & Counseling',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFDB2777),
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
                  icon: const Badge(
                    label: Text('2'),
                    child: Icon(Icons.notifications_outlined, color: Color(0xFFDB2777), size: 24),
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
                // Overview Stat Cards
                Row(
                  children: [
                    _buildStatCard('Active Cases', '${welfareList.length}', Icons.favorite, const Color(0xFFFDF2F8), const Color(0xFFDB2777)),
                    _buildStatCard('In Review', '${welfareList.where((w) => w.status == 'Under Review').length}', Icons.rate_review, const Color(0xFFFEF3C7), const Color(0xFFD97706)),
                    _buildStatCard('Resolved', '${welfareList.where((w) => w.status == 'Resolved').length}', Icons.check_circle_outline, const Color(0xFFDCFCE7), const Color(0xFF15803D)),
                  ],
                ),
                const SizedBox(height: 22),

                // Recent Welfare Cases Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Welfare Cases',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _currentIndex = 1;
                        });
                      },
                      child: const Text('View All >', style: TextStyle(fontSize: 13, color: Color(0xFFDB2777), fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                // Cases List
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: welfareList.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Center(
                            child: Column(
                              children: [
                                Icon(Icons.favorite_border, color: Colors.grey.shade400, size: 36),
                                const SizedBox(height: 8),
                                Text('No active welfare cases.', style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
                              ],
                            ),
                          ),
                        )
                      : Column(
                          children: welfareList.map((caseItem) {
                            return Column(
                              children: [
                                ListTile(
                                  onTap: () => _openCaseDetailSheet(caseItem),
                                  leading: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFFDF2F8),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.favorite, color: Color(0xFFDB2777), size: 20),
                                  ),
                                  title: Text(caseItem.title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                                  subtitle: Text('${caseItem.studentName} (${caseItem.roomNumber})', style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                                  trailing: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFDF2F8),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(color: const Color(0xFFFBCFE8)),
                                    ),
                                    child: Text(caseItem.status, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFFDB2777))),
                                  ),
                                ),
                                if (caseItem != welfareList.last) const Divider(height: 1, color: Color(0xFFF1F5F9)),
                              ],
                            );
                          }).toList(),
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
                                color: Color(0xFFFDF2F8),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.campaign, color: Color(0xFFDB2777), size: 22),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Announcement (${latestAnnouncement.targetRole})',
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
                            color: const Color(0xFFFDF2F8),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFFBCFE8)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                latestAnnouncement.title,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF9D174D),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                latestAnnouncement.content,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFFDB2777),
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
  // CASES TAB
  // -------------------------------------------------------------
  Widget _buildCasesTab(List<ComplaintItem> welfareList) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Student Care Cases', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
          const SizedBox(height: 4),
          const Text('Review and resolve student welfare and counseling requests', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
          const SizedBox(height: 16),
          Expanded(
            child: welfareList.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.favorite_border, color: Colors.grey.shade400, size: 48),
                        const SizedBox(height: 12),
                        Text('No active student care cases.', style: TextStyle(fontSize: 14, color: Colors.grey.shade600, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  )
                : ListView.separated(
                    itemCount: welfareList.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final item = welfareList[index];
                      return GestureDetector(
                        onTap: () => _openCaseDetailSheet(item),
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
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('${item.studentName} (${item.roomNumber})', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFDF2F8),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(color: const Color(0xFFFBCFE8)),
                                    ),
                                    child: Text(item.status, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFFDB2777))),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(item.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                              const SizedBox(height: 2),
                              Text(item.description, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                              if (item.followUpScheduledDate != null) ...[
                                const SizedBox(height: 6),
                                Text('Follow-up: ${item.followUpScheduledDate}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFDB2777))),
                              ],
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
  // NOTIFICATIONS TAB
  // -------------------------------------------------------------
  Widget _buildNotificationsTab() {
    final careAnnouncements = ComplaintRepository.instance.getAnnouncementsForRoleAndDept('Student Care');

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Student Care Notifications', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
          const SizedBox(height: 4),
          const Text('Student welfare notifications and official announcements', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.separated(
              itemCount: careAnnouncements.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final ann = careAnnouncements[index];
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFE2E8F0))),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: const Color(0xFFFDF2F8), borderRadius: BorderRadius.circular(12)),
                        child: const Icon(Icons.campaign, color: Color(0xFFDB2777), size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(ann.title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                            const SizedBox(height: 2),
                            Text(ann.content, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
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
  Widget _buildProfileTab(String careName) {
    final user = AuthService.instance.currentUser;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Student Care Profile', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
          const SizedBox(height: 4),
          const Text('Manage student care counselor profile', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFE2E8F0))),
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 36,
                  backgroundColor: Color(0xFFFDF2F8),
                  child: Icon(Icons.favorite, color: Color(0xFFDB2777), size: 40),
                ),
                const SizedBox(height: 12),
                Text(careName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                const SizedBox(height: 2),
                const Text('Hostel Counseling & Student Care', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFFDB2777))),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
                  child: Column(
                    children: [
                      _buildProfileRow(Icons.badge_outlined, 'Counselor ID', 'CARE-HQ-09'),
                      Divider(height: 20, color: Colors.grey.shade200),
                      _buildProfileRow(Icons.apartment_outlined, 'Department', 'Student Welfare & Counseling'),
                      Divider(height: 20, color: Colors.grey.shade200),
                      _buildProfileRow(Icons.email_outlined, 'Email ID', user?.email ?? 'studentcare@institution.edu'),
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
        Icon(icon, color: const Color(0xFFDB2777), size: 20),
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
          ),
          child: Column(
            children: [
              Icon(icon, color: textColor, size: 20),
              const SizedBox(height: 4),
              Text(value, style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: textColor)),
              const SizedBox(height: 2),
              Text(label, style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: textColor), textAlign: TextAlign.center, maxLines: 1),
            ],
          ),
        ),
      ),
    );
  }
}
