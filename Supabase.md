# Supabase Setup Guide for Smooth Interaction

## Adaptive Learning Video App (1--4 Years Old)

------------------------------------------------------------------------

# 1. Architecture Overview

Mobile App (Flutter / Antigravity) ↓ Supabase (Auth + PostgreSQL + Edge
Functions) ↓ CDN (AWS S3 / Cloudflare R2 for videos)

Goal: Low latency, smooth video feed, fast mastery updates.

------------------------------------------------------------------------

# 2. Supabase Project Setup

## Step 1: Create Project

-   Create new Supabase project
-   Choose region closest to target users
-   Enable automatic backups

IMPORTANT: Choose the same region as your CDN.

------------------------------------------------------------------------

# 3. Database Structure (Optimized for Speed)

## Tables

### users

-   id (uuid, primary key)
-   email
-   created_at

### children

-   id (uuid, primary key)
-   user_id (foreign key)
-   name
-   age
-   created_at

### topics

-   id
-   title

### knowledge_units

-   id
-   topic_id (indexed)
-   title

### videos

-   id
-   knowledge_unit_id (indexed)
-   video_url
-   thumbnail_url

### user_progress

-   id
-   child_id (indexed)
-   knowledge_unit_id (indexed)
-   mastery_score (float)
-   correct_count (int)
-   wrong_count (int)
-   repetition_count (int)
-   last_seen (timestamp)

------------------------------------------------------------------------

# 4. Indexing (CRITICAL FOR SMOOTH FEED)

Add indexes on:

-   knowledge_units.topic_id
-   videos.knowledge_unit_id
-   user_progress.child_id
-   user_progress.knowledge_unit_id

This ensures: - Fast mastery lookup - Fast video selection - Low latency
recommendation

------------------------------------------------------------------------

# 5. Row Level Security (RLS)

Enable RLS on:

-   children
-   user_progress

Policy: User can only access rows where: auth.uid() = user_id

This ensures child data protection.

------------------------------------------------------------------------

# 6. Edge Function for Adaptive Algorithm

Create Edge Function:

selectNextVideo(child_id)

Function flow: 1. Fetch mastery scores 2. Apply forgetting curve 3.
Calculate weights 4. Select weighted random knowledge unit 5. Return
video metadata

Why Edge Function? - Keeps logic server-side - Reduces client
computation - Improves security - Enables algorithm updates without app
update

------------------------------------------------------------------------

# 7. Performance Optimizations

## 1. Avoid Heavy Queries

Never fetch entire table. Always filter by child_id and indexed columns.

## 2. Use Pagination

Limit video fetch to: LIMIT 5

Preload next 5 videos.

## 3. Cache Strategy

-   Use Redis later if scaling
-   For MVP, rely on indexed PostgreSQL

## 4. Keep Videos Outside Supabase

Store large video files in CDN. Only store URLs in database.

------------------------------------------------------------------------

# 8. Smooth Interaction Checklist

-   Use indexed queries
-   Use Edge Functions for recommendations
-   Preload next 3--5 videos
-   Avoid large payload responses
-   Return only required fields
-   Keep response under 200ms

------------------------------------------------------------------------

# 9. Scaling Strategy

When users grow:

Phase 1: - Add read replicas - Enable connection pooling

Phase 2: - Add Redis cache layer - Separate recommendation microservice

Phase 3: - Move adaptive engine to dedicated ML service

------------------------------------------------------------------------

# 10. Security & Compliance

-   Enable RLS
-   Use HTTPS only
-   Store minimal child data
-   Encrypt sensitive fields if needed
-   Prepare for COPPA compliance

------------------------------------------------------------------------

# 11. Final Recommendation

For MVP: Supabase is more than enough.

Focus on: - Clean schema - Proper indexing - Server-side
recommendation - CDN for videos

Smooth interaction depends more on query optimization and video
buffering than on database size.

------------------------------------------------------------------------

**End of Supabase Setup Guide**
