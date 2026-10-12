import 'package:flutter/material.dart';
import 'app_error_handler.dart';
import 'auth_service.dart';
import 'complaint_repository.dart';

class ReportIssuePage extends StatefulWidget {
  const ReportIssuePage({super.key});

  @override
  State<ReportIssuePage> createState() => _ReportIssuePageState();
}

class _ReportIssuePageState extends State<ReportIssuePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _roomController = TextEditingController(text: 'Room 204');

  String _selectedCategory = 'Electrical';
  String _selectedPriority = 'Medium';
  bool _isSensitive = false;

  final List<String> _categories = [
    'Electrical',
    'Plumbing',
    'Furniture',
    'Cleanliness',
    'Wi-Fi / Internet',
    'Food / Mess',
    'Welfare / Misconduct',
    'Other'
  ];

  final List<String> _priorities = ['Low', 'Medium', 'High', 'Urgent'];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _roomController.dispose();
    super.dispose();
  }

  void _submitIssue() {
    try {
      if (_formKey.currentState!.validate()) {
        final currentUser = AuthService.instance.currentUser;
        final studentName = currentUser?.name ?? 'Student User';
        final roomNo = _roomController.text.trim().isEmpty ? 'Room 204' : _roomController.text.trim();

        final category = _isSensitive ? 'Welfare / Misconduct' : _selectedCategory;

        final newComplaint = ComplaintItem(
          id: DateTime.now().millisecondsSinceEpoch.toString().substring(3),
          studentName: studentName,
          roomNumber: roomNo,
          title: _titleController.text.trim(),
          category: category,
          description: _descriptionController.text.trim(),
          date: 'Just now',
          status: _isSensitive ? 'Under Review' : 'New',
          priority: _isSensitive ? 'High' : _selectedPriority,
          isSensitive: _isSensitive,
          timeline: _isSensitive
              ? ['Reported by $studentName (Confidential)', 'Routed to Warden & Student Care Officer']
              : (category == 'Food / Mess'
                  ? ['Reported by $studentName', 'Received by Warden & Management']
                  : ['Reported by $studentName', 'Received by Warden']),
          updates: _isSensitive
              ? ['Sensitive welfare complaint registered. Strictly restricted to Warden and Student Care.']
              : (category == 'Food / Mess'
                  ? ['Food complaint registered. Routed to Warden and Management.']
                  : ['Complaint registered by student. Received by Warden dashboard.']),
        );

        ComplaintRepository.instance.addComplaint(newComplaint);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isSensitive
                ? 'Confidential welfare issue submitted securely to Warden & Student Care!'
                : (category == 'Food / Mess'
                    ? 'Food complaint successfully registered for Warden & Management review!'
                    : 'Complaint successfully registered & received by Warden!')),
            backgroundColor: const Color(0xFF15803D),
          ),
        );

        Navigator.pop(context, newComplaint);
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
          'Report an Issue',
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
                // Header Banner
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF86EFAC)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDCFCE7),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.build_circle_outlined, color: Color(0xFF15803D), size: 30),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Submit a Complaint',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Standard complaints route to Warden. Food complaints route to Warden & Management.',
                              style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Issue Title
                const Text(
                  'What is the issue?',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _titleController,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter the issue title.';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: 'e.g., Fan not working, Mess food quality...',
                    hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
                    prefixIcon: const Icon(Icons.report_problem_outlined, color: Color(0xFF15803D)),
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
                      borderSide: const BorderSide(color: Color(0xFF15803D), width: 1.5),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Category Selection
                const Text(
                  'Category',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                ),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  initialValue: _selectedCategory,
                  items: _categories.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category, style: const TextStyle(fontSize: 13)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedCategory = value;
                        if (value == 'Food / Mess') {
                          _isSensitive = false;
                        }
                      });
                    }
                  },
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.category_outlined, color: Color(0xFF15803D)),
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
                  ),
                ),
                const SizedBox(height: 16),

                // Sensitive / Confidential Welfare Toggle Checkbox
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _isSensitive ? const Color(0xFF7E22CE) : Colors.grey.shade300, width: _isSensitive ? 1.5 : 1),
                  ),
                  child: CheckboxListTile(
                    title: const Text(
                      'Mark as Confidential / Sensitive Welfare Issue 🔒',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                    ),
                    subtitle: const Text(
                      'Strictly restricted. Only visible to Warden and Student Care Officer.',
                      style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                    ),
                    value: _isSensitive,
                    onChanged: (val) {
                      setState(() {
                        _isSensitive = val ?? false;
                        if (_isSensitive) {
                          _selectedCategory = 'Welfare / Misconduct';
                        }
                      });
                    },
                    activeColor: const Color(0xFF7E22CE),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const SizedBox(height: 16),

                // Description
                const Text(
                  'Description of the issue',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 4,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a complaint description.';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: 'Describe what happened, location details, or specific times...',
                    hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
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
                      borderSide: const BorderSide(color: Color(0xFF15803D), width: 1.5),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Room / Location & Priority Row
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Room / Location',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _roomController,
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return 'Please enter your room number.';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.meeting_room_outlined, color: Color(0xFF15803D)),
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
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Priority',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                          ),
                          const SizedBox(height: 6),
                          DropdownButtonFormField<String>(
                            initialValue: _selectedPriority,
                            items: _priorities.map((priority) {
                              return DropdownMenuItem(
                                value: priority,
                                child: Text(priority, style: const TextStyle(fontSize: 13)),
                              );
                            }).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  _selectedPriority = value;
                                });
                              }
                            },
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.flag_outlined, color: Color(0xFF15803D)),
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
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),

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
                    onPressed: _submitIssue,
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.send_rounded, color: Color(0xFF15803D), size: 18),
                        SizedBox(width: 8),
                        Text(
                          'Submit Issue Report',
                          style: TextStyle(color: Color(0xFF15803D), fontSize: 15, fontWeight: FontWeight.bold),
                        ),
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
