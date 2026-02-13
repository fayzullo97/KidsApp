-- SQL Function to get aggregated dashboard stats for a specific child
-- Returns a JSON structure to avoid N+1 queries from the Flutter app.

CREATE OR REPLACE FUNCTION get_child_dashboard_stats(child_input_id TEXT)
RETURNS JSON AS $$
DECLARE
    result JSON;
BEGIN
    SELECT json_agg(t)
    INTO result
    FROM (
        SELECT 
            t.id AS topic_id,
            t.name AS topic_name,
            t.age_range,
            
            -- Count total units in this topic
            COUNT(ku.id) AS total_units,
            
            -- Count learned units (mastery >= 0.8)
            COALESCE(SUM(CASE WHEN up.mastery_score >= 0.8 THEN 1 ELSE 0 END), 0) AS learned_units,
            
            -- Calculate topic completion percentage
            CASE 
                WHEN COUNT(ku.id) > 0 THEN 
                    ROUND((COALESCE(SUM(CASE WHEN up.mastery_score >= 0.8 THEN 1 ELSE 0 END), 0)::numeric / COUNT(ku.id)::numeric) * 100, 2)
                ELSE 0 
            END AS topic_completion_pct,
            
            -- Nested list of units with their individual stats
            COALESCE(
                json_agg(
                    json_build_object(
                        'unit_id', ku.id,
                        'unit_name', ku.name,
                        'mastery_score', COALESCE(up.mastery_score, 0),
                        'correct_count', COALESCE(up.correct_count, 0),
                        'wrong_count', COALESCE(up.wrong_count, 0),
                        'last_seen', up.last_seen,
                        'status', CASE 
                            WHEN up.mastery_score >= 0.8 THEN 'Learned'
                            WHEN up.correct_count > 0 THEN 'In Progress'
                            ELSE 'Not Started'
                        END
                    ) ORDER BY ku.name -- Sort units alphabetically within topic
                ) FILTER (WHERE ku.id IS NOT NULL), 
                '[]'
            ) AS units
            
        FROM topics t
        LEFT JOIN knowledge_units ku ON t.id = ku.topic_id
        LEFT JOIN user_progress up ON ku.id = up.knowledge_unit_id AND up.child_id = child_input_id
        GROUP BY t.id, t.name, t.age_range
        ORDER BY topic_completion_pct ASC -- Show least completed topics first (as requested)
    ) t;

    RETURN result;
END;
$$ LANGUAGE plpgsql;
