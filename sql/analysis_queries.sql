-- ============================================================================
-- HELPDESK PROCESS ANALYSIS - SQL QUERIES
-- Purpose: Extract and transform event log data to identify process bottlenecks
-- Database: PostgreSQL
-- Author: Usman Ghani Khan
-- ============================================================================

-- Query 1: Calculate cycle time between consecutive process stages
-- ============================================================================
WITH stage_transitions AS (
    SELECT 
        case_id,
        activity AS from_stage,
        LEAD(activity) OVER (PARTITION BY case_id ORDER BY timestamp) AS to_stage,
        timestamp AS start_time,
        LEAD(timestamp) OVER (PARTITION BY case_id ORDER BY timestamp) AS end_time,
        priority,
        category
    FROM helpdesk_events
)
SELECT 
    from_stage,
    to_stage,
    AVG(EXTRACT(EPOCH FROM (end_time - start_time)) / 3600) AS avg_hours,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY EXTRACT(EPOCH FROM (end_time - start_time)) / 3600) AS median_hours,
    COUNT(*) AS ticket_count
FROM stage_transitions
WHERE to_stage IS NOT NULL
GROUP BY from_stage, to_stage
ORDER BY avg_hours DESC;

-- Query 2: Identify bottleneck stages (stages with >24 hour average wait time)
-- ============================================================================
WITH stage_transitions AS (
    SELECT 
        case_id,
        activity AS from_stage,
        LEAD(activity) OVER (PARTITION BY case_id ORDER BY timestamp) AS to_stage,
        EXTRACT(EPOCH FROM (LEAD(timestamp) OVER (PARTITION BY case_id ORDER BY timestamp) - timestamp)) / 3600 AS duration_hours,
        priority
    FROM helpdesk_events
)
SELECT 
    from_stage,
    AVG(duration_hours) AS avg_wait_hours,
    COUNT(*) AS affected_tickets,
    CASE 
        WHEN AVG(duration_hours) > 40 THEN 'CRITICAL'
        WHEN AVG(duration_hours) > 20 THEN 'HIGH'
        ELSE 'NORMAL'
    END AS severity
FROM stage_transitions
WHERE to_stage IS NOT NULL
GROUP BY from_stage
HAVING AVG(duration_hours) > 10
ORDER BY avg_wait_hours DESC;

-- Query 3: Total resolution time by priority and category
-- ============================================================================
WITH ticket_lifecycle AS (
    SELECT 
        case_id,
        MIN(timestamp) AS ticket_created,
        MAX(timestamp) AS ticket_closed,
        MAX(priority) AS priority,
        MAX(category) AS category
    FROM helpdesk_events
    GROUP BY case_id
)
SELECT 
    priority,
    category,
    AVG(EXTRACT(EPOCH FROM (ticket_closed - ticket_created)) / 3600) AS avg_resolution_hours,
    COUNT(*) AS ticket_count
FROM ticket_lifecycle
GROUP BY priority, category
ORDER BY avg_resolution_hours DESC;

-- Query 4: Agent performance analysis
-- ============================================================================
SELECT 
    agent,
    COUNT(DISTINCT case_id) AS tickets_handled,
    AVG(EXTRACT(EPOCH FROM (
        MAX(timestamp) - MIN(timestamp)
    )) / 3600) AS avg_handling_time_hours
FROM helpdesk_events
GROUP BY agent
ORDER BY tickets_handled DESC;

-- Query 5: Tickets requiring customer interaction (bottleneck analysis)
-- ============================================================================
SELECT 
    COUNT(CASE WHEN activity = 'Awaiting Customer Response' THEN 1 END) AS customer_response_tickets,
    AVG(CASE WHEN activity = 'Awaiting Customer Response' 
        THEN EXTRACT(EPOCH FROM (
            LEAD(timestamp) OVER (PARTITION BY case_id ORDER BY timestamp) - timestamp
        )) / 3600 
    END) AS avg_customer_wait_hours,
    COUNT(DISTINCT case_id) AS total_tickets,
    ROUND(
        100.0 * COUNT(CASE WHEN activity = 'Awaiting Customer Response' THEN 1 END) / 
        COUNT(DISTINCT case_id), 2
    ) AS pct_requiring_customer_input
FROM helpdesk_events;
