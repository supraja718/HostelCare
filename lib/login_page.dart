import 'package:flutter/material.dart';
import 'auth_service.dart';
import 'forgot_password_flow.dart';
import 'management_dashboard.dart';
import 'service_staff_dashboard.dart';
import 'signup_page.dart';
import 'student_care_dashboard.dart';
import 'student_dashboard.dart';
import 'warden_dashboard.dart';

class LoginPage extends StatefulWidget {
  final String selectedRole;
  final String selectedDepartment;

  const LoginPage({
    super.key,
    required this.selectedRole,
    this.selectedDepartment = 'Electrician',
  });

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool rememberMe = false;
  bool isLoggingIn = false;
  bool obscurePassword = true;
  String? errorMessage;

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _performLogin() async {
    final username = usernameController.text.trim();
    final password = passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      setState(() {
        errorMessage = 'Please enter both Username/Email ID and Password.';
      });
      return;
    }

    setState(() {
      isLoggingIn = true;
      errorMessage = null;
    });

    try {
      await AuthService.instance.login(
        username,
        password,
        expectedRole: widget.selectedRole,
      );

      if (!mounted) return;

      Widget targetDashboard;
      switch (widget.selectedRole) {
        case 'Student':
          targetDashboard = const StudentDashboard();
          break;
        case 'Warden':
          targetDashboard = const WardenDashboard();
          break;
        case 'Service Staff':
          targetDashboard = ServiceStaffDashboard(department: widget.selectedDepartment);
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
        isLoggingIn = false;
        errorMessage = err.toString();
      });
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
                  const SizedBox(height: 28),

                  // Login Container
                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Log in to continue',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1E293B),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  widget.selectedRole == 'Service Staff'
                                      ? 'Role: ${widget.selectedDepartment} (Staff)'
                                      : 'Role: ${widget.selectedRole}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF2563EB),
                                  ),
                                ),
                              ],
                            ),
                            TextButton(
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: const Size(50, 30),
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text(
                                'Change Role',
                                style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),

                        TextField(
                          controller: usernameController,
                          decoration: InputDecoration(
                            isDense: false,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            hintText: 'Email or Username (e.g. student@hostel.edu)',
                            hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
                            prefixIcon: const Icon(Icons.person_outline, color: Color(0xFF2563EB), size: 22),
                            filled: true,
                            fillColor: Colors.blue.shade50,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.blue.shade200),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.blue.shade100),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),

                        TextField(
                          controller: passwordController,
                          obscureText: obscurePassword,
                          decoration: InputDecoration(
                            isDense: false,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            hintText: 'Password (e.g. Password123!)',
                            hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
                            prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF2563EB), size: 22),
                            suffixIcon: IconButton(
                              icon: Icon(obscurePassword ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                              onPressed: () => setState(() => obscurePassword = !obscurePassword),
                            ),
                            filled: true,
                            fillColor: Colors.blue.shade50,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.blue.shade200),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.blue.shade100),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: Checkbox(
                                    value: rememberMe,
                                    onChanged: (value) {
                                      setState(() {
                                        rememberMe = value ?? false;
                                      });
                                    },
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Text(
                                  'Remember me',
                                  style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                                ),
                              ],
                            ),
                            TextButton(
                              style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(50, 30)),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const ForgotPasswordFlow()),
                                );
                              },
                              child: const Text(
                                'Forgot Password?',
                                style: TextStyle(fontSize: 13, color: Color(0xFF2563EB), fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),

                        if (errorMessage != null) ...[
                          const SizedBox(height: 10),
                          Text(
                            errorMessage!,
                            style: const TextStyle(fontSize: 12, color: Colors.red, fontWeight: FontWeight.bold),
                          ),
                        ],
                        const SizedBox(height: 18),

                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2563EB),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                            ),
                            onPressed: isLoggingIn ? null : _performLogin,
                            child: isLoggingIn
                                ? const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(height: 18, width: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
                                      SizedBox(width: 10),
                                      Text('Authenticating...', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                                    ],
                                  )
                                : const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Login',
                                        style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                                      ),
                                      SizedBox(width: 8),
                                      Icon(Icons.arrow_forward, color: Colors.white, size: 16),
                                    ],
                                  ),
                          ),
                        ),
                        const SizedBox(height: 18),

                        Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text("Don't have an account? ", style: TextStyle(fontSize: 13, color: Color(0xFF64748B))),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const SignupPage()),
                                  );
                                },
                                child: const Text(
                                  'Sign Up',
                                  style: TextStyle(fontSize: 13, color: Color(0xFF2563EB), fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
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
