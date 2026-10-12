import 'package:flutter/material.dart';
import 'hospital_visit_repository.dart';

class WardenHospitalVisitPage extends StatefulWidget {
  const WardenHospitalVisitPage({super.key});

  @override
  State<WardenHospitalVisitPage> createState() => _WardenHospitalVisitPageState();
}

class _WardenHospitalVisitPageState extends State<WardenHospitalVisitPage> {
  String _selectedTab = 'Pending'; // 'Pending', 'Approved', 'Arranged', 'Rejected', 'Completed'

  void _openReviewDialog(HospitalVisitItem visit) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Review Hospital Visit: ${visit.studentName}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Reason: ${visit.reason}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF7E22CE))),
              Text('Room: ${visit.roomNumber} • Urgency: ${visit.urgency}', style: const TextStyle(fontSize: 12)),
              Text('Description: ${visit.description}', style: const TextStyle(fontSize: 12)),
              Text('Guardian: ${visit.guardianName} (${visit.guardianPhone})', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
              const SizedBox(height: 16),
              const Text('If rejecting, provide rejection reason:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
              const SizedBox(height: 6),
              TextField(
                controller: reasonController,
                decoration: InputDecoration(
                  hintText: 'Enter rejection reason...',
                  isDense: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(color: Colors.grey))),
          OutlinedButton(
            style: OutlinedButton.styleFrom(foregroundColor: Colors.red, side: const BorderSide(color: Colors.red)),
            onPressed: () {
              if (reasonController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please provide a rejection reason.'), backgroundColor: Colors.red),
                );
                return;
              }
              HospitalVisitRepository.instance.reviewVisit(
                visitId: visit.visitId,
                isApproved: false,
                rejectionReason: reasonController.text.trim(),
              );
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Hospital visit request rejected.'), backgroundColor: Colors.red));
            },
            child: const Text('Reject', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF15803D)),
            onPressed: () {
              HospitalVisitRepository.instance.reviewVisit(visitId: visit.visitId, isApproved: true);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Hospital visit approved! Now enter arranged date & time.'), backgroundColor: Color(0xFF15803D)));
            },
            child: const Text('Approve', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _openArrangeDialog(HospitalVisitItem visit) {
    final dateController = TextEditingController(text: '10 October 2026');
    final timeController = TextEditingController(text: '10:00 AM');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Arrange Hospital Visit: ${visit.studentName}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Enter the arranged date and time for the student visit:', style: TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 12),
            TextField(controller: dateController, decoration: const InputDecoration(labelText: 'Hospital Visit Date', isDense: true)),
            const SizedBox(height: 10),
            TextField(controller: timeController, decoration: const InputDecoration(labelText: 'Hospital Visit Time', isDense: true)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF7E22CE)),
            onPressed: () {
              if (dateController.text.trim().isNotEmpty && timeController.text.trim().isNotEmpty) {
                HospitalVisitRepository.instance.arrangeVisit(
                  visitId: visit.visitId,
                  date: dateController.text.trim(),
                  time: timeController.text.trim(),
                );
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Hospital visit arranged! Student notified.'), backgroundColor: Color(0xFF7E22CE)));
              }
            },
            child: const Text('Confirm & Notify Student', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: HospitalVisitRepository.instance,
      builder: (context, _) {
        final allVisits = HospitalVisitRepository.instance.visits;
        final filtered = allVisits.where((v) => v.status == _selectedTab).toList();

        return Scaffold(
          backgroundColor: const Color(0xFFF5F6F8),
          appBar: AppBar(
            title: const Text('Hospital Visit Management 🏥', style: TextStyle(color: Color(0xFF581C87), fontWeight: FontWeight.bold, fontSize: 18)),
            backgroundColor: const Color(0xFFF3E8FF),
            elevation: 0,
            iconTheme: const IconThemeData(color: Color(0xFF7E22CE)),
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tab Choice Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: ['Pending', 'Approved', 'Arranged', 'Rejected', 'Completed'].map((tab) {
                        bool isSel = (_selectedTab == tab);
                        return Padding(
                          padding: const EdgeInsets.only(right: 6.0),
                          child: ChoiceChip(
                            label: Text(tab),
                            selected: isSel,
                            selectedColor: const Color(0xFF7E22CE),
                            labelStyle: TextStyle(
                              fontSize: 12,
                              fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                              color: isSel ? Colors.white : const Color(0xFF7E22CE),
                            ),
                            onSelected: (selected) {
                              if (selected) setState(() => _selectedTab = tab);
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  Expanded(
                    child: filtered.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.inbox_outlined, color: Colors.grey.shade400, size: 48),
                                const SizedBox(height: 8),
                                Text('No $_selectedTab hospital visit requests.', style: TextStyle(fontSize: 13, color: Colors.grey.shade600, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          )
                        : ListView.separated(
                            itemCount: filtered.length,
                            separatorBuilder: (context, index) => const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final v = filtered[index];
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
                                        Text('${v.studentName} (${v.roomNumber})', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: v.status == 'Arranged' ? const Color(0xFFF3E8FF) : (v.status == 'Approved' ? const Color(0xFFDCFCE7) : (v.status == 'Rejected' ? Colors.red.shade50 : const Color(0xFFFEF3C7))),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(v.status, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: v.status == 'Arranged' ? const Color(0xFF7E22CE) : (v.status == 'Approved' ? const Color(0xFF15803D) : (v.status == 'Rejected' ? Colors.red.shade700 : const Color(0xFFD97706))))),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text('Reason: ${v.reason}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF7E22CE))),
                                    Text('Description: ${v.description}', style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                                    Text('Preferred: ${v.preferredDate} at ${v.preferredTime} • Urgency: ${v.urgency}', style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                                    if (v.rejectionReason != null) ...[
                                      const SizedBox(height: 4),
                                      Text('Rejection Reason: ${v.rejectionReason}', style: const TextStyle(fontSize: 11, color: Colors.red, fontWeight: FontWeight.bold)),
                                    ],
                                    if (v.arrangedDate != null) ...[
                                      const SizedBox(height: 4),
                                      Text('Arranged Visit: ${v.arrangedDate} at ${v.arrangedTime}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF7E22CE))),
                                    ],
                                    const SizedBox(height: 10),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        if (v.status == 'Pending') ...[
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: const Color(0xFFF3E8FF),
                                              foregroundColor: const Color(0xFF7E22CE),
                                              elevation: 0,
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                            ),
                                            onPressed: () => _openReviewDialog(v),
                                            child: const Text('Review Request', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                          ),
                                        ] else if (v.status == 'Approved') ...[
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: const Color(0xFFF3E8FF),
                                              foregroundColor: const Color(0xFF7E22CE),
                                              elevation: 0,
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                            ),
                                            onPressed: () => _openArrangeDialog(v),
                                            child: const Text('Enter Arranged Date & Time', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                          ),
                                        ] else if (v.status == 'Arranged') ...[
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: const Color(0xFFDCFCE7),
                                              foregroundColor: const Color(0xFF15803D),
                                              elevation: 0,
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                            ),
                                            onPressed: () {
                                              HospitalVisitRepository.instance.markCompleted(v.visitId);
                                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Hospital visit marked as completed!'), backgroundColor: Color(0xFF15803D)));
                                            },
                                            child: const Text('Mark Completed', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                          ),
                                        ],
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
            ),
          ),
        );
      },
    );
  }
}
