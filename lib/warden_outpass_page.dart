import 'package:flutter/material.dart';
import 'auth_service.dart';
import 'outpass_repository.dart';

class WardenOutpassPage extends StatefulWidget {
  const WardenOutpassPage({super.key});

  @override
  State<WardenOutpassPage> createState() => _WardenOutpassPageState();
}

class _WardenOutpassPageState extends State<WardenOutpassPage> {
  String _selectedTab = 'Pending'; // 'Pending', 'Approved', 'Rejected'

  void _openReviewDialog(OutpassItem outpass) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Review Outpass: ${outpass.studentName}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Type: ${outpass.outpassType}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF7E22CE))),
              Text('Room: ${outpass.roomNumber} • Destination: ${outpass.destination}', style: const TextStyle(fontSize: 12)),
              Text('Reason: ${outpass.reason}', style: const TextStyle(fontSize: 12)),
              Text('Guardian: ${outpass.guardianName} (${outpass.guardianPhone})', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
              const SizedBox(height: 16),
              const Text('If rejecting, please provide a rejection reason:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
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
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          OutlinedButton(
            style: OutlinedButton.styleFrom(foregroundColor: Colors.red, side: const BorderSide(color: Colors.red)),
            onPressed: () {
              if (reasonController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please provide a rejection reason.'), backgroundColor: Colors.red),
                );
                return;
              }
              final wardenName = AuthService.instance.currentUser?.name ?? 'Warden Administrator';
              OutpassRepository.instance.reviewOutpass(
                outpassId: outpass.outpassId,
                isApproved: false,
                rejectionReason: reasonController.text.trim(),
                wardenName: wardenName,
              );
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Outpass request rejected.'), backgroundColor: Colors.red),
              );
            },
            child: const Text('Reject', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF15803D)),
            onPressed: () {
              final wardenName = AuthService.instance.currentUser?.name ?? 'Warden Administrator';
              OutpassRepository.instance.reviewOutpass(
                outpassId: outpass.outpassId,
                isApproved: true,
                wardenName: wardenName,
              );
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Outpass request approved! Digital pass generated.'), backgroundColor: Color(0xFF15803D)),
              );
            },
            child: const Text('Approve', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: OutpassRepository.instance,
      builder: (context, _) {
        final allOutpasses = OutpassRepository.instance.outpasses;
        final filtered = allOutpasses.where((o) => o.status == _selectedTab).toList();

        return Scaffold(
          backgroundColor: const Color(0xFFF5F6F8),
          appBar: AppBar(
            title: const Text('Outpass Management 🎫', style: TextStyle(color: Color(0xFF581C87), fontWeight: FontWeight.bold, fontSize: 18)),
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
                  Row(
                    children: ['Pending', 'Approved', 'Rejected'].map((tab) {
                      bool isSel = (_selectedTab == tab);
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedTab = tab),
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: isSel ? const Color(0xFF7E22CE) : Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: const Color(0xFFC084FC)),
                            ),
                            child: Text(
                              tab,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: isSel ? Colors.white : const Color(0xFF7E22CE),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
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
                                Text('No $_selectedTab outpass requests.', style: TextStyle(fontSize: 13, color: Colors.grey.shade600, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          )
                        : ListView.separated(
                            itemCount: filtered.length,
                            separatorBuilder: (context, index) => const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final o = filtered[index];
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
                                        Text('${o.studentName} (${o.roomNumber})', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: o.status == 'Approved' ? const Color(0xFFDCFCE7) : (o.status == 'Rejected' ? Colors.red.shade50 : const Color(0xFFFEF3C7)),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(o.status, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: o.status == 'Approved' ? const Color(0xFF15803D) : (o.status == 'Rejected' ? Colors.red.shade700 : const Color(0xFFD97706)))),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text('${o.outpassType} • Destination: ${o.destination}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF7E22CE))),
                                    Text('Reason: ${o.reason}', style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                                    Text('Guardian: ${o.guardianName} (${o.guardianPhone})', style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                                    if (o.status == 'Pending') ...[
                                      const SizedBox(height: 12),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: const Color(0xFFF3E8FF),
                                              foregroundColor: const Color(0xFF7E22CE),
                                              elevation: 0,
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                            ),
                                            onPressed: () => _openReviewDialog(o),
                                            child: const Text('Review Request', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                          ),
                                        ],
                                      ),
                                    ],
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
