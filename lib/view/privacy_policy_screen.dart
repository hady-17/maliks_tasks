import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_markdown/flutter_markdown.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  Future<String> _loadPolicy() async {
    return await rootBundle.loadString('PRIVACY_POLICY.md');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Privacy Policy')),
      body: FutureBuilder<String>(
        future: _loadPolicy(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Error loading policy: ${snapshot.error}'),
            );
          }
          final data = snapshot.data ?? 'Privacy policy not available.';
          return Markdown(data: data, padding: const EdgeInsets.all(16));
        },
      ),
    );
  }
}
