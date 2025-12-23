import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:maliks_tasks/view/widgets/appBar.dart';
import 'package:maliks_tasks/view/widgets/navBar.dart';
import 'package:maliks_tasks/view/widgets/orderCard.dart';
import 'package:maliks_tasks/view/widgets/filter_popup.dart';
import 'package:maliks_tasks/view/widgets/order_filter.dart';
import '../../model/task/order.dart';
import '../../viewmodels/order_provider.dart';
import 'package:calendar_timeline/calendar_timeline.dart';
import '../../const.dart';

class Orderscreen extends StatefulWidget {
  final Map<String, dynamic>? profile;
  const Orderscreen({super.key, this.profile});

  @override
  State<Orderscreen> createState() => _OrderscreenState();
}

class _OrderscreenState extends State<Orderscreen> {
  final int _currentIndex = 1;
  Map<String, dynamic>? _filters;
  DateTime _selectedDate = DateTime.now();
  // local in-flight tracking removed; use provider's in-flight state

  Map<String, dynamic>? _resolveProfile(BuildContext context) {
    if (widget.profile != null) return widget.profile;
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic>) return args;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final p = _resolveProfile(context);
    final _isManager = (p != null && (p['role'] as String?) == 'manager');

    print('Profile in OrderScreen: $p');

    if (p == null) {
      return const Scaffold(body: Center(child: Text('No profile provided')));
    }

    final orderProvider = Provider.of<OrderProvider>(context);
    final role = (p['role'] as String?) ?? 'member';

    // Set default filters according to role: members see only their orders,
    // managers default to seeing all branch orders.
    _filters ??= {
      'status': 'both',
      'types': ['pickup', 'delivery', 'from_another_branch'],
      'scope': role == 'member' ? 'yours' : 'all',
    };
    // Compute bottom inset and nav bar height so we can pad the list
    final bottomInset = MediaQuery.of(context).viewPadding.bottom;
    final navBarHeight = 70.0 + bottomInset;
    final topInset = MediaQuery.of(context).viewPadding.top;

    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: ModernAppBar(
        isManager: _isManager,
        title: 'Orders',
        subtitle: 'All your orders at a glance',
        showBackButton: false,
        showDashboardButton: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFEDEDED), Color.fromARGB(255, 216, 42, 42)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: EdgeInsets.fromLTRB(16, topInset + 85, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Today\'s Orders',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    const Text(
                      'Filter orders',
                      style: TextStyle(color: Colors.black),
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      onPressed: () async {
                        // show order filter dialog
                        Map<String, dynamic> selected = _filters != null
                            ? Map<String, dynamic>.from(_filters!)
                            : {
                                'status': 'both',
                                'types': [
                                  'pickup',
                                  'delivery',
                                  'from_another_branch',
                                ],
                                'scope': 'all',
                              };

                        await showDialog<void>(
                          context: context,
                          builder: (ctx) {
                            return FilterPopup(
                              child: OrderFilter(
                                initialStatus: selected['status'] ?? 'both',
                                initialTypes: Set<String>.from(
                                  selected['types'] ??
                                      [
                                        'pickup',
                                        'delivery',
                                        'from_another_branch',
                                      ],
                                ),
                                initialScope: selected['scope'] ?? 'all',
                                availableSections:
                                    (p['branch_sections'] is List)
                                    ? List<String>.from(p['branch_sections'])
                                    : null,
                                disableScope: role == 'member',
                                onChanged: (m) {
                                  selected = m;
                                },
                              ),
                              onApply: () {
                                setState(() {
                                  _filters = selected;
                                });
                              },
                            );
                          },
                        );
                      },
                      icon: const Icon(
                        Icons.filter_list_alt,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            CalendarTimeline(
              initialDate: _selectedDate,
              firstDate: DateTime.now().subtract(const Duration(days: 30)),
              lastDate: DateTime.now().add(const Duration(days: 30)),
              onDateSelected: (date) {
                setState(() {
                  _selectedDate = date;
                });
              },
              leftMargin: 20,
              monthColor: Colors.black,
              dayColor: Colors.black,
              activeDayColor: Colors.white,
              activeBackgroundDayColor: Color(0xFF8C7E7E),
              dotColor: Colors.red,
              showYears: false,
            ),
            const SizedBox(height: 16),
            // Expanded ensures the StreamBuilder and its ListView get a bounded height
            Expanded(
              child: StreamBuilder<List<Order>>(
                stream: orderProvider.watchTodayOrders(
                  branchId: p['branch_id'],
                  // If scope is 'all' we should not restrict by the user's section;
                  // pass empty section to request all branch orders.
                  section: (_filters?['scope'] ?? 'all') == 'all'
                      ? ''
                      : (p['section'] ?? ''),
                  userId: p['id'],
                  orderDate: _selectedDate.toIso8601String().split('T').first,
                  status: _filters?['status'] ?? 'both',
                  types: _filters != null
                      ? List<String>.from(_filters!['types'] ?? [])
                      : null,
                  scope: _filters?['scope'] ?? 'all',
                ),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  final orders = snapshot.data ?? [];

                  if (orders.isEmpty) {
                    return const Center(child: Text('No orders for today'));
                  }

                  return ListView.builder(
                    padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + navBarHeight),
                    itemCount: orders.length,
                    itemBuilder: (context, index) {
                      final order = orders[index];

                      return OrderCard(
                        order: order,
                        isCompletedOverride: null,
                        isLoading: orderProvider.isToggling(order.id),
                        onComplete: () async {
                          final id = order.id;
                          try {
                            await orderProvider.toggleOrderStatus(id);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Order status updated'),
                                ),
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Failed to update status: $e'),
                                ),
                              );
                            }
                          }
                        },

                        onEdit: () async {
                          final order = orders[index];
                          // Permission: managers can edit any order in their branch
                          // members can edit their own orders or orders in their section
                          final role = p['role'] as String? ?? 'member';
                          final userId = p['id'] as String?;
                          final section = p['section'] as String?;

                          final allowed =
                              (role == 'manager' &&
                                  order.branchId ==
                                      (p['branch_id'] as String?)) ||
                              (order.createdUserId == userId) ||
                              (section != null &&
                                  section.isNotEmpty &&
                                  order.section == section);

                          if (!allowed) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'You are not allowed to edit this order',
                                  ),
                                ),
                              );
                            }
                            return;
                          }

                          final res = await Navigator.pushNamed(
                            context,
                            '/create_order',
                            arguments: {'profile': p, 'order': order.toJson()},
                          );

                          if (res != null) {
                            // show success message
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Order updated')),
                              );
                            }
                          }
                        },
                        onTap: () {
                          // TODO: Implement order details navigation
                          print('View order details: ${orders[index].id}');
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: ModernNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index == 0) {
            if (p['role'] == 'member') {
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/home',
                (route) => false,
                arguments: p,
              );
              return;
            }
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/manager_home',
              (route) => false,
              arguments: p,
            );
          } else if (index == 2) {
            if (p!['role'] == 'member') {
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/create_task',
                (route) => false,
                arguments: p,
              );
              return;
            }
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/manager_create_task',
              (route) => false,
              arguments: p,
            );
          } else if (index == 3) {
            print('pressed on $index');
          } else if (index == 4) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/profile',
              (route) => false,
              arguments: p,
            );
          } else {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/orders',
              (route) => false,
              arguments: p,
            );
          }
        },
        backgroundColor: const Color(0xFF8C7E7E),
        activeColor: Colors.white,
        inactiveColor: const Color(0xFFBDB8B8),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/create_order', arguments: p);
        },
        backgroundColor: kMainColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
