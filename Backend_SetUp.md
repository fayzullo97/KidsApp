# Architecture Setup Guide

## Supabase + Cloudflare R2 + Antigravity Integration

------------------------------------------------------------------------

# Overview

This document explains how to set up the backend architecture for the
Kids Learning App MVP using:

-   Supabase (Database + Auth)
-   Cloudflare R2 (Video Storage)
-   Cloudflare CDN (Video Delivery)
-   Antigravity (Frontend App Builder)

Architecture Flow:

Antigravity App\
↓\
Supabase (User Data + Video Metadata)\
↓\
Cloudflare R2 (Stores MP4 files)\
↓\
Cloudflare CDN (Serves videos globally)

------------------------------------------------------------------------

# 1. Cloudflare R2 Setup

## Step 1: Create R2 Bucket

1.  Log in to Cloudflare Dashboard
2.  Go to R2 → Create Bucket
3.  Name it: kids-app-videos
4.  Choose region closest to target users

## Step 2: Enable Public Access

For MVP: - Allow public read access for bucket - Enable R2 public URL or
connect custom domain

Example video URL: https://cdn.yourdomain.com/fruits/apple_01.mp4

------------------------------------------------------------------------

# 2. Video Upload Structure

Use organized folder structure inside R2:

kids-app-videos/ fruits/ apple/ apple_01.mp4 apple_02.mp4 banana/
banana_01.mp4 animals/ dog/ dog_01.mp4

This keeps scaling clean and manageable.

------------------------------------------------------------------------

# 3. Supabase Setup

## Tables Required

### topics

-   id (uuid, primary key)
-   name (text)
-   age_range (text)

### knowledge_units

-   id (uuid, primary key)
-   topic_id (foreign key)
-   name (text)

### videos

-   id (uuid, primary key)
-   knowledge_unit_id (foreign key)
-   video_url (text)
-   duration_seconds (int)

### user_progress

-   id (uuid)
-   child_id (uuid)
-   knowledge_unit_id (uuid)
-   mastery_score (float)
-   last_seen (timestamp)

------------------------------------------------------------------------

# 4. Connecting Supabase to Antigravity

## Step 1: Get Supabase API Keys

From Supabase dashboard: - Project URL - Anon public key

Provide these to Antigravity environment settings.

## Step 2: Fetch Videos in App

Query example:

SELECT video_url FROM videos WHERE knowledge_unit_id = :unit_id ORDER BY
RANDOM() LIMIT 1;

App loads returned video_url into video player.

------------------------------------------------------------------------

# 5. Connecting Cloudflare R2 to Antigravity

Antigravity only needs the public video URL.

It does NOT connect directly to R2 using secret keys.

Flow: 1. Supabase stores video URL 2. Antigravity fetches video URL 3.
Video player streams directly from Cloudflare CDN

------------------------------------------------------------------------

# 6. Video Optimization Guidelines

-   Use MP4 (H.264 codec)
-   Max 720p resolution
-   8--15 seconds length
-   Target size: 1--2MB per video

This ensures smooth loading for toddlers.

------------------------------------------------------------------------

# 7. Security Notes

-   Keep R2 write access private
-   Do NOT expose R2 API keys
-   Only expose public CDN URLs
-   Enable Row Level Security in Supabase

------------------------------------------------------------------------

# 8. Future Upgrade Path

When scaling:

-   Add signed URLs for protected access
-   Enable Cloudflare Stream for adaptive bitrate
-   Add Redis cache for recommendations
-   Move recommendation logic to Supabase Edge Functions

------------------------------------------------------------------------

# Final Architecture Summary

Cloudflare R2 → Stores videos\
Supabase → Stores metadata + progress\
Antigravity → Fetches URLs and plays video\
CDN → Ensures fast streaming worldwide

This setup is scalable, low cost, and production ready for MVP.

------------------------------------------------------------------------

**End of Setup Guide**
