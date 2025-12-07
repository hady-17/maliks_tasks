import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:maliks_tasks/viewmodels/login_viewmodel.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LoginViewModel(),
      child: const _LoginPageContent(),
    );
  }
}

class _LoginPageContent extends StatefulWidget {
  const _LoginPageContent();

  @override
  State<_LoginPageContent> createState() => _LoginPageContentState();
}

class _LoginPageContentState extends State<_LoginPageContent> {
  final _formKey = GlobalKey<FormState>();

  Future<void> _handleSubmit(LoginViewModel vm) async {
    if (!_formKey.currentState!.validate()) return;

    final profile = await vm.submit();

    if (!mounted) return;

    if (profile != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account created successfully!')),
      );
      final role = profile['role'] ?? 'member';
      final route = (role == 'manager') ? '/manager_home' : '/home';
      Navigator.pushReplacementNamed(context, route, arguments: profile);
    } else if (vm.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(vm.errorMessage!), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<LoginViewModel>();
    final accent = Colors.red.shade800;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 56,
                  maxWidth: 600,
                ),
                child: Center(
                  child: Card(
                    elevation: 6,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 24,
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Header
                            _buildHeader(context, accent),

                            const SizedBox(height: 20),

                            // Full name
                            _buildTextField(
                              controller: vm.nameController,
                              label: 'Full name',
                              hint: 'John Doe',
                              prefix: Icons.person_outline,
                              validator: vm.validateName,
                            ),

                            const SizedBox(height: 12),

                            // Email
                            _buildTextField(
                              controller: vm.emailController,
                              label: 'Email',
                              hint: 'name@example.com',
                              prefix: Icons.email_outlined,
                              keyboardType: TextInputType.emailAddress,
                              validator: vm.validateEmail,
                            ),

                            const SizedBox(height: 12),

                            // Password
                            _buildTextField(
                              controller: vm.passwordController,
                              label: 'Password',
                              hint: 'At least 6 characters',
                              prefix: Icons.lock_outline,
                              obscureText: vm.obscurePassword,
                              suffix: IconButton(
                                icon: Icon(
                                  vm.obscurePassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: Colors.grey[700],
                                ),
                                onPressed: vm.togglePasswordVisibility,
                              ),
                              validator: vm.validatePassword,
                            ),

                            const SizedBox(height: 12),

                            // Confirm Password
                            _buildTextField(
                              controller: vm.confirmController,
                              label: 'Confirm password',
                              hint: 'Repeat your password',
                              prefix: Icons.lock_outline,
                              obscureText: vm.obscureConfirm,
                              suffix: IconButton(
                                icon: Icon(
                                  vm.obscureConfirm
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: Colors.grey[700],
                                ),
                                onPressed: vm.toggleConfirmVisibility,
                              ),
                              validator: vm.validateConfirmPassword,
                            ),

                            const SizedBox(height: 12),

                            // Branch & Position row
                            Row(
                              children: [
                                Expanded(
                                  child: _buildDropdown(
                                    value: vm.selectedBranch,
                                    hint: 'Branch',
                                    items: vm.branches,
                                    onChanged: vm.setBranch,
                                    validator: (v) =>
                                        vm.validateDropdown(v, 'Branch'),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildDropdown(
                                    value: vm.selectedPosition,
                                    hint: 'Position',
                                    items: vm.positions,
                                    onChanged: vm.setPosition,
                                    validator: (v) =>
                                        vm.validateDropdown(v, 'Position'),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 12),

                            // Shift dropdown
                            _buildDropdown(
                              value: vm.selectedShift,
                              hint: 'Shift',
                              items: vm.shifts,
                              onChanged: vm.setShift,
                              validator: (v) => vm.validateDropdown(v, 'Shift'),
                            ),

                            const SizedBox(height: 20),

                            // Submit Button
                            ElevatedButton(
                              onPressed: vm.isLoading
                                  ? null
                                  : () => _handleSubmit(vm),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: accent,
                                disabledBackgroundColor: accent.withOpacity(
                                  0.6,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 2,
                              ),
                              child: vm.isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text(
                                      'Create account',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),

                            const SizedBox(height: 12),

                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text(
                                'Already have an account? Sign in',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Color accent) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: accent,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 8),
            ],
          ),
          child: const Icon(Icons.lock_open, color: Colors.white, size: 28),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Create account',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 2),
            Text(
              'Fill the form to get started',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    IconData? prefix,
    Widget? suffix,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8),
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: prefix != null
              ? Icon(prefix, color: Colors.grey[700])
              : null,
          suffixIcon: suffix,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String? value,
    required String hint,
    required List<String> items,
    required void Function(String?) onChanged,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: DropdownButtonFormField<String>(
        value: value,
        hint: Text(hint),
        decoration: const InputDecoration(border: InputBorder.none),
        items: items
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        onChanged: onChanged,
        validator: validator,
      ),
    );
  }
}
