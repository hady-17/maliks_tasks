# Manager Dashboard - MVVM Architecture

## Clean Code & MVVM Pattern Implementation

### Architecture Overview

```
┌─────────────────────────────────────────────────────────┐
│                      View Layer                         │
│  (dashboardManager.dart + widget components)            │
│  - Presentational logic only                            │
│  - No business logic                                    │
│  - Observes ViewModel state                             │
└──────────────────┬──────────────────────────────────────┘
                   │
                   │ (Provider)
                   ↓
┌─────────────────────────────────────────────────────────┐
│                   ViewModel Layer                       │
│         (manager_metrics_provider.dart)                 │
│  - Business logic & state management                    │
│  - Data aggregation & computation                       │
│  - Exposes state to View via ChangeNotifier             │
└──────────────────┬──────────────────────────────────────┘
                   │
                   │ (Supabase Client)
                   ↓
┌─────────────────────────────────────────────────────────┐
│                    Model Layer                          │
│  (MemberMetric, OverallKpis)                            │
│  - Pure data models                                     │
│  - No business logic                                    │
│  - Immutable where possible                             │
└─────────────────────────────────────────────────────────┘
```

## File Structure

```
lib/
├── view/
│   ├── screens/
│   │   └── dashboardManager.dart          # Main screen (View)
│   └── widgets/
│       ├── appBar.dart
│       ├── navBar.dart
│       └── dashboard/                     # Optional: modular widgets
│           ├── date_range_selector.dart
│           ├── kpi_cards.dart
│           ├── performance_chart.dart
│           ├── performance_table.dart
│           └── dashboard_states.dart
├── viewmodels/
│   └── manager_metrics_provider.dart      # ViewModel
└── model/
    └── (MemberMetric defined in provider) # Model
```

## MVVM Principles Applied

### 1. Separation of Concerns

**View (dashboardManager.dart)**
- ✅ Only handles UI rendering
- ✅ Reacts to state changes
- ✅ Delegates user actions to ViewModel
- ✅ No direct database/API calls
- ✅ No business logic

**ViewModel (manager_metrics_provider.dart)**
- ✅ Manages application state
- ✅ Contains all business logic
- ✅ Fetches and processes data
- ✅ Exposes reactive state via ChangeNotifier
- ✅ No UI code

**Model (MemberMetric)**
- ✅ Pure data structures
- ✅ No business logic
- ✅ Computed properties for derived values

### 2. Single Responsibility Principle

Each widget has one clear purpose:

- `ManagerDashboardScreen` → Main container & navigation
- `_DashboardBody` → State-based rendering (loading/error/content)
- `_DashboardContent` → Layout & composition
- `_LoadingState` → Loading UI
- `_ErrorState` → Error UI with retry
- `_EmptyState` → Empty state UI
- `_DateRangeSelector` → Date range picker
- `_MetricTypeSelector` → Toggle tasks/orders
- `_KpiGrid` → KPI cards layout
- `_AverageCompletionRow` → Average times display
- `_PerformanceChart` → Performance visualization
- `_PerformanceTable` → Detailed metrics table

### 3. Dependency Injection

```dart
// Provider registered globally in main.dart
ChangeNotifierProvider(create: (_) => ManagerMetricsProvider())

// View accesses ViewModel via Provider
final metrics = context.watch<ManagerMetricsProvider>();
// OR
final provider = context.read<ManagerMetricsProvider>();
```

### 4. Unidirectional Data Flow

```
User Action → View → ViewModel → Model → Database
                ↑                  ↓
                └──── State Update ←
```

Example:
1. User taps "Change Date Range"
2. View calls `_pickDateRange()`
3. View updates local state, calls `_loadMetrics()`
4. ViewModel fetches data from database
5. ViewModel updates state via `notifyListeners()`
6. View rebuilds with new data

### 5. State Management

**View State (Local)**
```dart
DateTimeRange _dateRange  // UI-specific state
bool _showTasks           // UI toggle state
```

