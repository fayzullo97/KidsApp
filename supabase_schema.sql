-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 1. Topics Table
CREATE TABLE IF NOT EXISTS topics (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    age_range TEXT DEFAULT '1-4',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 2. Knowledge Units Table
CREATE TABLE IF NOT EXISTS knowledge_units (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    topic_id UUID REFERENCES topics(id) ON DELETE CASCADE NOT NULL,
    name TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 3. Videos Table
CREATE TABLE IF NOT EXISTS videos (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    knowledge_unit_id UUID REFERENCES knowledge_units(id) ON DELETE CASCADE NOT NULL,
    video_url TEXT NOT NULL,
    duration_seconds INTEGER,
    thumbnail_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 4. User Progress Table
CREATE TABLE IF NOT EXISTS user_progress (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    child_id TEXT NOT NULL, -- MVP: Text ID from local storage. Production: UUID from auth.users
    knowledge_unit_id UUID REFERENCES knowledge_units(id) ON DELETE CASCADE NOT NULL,
    mastery_score FLOAT DEFAULT 0.0 CHECK (mastery_score >= 0.0 AND mastery_score <= 1.0),
    correct_count INTEGER DEFAULT 0,
    wrong_count INTEGER DEFAULT 0,
    last_seen TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    UNIQUE(child_id, knowledge_unit_id)
);

-- Indexes for Performance
CREATE INDEX IF NOT EXISTS idx_knowledge_units_topic_id ON knowledge_units(topic_id);
CREATE INDEX IF NOT EXISTS idx_videos_knowledge_unit_id ON videos(knowledge_unit_id);
CREATE INDEX IF NOT EXISTS idx_user_progress_child_id ON user_progress(child_id);
CREATE INDEX IF NOT EXISTS idx_user_progress_unit_id ON user_progress(knowledge_unit_id);

-- Row Level Security (RLS)
ALTER TABLE topics ENABLE ROW LEVEL SECURITY;
ALTER TABLE knowledge_units ENABLE ROW LEVEL SECURITY;
ALTER TABLE videos ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_progress ENABLE ROW LEVEL SECURITY;

-- Policies (Public Read for Content)
CREATE POLICY "Public read access for topics" ON topics FOR SELECT USING (true);
CREATE POLICY "Public read access for knowledge_units" ON knowledge_units FOR SELECT USING (true);
CREATE POLICY "Public read access for videos" ON videos FOR SELECT USING (true);

-- Policy for User Progress (MVP: Allow public for simulated auth, ideally restrict by child_id)
CREATE POLICY "Public access for progress (MVP)" ON user_progress FOR ALL USING (true);

-- Seed Initial Data
INSERT INTO topics (name, age_range) VALUES 
('Animals', '1-4'),
('Fruits', '1-4'),
('Numbers', '2-4')
ON CONFLICT DO NOTHING;

-- CMS UPDATES (Added for Admin Dashboard)

-- 1. Update Topics
ALTER TABLE topics ADD COLUMN IF NOT EXISTS description TEXT;
ALTER TABLE topics ADD COLUMN IF NOT EXISTS icon_url TEXT;

-- 2. Update Knowledge Units
ALTER TABLE knowledge_units ADD COLUMN IF NOT EXISTS mastery_threshold INTEGER DEFAULT 10;
ALTER TABLE knowledge_units ADD COLUMN IF NOT EXISTS thumbnail_url TEXT;

-- 3. Update Videos
ALTER TABLE videos ADD COLUMN IF NOT EXISTS file_size INTEGER;
ALTER TABLE videos ADD COLUMN IF NOT EXISTS upload_status TEXT DEFAULT 'pending'; -- pending, processing, completed

-- 4. Create Questions Table
CREATE TABLE IF NOT EXISTS questions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    knowledge_unit_id UUID REFERENCES knowledge_units(id) ON DELETE CASCADE NOT NULL,
    question_text TEXT NOT NULL,
    question_type TEXT NOT NULL CHECK (question_type IN ('single_choice', 'tap_object', 'image_selection')),
    correct_answer TEXT NOT NULL,
    incorrect_answers JSONB DEFAULT '[]'::jsonb,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Index for questions
CREATE INDEX IF NOT EXISTS idx_questions_unit_id ON questions(knowledge_unit_id);

-- RLS for Questions
ALTER TABLE questions ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public read access for questions" ON questions FOR SELECT USING (true);
