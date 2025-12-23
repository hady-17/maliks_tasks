import 'package:flutter/material.dart';
import '../widgets/appBar.dart';

class UnactivePage extends StatelessWidget {
  const UnactivePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const ModernAppBar(title: "Account Inactive"),
      body: const SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Text(
              'Your account is not active yet. Please wait for activation by an administrator.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18),
            ),
          ),
        ),
      ),
    );
  }
}
