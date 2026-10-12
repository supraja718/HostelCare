import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'app_error_handler.dart';
import 'auth_service.dart';
import 'complaint_repository.dart';
import 'role_selection_page.dart';

class ServiceStaffDashboard extends StatefulWidget {
  final String department; // 'Electrician', 'Plumber', 'Carpenter', 'Wi-Fi Technician', 'Cleaning Staff'

  const ServiceStaffDashboard({super.key, required this.department});

  @override
  State<ServiceStaffDashboard> createState() => _ServiceStaffDashboardState();
}

class _ServiceStaffDashboardState extends State<ServiceStaffDashboard> {
  int _currentIndex = 0;
  String _selectedFilter = 'Assigned Jobs';
  String _availabilityStatus = 'Available';

  String get departmentCategory {
    switch (widget.department) {
      case 'Electrician':
        return 'Electrical';
      case 'Plumbing':
      case 'Plumber':
        return 'Plumbing';
      case 'Carpenter':
        return 'Furniture';
      case 'Wi-Fi Technician':
        return 'Wi-Fi / Internet';
      case 'Cleaning Staff':
      default:
        return 'Cleanliness';
    }
  }

  IconData get departmentIcon {
    switch (widget.department) {
      case 'Electrician':
        return Icons.flash_on;
      case 'Plumbing':
      case 'Plumber':
        return Icons.water_drop;
      case 'Carpenter':
        return Icons.chair;
      case 'Wi-Fi Technician':
        return Icons.wifi;
      case 'Cleaning Staff':
      default:
        return Icons.cleaning_services;
    }
  }

  List<ComplaintItem> get _departmentJobs {
    final cat = departmentCategory;
    return ComplaintRepository.instance.complaints
        .where((c) => !c.isSensitive && (c.category == cat || c.category.contains(cat)))
        .toList();
  }

  int get assignedCount => _departmentJobs.length;
  int get inProgressCount => _departmentJobs.where((t) => t.status == 'In Progress' || t.status == 'Assigned').length;
  int get completedTodayCount => _departmentJobs.where((t) => t.status == 'Repair Completed' || t.status == 'Verified' || t.status == 'Resolved').length;
  int get pendingCount => _departmentJobs.where((t) => t.status == 'Pending' || t.status == 'New' || t.status == 'Reported').length;

  List<ComplaintItem> get filteredJobs {
    if (_selectedFilter == 'In Progress') {
      return _departmentJobs.where((t) => t.status == 'In Progress' || t.status == 'Assigned').toList();
    } else if (_selectedFilter == 'Completed') {
      return _departmentJobs.where((t) => t.status == 'Repair Completed' || t.status == 'Verified' || t.status == 'Resolved').toList();
    } else if (_selectedFilter == 'Pending') {
      return _departmentJobs.where((t) => t.status == 'Pending' || t.status == 'New' || t.status == 'Reported').toList();
    } else {
      return _departmentJobs;
    }
  }

