import 'package:flutter/material.dart';
import '../widgets/appBar.dart';
import '../widgets/navBar.dart';

class AccountApprovel extends StatelessWidget {
  const AccountApprovel({super.key});

  @override
  Widget build(BuildContext context) {
    final _currentIndex = 0;
    return Scaffold(
      appBar: const ModernAppBar(
        title: "Account Approval Pending",
        isManager: true,
      ),
      body: const SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Text(
              'Your account is pending approval. Please wait for an administrator to approve your account.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18),
            ),
          ),
        ),
      ),
    );
  }
}
