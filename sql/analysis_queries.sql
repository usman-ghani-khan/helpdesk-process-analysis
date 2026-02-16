-- ============================================================================
-- HELPDESK PROCESS BOTTLENECK ANALYSIS - SQL QUERIES
-- Purpose: Identify process slowdowns and calculate improvement opportunities
-- Database: PostgreSQL
-- Author: Usman Ghani Khan
-- ============================================================================

-- ============================================================================
-- QUERY 1: Calculate cycle time between consecutive process stages
-- Uses window functions (LEAD) to find time between events
-- ============================================================================

WITH stage_transitions AS (
    SELECT 
        case_id,
        activity AS from_stage,
        LEAD(activity) OVER (PARTITION BY case_id ORDER BY timestamp) AS to_stage,
        timestamp AS start_time,
        LEAD(timestamp) OVER (PARTITION BY case_id ORDER BY timestamp) AS end_time,
        priority,
        category,
        agent
    FROM helpdesk_events
)
SELECT 
    from_stage,
    to_stage,
    ROUND(AVG(EXTRACT(EPOCH FROM (end_time - start_time)) / 3600)::numeric, 2) AS avg_hours,
    ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY EXTRACT(EPOCH FROM (end_time - start_time)) / 3600)::numeric, 2) AS median_hours,
    ROUND(STDDEV(EXTRACT(EPOCH FROM (end_time - start_time)) / 3600)::numeric, 2) AS std_hours,
    COUNT(*) AS ticket_count
FROM stage_transitions
WHERE to_stage IS NOT NULL
GROUP BY from_stage, to_stage
ORDER BY avg_hours DESC;

-- Expected Output: Shows which stage transitions take the most time
-- Business Value: Identifies where tickets get stuck in the workflow


-- ============================================================================
-- QUERY 2: Identify bottleneck stages (critical, high, moderate severity)
-- Flags stages with >20 hour average wait time as bottlenecks
-- ============================================================================

WITH stage_durations AS (
    SELECT 
        case_id,
        activity AS from_stage,
        LEAD(timestamp) OVER (PARTITION BY case_id ORDER BY timestamp) - timestamp AS duration,
        priority,
        category
    FROM helpdesk_events
)
SELECT 
    from_stage,
    ROUND(AVG(EXTRACT(EPOCH FROM duration) / 3600)::numeric, 2) AS avg_wait_hours,
    ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY EXTRACT(EPOCH FROM duration) / 3600)::numeric, 2) AS median_hours,
    COUNT(*) AS affected_tickets,
    CASE 
        WHEN AVG(EXTRACT(EPOCH FROM duration) / 3600) > 40 THEN 'CRITICAL'
        WHEN AVG(EXTRACT(EPOCH FROM duration) / 3600) > 20 THEN 'HIGH'
        WHEN AVG(EXTRACT(EPOCH FROM duration) / 3600) > 10 THEN 'MODERATE'
        ELSE 'NORMAL'
    END AS severity_level
FROM stage_durations
WHERE duration IS NOT NULL
GROUP BY from_stage
HAVING AVG(EXTRACT(EPOCH FROM duration) / 3600) > 5  -- Only stages with >5 hour average
ORDER BY avg_wait_hours DESC;

-- Expected Output: Ranked list of bottleneck stages with severity flags
-- Business Value: Prioritizes which bottlenecks to address first


-- ============================================================================
-- QUERY 3: Segment bottleneck performance by priority level
-- Shows if high-priority tickets are actually getting faster treatment
-- ============================================================================

WITH stage_durations AS (
    SELECT 
        case_id,
        activity AS from_stage,
        EXTRACT(EPOCH FROM (LEAD(timestamp) OVER (PARTITION BY case_id ORDER BY timestamp) - timestamp)) / 3600 AS duration_hours,
        priority
    FROM helpdesk_events
)
SELECT 
    from_stage,
    priority,
    ROUND(AVG(duration_hours)::numeric, 2) AS avg_hours,
    COUNT(*) AS ticket_count
FROM stage_durations
WHERE duration_hours IS NOT NULL
  AND from_stage IN ('Investigation Started', 'Solution Implemented')  -- Focus on top 2 bottlenecks
GROUP BY from_stage, priority
ORDER BY from_stage, avg_hours DESC;

-- Expected Output: Shows wait times by priority for critical stages
-- Business Value: Reveals if priority-based SLAs are working


-- ============================================================================
-- QUERY 4: Calculate total resolution time by category and priority
-- End-to-end ticket lifecycle analysis
-- ============================================================================

WITH ticket_lifecycle AS (
    SELECT 
        case_id,
        MIN(timestamp) AS ticket_created,
        MAX(timestamp) AS ticket_closed,
        MAX(priority) AS priority,  -- Using MAX to pick one value per case
        MAX(category) AS category
    FROM helpdesk_events
    GROUP BY case_id
)
SELECT 
    category,
    priority,
    ROUND(AVG(EXTRACT(EPOCH FROM (ticket_closed - ticket_created)) / 3600)::numeric, 2) AS avg_resolution_hours,
    ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY EXTRACT(EPOCH FROM (ticket_closed - ticket_created)) / 3600)::numeric, 2) AS median_hours,
    COUNT(*) AS ticket_count
FROM ticket_lifecycle
GROUP BY category, priority
ORDER BY avg_resolution_hours DESC;

