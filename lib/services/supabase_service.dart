import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:kids_learning_app/models/topic.dart';
import 'package:kids_learning_app/models/knowledge_unit.dart';
import 'package:kids_learning_app/models/video.dart';
import 'package:kids_learning_app/services/mock_data_service.dart'; // Fallback for types
import 'package:kids_learning_app/models/dashboard/topic_stats.dart';

class SupabaseService extends MockDataService {
  final SupabaseClient _client = Supabase.instance.client;

  @override
  Future<void> saveChild(child) async {
    // For MVP, we might just store child locally or in a 'children' table if auth exists.
    // Given the schema, we tracking progress by child_id (string).
    // So distinct save might not be needed unless we have a children table.
    // Implementation depends on if we added a children table or just strictly follow the schema provided.
    // The provided schema shows 'user_progress' has 'child_id'.
    // We will assume local storage dictates the 'child_id' for now.
    print('SupabaseService: Child ${child.name} initialized locally.');
  }

  @override
  Future<List<Video>> getRecommendedVideos(String childId) async {
    try {
      // 1. Fetch all videos with their unit metadata
      final response = await _client
          .from('videos')
          .select('id, video_url, thumbnail_url, knowledge_unit_id, knowledge_units(topic_id)');
      
      final List<dynamic> data = response;
      if (data.isEmpty) return [];

      // 2. Fetch user progress for this child
      final progressResponse = await _client
          .from('user_progress')
          .select('knowledge_unit_id, mastery_score')
          .eq('child_id', childId);
      
      final Map<String, double> masteryMap = {};
      for (var p in progressResponse) {
        masteryMap[p['knowledge_unit_id'] as String] = (p['mastery_score'] as num).toDouble();
      }

      // 3. Weighted Random Selection
      // Algorithm: Weight = (1.0 - Mastery) + ExplorationBonus (0.2)
      // Higher weight = Higher chance of being selected
      final List<Map<String, dynamic>> weightedVideos = [];
      double totalWeight = 0.0;

      for (var json in data) {
        final unitId = json['knowledge_unit_id'] as String;
        final mastery = masteryMap[unitId] ?? 0.0;
        final weight = (1.0 - mastery) + 0.2; // 0.2 is exploration bonus
        
        weightedVideos.add({
          'video': json,
          'weight': weight,
        });
        totalWeight += weight;
      }

      // Select 5 videos based on weights
      List<Video> selectedVideos = [];
      final random = DateTime.now().millisecondsSinceEpoch;
      
      // Simple Roulette Wheel Selection for 5 items
      for (int i = 0; i < 5; i++) {
         double randomPoint = (DateTime.now().microsecondsSinceEpoch % 1000) / 1000.0 * totalWeight;
         double currentWeight = 0.0;
         
         for (var item in weightedVideos) {
           currentWeight += item['weight'] as double;
           if (currentWeight >= randomPoint) {
             final json = item['video'];
             selectedVideos.add(Video(
                id: json['id'],
                unitId: json['knowledge_unit_id'],
                videoUrl: json['video_url'],
                thumbnailUrl: json['thumbnail_url'] ?? '',
             ));
             break;
           }
         }
      }
      
      // Fallback if selection failed (rarity)
      if (selectedVideos.isEmpty) {
         return data.take(5).map((json) => Video(
            id: json['id'],
            unitId: json['knowledge_unit_id'],
            videoUrl: json['video_url'],
            thumbnailUrl: json['thumbnail_url'] ?? '',
         )).toList();
      }

      return selectedVideos;
    } catch (e) {
      print('Supabase Error fetching videos: $e');
      return []; 
    }
  }

  @override
  Future<void> updateProgress(String childId, String unitId, bool correct) async {
    try {
      // Upsert progress
      // We need to fetch current mastery first or use an RPC.
      // For simplicity, we'll use a simple upsert if possible, but logic like "increment count" is harder with standard upsert without reading first.
      
      // Let's read first
      final existing = await _client
          .from('user_progress')
          .select()
          .eq('child_id', childId)
          .eq('knowledge_unit_id', unitId)
          .maybeSingle();

      double newMastery = 0.0;
      int correctCount = 0;
      int wrongCount = 0;

      if (existing != null) {
        newMastery = (existing['mastery_score'] as num).toDouble();
        correctCount = existing['correct_count'] as int;
        wrongCount = existing['wrong_count'] as int;
      }

      if (correct) {
        correctCount++;
        newMastery = (newMastery + 0.1).clamp(0.0, 1.0);
      } else {
        wrongCount++;
      }

      await _client.from('user_progress').upsert({
        'child_id': childId,
        'knowledge_unit_id': unitId,
        'mastery_score': newMastery,
        'correct_count': correctCount,
        'wrong_count': wrongCount,
        'last_seen': DateTime.now().toIso8601String(),
      }, onConflict: 'child_id,knowledge_unit_id'); // Ensure unique constraint matches

    } catch (e) {
      print('Supabase Error updating progress: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getChildProgress(String childId) async {
    try {
      final response = await _client
          .from('user_progress')
          .select('mastery_score, correct_count, wrong_count, knowledge_units(name, topics(name))')
          .eq('child_id', childId);
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Supabase Error fetching progress: $e');
      return [];
    }
  }

  Future<List<TopicStats>> getDashboardStats(String childId) async {
    try {
      final response = await _client.rpc('get_child_dashboard_stats', params: {'child_input_id': childId});
      
      if (response == null) return [];
      
      final List<dynamic> data = response as List<dynamic>;
      return data.map((json) => TopicStats.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      print('Supabase Error fetching dashboard stats: $e');
      return [];
    }
  }
}