  void _openJobDetailSheet(ComplaintItem job) {
    String? uploadedPhotoPath = job.resolutionProof;
    bool photoAttached = job.resolutionProof != null;
    final ImagePicker picker = ImagePicker();
    final noteController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            padding: const EdgeInsets.all(22),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF7ED),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFFED7AA)),
                        ),
                        child: Text(
                          job.status,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFC2410C)),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    job.title,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Room: ${job.roomNumber} • Sector: ${job.category}',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFFC2410C)),
                  ),
                  const SizedBox(height: 12),

                  // Issue Details Container
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
                        const Text('Issue to Fix:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                        const SizedBox(height: 4),
                        Text(job.description, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF334155))),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  if (job.status != 'Resolved') ...[
                    // Take Repair Photo Box (REAL CAMERA ONLY - NO GALLERY)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF7ED),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFFED7AA), width: 1.5),
                      ),
                      child: Column(
                        children: [
                          if (photoAttached && uploadedPhotoPath != null) ...[
                            const Icon(Icons.check_circle, color: Color(0xFF15803D), size: 36),
                            const SizedBox(height: 6),
                            Text(
                              'Photo Captured: ${uploadedPhotoPath!.split('/').last}',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF15803D)),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                OutlinedButton.icon(
                                  style: OutlinedButton.styleFrom(foregroundColor: Colors.red, side: const BorderSide(color: Colors.red)),
                                  onPressed: () async {
                                    try {
                                      final XFile? photo = await picker.pickImage(source: ImageSource.camera);
                                      if (photo != null) {
                                        setSheetState(() {
                                          uploadedPhotoPath = photo.path;
                                          photoAttached = true;
                                        });
                                      }
                                    } catch (e) {
                                      if (!context.mounted) return;
                                      AppErrorHandler.showFriendlyError(context, 'Camera permission is required to capture repair proof.');
                                    }
                                  },
                                  icon: const Icon(Icons.refresh, size: 16),
                                  label: const Text('Retake', style: TextStyle(fontWeight: FontWeight.bold)),
                                ),
                                const SizedBox(width: 12),
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF15803D), foregroundColor: Colors.white),
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Photo confirmed successfully!'), backgroundColor: Color(0xFF15803D)),
                                    );
                                  },
                                  icon: const Icon(Icons.check, size: 16),
                                  label: const Text('Use Photo', style: TextStyle(fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                          ] else ...[
                            const Icon(Icons.camera_alt_rounded, color: Color(0xFFC2410C), size: 38),
                            const SizedBox(height: 8),
                            const Text('Take Repair Photo', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF9A3412))),
                            const SizedBox(height: 2),
                            const Text('A real camera photo of the completed repair is required.', style: TextStyle(fontSize: 11, color: Color(0xFFC2410C)), textAlign: TextAlign.center),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              height: 44,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFC2410C),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                onPressed: () async {
                                  try {
                                    final XFile? photo = await picker.pickImage(source: ImageSource.camera);
                                    if (photo != null) {
                                      setSheetState(() {
                                        uploadedPhotoPath = photo.path;
                                        photoAttached = true;
                                      });
                                    }
                                  } catch (e) {
                                    if (!context.mounted) return;
                                    AppErrorHandler.showFriendlyError(context, 'Camera permission is required to capture repair proof.');
                                  }
                                },
                                icon: const Icon(Icons.camera_alt, size: 20),
                                label: const Text('Take Repair Photo', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Completion Note
                    TextField(
                      controller: noteController,
                      decoration: InputDecoration(
                        labelText: 'Completion Note (Optional)',
                        hintText: 'e.g. Damaged pipe replaced and water leakage tested.',
                        isDense: true,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    const SizedBox(height: 18),

                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF15803D),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () {
                          if (!photoAttached || uploadedPhotoPath == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Repair proof photo is required.'), backgroundColor: Colors.red),
                            );
                            return;
                          }

                          try {
                            ComplaintRepository.instance.submitWorkByStaff(
                              complaintId: job.id,
                              photoProof: uploadedPhotoPath!,
                              remarks: noteController.text.trim().isNotEmpty ? noteController.text.trim() : 'Repair proof uploaded',
                            );
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Repair completed & submitted for verification!'), backgroundColor: Color(0xFF15803D)),
                            );
                          } catch (e) {
                            AppErrorHandler.showFriendlyError(context, 'Photo upload failed. Please try again.');
                          }
                        },
                        icon: const Icon(Icons.check_circle_rounded, size: 22),
                        label: const Text('Mark as Resolved', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      ),
                    ),
                  ] else ...[
                    if (job.resolutionProof != null) ...[
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(color: const Color(0xFFDCFCE7), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF86EFAC))),
                        child: Row(
                          children: [
                            const Icon(Icons.verified, color: Color(0xFF15803D), size: 24),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Real Camera Photo Proof Uploaded:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF15803D))),
                                  Text(job.resolutionProof!, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF14532D))),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ],
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
        content: const Text('Are you sure you want to log out?'),
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
        final staffUser = AuthService.instance.currentUser;
        final staffName = staffUser?.name ?? widget.department;

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
              selectedItemColor: const Color(0xFFC2410C),
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
                  label: 'My Jobs',
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
                _buildHomeTab(staffName),
                _buildJobsTab(),
                _buildNotificationsTab(),
                _buildProfileTab(staffName),
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
  Widget _buildHomeTab(String staffName) {
    final jobsList = filteredJobs;
    final staffAnnouncements = ComplaintRepository.instance.getAnnouncementsForRoleAndDept('Service Staff', department: widget.department);
    final latestAnnouncement = staffAnnouncements.isNotEmpty ? staffAnnouncements.first : null;

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 80.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Light Orange Staff Profile Banner
          Container(
            margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF7ED),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFFED7AA), width: 1.5),
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
                  child: CircleAvatar(
                    radius: 22,
                    backgroundColor: const Color(0xFFFED7AA),
                    child: Icon(departmentIcon, color: const Color(0xFFC2410C), size: 24),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        staffName,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF9A3412),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Text('Status: ', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFC2410C))),
                          DropdownButton<String>(
                            value: _availabilityStatus,
                            isDense: true,
                            underline: const SizedBox(),
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFC2410C)),
                            items: ['Available', 'Busy', 'Off Duty'].map((st) => DropdownMenuItem(value: st, child: Text(st))).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() {
                                  _availabilityStatus = val;
                                });
                              }
                            },
                          ),
                        ],
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
                    child: Icon(Icons.notifications_outlined, color: Color(0xFFC2410C), size: 24),
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
                    _buildStatCard('Assigned Jobs', '$assignedCount', Icons.assignment_turned_in, const Color(0xFFEFF6FF), const Color(0xFF2563EB)),
                    _buildStatCard('In Progress', '$inProgressCount', Icons.autorenew_rounded, const Color(0xFFF3E8FF), const Color(0xFF7E22CE)),
                    _buildStatCard('Completed', '$completedTodayCount', Icons.check_circle_outline, const Color(0xFFDCFCE7), const Color(0xFF15803D)),
                    _buildStatCard('Pending', '$pendingCount', Icons.access_time_filled, const Color(0xFFFEF3C7), const Color(0xFFD97706)),
                  ],
                ),
                const SizedBox(height: 20),

                // Section Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'My Assigned Jobs',
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
                        'View All >',
                        style: TextStyle(fontSize: 13, color: Color(0xFFC2410C), fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                // Jobs Container
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: jobsList.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Center(
                            child: Column(
                              children: [
                                Icon(Icons.check_circle_outline, color: Colors.grey.shade400, size: 36),
                                const SizedBox(height: 8),
                                Text('No $_selectedFilter jobs found.', style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
                              ],
                            ),
                          ),
                        )
                      : Column(
                          children: jobsList.take(4).map((job) {
                            return Column(
                              children: [
                                ListTile(
                                  onTap: () => _openJobDetailSheet(job),
                                  leading: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFFFF7ED),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(departmentIcon, color: const Color(0xFFC2410C), size: 20),
                                  ),
                                  title: Text(job.title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                                  subtitle: Text('${job.roomNumber} • Assigned by Warden', style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                                  trailing: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFFF7ED),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(color: const Color(0xFFFED7AA)),
                                    ),
                                    child: Text(job.status, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFFC2410C))),
                                  ),
                                ),
                                if (job != jobsList.take(4).last) const Divider(height: 1, color: Color(0xFFF1F5F9)),
                              ],
                            );
                          }).toList(),
                        ),
                ),
                const SizedBox(height: 20),

                // Sector Specific Announcement Container
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
                                color: Color(0xFFFFF7ED),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.campaign, color: Color(0xFFC2410C), size: 22),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              '${widget.department} Announcement',
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
                            color: const Color(0xFFFFF7ED),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFFED7AA)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                latestAnnouncement.title,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF9A3412),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                latestAnnouncement.content,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFFC2410C),
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
  // JOBS TAB
  // -------------------------------------------------------------
  Widget _buildJobsTab() {
    final jobs = filteredJobs;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${widget.department} Assigned Jobs',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
          ),
          const SizedBox(height: 4),
          const Text(
            'Manage and update service tasks assigned to your department',
            style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 16),

          Expanded(
            child: jobs.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.assignment_outlined, color: Colors.grey.shade400, size: 48),
                        const SizedBox(height: 12),
                        Text('No $_selectedFilter jobs found.', style: TextStyle(fontSize: 14, color: Colors.grey.shade600, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  )
                : ListView.separated(
                    itemCount: jobs.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final job = jobs[index];
                      return Container(
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
                                Text(
                                  'Room ${job.roomNumber}',
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFF7ED),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: const Color(0xFFFED7AA)),
                                  ),
                                  child: Text(job.status, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFFC2410C))),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(job.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                            const SizedBox(height: 2),
                            Text(job.description, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFFFF7ED),
                                    foregroundColor: const Color(0xFFC2410C),
                                    elevation: 0,
                                    side: const BorderSide(color: Color(0xFFFED7AA)),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  onPressed: () => _openJobDetailSheet(job),
                                  icon: const Icon(Icons.camera_alt_outlined, size: 16),
                                  label: const Text('Take Repair Photo', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                ),
                              ],
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
  // NOTIFICATIONS TAB
  // -------------------------------------------------------------
  Widget _buildNotificationsTab() {
    final staffAnnouncements = ComplaintRepository.instance.getAnnouncementsForRoleAndDept('Service Staff', department: widget.department);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${widget.department} Sector Announcements', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
          const SizedBox(height: 4),
          Text('Official announcements broadcasted specifically for ${widget.department}', style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.separated(
              itemCount: staffAnnouncements.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final notif = staffAnnouncements[index];
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFE2E8F0))),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: const Color(0xFFFFF7ED), borderRadius: BorderRadius.circular(12)),
                        child: const Icon(Icons.campaign, color: Color(0xFFC2410C), size: 24),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(notif.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                            const SizedBox(height: 4),
                            Text(notif.content, style: const TextStyle(fontSize: 12, color: Color(0xFF475569))),
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
  Widget _buildProfileTab(String staffName) {
    final user = AuthService.instance.currentUser;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Staff Profile', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
          const SizedBox(height: 4),
          const Text('View service staff account details', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFE2E8F0))),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor: const Color(0xFFFFF7ED),
                  child: Icon(departmentIcon, color: const Color(0xFFC2410C), size: 40),
                ),
                const SizedBox(height: 12),
                Text(staffName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                const SizedBox(height: 2),
                Text('${widget.department} Department', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFFC2410C))),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
                  child: Column(
                    children: [
                      _buildProfileRow(Icons.badge_outlined, 'Staff ID', 'STAFF-${widget.department.substring(0, 3).toUpperCase()}-01'),
                      Divider(height: 20, color: Colors.grey.shade200),
                      _buildProfileRow(Icons.business_outlined, 'Department', departmentCategory),
                      Divider(height: 20, color: Colors.grey.shade200),
                      _buildProfileRow(Icons.email_outlined, 'Email ID', user?.email ?? 'staff@institution.edu'),
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
        Icon(icon, color: const Color(0xFFC2410C), size: 20),
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
