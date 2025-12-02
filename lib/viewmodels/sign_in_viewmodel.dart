import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignInViewModel extends ChangeNotifier {
  // ---------------------------------------------------------------------------
  // Text Controllers
  // ---------------------------------------------------------------------------
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // ---------------------------------------------------------------------------
  // UI State
  // ---------------------------------------------------------------------------
  bool _obscurePassword = true;
  bool _rememberMe = false;
  bool _isLoading = false;
  String? _errorMessage;

  bool get obscurePassword => _obscurePassword;
  bool get rememberMe => _rememberMe;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void togglePasswordVisibility() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  void setRememberMe(bool value) {
    _rememberMe = value;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Validators
  // ---------------------------------------------------------------------------
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  // ---------------------------------------------------------------------------
  // Sign In
  // ---------------------------------------------------------------------------
  Future<Map<String, dynamic>?> signIn() async {
    if (validateEmail(emailController.text) != null ||
        validatePassword(passwordController.text) != null) {
      return null;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final supabase = Supabase.instance.client;

      final res = await supabase.auth.signInWithPassword(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      final userId = res.user?.id ?? supabase.auth.currentUser?.id;

      if (userId == null) {
        _isLoading = false;
        _errorMessage = 'Sign in failed: no user.';
        notifyListeners();
        return null;
      }

      // Fetch profile
      final profile = await supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();

      // Persist the remember-me choice so app startup can respect it
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('remember_me', _rememberMe);
        await prefs.setString('remember_user_id', userId);
      } catch (_) {
        // ignore storage errors; not fatal for sign-in
      }

      _isLoading = false;
      notifyListeners();
      if (profile is Map<String, dynamic>) return profile;
      return null;
    } on AuthException catch (e) {
      _isLoading = false;
      _errorMessage = e.message;
      notifyListeners();
      return null;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return null;
    }
  }

  // ---------------------------------------------------------------------------
  // Social Sign In (placeholders)
  // ---------------------------------------------------------------------------
  Future<bool> signInWithGoogle() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // TODO: Implement Google sign-in with Supabase
      // final supabase = Supabase.instance.client;
      // await supabase.auth.signInWithOAuth(OAuthProvider.google);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> signInWithApple() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // TODO: Implement Apple sign-in with Supabase
      // final supabase = Supabase.instance.client;
      // await supabase.auth.signInWithOAuth(OAuthProvider.apple);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // ---------------------------------------------------------------------------
  // Forgot Password
  // ---------------------------------------------------------------------------
  Future<bool> sendPasswordReset() async {
    final email = emailController.text.trim();
    if (email.isEmpty ||
        !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      _errorMessage = 'Please enter a valid email first';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final supabase = Supabase.instance.client;
      await supabase.auth.resetPasswordForEmail(email);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // ---------------------------------------------------------------------------
  // Dispose
  // ---------------------------------------------------------------------------
  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
