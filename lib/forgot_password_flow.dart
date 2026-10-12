import 'dart:async';
import 'package:flutter/material.dart';

class ForgotPasswordFlow extends StatefulWidget {
  const ForgotPasswordFlow({super.key});

  @override
  State<ForgotPasswordFlow> createState() => _ForgotPasswordFlowState();
}

class _ForgotPasswordFlowState extends State<ForgotPasswordFlow> {
  int _currentStep = 0; // 0: Email/ID, 1: OTP, 2: New Password, 3: Success

  // Step 0: Email / ID
  final TextEditingController _emailOrIdController = TextEditingController();
  bool _isSendingLink = false;
  String? _emailErrorMessage;

  // Step 1: OTP Verification
  final List<TextEditingController> _otpControllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _otpFocusNodes = List.generate(6, (_) => FocusNode());
  int _resendTimerSeconds = 45;
  Timer? _timer;
  bool _isVerifyingOtp = false;
  String? _otpErrorMessage;

  // Step 2: New Password
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  bool _isUpdatingPassword = false;
  String? _passwordErrorMessage;

  // Password criteria getters
  bool get _hasMinLength => _newPasswordController.text.length >= 8;
  bool get _hasUppercase => RegExp(r'[A-Z]').hasMatch(_newPasswordController.text);
  bool get _hasLowercase => RegExp(r'[a-z]').hasMatch(_newPasswordController.text);
  bool get _hasNumber => RegExp(r'[0-9]').hasMatch(_newPasswordController.text);
  bool get _hasSpecialChar => RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(_newPasswordController.text);
  bool get _allCriteriaMet => _hasMinLength && _hasUppercase && _hasLowercase && _hasNumber && _hasSpecialChar;

