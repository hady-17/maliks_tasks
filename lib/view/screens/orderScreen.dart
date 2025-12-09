import 'package:flutter/material.dart';
import '../widgets/appBar.dart';
import '../widgets/navBar.dart';
import '../../const.dart';

class Orderscreen extends StatefulWidget {
  final Map<String, dynamic>? profile;
  const Orderscreen({super.key, this.profile});

  @override
  State<Orderscreen> createState() => _OrderscreenState();
}

class _OrderscreenState extends State<Orderscreen> {
  Map<String, dynamic>? _resolveProfile(BuildContext context) {
    if (widget.profile != null) return widget.profile;
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic>) return args;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final profile = _resolveProfile(context);
    if (profile == null) {
      return const Scaffold(body: Center(child: Text('No profile provided')));
    }
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: ModernAppBar(
        title: 'Orders',
        subtitle: 'Your order details',
        showBackButton: true,
      ),
      body: Container(
        decoration: gradialColor,
        child: Center(child: Text('Order Screen for ${profile['email']}')),
      ),
      bottomNavigationBar: ModernNavBar(
        currentIndex: 1,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/home',
              (route) => false,
              arguments: profile,
            );
          } else if (index == 2) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/create_task',
              (route) => false,
              arguments: profile,
            );
          } else if (index == 3) {
          } else {
            // Do nothing for the current index
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/profile',
              (route) => false,
              arguments: profile,
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          print('action button pressed');
        },
        backgroundColor: kMainColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  BoxDecoration gradialColor = BoxDecoration(
    gradient: LinearGradient(
      colors: [Color(0xFFEDEDED), Color.fromARGB(255, 216, 42, 42)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
  );
}
