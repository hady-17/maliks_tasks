import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../view/widgets/appBar.dart';
import '../../const.dart';
import '../../viewmodels/create_order_provider.dart';

class CreateOrderScreen extends StatelessWidget {
  final Map<String, dynamic>? profile;
  const CreateOrderScreen({super.key, this.profile});

  Map<String, dynamic>? _resolveProfile(BuildContext context) {
    if (profile != null) return profile;
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic>) {
      if (args.containsKey('profile')) {
        final p = args['profile'];
        if (p is Map<String, dynamic>) return p;
      }
      return args;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final p = _resolveProfile(context);
    final routeArgs = ModalRoute.of(context)?.settings.arguments;
    Map<String, dynamic>? orderArg;
    if (routeArgs is Map<String, dynamic> && routeArgs['order'] != null) {
      final o = routeArgs['order'];
      if (o is Map<String, dynamic>)
        orderArg = o;
      else if (o is Map)
        orderArg = Map<String, dynamic>.from(o);
    }

    return ChangeNotifierProvider<CreateOrderProvider>(
      create: (_) {
        final vm = CreateOrderProvider();
        vm.initFromProfile(p);
        if (orderArg != null) vm.initFromOrder(orderArg);
        return vm;
      },
      child: _CreateOrderContent(profile: p),
    );
  }
}

class _CreateOrderContent extends StatelessWidget {
  final Map<String, dynamic>? profile;
  const _CreateOrderContent({required this.profile});

