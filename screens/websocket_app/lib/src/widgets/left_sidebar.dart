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
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 150;
        
        return Container(
          decoration: BoxDecoration(
            color: Colors.black,
            border: Border(
              right: BorderSide(color: Colors.cyan.withOpacity(0.5), width: 1),
            ),
          ),
          child: ListView.builder(
            padding: EdgeInsets.symmetric(
              vertical: 20,
              horizontal: isCompact ? 8 : 15,
            ),
            itemCount: menuItems.length,
            itemBuilder: (context, index) {
              final item = menuItems[index];
              final isSelected = item == selectedMenu;

              return Padding(
                padding: const EdgeInsets.only(bottom: 15),
                child: _buildMenuButton(item, isSelected, isCompact),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildMenuButton(String label, bool isSelected, bool isCompact) {
    return InkWell(
      onTap: () => onMenuSelected(label),
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: isCompact ? 12 : 15,
          horizontal: isCompact ? 4 : 0,
        ),
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
              fontSize: isCompact ? 14 : 16,
              fontWeight: FontWeight.bold,
              letterSpacing: isCompact ? 1.0 : 1.5,
            ),
          ),
        ),
      ),
    );
  }
}