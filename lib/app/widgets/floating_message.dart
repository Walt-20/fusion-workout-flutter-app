import 'package:flutter/material.dart';

class FloatingMessage extends StatelessWidget {
  final int foodCount;

  const FloatingMessage({super.key, required this.foodCount});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom:
          MediaQuery.of(context).viewInsets.bottom + 10, // Adjust the position
      left: 16.0,
      right: 16.0,
      child: Container(
        padding: const EdgeInsets.all(16.0),
        color: Colors.black.withOpacity(0.7),
        child: Text(
          'Foods added: $foodCount',
          style: const TextStyle(color: Colors.white, fontSize: 16),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
