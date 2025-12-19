# Manager Dashboard - Quick Setup Guide

## 🎯 What's Been Implemented

A complete Manager Dashboard showing:
- ✅ Team member performance metrics (tasks & orders placed/done)
- ✅ Average completion times for tasks and orders
- ✅ Per-member breakdown with individual stats
- ✅ Real-time data with pull-to-refresh
- ✅ Professional UI with KPI cards

## 🚀 Setup Steps

### 1. Database Migration (REQUIRED)
Run this SQL in your Supabase SQL Editor:

```sql
-- Add done_at column to tasks table
ALTER TABLE public.tasks
ADD COLUMN IF NOT EXISTS done_at timestamp without time zone;

-- Create index for performance
CREATE INDEX IF NOT EXISTS idx_tasks_done_at ON public.tasks(done_at);
```

**File**: `database_migrations/add_done_at_to_tasks.sql`

### 2. Verify Installation
All code changes are complete:
- ✅ `ManagerMetricsProvider` registered in `main.dart`
- ✅ Dashboard UI in `lib/view/screens/dashboardManager.dart`
- ✅ Metrics logic in `lib/viewmodels/manager_metrics_provider.dart`
- ✅ Task/Order providers updated to set `done_at` timestamps

### 3. Test the Dashboard

```powershell
# Run the app
flutter run
```

1. Sign in as a **manager** user
2. Navigate to Manager Dashboard (route: `/manager_dashboard`)
3. Pull down to refresh metrics
4. View team performance breakdown

## 📊 What You'll See

### Top Section - KPI Grid
- Tasks Placed
- Tasks Done
- Orders Placed
- Orders Done

### Middle Section - Averages
- Average Task Completion Time (minutes)
- Average Order Completion Time (minutes)

### Bottom Section - Team Performance List
For each team member:
- Name
- Tasks: done/placed
- Orders: done/placed
- Individual average completion times

## 🔧 How It Works

### Data Flow
1. Dashboard loads with manager's `branch_id` from profile
2. Provider fetches all members in branch
3. Provider queries tasks/orders and computes:
   - Counts per member
   - Completion durations per member
   - Global team averages
4. UI displays aggregated metrics

### Completion Time Calculation
- **Tasks**: `done_at - created_at`
- **Orders**: `done_at - created_at`
- Only counted when both timestamps exist

### Automatic Timestamp Recording
When tasks/orders are marked as done:
- `TaskProvider.toggleTaskDone()` → sets `done_at = now()`
- `TaskProvider.markTaskAsDone()` → sets `done_at = now()`
- `ManagerTaskProvider.toggleTaskDone()` → sets `done_at = now()`
- `OrderProvider.toggleOrderStatus()` → sets `done_at = now()`

## 📝 Next Steps (Optional Enhancements)

### Add Charts (fl_chart is already installed)
Replace the member list with:
- Bar charts for placed vs done comparison
- Line charts for trend over time
- Pie charts for distribution

### Add Filters
- Date range picker (last 7 days, last 30 days, custom)
- Filter by section
- Filter by individual member

### Export Features
- CSV export of metrics
- PDF report generation
- Share functionality

### Real-time Updates
- Use Supabase realtime subscriptions
- Auto-refresh on data changes

## 🐛 Troubleshooting

**No data showing?**
- Check that manager has `branch_id` in profile
- Verify tasks/orders exist for the branch
- Run the migration if not done

**Wrong averages?**
- Ensure migration was applied
- Check existing tasks have `done_at` when status='done'
- Backfill historical data (see migration file comments)

**Performance issues?**
- Add indexes (included in migration)
- Consider date range filtering
- For large teams, use DB-side RPCs

## 📚 Documentation

Full documentation: `docs/MANAGER_DASHBOARD.md`

Migration file: `database_migrations/add_done_at_to_tasks.sql`

## ✨ Features Summary

| Feature | Status | Location |
|---------|--------|----------|
| KPI Cards | ✅ Done | dashboardManager.dart |
| Avg Completion Times | ✅ Done | manager_metrics_provider.dart |
| Member Performance List | ✅ Done | dashboardManager.dart |
| Pull-to-Refresh | ✅ Done | dashboardManager.dart |
| Error Handling | ✅ Done | manager_metrics_provider.dart |
| done_at Timestamps | ✅ Done | task_provider.dart, managerProvider.dart |
| Database Migration | ✅ Ready | database_migrations/ |
| Documentation | ✅ Done | docs/MANAGER_DASHBOARD.md |

## 🎉 Ready to Use!

Run the migration, then launch the app. The dashboard will display team metrics automatically when accessed by a manager user.
