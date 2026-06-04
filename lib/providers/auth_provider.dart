import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _error;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _currentUser != null;

  Future<void> loadCurrentUser() async {
    final user = _authService.currentUser;
    if (user == null) return;
    _currentUser = await _authService.getUserData(user.uid);
    notifyListeners();
  }

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _currentUser = await _authService.signIn(
        email: email,
        password: password,
      );
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_role', _currentUser!.role.name);
      return true;
    } catch (e) {
      _error = _parseError(e.toString());
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register({
    required String email,
    required String password,
    required String name,
    required UserRole role,
    String? classId,
    String? subject,
    String? department,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _currentUser = await _authService.register(
        email: email,
        password: password,
        name: name,
        role: role,
        classId: classId,
        subject: subject,
        department: department,
      );
      return true;
    } catch (e) {
      _error = _parseError(e.toString());
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_role');
    notifyListeners();
  }

  Future<bool> resetPassword(String email) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _authService.resetPassword(email);
      return true;
    } catch (e) {
      _error = _parseError(e.toString());
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  String _parseError(String raw) {
    if (raw.contains('user-not-found') || raw.contains('wrong-password') || raw.contains('invalid-credential')) {
      return 'Email ou mot de passe incorrect.';
    }
    if (raw.contains('email-already-in-use')) {
      return 'Cet email est déjà utilisé.';
    }
    if (raw.contains('weak-password')) {
      return 'Le mot de passe doit contenir au moins 6 caractères.';
    }
    if (raw.contains('network-request-failed')) {
      return 'Erreur de connexion réseau.';
    }
    if (raw.contains('Rôle incorrect')) {
      return 'Rôle incorrect pour ce compte.';
    }
    return 'Une erreur est survenue. Réessayez.';
  }
}