  @override
  void initState() {
    super.initState();
    _newPasswordController.addListener(() {
      setState(() {});
    });
    _confirmPasswordController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _emailOrIdController.dispose();
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _otpFocusNodes) {
      node.dispose();
    }
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _startResendTimer() {
    _timer?.cancel();
    setState(() {
      _resendTimerSeconds = 45;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendTimerSeconds > 0) {
        setState(() {
          _resendTimerSeconds--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  // Action Step 0: Submit Email
  void _submitEmailOrId() async {
    final input = _emailOrIdController.text.trim();
    if (input.isEmpty) {
      setState(() {
        _emailErrorMessage = 'Please enter your email or User ID.';
      });
      return;
    }

    setState(() {
      _emailErrorMessage = null;
      _isSendingLink = true;
    });

    // Simulate API network call
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    setState(() {
      _isSendingLink = false;
      _currentStep = 1; // Move to OTP
    });

    _startResendTimer();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("If an account matches the information provided, you'll receive password reset instructions shortly."),
        duration: Duration(seconds: 4),
        backgroundColor: Color(0xFF2563EB),
      ),
    );
  }

  // Action Step 1: Submit OTP
  void _verifyOtp() async {
    final otp = _otpControllers.map((c) => c.text).join();
    if (otp.length < 6) {
      setState(() {
        _otpErrorMessage = 'Please enter the complete 6-digit verification code.';
      });
      return;
    }

    setState(() {
      _otpErrorMessage = null;
      _isVerifyingOtp = true;
    });

    await Future.delayed(const Duration(seconds: 1, milliseconds: 500));

    if (!mounted) return;

    setState(() {
      _isVerifyingOtp = false;
      _currentStep = 2; // Move to New Password
    });
  }

  // Action Step 2: Reset Password
  void _resetPassword() async {
    final newPass = _newPasswordController.text;
    final confirmPass = _confirmPasswordController.text;

    if (!_hasMinLength) {
      setState(() {
        _passwordErrorMessage = 'Password must contain at least 8 characters.';
      });
      return;
    }

    if (!_allCriteriaMet) {
      setState(() {
        _passwordErrorMessage = 'Password does not meet the required security criteria.';
      });
      return;
    }

    if (newPass != confirmPass) {
      setState(() {
        _passwordErrorMessage = 'Passwords do not match.';
      });
      return;
    }

    setState(() {
      _passwordErrorMessage = null;
      _isUpdatingPassword = true;
    });

    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    setState(() {
      _isUpdatingPassword = false;
      _currentStep = 3; // Move to Success
    });
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
                  // App Logo (Matching Login)
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

                  // Main Step Card
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _buildStepContent(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildForgotPasswordStep();
      case 1:
        return _buildOtpVerificationStep();
      case 2:
        return _buildResetPasswordStep();
      case 3:
      default:
        return _buildSuccessStep();
    }
  }

  // -------------------------------------------------------------
  // STEP 0: FORGOT PASSWORD PAGE
  // -------------------------------------------------------------
  Widget _buildForgotPasswordStep() {
    return Container(
      key: const ValueKey(0),
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
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Color(0xFFE0F2FE),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.lock_reset, color: Color(0xFF2563EB), size: 22),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Forgot your password?',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            "Enter your registered email address or User ID and we'll send you instructions to reset your password.",
            style: TextStyle(fontSize: 12, color: Color(0xFF64748B), height: 1.4),
          ),
          const SizedBox(height: 20),

          // Form Field
          const Text(
            'Email or User ID',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _emailOrIdController,
            decoration: InputDecoration(
              isDense: false,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              hintText: 'Enter your email or User ID',
              hintStyle: const TextStyle(fontSize: 14, color: Colors.grey),
              prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFF2563EB), size: 22),
              filled: true,
              fillColor: Colors.blue.shade50,
              errorText: _emailErrorMessage,
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
          const SizedBox(height: 22),

          // Primary Button
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
              onPressed: _isSendingLink ? null : _submitEmailOrId,
              child: _isSendingLink
                  ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        ),
                        SizedBox(width: 10),
                        Text('Sending...', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                      ],
                    )
                  : const Text('Send Reset Link', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 18),

          // Back to Login
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Remember your password? ', style: TextStyle(fontSize: 13, color: Color(0xFF64748B))),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Text(
                    'Back to Login',
                    style: TextStyle(fontSize: 13, color: Color(0xFF2563EB), fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // STEP 1: OTP VERIFICATION STEP
  // -------------------------------------------------------------
  Widget _buildOtpVerificationStep() {
    String formattedTime = '00:${_resendTimerSeconds.toString().padLeft(2, '0')}';
    String displayEmail = _emailOrIdController.text.contains('@')
        ? '${_emailOrIdController.text.substring(0, 1)}******@${_emailOrIdController.text.split('@').last}'
        : 's******@example.com';

    return Container(
      key: const ValueKey(1),
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
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Color(0xFFE0F2FE),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.mark_email_read_outlined, color: Color(0xFF2563EB), size: 22),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Verify your account',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Enter the verification code sent to your registered email ($displayEmail).',
            style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), height: 1.4),
          ),
          const SizedBox(height: 22),

