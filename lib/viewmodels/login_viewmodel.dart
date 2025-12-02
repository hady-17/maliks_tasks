import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginViewModel extends ChangeNotifier {
  // ---------------------------------------------------------------------------
  // Controllers
  // ---------------------------------------------------------------------------
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();

  // ---------------------------------------------------------------------------
  // Dropdown selections
  // ---------------------------------------------------------------------------
  String? _selectedBranch;
  String? _selectedPosition;
  String? _selectedShift;

  String? get selectedBranch => _selectedBranch;
  String? get selectedPosition => _selectedPosition;
  String? get selectedShift => _selectedShift;

  void setBranch(String? value) {
    _selectedBranch = value;
    notifyListeners();
  }

  void setPosition(String? value) {
    _selectedPosition = value;
    notifyListeners();
  }

  void setShift(String? value) {
    _selectedShift = value;
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Dropdown options (static for now)
  // ---------------------------------------------------------------------------
  final List<String> branches = [
    'AUB',
    'Book&Pens',
    'Hamra',
    'Ashrafieh',
    'Jnah',
    'Mar Mikhael',
    'New Branch',
    '3F',
  ];

  final List<String> positions = [
    'Manager',
    'supervisor',
    'Cashier',
    'stationary',
    'Designer',
    'services',
  ];

  final List<String> shifts = ['Day', 'Night'];

  // ---------------------------------------------------------------------------
  // UI State
  // ---------------------------------------------------------------------------
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;
  String? _errorMessage;

  bool get obscurePassword => _obscurePassword;
  bool get obscureConfirm => _obscureConfirm;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void togglePasswordVisibility() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  void toggleConfirmVisibility() {
    _obscureConfirm = !_obscureConfirm;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Validators
  // ---------------------------------------------------------------------------
  String? validateName(String? value) {
    if (value == null || value.trim().length < 2) {
      return 'Enter your full name';
    }
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Enter your email';

    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value)) {
      return 'Enter a valid email';
    }

    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) return 'Confirm your password';

    if (value != passwordController.text) {
      return 'Passwords do not match';
    }

    return null;
  }

  String? validateDropdown(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return 'Please select $fieldName';
    }
    return null;
  }

  // ---------------------------------------------------------------------------
  // Fetch branch ID (UUID) by name
  // ---------------------------------------------------------------------------
  Future<String> _resolveBranchId(String branchName) async {
    final supabase = Supabase.instance.client;

    final data = await supabase
        .from('branches')
        .select('id')
        .eq('name', branchName)
        .maybeSingle();

    if (data == null) {
      throw Exception("Branch '$branchName' not found in database.");
    }

    return data['id'];
  }

  // ---------------------------------------------------------------------------
  // Submit (Signup + Profile Update) - returns profile map on success
  // ---------------------------------------------------------------------------
  Future<Map<String, dynamic>?> submit() async {
    // Validate all fields
    if (validateName(nameController.text) != null ||
        validateEmail(emailController.text) != null ||
        validatePassword(passwordController.text) != null ||
        validateConfirmPassword(confirmController.text) != null ||
        validateDropdown(_selectedBranch, 'Branch') != null ||
        validateDropdown(_selectedPosition, 'Position') != null ||
        validateDropdown(_selectedShift, 'Shift') != null) {
      return null;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final supabase = Supabase.instance.client;

      // 1. Sign up user
      final response = await supabase.auth.signUp(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      if (response.user == null) {
        throw Exception("Signup failed: no user returned.");
      }

      // 2. Resolve branch ID
      final branchId = await _resolveBranchId(_selectedBranch!);

      // 3. Update the auto-created profile row
      await supabase
          .from('profiles')
          .update({
            'full_name': nameController.text.trim(),
            'section': _selectedPosition,
            'branch_id': branchId,
            'shift': _selectedShift,
          })
          .eq('id', response.user!.id);

      // 4. Fetch and return the updated profile
      final profile = await supabase
          .from('profiles')
          .select()
          .eq('id', response.user!.id)
          .maybeSingle();

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
  // Cleanup
  // ---------------------------------------------------------------------------
  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmController.dispose();
    super.dispose();
  }
}
