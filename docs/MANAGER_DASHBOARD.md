# Manager Dashboard

## Overview
The Manager Dashboard provides comprehensive team performance metrics and analytics for managers to track:
- Team member task and order completion rates
- Average completion times
- Individual member performance breakdown
- Real-time metrics with pull-to-refresh

## Features

### Key Performance Indicators (KPIs)
- **Tasks Placed**: Total tasks assigned across the team
- **Tasks Done**: Total tasks completed
- **Orders Placed**: Total orders created
- **Orders Done**: Total orders completed

### Performance Metrics
- **Average Task Completion Time**: Mean time from task creation to completion (in minutes)
- **Average Order Completion Time**: Mean time from order creation to completion (in minutes)

### Team Performance View
- Per-member breakdown showing:
  - Tasks done vs tasks placed
  - Orders done vs orders placed
  - Individual average completion times for tasks and orders
- Member names fetched from profiles table

## Technical Implementation

### Data Sources
- `tasks` table: task tracking and completion
- `orders` table: order tracking and completion
- `profiles` table: team member information

### Key Files
- `lib/view/screens/dashboardManager.dart`: Dashboard UI
- `lib/viewmodels/manager_metrics_provider.dart`: Metrics computation logic
- `database_migrations/add_done_at_to_tasks.sql`: Required database migration

### Database Requirements

#### Required Migration
Run the migration to add `done_at` timestamp to tasks table:

```sql
ALTER TABLE public.tasks
ADD COLUMN IF NOT EXISTS done_at timestamp without time zone;

CREATE INDEX IF NOT EXISTS idx_tasks_done_at ON public.tasks(done_at);
```

**Location**: `database_migrations/add_done_at_to_tasks.sql`

#### How to Apply Migration
1. Open Supabase Dashboard → SQL Editor
2. Copy the contents of `database_migrations/add_done_at_to_tasks.sql`
3. Run the SQL script
4. Verify the column exists: `SELECT done_at FROM tasks LIMIT 1;`

### Architecture

#### Provider Pattern
The dashboard uses Flutter's `Provider` for state management:
- `ManagerMetricsProvider` fetches and computes all metrics
- UI observes provider state with `context.watch<ManagerMetricsProvider>()`
- Supports pull-to-refresh for real-time updates

#### Data Flow
1. Dashboard loads → fetches branch ID from route arguments (manager profile)
2. Provider queries:
   - All members in branch from `profiles`
   - All tasks created/done by members
   - All orders created/done by members
3. Provider aggregates:
   - Counts per member (placed/done)
   - Completion durations per member
   - Global averages across team
4. UI rebuilds with computed metrics

#### Completion Time Calculation
- **Tasks**: `done_at - created_at` (requires `done_at` column)
- **Orders**: `done_at - created_at` (built-in)
- Averages computed per member, then globally

### Code Integration

#### Providers Updated
The following providers now set `done_at` when marking items as done:
- `TaskProvider.toggleTaskDone()` 
- `TaskProvider.markTaskAsDone()`
- `TaskProvider.reopenTask()`
- `ManagerTaskProvider.toggleTaskDone()`

#### Global Registration
`ManagerMetricsProvider` is registered in `main.dart`:
```dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => TaskProvider()),
    ChangeNotifierProvider(create: (_) => ManagerTaskProvider()),
    ChangeNotifierProvider(create: (_) => OrderProvider()),
    ChangeNotifierProvider(create: (_) => ManagerMetricsProvider()),
  ],
  ...
)
```

## Usage

### Navigation
Managers can access the dashboard from:
- Route: `/manager_dashboard`
- The route receives manager profile as arguments (contains `branch_id`)

### Refresh Data
Pull down on the screen to refresh metrics in real-time.

## Future Enhancements

### Planned Features
1. **Date Range Filtering**: Allow managers to view metrics for custom time periods
2. **Charts & Visualizations**: 
   - Bar charts for tasks/orders per member
   - Line charts for completion trends over time
   - Pie charts for task distribution
3. **Export Functionality**: CSV/PDF export of metrics
4. **Member Filtering**: Filter by section or individual member
5. **Drill-Down Views**: Tap member to see detailed task/order list
6. **Notifications**: Alert managers when metrics exceed thresholds

### Performance Optimizations
- Add database RPCs for server-side aggregation (reduce client-side processing)
- Implement pagination for large teams
- Add caching layer for frequently accessed metrics

## Troubleshooting

### No data showing
- Verify manager has `branch_id` in their profile
- Check that tasks/orders exist for the branch
- Ensure `done_at` migration has been applied

### Slow performance
- Add database indexes on frequently queried columns
- Consider server-side aggregation with RPCs
- Limit date ranges for queries

### Incorrect averages
- Verify `done_at` is being set when tasks/orders are marked done
- Check for null timestamps in database
- Ensure system clocks are synchronized

## Dependencies
- `fl_chart: ^1.1.1` - (Ready for future chart visualizations)
- `provider: ^6.1.5+1` - State management
- `supabase_flutter: ^2.10.3` - Database client

## Related Files
- Task model: `lib/model/task/tasks.dart`
- Order model: `lib/model/task/order.dart`
- Navigation: `lib/main.dart` (route definition)
