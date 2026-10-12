import 'package:flutter/material.dart';
import 'auth_service.dart';
import 'management_dashboard.dart';
import 'service_staff_dashboard.dart';
import 'student_care_dashboard.dart';
import 'student_dashboard.dart';
import 'warden_dashboard.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _roomController = TextEditingController();

  String _selectedRole = 'Student';
  String _selectedDepartment = 'Electrician';
  bool _obscurePassword = true;
  bool _isSubmitting = false;
  String? _errorMessage;

  final List<String> _roles = ['Student', 'Warden', 'Service Staff', 'Management', 'Student Care'];
  final List<String> _departments = ['Electrician', 'Plumber', 'Carpenter', 'Wi-Fi Technician', 'Cleaning Staff'];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _roomController.dispose();
    super.dispose();
  }

  void _submitSignup() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
        _errorMessage = null;
      });

      try {
        await AuthService.instance.registerUser(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
          role: _selectedRole,
          department: _selectedRole == 'Service Staff' ? _selectedDepartment : null,
          roomNumber: _selectedRole == 'Student' ? _roomController.text.trim() : null,
        );

        if (!mounted) return;

        Widget targetDashboard;
        switch (_selectedRole) {
          case 'Student':
            targetDashboard = const StudentDashboard();
            break;
          case 'Warden':
            targetDashboard = const WardenDashboard();
            break;
          case 'Service Staff':
            targetDashboard = ServiceStaffDashboard(department: _selectedDepartment);
            break;
          case 'Management':
            targetDashboard = const ManagementDashboard();
            break;
          case 'Student Care':
          default:
            targetDashboard = const StudentCareDashboard();
            break;
        }

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => targetDashboard),
          (route) => false,
        );
      } catch (err) {
        setState(() {
          _isSubmitting = false;
          _errorMessage = err.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 450),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // App Logo
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E3A8A),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.apartment,
                      color: Colors.white,
                      size: 36,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // App Name
                  const Text(
                    'HostelCare',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Tagline
                  const Text(
                    'INSTITUTIONAL COMPLAINT & WELFARE MANAGEMENT',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF64748B),
                      letterSpacing: 1.0,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),

                  // Signup Form Container
                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Create an Account',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Register to access hostel complaints & welfare portal',
                            style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                          ),
                          const SizedBox(height: 18),

                          // Full Name
                          const Text('Full Name', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _nameController,
                            validator: (val) => val == null || val.trim().isEmpty ? 'Enter full name' : null,
                            decoration: InputDecoration(
                              hintText: 'e.g. Rahul Sharma',
                              hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
                              prefixIcon: const Icon(Icons.person_outline, color: Color(0xFF2563EB), size: 20),
                              filled: true,
                              fillColor: Colors.blue.shade50,
                              isDense: true,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.blue.shade200)),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.blue.shade100)),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Email
                          const Text('Email Address', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _emailController,
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) return 'Enter email address';
                              if (!val.contains('@')) return 'Enter a valid email address';
                              return null;
                            },
                            decoration: InputDecoration(
                              hintText: 'e.g. student@hostel.edu',
                              hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
                              prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFF2563EB), size: 20),
                              filled: true,
                              fillColor: Colors.blue.shade50,
                              isDense: true,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.blue.shade200)),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.blue.shade100)),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Password
                          const Text('Password', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            validator: (val) {
                              if (val == null || val.isEmpty) return 'Enter password';
                              if (val.length < 6) return 'Password must be at least 6 characters';
                              return null;
                            },
                            decoration: InputDecoration(
                              hintText: 'Enter password',
                              hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
                              prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF2563EB), size: 20),
                              suffixIcon: IconButton(
                                icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                              ),
                              filled: true,
                              fillColor: Colors.blue.shade50,
                              isDense: true,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.blue.shade200)),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.blue.shade100)),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Select Role
                          const Text('Account Role', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                          const SizedBox(height: 6),
                          DropdownButtonFormField<String>(
                            initialValue: _selectedRole,
                            items: _roles.map((r) => DropdownMenuItem(value: r, child: Text(r, style: const TextStyle(fontSize: 13)))).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() {
                                  _selectedRole = val;
                                });
                              }
                            },
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.badge_outlined, color: Color(0xFF2563EB), size: 20),
                              filled: true,
                              fillColor: Colors.blue.shade50,
                              isDense: true,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.blue.shade200)),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.blue.shade100)),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Dynamic Role Details
                          if (_selectedRole == 'Student') ...[
                            const Text('Room Number', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _roomController,
                              validator: (val) => val == null || val.trim().isEmpty ? 'Enter room number' : null,
                              decoration: InputDecoration(
                                hintText: 'e.g. Room 204',
                                hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
                                prefixIcon: const Icon(Icons.meeting_room_outlined, color: Color(0xFF2563EB), size: 20),
                                filled: true,
                                fillColor: Colors.blue.shade50,
                                isDense: true,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.blue.shade200)),
                                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.blue.shade100)),
                              ),
                            ),
                            const SizedBox(height: 12),
                          ] else if (_selectedRole == 'Service Staff') ...[
                            const Text('Service Department', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                            const SizedBox(height: 6),
                            DropdownButtonFormField<String>(
                              initialValue: _selectedDepartment,
                              items: _departments.map((d) => DropdownMenuItem(value: d, child: Text(d, style: const TextStyle(fontSize: 13)))).toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() {
                                    _selectedDepartment = val;
                                  });
                                }
                              },
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.build_circle_outlined, color: Color(0xFF2563EB), size: 20),
                                filled: true,
                                fillColor: Colors.blue.shade50,
                                isDense: true,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.blue.shade200)),
                                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.blue.shade100)),
                              ),
                            ),
                            const SizedBox(height: 12),
                          ],

                          if (_errorMessage != null) ...[
                            const SizedBox(height: 4),
                            Text(_errorMessage!, style: const TextStyle(fontSize: 12, color: Colors.red, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 12),
                          ],

                          // Submit Button
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2563EB),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                elevation: 2,
                              ),
                              onPressed: _isSubmitting ? null : _submitSignup,
                              child: _isSubmitting
                                  ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                  : const Text('Create Account', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                            ),
                          ),
                          const SizedBox(height: 16),

                          Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text('Already have an account? ', style: TextStyle(fontSize: 13, color: Color(0xFF64748B))),
                                GestureDetector(
                                  onTap: () => Navigator.pop(context),
                                  child: const Text('Log In', style: TextStyle(fontSize: 13, color: Color(0xFF2563EB), fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
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
      ),
    );
  }
}
