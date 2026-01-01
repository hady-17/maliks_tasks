import 'package:flutter/material.dart';
import '../widgets/appBar.dart';

class Adminscreen extends StatelessWidget {
  const Adminscreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: const ModernAppBar(title: 'Admin Screen'),
      body: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradiantColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: const Text(
          'Welcome to the Admin Screen',
          style: TextStyle(fontSize: 24),
        ),
      ),
      drawer: Drawer(
        // Drawer content can be added here
        child: ListView(
          padding: EdgeInsets.zero,
          children: const <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: gradiantColors,
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Text(
                'Admin Menu',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: Icon(Icons.dashboard),
              title: Text('Dashboard'),
              onTap: null,
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Settings'),
              onTap: null,
            ),
          ],
        ),
      ),
    );
  }
}

const gradiantColors = [
  Color.fromARGB(255, 130, 45, 59),
  Color.fromARGB(255, 252, 43, 39),
];
