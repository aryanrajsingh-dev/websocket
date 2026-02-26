import 'package:flutter/material.dart';

class ModeIndicator extends StatelessWidget {
  final String mode;

  const ModeIndicator({
    super.key,
    required this.mode,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border.all(color: Colors.cyan, width: 2),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(0),
          topRight: Radius.circular(15),
          bottomRight: Radius.circular(0),
          bottomLeft: Radius.circular(0),
        ),
      ),
      child: Text(
        'MODE: $mode',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
