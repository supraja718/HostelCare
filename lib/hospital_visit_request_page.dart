import 'package:flutter/material.dart';
import 'app_error_handler.dart';
import 'auth_service.dart';
import 'hospital_visit_repository.dart';

class HospitalVisitRequestPage extends StatefulWidget {
  const HospitalVisitRequestPage({super.key});

  @override
  State<HospitalVisitRequestPage> createState() => _HospitalVisitRequestPageState();
}

class _HospitalVisitRequestPageState extends State<HospitalVisitRequestPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _reasonController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _dateController = TextEditingController(text: 'Today');
  final TextEditingController _timeController = TextEditingController(text: '10:00 AM');
  final TextEditingController _guardianNameController = TextEditingController();
  final TextEditingController _guardianPhoneController = TextEditingController();

  String _selectedUrgency = 'Normal'; // 'Normal' or 'Urgent'

  @override
  void dispose() {
    _reasonController.dispose();
    _descriptionController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    _guardianNameController.dispose();
    _guardianPhoneController.dispose();
    super.dispose();
  }

  void _submitRequest() {
    try {
      if (_formKey.currentState!.validate()) {
        final phone = _guardianPhoneController.text.trim();
        if (phone.length < 10) {
          throw 'Please enter a valid Parent/Guardian phone number.';
        }

        final user = AuthService.instance.currentUser;
        final studentName = user?.name ?? 'Student User';
        final roomNumber = user?.roomNumber ?? 'Room 204';
        final studentId = user?.email ?? 'STU01';

        final request = HospitalVisitItem(
          visitId: 'HV-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}',
          studentId: studentId,
          studentName: studentName,
          roomNumber: roomNumber,
          reason: _reasonController.text.trim(),
          description: _descriptionController.text.trim(),
          preferredDate: _dateController.text.trim(),
          preferredTime: _timeController.text.trim(),
          urgency: _selectedUrgency,
          guardianName: _guardianNameController.text.trim(),
          guardianPhone: phone,
          status: 'Pending',
          createdAt: 'Just now',
        );

        HospitalVisitRepository.instance.createVisitRequest(request);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Hospital visit request submitted successfully.'),
            backgroundColor: Color(0xFF15803D),
          ),
        );

        Navigator.pop(context);
      }
    } catch (e) {
      AppErrorHandler.showFriendlyError(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0FDF4),
      appBar: AppBar(
        title: const Text(
          'Hospital Visit Request 🏥',
          style: TextStyle(color: Color(0xFF14532D), fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: const Color(0xFFDCFCE7),
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF15803D)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF86EFAC)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.local_hospital, color: Color(0xFF15803D), size: 28),
                      SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Medical Assistance', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                            SizedBox(height: 2),
                            Text('Submit your hospital visit request for warden review and arrangement.', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Reason
                const Text('Reason for Hospital Visit', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _reasonController,
                  validator: (val) => val == null || val.trim().isEmpty ? 'Please enter reason' : null,
                  decoration: InputDecoration(
                    hintText: 'e.g., Severe fever, Injury...',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 14),

                // Description
                const Text('Brief Description of the Issue', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 3,
                  validator: (val) => val == null || val.trim().isEmpty ? 'Please enter description' : null,
                  decoration: InputDecoration(
                    hintText: 'Describe symptoms or health issue briefly...',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 14),

                // Date & Time
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Preferred Date', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _dateController,
                            validator: (val) => val == null || val.trim().isEmpty ? 'Required' : null,
                            decoration: InputDecoration(filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Preferred Time', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _timeController,
                            validator: (val) => val == null || val.trim().isEmpty ? 'Required' : null,
                            decoration: InputDecoration(filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Urgency
                const Text('Urgency', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  initialValue: _selectedUrgency,
                  items: ['Normal', 'Urgent'].map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedUrgency = val);
                  },
                  decoration: InputDecoration(filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                ),
                const SizedBox(height: 14),

                // Guardian Name & Phone
                const Text('Parent / Guardian Name', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _guardianNameController,
                  validator: (val) => val == null || val.trim().isEmpty ? 'Please enter parent/guardian name' : null,
                  decoration: InputDecoration(
                    hintText: 'e.g., Mr. Sharma (Father)',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 14),

                const Text('Parent / Guardian Phone Number', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _guardianPhoneController,
                  keyboardType: TextInputType.phone,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) return 'Please enter parent phone number';
                    if (val.trim().length < 10) return 'Please enter a valid 10-digit phone number';
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: 'e.g., +91 9876543210',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFDCFCE7),
                      foregroundColor: const Color(0xFF15803D),
                      elevation: 1,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: Color(0xFF86EFAC), width: 1.5)),
                    ),
                    onPressed: _submitRequest,
                    child: const Text('Submit Hospital Visit Request', style: TextStyle(color: Color(0xFF15803D), fontSize: 15, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
