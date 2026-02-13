# Admin Management Dashboard (CMS) Architecture

## Kids Learning App

------------------------------------------------------------------------

# Overview

This document defines the architecture and system requirements for the
Admin Dashboard (Content Management System) of the Kids Learning App.

The CMS must integrate with:

-   Supabase (Database)
-   Cloudflare R2 (Video Storage)
-   Antigravity (Frontend Builder)

------------------------------------------------------------------------

# 1. Topic Management

Admin must be able to:

-   Create topic
-   Edit topic
-   Delete topic
-   Assign age category (1--4 years)
-   Add topic icon/image

### Database Schema: topics

-   id (uuid, primary key)
-   name (text)
-   description (text, optional)
-   age_category (int or array)
-   icon_url (text)
-   created_at (timestamp)

------------------------------------------------------------------------

# 2. Knowledge Unit Management

Inside each topic:

-   Create unit (e.g., Apple)
-   Edit unit
-   Delete unit
-   Set mastery threshold (default = 10)
-   Add thumbnail image

### Database Schema: knowledge_units

-   id (uuid, primary key)
-   topic_id (uuid, foreign key → topics.id)
-   name (text)
-   mastery_threshold (int)
-   thumbnail_url (text)
-   created_at (timestamp)

------------------------------------------------------------------------

# 3. Video Management

Inside each unit:

-   Upload video
-   Add multiple videos per unit
-   Set duration
-   Set order (optional)
-   Store metadata
-   Delete video

## IMPORTANT

Each video MUST store relation to:

-   topic_id
-   knowledge_unit_id

This ensures proper adaptive logic and scalable structure.

### Database Schema: videos

-   id (uuid, primary key)
-   topic_id (uuid, foreign key)
-   knowledge_unit_id (uuid, foreign key)
-   video_url (text, Cloudflare R2 public URL)
-   duration_seconds (int)
-   file_size (int)
-   created_at (timestamp)
-   upload_status (text)

------------------------------------------------------------------------

# 4. Question Management

Inside each unit:

-   Create question
-   Edit question
-   Delete question
-   Set question type:
    -   Single choice
    -   Tap object
    -   Image selection
-   Define correct answer
-   Define incorrect answers

### Database Schema: questions

-   id (uuid, primary key)
-   knowledge_unit_id (uuid, foreign key)
-   question_text (text)
-   question_type (text)
-   correct_answer (text)
-   incorrect_answers (json array)
-   created_at (timestamp)

------------------------------------------------------------------------

# 5. Video Upload Flow Architecture

1.  Admin selects file in dashboard
2.  Frontend sends file to backend endpoint
3.  Backend uploads file to Cloudflare R2
4.  R2 returns public URL
5.  Backend stores metadata in Supabase
6.  UI confirms upload success

⚠ Do NOT expose R2 secret keys to frontend.

------------------------------------------------------------------------

# 6. Admin Dashboard UI Structure

Sidebar: - Topics - Units - Videos - Questions - Analytics (future)

Topic Page: - List units - Add unit button

Unit Page: - List videos - Upload video button - List questions - Add
question button

Video Upload Modal: - File selector - Duration input - Upload progress
bar - Metadata preview - Confirmation message

------------------------------------------------------------------------

# 7. Database Indexing

Add indexes on:

-   topic_id
-   knowledge_unit_id
-   age_category

Enable Row Level Security:

-   Admin: full access
-   Parents: read-only filtered access

------------------------------------------------------------------------

# 8. Scalability Targets

System must support:

-   100+ topics
-   1,000+ units
-   50,000+ videos
-   Millions of users

------------------------------------------------------------------------

# 9. Security Best Practices

-   Keep R2 API keys server-side only
-   Validate file type (MP4 only)
-   Limit file size
-   Enable Supabase RLS
-   Use signed URLs in production

------------------------------------------------------------------------

# Final Architecture Flow

Admin Dashboard\
↓\
Backend API\
↓\
Cloudflare R2 (video storage)\
↓\
Supabase (metadata storage)\
↓\
App fetches video_url from database

------------------------------------------------------------------------

**End of Admin CMS Architecture Document**
