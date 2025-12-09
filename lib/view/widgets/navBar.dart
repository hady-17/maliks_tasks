import 'package:flutter/material.dart';

/// Modern, stylish bottom navigation bar with smooth animations
/// and elevated design with floating active indicator
class ModernNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final Color backgroundColor;
  final Color activeColor;
  final Color inactiveColor;

  const ModernNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.backgroundColor = const Color(0xFF8C7E7E),
    this.activeColor = Colors.white,
    this.inactiveColor = const Color(0xFFBDB8B8),
  });

  @override
  Widget build(BuildContext context) {
    final items = _buildNavItems();
    // Use viewPadding to include system UI (gesture/navigation) insets
    final bottomInset = MediaQuery.of(context).viewPadding.bottom;

    return Container(
      height: 70 + bottomInset,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: Padding(
          padding: EdgeInsets.only(bottom: bottomInset),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(
              items.length,
              (index) => _NavBarItem(
                icon: items[index].icon,
                label: items[index].label,
                isActive: currentIndex == index,
                onTap: () => onTap(index),
                activeColor: activeColor,
                inactiveColor: inactiveColor,
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<_NavItemData> _buildNavItems() {
    return [
      _NavItemData(icon: Icons.home_rounded, label: 'Home'),
      _NavItemData(icon: Icons.list_rounded, label: 'Orders'),
      _NavItemData(icon: Icons.add_task_rounded, label: 'Add Task'),
      _NavItemData(icon: Icons.notifications_rounded, label: 'Alerts'),
      _NavItemData(icon: Icons.person_rounded, label: 'Profile'),
    ];
  }
}

class _NavItemData {
  final IconData icon;
  final String label;

  _NavItemData({required this.icon, required this.label});
}

class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final Color activeColor;
  final Color inactiveColor;

  const _NavBarItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
    required this.activeColor,
    required this.inactiveColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? Colors.white.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              transform: Matrix4.translationValues(0, isActive ? -2 : 0, 0),
              child: Icon(
                icon,
                color: isActive ? activeColor : inactiveColor,
                size: isActive ? 28 : 24,
              ),
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              style: TextStyle(
                color: isActive ? activeColor : inactiveColor,
                fontSize: isActive ? 12 : 11,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}
