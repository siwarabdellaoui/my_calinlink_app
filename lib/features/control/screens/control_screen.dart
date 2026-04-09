import 'package:flutter/material.dart';
export 'control_screen.dart';
class ControlScreen extends StatelessWidget {
  const ControlScreen({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(
    body: Center(child: CircularProgressIndicator()),
  );
}