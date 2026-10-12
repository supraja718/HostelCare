import 'package:flutter/material.dart';
import 'login_page.dart';

class RoleSelectionPage extends StatefulWidget {
  const RoleSelectionPage({super.key});

  @override
  State<RoleSelectionPage> createState() => _RoleSelectionPageState();
}

class _RoleSelectionPageState extends State<RoleSelectionPage> {
  String selectedRole = 'Student';
  String selectedDepartment = 'Electrician';

  final List<String> _serviceDepartments = [
    'Electrician',
    'Plumber',
    'Carpenter',
    'Wi-Fi Technician',
    'Cleaning Staff',
  ];

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

                  // Role Selection Container
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
                        const Text(
                          'Select your role',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(height: 16),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            buildRoleCard('Student', Icons.school, const Color(0xFFDCFCE7), const Color(0xFF15803D)),
                            buildRoleCard('Warden', Icons.person, Colors.purple.shade50, Colors.purple.shade700),
                            buildRoleCard('Management', Icons.groups, Colors.blue.shade50, Colors.blue.shade700),
                          ],
                        ),
                        const SizedBox(height: 12),

                        Row(
                          children: [
                            buildRoleCard('Service Staff', Icons.build, Colors.amber.shade50, Colors.amber.shade800),
                            const SizedBox(width: 12),
                            buildRoleCard('Student Care', Icons.favorite, Colors.pink.shade50, Colors.pink.shade700),
                            const Spacer(),
                          ],
                        ),

                        // Service Staff Department Dropdown
                        if (selectedRole == 'Service Staff') ...[
                          const SizedBox(height: 18),
                          const Text(
                            'Select Service Department',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          const SizedBox(height: 6),
                          DropdownButtonFormField<String>(
                            initialValue: selectedDepartment,
                            items: _serviceDepartments.map((dept) {
                              return DropdownMenuItem(
                                value: dept,
                                child: Text(dept, style: const TextStyle(fontSize: 13)),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() {
                                  selectedDepartment = val;
                                });
                              }
                            },
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.build_circle_outlined, color: Color(0xFFD97706)),
                              filled: true,
                              fillColor: Colors.amber.shade50,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.amber.shade200),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.amber.shade200),
                              ),
                            ),
                          ),
                        ],

                        const SizedBox(height: 24),

                        // Continue Button
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
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => LoginPage(
                                    selectedRole: selectedRole,
                                    selectedDepartment: selectedDepartment,
                                  ),
                                ),
                              );
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  selectedRole == 'Service Staff'
                                      ? 'Continue as $selectedDepartment'
                                      : 'Continue as $selectedRole',
                                  style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(width: 8),
                                const Icon(Icons.arrow_forward, color: Colors.white, size: 16),
                              ],
                            ),
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

  Widget buildRoleCard(String roleName, IconData icon, Color bgColor, Color textColor) {
    bool isSelected = (selectedRole == roleName);

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedRole = roleName;
          });
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? textColor : Colors.transparent,
              width: 2,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: textColor, size: 26),
              const SizedBox(height: 8),
              Text(
                roleName,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