  String _formatDate(DateTime d) {
    return '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      appBar: ModernAppBar(
        title: 'Create Order',
        subtitle: 'Manager Panel',
        showBackButton: true,
        backgroundColor: kMainColor,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromARGB(255, 130, 45, 59),
              Color.fromARGB(255, 252, 43, 39),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 920),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 12,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Consumer<CreateOrderProvider>(
                      builder: (context, vm, _) {
                        // Resolve route args to see if we were called for editing
                        final routeArgs = ModalRoute.of(
                          context,
                        )?.settings.arguments;
                        Map<String, dynamic>? orderArg;
                        if (routeArgs is Map<String, dynamic> &&
                            routeArgs['order'] != null) {
                          final o = routeArgs['order'];
                          if (o is Map<String, dynamic>)
                            orderArg = o;
                          else if (o is Map)
                            orderArg = Map<String, dynamic>.from(o);
                        }

                        if (orderArg != null && !vm.isEditing) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (!vm.isEditing) vm.initFromOrder(orderArg!);
                          });
                        }

                        if (profile == null)
                          return const Center(
                            child: Text('No profile provided'),
                          );

                        final _formKey = GlobalKey<FormState>();

                        return SingleChildScrollView(
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Header
                                Row(
                                  children: [
                                    Container(
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: LinearGradient(
                                          colors: [
                                            Color(0xFFEE9CA7),
                                            Color(0xFFFFDDE1),
                                          ],
                                        ),
                                      ),
                                      padding: const EdgeInsets.all(10),
                                      child: const Icon(
                                        Icons.shopping_bag_rounded,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: const [
                                        Text(
                                          'New Order',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        SizedBox(height: 2),
                                        Text(
                                          'Create and assign orders quickly',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.black54,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 18),

                                // Title
                                TextField(
                                  controller: vm.titleController,
                                  decoration: InputDecoration(
                                    labelText: 'Order title',
                                    filled: true,
                                    fillColor: Colors.grey.shade50,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),

                                // Description
                                TextField(
                                  controller: vm.descriptionController,
                                  maxLines: 3,
                                  decoration: InputDecoration(
                                    labelText: 'Description',
                                    filled: true,
                                    fillColor: Colors.grey.shade50,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 14),

                                // Row: Date
                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton.icon(
                                        onPressed: () async {
                                          final now = DateTime.now();
                                          final picked = await showDatePicker(
                                            context: context,
                                            initialDate: vm.orderedDate,
                                            firstDate: DateTime(now.year - 2),
                                            lastDate: DateTime(now.year + 2),
                                          );
                                          if (picked != null)
                                            vm.setOrderedDate(picked);
                                        },
                                        icon: const Icon(
                                          Icons.calendar_today_outlined,
                                        ),
                                        label: Text(
                                          _formatDate(vm.orderedDate),
                                        ),
                                        style: OutlinedButton.styleFrom(
                                          backgroundColor: Colors.grey.shade50,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: OutlinedButton.icon(
                                        onPressed: () async {
                                          final now = DateTime.now();
                                          final picked = await showDatePicker(
                                            context: context,
                                            initialDate: vm.dueDate ?? now,
                                            firstDate: DateTime(now.year - 2),
                                            lastDate: DateTime(now.year + 2),
                                          );
                                          if (picked != null)
                                            vm.setDueDate(picked);
                                        },
                                        icon: const Icon(
                                          Icons.calendar_today_outlined,
                                        ),
                                        label: Text(
                                          vm.dueDate == null
                                              ? 'Due date'
                                              : _formatDate(vm.dueDate!),
                                        ),
                                        style: OutlinedButton.styleFrom(
                                          backgroundColor: Colors.grey.shade50,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),

                                // Item
                                TextField(
                                  controller: vm.itemController,
                                  decoration: InputDecoration(
                                    labelText: 'Item',
                                    filled: true,
                                    fillColor: Colors.grey.shade50,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),

                                // Sections dropdown (dedupe items and ensure value exists)
                                Builder(
                                  builder: (ctx) {
                                    final profileSection =
                                        profile!['section'] as String? ?? '';
                                    final sections = List<String>.from(
                                      vm.availableSections.toSet(),
                                    );

                                    // Determine the effective selected value
                                    String? effectiveValue =
                                        vm.section ??
                                        (profileSection.isNotEmpty
                                            ? profileSection
                                            : (sections.isNotEmpty
                                                  ? sections.first
                                                  : null));

                                    // Ensure the effective value appears exactly once in the items
                                    if (effectiveValue != null &&
                                        !sections.contains(effectiveValue)) {
                                      sections.insert(0, effectiveValue);
                                    }

                                    final items = sections.isEmpty
                                        ? [
                                            DropdownMenuItem(
                                              value: profileSection,
                                              child: Text(profileSection),
                                            ),
                                          ]
                                        : sections
                                              .map(
                                                (s) => DropdownMenuItem(
                                                  value: s,
                                                  child: Text(s),
                                                ),
                                              )
                                              .toList();

                                    return DropdownButtonFormField<String>(
                                      decoration: InputDecoration(
                                        labelText: 'Section',
                                        filled: true,
                                        fillColor: Colors.grey.shade50,
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          borderSide: BorderSide.none,
                                        ),
                                      ),
                                      value: effectiveValue,
                                      items: items,
                                      onChanged: (v) => vm.setSection(v),
                                    );
                                  },
                                ),
                                const SizedBox(height: 12),

                                // Type dropdown (pickup, delivery, from_another_branch)
                                DropdownButtonFormField<String>(
                                  decoration: InputDecoration(
                                    labelText: 'Type',
                                    filled: true,
                                    fillColor: Colors.grey.shade50,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                  value: vm.type,
                                  items: const [
                                    DropdownMenuItem(
                                      value: 'pickup',
                                      child: Text('Pickup'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'delivery',
                                      child: Text('Delivery'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'from_another_branch',
                                      child: Text('From another branch'),
                                    ),
                                  ],
                                  onChanged: (v) => vm.setType(v ?? 'delivery'),
                                ),
                                const SizedBox(height: 12),

                                // Customer fields
                                TextField(
                                  controller: vm.customerNameController,
                                  decoration: InputDecoration(
                                    labelText: 'Customer name',
                                    filled: true,
                                    fillColor: Colors.grey.shade50,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextField(
                                  controller: vm.customerPhoneController,
                                  decoration: InputDecoration(
                                    labelText: 'Customer phone',
                                    filled: true,
                                    fillColor: Colors.grey.shade50,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 18),

                                // Actions
                                Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: vm.isLoading
                                            ? null
                                            : () async {
                                                // basic validation
                                                if (vm.titleController.text
                                                    .trim()
                                                    .isEmpty) {
                                                  if (context.mounted) {
                                                    ScaffoldMessenger.of(
                                                      context,
                                                    ).showSnackBar(
                                                      const SnackBar(
                                                        content: Text(
                                                          'Title is required',
                                                        ),
                                                      ),
                                                    );
                                                  }
                                                  return;
                                                }
                                                if (vm.itemController.text
                                                    .trim()
                                                    .isEmpty) {
                                                  if (context.mounted) {
                                                    ScaffoldMessenger.of(
                                                      context,
                                                    ).showSnackBar(
                                                      const SnackBar(
                                                        content: Text(
                                                          'Item is required',
                                                        ),
                                                      ),
                                                    );
                                                  }
                                                  return;
                                                }

                                                if (vm.isEditing) {
                                                  final res = await vm
                                                      .updateOrder();
                                                  if (res != null) {
                                                    if (context.mounted) {
                                                      ScaffoldMessenger.of(
                                                        context,
                                                      ).showSnackBar(
                                                        const SnackBar(
                                                          content: Text(
                                                            'Order updated',
                                                          ),
                                                        ),
                                                      );
                                                      Navigator.of(
                                                        context,
                                                      ).pop(res);
                                                    }
                                                  } else {
                                                    if (context.mounted)
                                                      ScaffoldMessenger.of(
                                                        context,
                                                      ).showSnackBar(
                                                        SnackBar(
                                                          content: Text(
                                                            vm.error ??
                                                                'Failed to update order',
                                                          ),
                                                        ),
                                                      );
                                                  }
                                                } else {
                                                  final res = await vm
                                                      .createOrder();
                                                  if (res != null) {
                                                    if (context.mounted) {
                                                      ScaffoldMessenger.of(
                                                        context,
                                                      ).showSnackBar(
                                                        const SnackBar(
                                                          content: Text(
                                                            'Order created successfully',
                                                          ),
                                                        ),
                                                      );
                                                      Navigator.of(
                                                        context,
                                                      ).pop(res);
                                                    }
                                                  } else {
                                                    if (context.mounted)
                                                      ScaffoldMessenger.of(
                                                        context,
                                                      ).showSnackBar(
                                                        SnackBar(
                                                          content: Text(
                                                            vm.error ??
                                                                'Failed to create order',
                                                          ),
                                                        ),
                                                      );
                                                  }
                                                }
                                              },
                                        style: ElevatedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 14,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          backgroundColor: Colors.red.shade700,
                                        ),
                                        child: AnimatedSwitcher(
                                          duration: const Duration(
                                            milliseconds: 250,
                                          ),
                                          child: vm.isLoading
                                              ? const SizedBox(
                                                  key: ValueKey('loading'),
                                                  height: 18,
                                                  width: 18,
                                                  child:
                                                      CircularProgressIndicator(
                                                        color: Colors.white,
                                                        strokeWidth: 2,
                                                      ),
                                                )
                                              : Text(
                                                  vm.isEditing
                                                      ? 'Update Order'
                                                      : 'Create Order',
                                                  key: const ValueKey('label'),
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                  ),
                                                ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Column(
                                      children: [
                                        OutlinedButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          style: OutlinedButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 14,
                                              horizontal: 20,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            backgroundColor: Colors.white,
                                          ),
                                          child: const Text(
                                            'Cancel',
                                            style: TextStyle(
                                              color: Colors.black87,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        // Show delete button only when editing and current user is manager
                                        if (vm.isEditing &&
                                            (profile?['role'] == 'manager'))
                                          OutlinedButton(
                                            onPressed: vm.isLoading
                                                ? null
                                                : () async {
                                                    final ok = await showDialog<bool>(
                                                      context: context,
                                                      builder: (ctx) => AlertDialog(
                                                        title: const Text(
                                                          'Delete order?',
                                                        ),
                                                        content: const Text(
                                                          'This will permanently delete the order.',
                                                        ),
                                                        actions: [
                                                          TextButton(
                                                            onPressed: () =>
                                                                Navigator.of(
                                                                  ctx,
                                                                ).pop(false),
                                                            child: const Text(
                                                              'Cancel',
                                                            ),
                                                          ),
                                                          TextButton(
                                                            onPressed: () =>
                                                                Navigator.of(
                                                                  ctx,
                                                                ).pop(true),
                                                            child: const Text(
                                                              'Delete',
                                                              style: TextStyle(
                                                                color:
                                                                    Colors.red,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                    if (ok == true) {
                                                      final deleted = await vm
                                                          .deleteOrder();
                                                      if (deleted) {
                                                        if (context.mounted)
                                                          Navigator.of(
                                                            context,
                                                          ).pop(true);
                                                      } else {
                                                        ScaffoldMessenger.of(
                                                          context,
                                                        ).showSnackBar(
                                                          SnackBar(
                                                            content: Text(
                                                              vm.error ??
                                                                  'Failed to delete',
                                                            ),
                                                          ),
                                                        );
                                                      }
                                                    }
                                                  },
                                            style: OutlinedButton.styleFrom(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 10,
                                                    horizontal: 18,
                                                  ),
                                              backgroundColor: Colors.white,
                                              side: const BorderSide(
                                                color: Colors.red,
                                              ),
                                            ),
                                            child: const Text(
                                              'Delete',
                                              style: TextStyle(
                                                color: Colors.red,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
