import 'package:flutter/material.dart';

class LeftSidebar extends StatelessWidget {
  final String selectedMenu;
  final ValueChanged<String> onMenuSelected;

  const LeftSidebar({
    super.key,
    required this.selectedMenu,
    required this.onMenuSelected,
  });

  @override
  Widget build(BuildContext context) {
    final menuItems = [
      'SYS',
      'DRIVE',
      'POWER',
      'COMPUTE',
      'SENSOR',
      'COM',
      'ALERTS',
      'PAYLOAD',
    ];

    return Container(
      width: 200,
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border(
          right: BorderSide(color: Colors.cyan.withOpacity(0.5), width: 1),
        ),
      ),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
        itemCount: menuItems.length,
        itemBuilder: (context, index) {
          final item = menuItems[index];
          final isSelected = item == selectedMenu;

          return Padding(
            padding: const EdgeInsets.only(bottom: 15),
            child: _buildMenuButton(item, isSelected),
          );
        },
      ),
    );
  }

  Widget _buildMenuButton(String label, bool isSelected) {
    return InkWell(
      onTap: () => onMenuSelected(label),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: isSelected ? Colors.cyan.withOpacity(0.3) : Colors.transparent,
          border: Border.all(
            color: isSelected ? Colors.cyan : Colors.cyan.withOpacity(0.5),
            width: 2,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.cyan : Colors.cyan.withOpacity(0.8),
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
        ),
      ),
    );
  }
}
