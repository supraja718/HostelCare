import 'package:flutter/material.dart';
import 'outpass_repository.dart';

class DigitalOutpassPage extends StatelessWidget {
  final OutpassItem outpass;

  const DigitalOutpassPage({super.key, required this.outpass});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      appBar: AppBar(
        title: const Text('Digital Outpass 🎫', style: TextStyle(color: Color(0xFF14532D), fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: const Color(0xFFDCFCE7),
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF15803D)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 450),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF86EFAC), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 15,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Pass Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('HOSTELCARE', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A))),
                            Text('Central Campus Hostel', style: TextStyle(fontSize: 11, color: Colors.grey)),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDCFCE7),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFF86EFAC)),
                          ),
                          child: Text(
                            outpass.status.toUpperCase(),
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF15803D)),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 30, thickness: 1.5),

                    // Pass Title
                    Center(
                      child: Text(
                        'DIGITAL ${outpass.outpassType.toUpperCase()}',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B), letterSpacing: 0.5),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Details Grid
                    _buildPassRow('Outpass ID', outpass.outpassId),
                    _buildPassRow('Student Name', outpass.studentName),
                    _buildPassRow('Student ID', outpass.studentId),
                    _buildPassRow('Room Number', outpass.roomNumber),
                    _buildPassRow('Outing Date', outpass.expectedReturnDate != null ? '${outpass.outingDate} to ${outpass.expectedReturnDate}' : outpass.outingDate),
                    _buildPassRow('Timing', '${outpass.goingOutTime} - ${outpass.expectedReturnTime}'),
                    _buildPassRow('Destination', outpass.destination),
                    _buildPassRow('Reason', outpass.reason),
                    _buildPassRow('Guardian Name', outpass.guardianName),
                    _buildPassRow('Guardian Phone', outpass.guardianPhone),

                    const Divider(height: 30, thickness: 1),

                    // Approval Stamp info
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0FDF4),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF86EFAC)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('APPROVAL AUTHENTICATION', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF15803D))),
                          const SizedBox(height: 4),
                          Text('Approved By: ${outpass.approvedBy ?? "Warden Administrator"}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                          Text('Approval Timestamp: ${outpass.approvalDate ?? "Just now"}', style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFDCFCE7),
                          foregroundColor: const Color(0xFF15803D),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back, size: 16),
                        label: const Text('Back to Dashboard', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      ),
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

  Widget _buildPassRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF64748B))),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
          ),
        ],
      ),
    );
  }
}
