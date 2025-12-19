-- Migration: Add done_at timestamp to tasks table
-- Purpose: Enable accurate task completion time tracking for manager dashboard metrics
-- Date: 2025-12-19

-- Add done_at column to tasks table
ALTER TABLE public.tasks
ADD COLUMN IF NOT EXISTS done_at timestamp without time zone;

-- Optional: Create index for performance on done_at queries
CREATE INDEX IF NOT EXISTS idx_tasks_done_at ON public.tasks(done_at);

-- Optional: Backfill done_at for existing completed tasks (use updated_at as approximation)
-- Uncomment if you want to backfill historical data:
-- UPDATE public.tasks
-- SET done_at = updated_at
-- WHERE status = 'done' AND done_at IS NULL AND updated_at IS NOT NULL;

-- Note: The Flutter app now automatically sets done_at when marking tasks as done
