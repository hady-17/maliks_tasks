import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maliks_tasks/view/screens/create_task.dart';

void main() {
  testWidgets('CreateTaskPage prefills assignee, assigned-to, and priority', (
    tester,
  ) async {
    final profile = {
      'id': '00000000-0000-0000-0000-000000000001',
      'branch_id': '11111111-1111-1111-1111-111111111111',
      'section': 'Engineering',
      'shift': 'day',
      'role': 'member', // Test as team member (not manager)
    };

    await tester.pumpWidget(
      MaterialApp(
        routes: {'/create_task': (c) => const CreateTask()},
        home: Builder(
          builder: (context) {
            return Center(
              child: ElevatedButton(
                onPressed: () => Navigator.pushNamed(
                  context,
                  '/create_task',
                  arguments: profile,
                ),
                child: const Text('open'),
              ),
            );
          },
        ),
      ),
    );

    // Open the create page
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    // Find the assignee field and ensure it's prefilled and disabled
    final assigneeFinder = find.widgetWithText(
      TextFormField,
      'Assignee (Creator)',
    );
    expect(assigneeFinder, findsOneWidget);
    final assigneeWidget = tester.widget<TextFormField>(assigneeFinder);
    expect(assigneeWidget.controller?.text, equals(profile['id']));
    expect(assigneeWidget.enabled, isFalse); // Should be read-only

    // Find the assigned-to field and ensure it's prefilled with same email
    final assignedToFinder = find.byKey(const Key('assignedToField'));
    expect(assignedToFinder, findsOneWidget);
    final assignedToWidget = tester.widget<TextFormField>(assignedToFinder);
    expect(assignedToWidget.controller?.text, equals(profile['id']));
    expect(
      assignedToWidget.enabled,
      isFalse,
    ); // Should be disabled for team member

    // Find the priority dropdown and ensure default is 'normal'
    final priorityFinder = find.byKey(const Key('priorityDropdown'));
    expect(priorityFinder, findsOneWidget);
    final dropdownWidget = tester.widget<DropdownButton<String>>(
      priorityFinder,
    );
    expect(dropdownWidget.value, equals('normal'));
  });

  testWidgets('Manager can edit assigned-to, section, and branch', (
    tester,
  ) async {
    final profile = {
      'id': '00000000-0000-0000-0000-000000000001',
      'email': 'manager@example.com',
      'branch_id': '11111111-1111-1111-1111-111111111111',
      'section': 'Management',
      'shift': 'both',
      'role': 'manager', // Test as manager
    };

    await tester.pumpWidget(
      MaterialApp(
        routes: {'/create_task': (c) => const CreateTask()},
        home: Builder(
          builder: (context) {
            return Center(
              child: ElevatedButton(
                onPressed: () => Navigator.pushNamed(
                  context,
                  '/create_task',
                  arguments: profile,
                ),
                child: const Text('open'),
              ),
            );
          },
        ),
      ),
    );

    // Open the create page
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    // Assigned-to field should be enabled for manager
    final assignedToFinder = find.byKey(const Key('assignedToField'));
    final assignedToWidget = tester.widget<TextFormField>(assignedToFinder);
    expect(assignedToWidget.enabled, isTrue); // Manager can change

    // Branch ID field should be enabled for manager
    final branchFinder = find.widgetWithText(TextFormField, 'Branch ID');
    expect(branchFinder, findsOneWidget);
    final branchWidget = tester.widget<TextFormField>(branchFinder);
    expect(branchWidget.enabled, isTrue);

    // Assigned Section field should be enabled for manager
    final sectionFinder = find.widgetWithText(
      TextFormField,
      'Assigned Section',
    );
    expect(sectionFinder, findsOneWidget);
    final sectionWidget = tester.widget<TextFormField>(sectionFinder);
    expect(sectionWidget.enabled, isTrue);
  });
}
