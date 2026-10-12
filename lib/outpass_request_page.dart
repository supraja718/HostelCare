import 'package:flutter/material.dart';
import 'app_error_handler.dart';
import 'auth_service.dart';
import 'outpass_repository.dart';

class OutpassRequestPage extends StatefulWidget {
  const OutpassRequestPage({super.key});

  @override
  State<OutpassRequestPage> createState() => _OutpassRequestPageState();
}

class _OutpassRequestPageState extends State<OutpassRequestPage> {
  final _formKey = GlobalKey<FormState>();
  String _outpassType = 'One-Day Outing'; // 'One-Day Outing' or 'Holiday Home Visit'

  final TextEditingController _outingDateController = TextEditingController(text: 'Today');
  final TextEditingController _returnDateController = TextEditingController(text: 'Tomorrow');
  final TextEditingController _goingTimeController = TextEditingController(text: '10:00 AM');
  final TextEditingController _returnTimeController = TextEditingController(text: '06:00 PM');
  final TextEditingController _destinationController = TextEditingController();
  final TextEditingController _reasonController = TextEditingController();
  final TextEditingController _guardianNameController = TextEditingController();
  final TextEditingController _guardianPhoneController = TextEditingController();

  @override
  void dispose() {
    _outingDateController.dispose();
    _returnDateController.dispose();
    _goingTimeController.dispose();
    _returnTimeController.dispose();
    _destinationController.dispose();
    _reasonController.dispose();
    _guardianNameController.dispose();
    _guardianPhoneController.dispose();
    super.dispose();
  }

  void _submitOutpass() {
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

        final newOutpass = OutpassItem(
          outpassId: 'OP-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}',
          studentId: studentId,
          studentName: studentName,
          roomNumber: roomNumber,
          outpassType: _outpassType,
          outingDate: _outingDateController.text.trim(),
          expectedReturnDate: _outpassType == 'Holiday Home Visit' ? _returnDateController.text.trim() : null,
          goingOutTime: _goingTimeController.text.trim(),
          expectedReturnTime: _returnTimeController.text.trim(),
          destination: _destinationController.text.trim(),
          reason: _reasonController.text.trim(),
          guardianName: _guardianNameController.text.trim(),
          guardianPhone: phone,
          status: 'Pending',
          createdAt: 'Just now',
        );

        OutpassRepository.instance.createOutpass(newOutpass);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Outpass request submitted successfully! Sent to Warden for review.'),
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
          'Request Outpass',
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
                // Type Selector Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF86EFAC)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Select Outpass Type', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: ChoiceChip(
                              label: const Center(child: Text('One-Day Outing')),
                              selected: _outpassType == 'One-Day Outing',
                              selectedColor: const Color(0xFFDCFCE7),
                              labelStyle: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: _outpassType == 'One-Day Outing' ? const Color(0xFF15803D) : const Color(0xFF64748B),
                              ),
                              onSelected: (selected) {
                                if (selected) setState(() => _outpassType = 'One-Day Outing');
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ChoiceChip(
                              label: const Center(child: Text('Home Visit')),
                              selected: _outpassType == 'Holiday Home Visit',
                              selectedColor: const Color(0xFFDCFCE7),
                              labelStyle: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: _outpassType == 'Holiday Home Visit' ? const Color(0xFF15803D) : const Color(0xFF64748B),
                              ),
                              onSelected: (selected) {
                                if (selected) setState(() => _outpassType = 'Holiday Home Visit');
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Date & Time Fields
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_outpassType == 'Holiday Home Visit' ? 'Departure Date' : 'Outing Date', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _outingDateController,
                            validator: (val) => val == null || val.trim().isEmpty ? 'Required' : null,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_outpassType == 'Holiday Home Visit') ...[
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Return Date', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _returnDateController,
                              validator: (val) => val == null || val.trim().isEmpty ? 'Required' : null,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 14),

                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Going-out Time', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _goingTimeController,
                            validator: (val) => val == null || val.trim().isEmpty ? 'Required' : null,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Expected Return Time', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _returnTimeController,
                            validator: (val) => val == null || val.trim().isEmpty ? 'Required' : null,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Destination
                const Text('Destination', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _destinationController,
                  validator: (val) => val == null || val.trim().isEmpty ? 'Please enter destination address/city' : null,
                  decoration: InputDecoration(
                    hintText: 'e.g., Connaught Place, New Delhi',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 14),

                // Reason
                const Text('Reason for Outpass', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _reasonController,
                  maxLines: 2,
                  validator: (val) => val == null || val.trim().isEmpty ? 'Please enter reason for outpass' : null,
                  decoration: InputDecoration(
                    hintText: 'e.g., Medical appointment, Family function...',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 14),

                // Parent / Guardian Name & Phone
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

                const Text('Parent / Guardian Emergency Phone Number', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
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

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFDCFCE7),
                      foregroundColor: const Color(0xFF15803D),
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: Color(0xFF86EFAC), width: 1.5),
                      ),
                    ),
                    onPressed: _submitOutpass,
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle_rounded, color: Color(0xFF15803D), size: 18),
                        SizedBox(width: 8),
                        Text('Submit Outpass Request', style: TextStyle(color: Color(0xFF15803D), fontSize: 15, fontWeight: FontWeight.bold)),
                      ],
                    ),
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
