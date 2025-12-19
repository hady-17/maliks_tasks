import 'package:flutter/material.dart';

class memeberDashBoardscreen extends StatefulWidget {
  const memeberDashBoardscreen({super.key});

  @override
  State<memeberDashBoardscreen> createState() => _memeberDashBoardscreenState();
}

class _memeberDashBoardscreenState extends State<memeberDashBoardscreen> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: const Center(child: Text('Member Dashboard Screen')),
    );
  }
}