          // 6-Digit OTP Box Input
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(6, (index) {
              return SizedBox(
                width: 48,
                height: 52,
                child: TextField(
                  controller: _otpControllers[index],
                  focusNode: _otpFocusNodes[index],
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  maxLength: 1,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                  decoration: InputDecoration(
                    counterText: '',
                    filled: true,
                    fillColor: Colors.blue.shade50,
                    contentPadding: EdgeInsets.zero,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.blue.shade200),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFF2563EB), width: 2),
                    ),
                  ),
                  onChanged: (val) {
                    if (val.isNotEmpty && index < 5) {
                      _otpFocusNodes[index + 1].requestFocus();
                    } else if (val.isEmpty && index > 0) {
                      _otpFocusNodes[index - 1].requestFocus();
                    }
                    if (_otpControllers.every((c) => c.text.isNotEmpty)) {
                      _verifyOtp();
                    }
                  },
                ),
              );
            }),
          ),
          if (_otpErrorMessage != null) ...[
            const SizedBox(height: 10),
            Text(_otpErrorMessage!, style: const TextStyle(fontSize: 12, color: Colors.red, fontWeight: FontWeight.bold)),
          ],
          const SizedBox(height: 20),

          // Countdown Timer & Resend Option
          Center(
            child: _resendTimerSeconds > 0
                ? Text(
                    'Resend code in $formattedTime',
                    style: const TextStyle(fontSize: 13, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Didn't receive the code? ", style: TextStyle(fontSize: 13, color: Color(0xFF64748B))),
                      GestureDetector(
                        onTap: () {
                          _startResendTimer();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('A new 6-digit verification code has been sent.')),
                          );
                        },
                        child: const Text(
                          'Resend Code',
                          style: TextStyle(fontSize: 13, color: Color(0xFF2563EB), fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
          ),
          const SizedBox(height: 22),

          // Verify Button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 2,
              ),
              onPressed: _isVerifyingOtp ? null : _verifyOtp,
              child: _isVerifyingOtp
                  ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: 18, width: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
                        SizedBox(width: 10),
                        Text('Verifying...', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                      ],
                    )
                  : const Text('Verify Code', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // STEP 2: CREATE NEW PASSWORD PAGE
  // -------------------------------------------------------------
  Widget _buildResetPasswordStep() {
    return Container(
      key: const ValueKey(2),
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
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Color(0xFFE0F2FE),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.password_rounded, color: Color(0xFF2563EB), size: 22),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Create a new password',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Your new password must be different from your previous password.',
            style: TextStyle(fontSize: 12, color: Color(0xFF64748B), height: 1.4),
          ),
          const SizedBox(height: 18),

          // New Password Field
          const Text('New Password', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
          const SizedBox(height: 6),
          TextField(
            controller: _newPasswordController,
            obscureText: _obscureNewPassword,
            decoration: InputDecoration(
              hintText: 'Enter new password',
              hintStyle: const TextStyle(fontSize: 14, color: Colors.grey),
              prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF2563EB), size: 22),
              suffixIcon: IconButton(
                icon: Icon(_obscureNewPassword ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                onPressed: () => setState(() => _obscureNewPassword = !_obscureNewPassword),
              ),
              filled: true,
              fillColor: Colors.blue.shade50,
              isDense: false,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.blue.shade200)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5)),
            ),
          ),
          const SizedBox(height: 14),

          // Confirm Password Field
          const Text('Confirm Password', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
          const SizedBox(height: 6),
          TextField(
            controller: _confirmPasswordController,
            obscureText: _obscureConfirmPassword,
            decoration: InputDecoration(
              hintText: 'Confirm new password',
              hintStyle: const TextStyle(fontSize: 14, color: Colors.grey),
              prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF2563EB), size: 22),
              suffixIcon: IconButton(
                icon: Icon(_obscureConfirmPassword ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
              ),
              filled: true,
              fillColor: Colors.blue.shade50,
              isDense: false,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.blue.shade200)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5)),
            ),
          ),
          const SizedBox(height: 16),

          // Dynamic Password Criteria Checklist Indicators
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Password Requirements:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                const SizedBox(height: 8),
                _buildCriterionItem('At least 8 characters', _hasMinLength),
                _buildCriterionItem('One uppercase letter', _hasUppercase),
                _buildCriterionItem('One lowercase letter', _hasLowercase),
                _buildCriterionItem('One number', _hasNumber),
                _buildCriterionItem('One special character (!@#\$%^&*)', _hasSpecialChar),
              ],
            ),
          ),

          if (_passwordErrorMessage != null) ...[
            const SizedBox(height: 10),
            Text(_passwordErrorMessage!, style: const TextStyle(fontSize: 12, color: Colors.red, fontWeight: FontWeight.bold)),
          ],
          const SizedBox(height: 20),

          // Primary Submit Button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 2,
              ),
              onPressed: _isUpdatingPassword ? null : _resetPassword,
              child: _isUpdatingPassword
                  ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: 18, width: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
                        SizedBox(width: 10),
                        Text('Updating...', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                      ],
                    )
                  : const Text('Reset Password', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCriterionItem(String text, bool satisfied) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          Icon(
            satisfied ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
            color: satisfied ? const Color(0xFF15803D) : Colors.grey.shade400,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              fontWeight: satisfied ? FontWeight.bold : FontWeight.normal,
              color: satisfied ? const Color(0xFF15803D) : const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // STEP 3: SUCCESS PAGE
  // -------------------------------------------------------------
  Widget _buildSuccessStep() {
    return Container(
      key: const ValueKey(3),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFFDCFCE7),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle_rounded,
              color: Color(0xFF15803D),
              size: 52,
            ),
          ),
          const SizedBox(height: 18),

          const Text(
            'Password Reset Successful',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),

          const Text(
            'Your password has been updated successfully. You can now log in using your new password.',
            style: TextStyle(fontSize: 13, color: Color(0xFF64748B), height: 1.4),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 2,
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text('Back to Login', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}
