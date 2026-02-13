-- 1. Ensure Topics exist (just in case)
INSERT INTO topics (name, age_range) VALUES 
('Animals', '1-4'),
('Fruits', '1-4')
ON CONFLICT DO NOTHING;

-- 2. Insert Knowledge Units
INSERT INTO knowledge_units (topic_id, name)
SELECT id, 'Bee' FROM topics WHERE name = 'Animals' LIMIT 1;

INSERT INTO knowledge_units (topic_id, name)
SELECT id, 'Butterfly' FROM topics WHERE name = 'Animals' LIMIT 1;

INSERT INTO knowledge_units (topic_id, name)
SELECT id, 'Apple' FROM topics WHERE name = 'Fruits' LIMIT 1;

-- 3. Insert Videos
-- Bee Video
INSERT INTO videos (knowledge_unit_id, video_url, thumbnail_url, duration_seconds)
SELECT id, 'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4', 'https://via.placeholder.com/150/FFCC00/FFFFFF?Text=Bee', 8
FROM knowledge_units WHERE name = 'Bee' LIMIT 1;

-- Butterfly Video
INSERT INTO videos (knowledge_unit_id, video_url, thumbnail_url, duration_seconds)
SELECT id, 'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4', 'https://via.placeholder.com/150/00CCFF/FFFFFF?Text=Butterfly', 8
FROM knowledge_units WHERE name = 'Butterfly' LIMIT 1;

-- Apple Video
INSERT INTO videos (knowledge_unit_id, video_url, thumbnail_url, duration_seconds)
SELECT id, 'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4', 'https://via.placeholder.com/150/FF0000/FFFFFF?Text=Apple', 8
FROM knowledge_units WHERE name = 'Apple' LIMIT 1;
