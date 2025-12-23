import 'package:flutter/material.dart';

class ModernAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final bool showBackButton;
  final bool showNotifications;
  final bool showDashboardButton;
  final VoidCallback? onDashboard;
  final bool hasNotifications;
  final Color backgroundColor;
  final bool isManager;

  const ModernAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.showBackButton = false,
    this.showNotifications = false,
    this.showDashboardButton = false,
    this.onDashboard,
    this.hasNotifications = false,
    this.backgroundColor = const Color(0xFF8C7E7E), // default color
    this.isManager = false,
  });

  @override
  Size get preferredSize => const Size.fromHeight(72);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: backgroundColor,
      centerTitle: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      leading: showBackButton
          ? IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              color: Colors.black87,
              onPressed: () => Navigator.pop(context),
            )
          : null,
      titleSpacing: showBackButton ? 0 : 16,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (subtitle != null)
            Text(
              subtitle!,
              style: TextStyle(color: Colors.grey[200], fontSize: 13),
            ),
        ],
      ),
      actions: [
        if (showDashboardButton)
          IconButton(
            onPressed:
                onDashboard ??
                () {
                  print('dashboard button pressed');
                },
            icon: const Icon(Icons.dashboard_rounded),
            color: Colors.white,
          ),
        if (showNotifications)
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                IconButton(
                  onPressed: () {
                    // TODO: Navigate to notifications screen
                    print('Notifications button pressed');
                  },
                  icon: const Icon(Icons.notifications_none_rounded),
                  color: Colors.black87,
                ),

                // 🔴 red badge bubble
                if (hasNotifications)
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      height: 10,
                      width: 10,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: GestureDetector(
            onTap: () {
              if (isManager) {
                Navigator.pushNamed(context, '/account_approvel');
                return;
              }
              // TODO: profile screen for non-manager users
              print('Profile avatar tapped');
            },
            child: CircleAvatar(
              radius: 18,
              backgroundColor: Colors.grey[200],
              child: Icon(
                isManager ? Icons.manage_accounts_rounded : Icons.person,
                color: Colors.black54,
              ),
            ),
          ),
        ),
      ],
      shadowColor: Colors.black.withOpacity(0.05),
    );
  }
}