**Application State (ViewModel)**
```dart
bool isLoading            // Loading indicator
String? error             // Error message
List<MemberMetric> memberMetrics  // Data
int totalTasksPlaced      // Computed metrics
```

### 6. Clean Code Practices

#### Naming Conventions
- Classes: `PascalCase`
- Private classes: `_PascalCase`
- Methods: `camelCase`
- Private methods: `_camelCase`
- Constants: `SCREAMING_SNAKE_CASE`

#### Widget Organization
```dart
// Public widgets (exposed)
class ManagerDashboardScreen extends StatefulWidget

// Private widgets (internal use only)
class _DashboardBody extends StatelessWidget
class _LoadingState extends StatelessWidget
```

#### Method Extraction
```dart
// Before (inline logic)
Text('${_dateRange.start.toString().split(' ').first} → ${_dateRange.end.toString().split(' ').first}')

// After (extracted helper)
String _formatDateRange() {
  final start = dateRange.start.toString().split(' ').first;
  final end = dateRange.end.toString().split(' ').first;
  return '$start → $end';
}
```

#### Immutability
```dart
// Widgets are immutable
class _DateRangeSelector extends StatelessWidget {
  final DateTimeRange dateRange;  // final fields
  final VoidCallback onPressed;
  
  const _DateRangeSelector({
    required this.dateRange,
    required this.onPressed,
  });
}
```

### 7. Testability

Each layer can be tested independently:

**ViewModel Tests**
```dart
test('loadMetrics fetches and aggregates data', () async {
  final provider = ManagerMetricsProvider();
  await provider.loadMetrics(branchId: 'test-branch');
  expect(provider.isLoading, false);
  expect(provider.memberMetrics, isNotEmpty);
});
```

**Widget Tests**
```dart
testWidgets('shows loading state initially', (tester) async {
  await tester.pumpWidget(ManagerDashboardScreen());
  expect(find.byType(CircularProgressIndicator), findsOneWidget);
});
```

## Benefits of This Architecture

### Maintainability
- Clear separation makes it easy to locate and modify code
- Changes to UI don't affect business logic and vice versa
- Each component has a single, well-defined responsibility

### Scalability
- Easy to add new metrics or visualizations
- ViewModel can be reused across different views
- Widgets can be extracted and reused

### Testability
- Each layer can be tested independently
- Mock providers for widget tests
- Test business logic without UI

### Readability
- Self-documenting code structure
- Clear data flow
- Consistent naming conventions

### Reusability
- Widgets can be extracted to shared library
- ViewModel logic is view-agnostic
- Models are pure data structures

## Code Quality Metrics

✅ **Single Responsibility**: Each class/method has one purpose
✅ **DRY (Don't Repeat Yourself)**: Extracted common UI patterns
✅ **KISS (Keep It Simple)**: Simple, focused components
✅ **SOLID Principles**: Followed throughout
✅ **Immutability**: Widgets and data structures are immutable
✅ **Type Safety**: Strong typing with Dart's type system
✅ **Error Handling**: Proper error states and retry mechanisms
✅ **Performance**: Efficient widget rebuilds with Provider

## Future Improvements

### Potential Enhancements
1. **Extract Widgets**: Move dashboard widgets to separate files
2. **Add Use Cases**: Create interactor layer for complex operations
3. **Implement Repository**: Abstract data access layer
4. **Add Caching**: Cache metrics for offline support
5. **Unit Tests**: Add comprehensive test coverage
6. **Integration Tests**: Test full user flows
7. **Documentation**: Add inline documentation
8. **Accessibility**: Add semantic labels and screen reader support

### Advanced Patterns
- **Riverpod**: Consider migrating to Riverpod for better DI
- **Freezed**: Use freezed for immutable models
- **GetIt**: Service locator for complex dependencies
- **BLoC**: Alternative state management for complex flows
