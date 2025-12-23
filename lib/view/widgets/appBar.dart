import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ModernAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final bool showBackButton;
  final bool showNotifications;
  final bool showDashboardButton;
  final VoidCallback? onDashboard;
  final bool hasNotifications;
  final Color backgroundColor;
  final bool isManager;
  final int pendingApprovals;

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
    this.pendingApprovals = 0,
  });

  @override
  Size get preferredSize => const Size.fromHeight(72);

  @override
  State<ModernAppBar> createState() => _ModernAppBarState();
}

class _ModernAppBarState extends State<ModernAppBar> {
  int _pending = 0;
  StreamSubscription<List<Map<String, dynamic>>>? _sub;

  @override
  void initState() {
    super.initState();
    _pending = widget.pendingApprovals;
    if (widget.isManager && _pending == 0) {
      _loadPendingApprovals();
    }
    // also subscribe will be started by _loadPendingApprovals when branchId known
  }

  Future<void> _loadPendingApprovals() async {
    try {
      final supabase = Supabase.instance.client;
      final uid = supabase.auth.currentUser?.id;
      if (uid == null) return;

      final profile = await supabase
          .from('profiles')
          .select()
          .eq('id', uid)
          .maybeSingle();
      final branchId = profile == null ? null : profile['branch_id'] as String?;
      if (branchId == null) return;

      final res = await supabase
          .from('profiles')
          .select('id')
          .eq('branch_id', branchId)
          .eq('active', false);

      final list = res as List<dynamic>? ?? [];
      if (mounted) setState(() => _pending = list.length);
      // subscribe for live updates
      _subscribeToBranch(branchId);
    } catch (e) {
      // ignore fetch errors for badge
    }
  }

  void _subscribeToBranch(String branchId) {
    // cancel any existing
    _sub?.cancel();

    final stream = Supabase.instance.client
        .from('profiles')
        .stream(primaryKey: ['id'])
        .eq('branch_id', branchId)
        .order('full_name');

    _sub = stream.listen((List<Map<String, dynamic>> data) {
      final pending = data.where((e) => e['active'] == false).length;
      if (mounted) setState(() => _pending = pending);
    }, onError: (_) {
      // ignore
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: widget.backgroundColor,
      centerTitle: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      leading: widget.showBackButton
          ? IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              color: Colors.black87,
              onPressed: () => Navigator.pop(context),
            )
          : null,
      titleSpacing: widget.showBackButton ? 0 : 16,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.title,
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (widget.subtitle != null)
            Text(
              widget.subtitle!,
              style: TextStyle(color: Colors.grey[200], fontSize: 13),
            ),
        ],
      ),
      actions: [
        if (widget.showDashboardButton)
          IconButton(
            onPressed:
                widget.onDashboard ??
                () {
                  print('dashboard button pressed');
                },
            icon: const Icon(Icons.dashboard_rounded),
            color: Colors.white,
          ),
        if (widget.showNotifications)
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
                if (widget.hasNotifications)
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
              if (widget.isManager) {
                Navigator.pushNamed(context, '/account_approvel');
                return;
              }
              // TODO: profile screen for non-manager users
              print('Profile avatar tapped');
            },
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.grey[200],
                  child: Icon(
                    widget.isManager
                        ? Icons.manage_accounts_rounded
                        : Icons.person,
                    color: Colors.black54,
                  ),
                ),
                if (_pending > 0)
                  Positioned(
                    top: -2,
                    right: -2,
                    child: Container(
                      height: 12,
                      width: 12,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
      shadowColor: Colors.black.withOpacity(0.05),
    );
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
