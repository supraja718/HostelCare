import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserAccount {
  final String name;
  final String email;
  final String passwordHash;
  final String role; // 'Student', 'Warden', 'Service Staff', 'Management', 'Student Care'
  final String? department; // 'Electrician', 'Plumber', etc.
  final String? roomNumber;

  UserAccount({
    required this.name,
    required this.email,
    required this.passwordHash,
    required this.role,
    this.department,
    this.roomNumber,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        'passwordHash': passwordHash,
        'role': role,
        'department': department,
        'roomNumber': roomNumber,
      };

  factory UserAccount.fromJson(Map<String, dynamic> json) => UserAccount(
        name: json['name'] ?? 'User',
        email: json['email'] ?? '',
        passwordHash: json['passwordHash'] ?? '',
        role: json['role'] ?? 'Student',
        department: json['department'],
        roomNumber: json['roomNumber'],
      );
}

class AuthService extends ChangeNotifier {
  static final AuthService instance = AuthService._internal();
  AuthService._internal() {
    _initDefaultUsers();
  }

  UserAccount? _currentUser;
  UserAccount? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;

  final Map<String, UserAccount> _registeredUsers = {};

  String _hashPassword(String password) {
    final bytes = utf8.encode('hostelcare_salt_$password');
    return base64Encode(bytes);
  }

  void _initDefaultUsers() {
    final defaultUsers = [
      UserAccount(
        name: 'Student User',
        email: 'student@hostel.edu',
        passwordHash: _hashPassword('Password123!'),
        role: 'Student',
        roomNumber: 'Room 204',
      ),
      UserAccount(
        name: 'Warden Administrator',
        email: 'warden@hostel.edu',
        passwordHash: _hashPassword('Password123!'),
        role: 'Warden',
      ),
      UserAccount(
        name: 'Ramesh Electrician',
        email: 'electrician@hostel.edu',
        passwordHash: _hashPassword('Password123!'),
        role: 'Service Staff',
        department: 'Electrician',
      ),
      UserAccount(
        name: 'Suresh Plumber',
        email: 'plumber@hostel.edu',
        passwordHash: _hashPassword('Password123!'),
        role: 'Service Staff',
        department: 'Plumber',
      ),
      UserAccount(
        name: 'Management Admin',
        email: 'management@hostel.edu',
        passwordHash: _hashPassword('Password123!'),
        role: 'Management',
      ),
      UserAccount(
        name: 'Student Care Officer',
        email: 'care@hostel.edu',
        passwordHash: _hashPassword('Password123!'),
        role: 'Student Care',
      ),
    ];

    for (var u in defaultUsers) {
      _registeredUsers[u.email.toLowerCase()] = u;
    }
  }

  Future<void> checkPersistentSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionJson = prefs.getString('active_user_session');
      if (sessionJson != null) {
        final Map<String, dynamic> data = jsonDecode(sessionJson);
        _currentUser = UserAccount.fromJson(data);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading persistent session: $e');
    }
  }

  Future<bool> registerUser({
    required String name,
    required String email,
    required String password,
    required String role,
    String? department,
    String? roomNumber,
  }) async {
    final key = email.toLowerCase().trim();
    if (_registeredUsers.containsKey(key)) {
      throw 'An account with this email address already exists.';
    }

    final newUser = UserAccount(
      name: name.trim(),
      email: email.trim(),
      passwordHash: _hashPassword(password),
      role: role,
      department: department,
      roomNumber: roomNumber,
    );

    _registeredUsers[key] = newUser;
    _currentUser = newUser;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('active_user_session', jsonEncode(newUser.toJson()));
    } catch (e) {
      debugPrint('Error storing session: $e');
    }

    notifyListeners();
    return true;
  }

  Future<bool> login(String emailOrId, String password, {String? expectedRole}) async {
    final key = emailOrId.toLowerCase().trim();

    UserAccount? account;
    if (_registeredUsers.containsKey(key)) {
      account = _registeredUsers[key];
    } else {
      for (var u in _registeredUsers.values) {
        if (u.email.toLowerCase().startsWith(key) || u.name.toLowerCase() == key) {
          account = u;
          break;
        }
      }
    }

    if (account == null) {
      throw 'Invalid Email/User ID or Password.';
    }

    if (account.passwordHash != _hashPassword(password)) {
      throw 'Invalid Email/User ID or Password.';
    }

    // Role Guard Check
    if (expectedRole != null && expectedRole.isNotEmpty) {
      if (account.role != expectedRole) {
        throw 'Access Denied: Your account role (${account.role}) does not match the selected portal ($expectedRole).';
      }
    }

    _currentUser = account;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('active_user_session', jsonEncode(account.toJson()));
    } catch (e) {
      debugPrint('Error saving session: $e');
    }

    notifyListeners();
    return true;
  }

  Future<void> logout() async {
    _currentUser = null;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('active_user_session');
    } catch (e) {
      debugPrint('Error clearing session: $e');
    }
    notifyListeners();
  }

  bool isAuthorizedForRole(String requiredRole) {
    if (_currentUser == null) return false;
    if (_currentUser!.role == requiredRole) return true;
    if (requiredRole == 'Student Care' && _currentUser!.role == 'Student Welfare Officer') return true;
    return false;
  }
}