-- Expected Output: Average resolution time by ticket type and priority
-- Business Value: Identifies which ticket types need more resources


-- ============================================================================
-- QUERY 5: Agent performance analysis (workload and efficiency)
-- Identifies high-performing agents and workload imbalances
-- ============================================================================

WITH agent_tickets AS (
    SELECT 
        agent,
        case_id,
        MIN(timestamp) AS first_touch,
        MAX(timestamp) AS last_touch
    FROM helpdesk_events
    WHERE agent IS NOT NULL
    GROUP BY agent, case_id
)
SELECT 
    agent,
    COUNT(DISTINCT case_id) AS tickets_handled,
    ROUND(AVG(EXTRACT(EPOCH FROM (last_touch - first_touch)) / 3600)::numeric, 2) AS avg_handling_time_hours,
    ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY EXTRACT(EPOCH FROM (last_touch - first_touch)) / 3600)::numeric, 2) AS median_handling_hours
FROM agent_tickets
GROUP BY agent
HAVING COUNT(DISTINCT case_id) >= 10  -- Only agents with significant volume
ORDER BY tickets_handled DESC;

-- Expected Output: Agent workload and efficiency metrics
-- Business Value: Helps balance workload and identify top performers


-- ============================================================================
-- QUERY 6: Customer interaction bottleneck analysis
-- Identifies how many tickets require customer input and the wait time
-- ============================================================================

WITH customer_waits AS (
    SELECT 
        case_id,
        activity,
        timestamp,
        LEAD(timestamp) OVER (PARTITION BY case_id ORDER BY timestamp) AS next_timestamp,
        EXTRACT(EPOCH FROM (LEAD(timestamp) OVER (PARTITION BY case_id ORDER BY timestamp) - timestamp)) / 3600 AS wait_hours
    FROM helpdesk_events
    WHERE activity = 'Awaiting Customer Response'
)
SELECT 
    COUNT(DISTINCT case_id) AS tickets_requiring_customer_input,
    ROUND(AVG(wait_hours)::numeric, 2) AS avg_customer_wait_hours,
    ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY wait_hours)::numeric, 2) AS median_wait_hours,
    ROUND((COUNT(DISTINCT case_id)::numeric / (SELECT COUNT(DISTINCT case_id) FROM helpdesk_events) * 100), 2) AS pct_tickets_requiring_input
FROM customer_waits
WHERE wait_hours IS NOT NULL;

-- Expected Output: Volume and duration of customer-dependent delays
-- Business Value: Quantifies impact of customer responsiveness on resolution time


-- ============================================================================
-- QUERY 7: Business impact calculation - projected savings from improvements
-- Calculates ROI if top bottlenecks are reduced by 30%
-- ============================================================================

WITH bottleneck_summary AS (
    -- Get top 2 bottleneck stages
    SELECT 
        from_stage,
        ROUND(AVG(EXTRACT(EPOCH FROM duration) / 3600)::numeric, 2) AS avg_hours
    FROM (
        SELECT 
            activity AS from_stage,
            LEAD(timestamp) OVER (PARTITION BY case_id ORDER BY timestamp) - timestamp AS duration
        FROM helpdesk_events
    ) stage_times
    WHERE duration IS NOT NULL
    GROUP BY from_stage
    ORDER BY AVG(EXTRACT(EPOCH FROM duration) / 3600) DESC
    LIMIT 2
),
ticket_counts AS (
    SELECT COUNT(DISTINCT case_id) AS total_tickets FROM helpdesk_events
)
SELECT 
    SUM(avg_hours) AS total_bottleneck_hours_per_ticket,
    ROUND(SUM(avg_hours) * 0.30, 2) AS hours_saved_per_ticket_30pct_reduction,
    (SELECT total_tickets FROM ticket_counts) AS tickets_analyzed,
    ROUND(SUM(avg_hours) * 0.30 * 500, 0) AS annual_hours_saved_500_tickets_per_year,  -- Assume 500 tickets/year
    ROUND((SUM(avg_hours) * 0.30 * 500) / 2080, 2) AS fte_equivalency,  -- 2080 = standard work year
    ROUND((SUM(avg_hours) * 0.30 * 500) * 30, 0) AS annual_cost_savings_at_30_per_hour
FROM bottleneck_summary;

-- Expected Output: Financial impact of reducing top bottlenecks by 30%
-- Business Value: Builds business case for process improvement investments


-- ============================================================================
-- SUMMARY EXPORT QUERY: Stage-level summary for Tableau
-- This creates the dataset used in dashboard visualizations
-- ============================================================================

WITH stage_times AS (
    SELECT 
        activity AS from_stage,
        EXTRACT(EPOCH FROM (LEAD(timestamp) OVER (PARTITION BY case_id ORDER BY timestamp) - timestamp)) / 3600 AS duration_hours
    FROM helpdesk_events
)
SELECT 
    from_stage AS "Stage",
    ROUND(AVG(duration_hours)::numeric, 2) AS "Avg_Hours",
    ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY duration_hours)::numeric, 2) AS "Median_Hours",
    ROUND(STDDEV(duration_hours)::numeric, 2) AS "Std_Hours",
    COUNT(*) AS "Count"
FROM stage_times
WHERE duration_hours IS NOT NULL
GROUP BY from_stage
ORDER BY AVG(duration_hours) DESC;

-- Expected Output: Clean summary table ready for Tableau import
-- Usage: Export this to stage_summary.csv for dashboard creation
