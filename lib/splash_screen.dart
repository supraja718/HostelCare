import 'dart:async';
import 'package:flutter/material.dart';
import 'auth_service.dart';
import 'management_dashboard.dart';
import 'role_selection_page.dart';
import 'service_staff_dashboard.dart';
import 'student_care_dashboard.dart';
import 'student_dashboard.dart';
import 'warden_dashboard.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthenticationAndNavigate();
  }

  Widget _getDestinationPage() {
    if (!AuthService.instance.isLoggedIn || AuthService.instance.currentUser == null) {
      return const RoleSelectionPage();
    }

    final user = AuthService.instance.currentUser!;
    switch (user.role) {
      case 'Student':
        return const StudentDashboard();
      case 'Warden':
        return const WardenDashboard();
      case 'Service Staff':
        return ServiceStaffDashboard(department: user.department ?? 'Electrician');
      case 'Management':
        return const ManagementDashboard();
      case 'Student Care':
      case 'Student Welfare Officer':
      default:
        return const StudentCareDashboard();
    }
  }

  void _checkAuthenticationAndNavigate() async {
    try {
      await AuthService.instance.checkPersistentSession();
    } catch (e) {
      debugPrint('Error restoring session: $e');
    }

    await Future.delayed(const Duration(milliseconds: 1500));

    if (!mounted) return;

    final destination = _getDestinationPage();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => destination),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),

                // Hostel/App Logo Container
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E3A8A),
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF1E3A8A).withValues(alpha: 0.25),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.apartment,
                    color: Colors.white,
                    size: 48,
                  ),
                ),
                const SizedBox(height: 20),

                // App Name
                const Text(
                  'HostelCare',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 6),

                // Tagline
                const Text(
                  'Report. Resolve. Connect.',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2563EB),
                    letterSpacing: 1.2,
                  ),
                  textAlign: TextAlign.center,
                ),

                const Spacer(),

                // Subtle Loading Indicator
                const Column(
                  children: [
                    SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        color: Color(0xFF2563EB),
                        strokeWidth: 2.5,
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Checking session...',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
