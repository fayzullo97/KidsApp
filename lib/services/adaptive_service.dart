import 'package:kids_learning_app/models/video.dart';
import 'package:kids_learning_app/services/mock_data_service.dart';
import 'dart:math';

class AdaptiveService {
  final MockDataService dataService;

  AdaptiveService(this.dataService);

  // Simple adaptive logic for MVP:
  // 1. Get all videos
  // 2. Randomly select one (Simulating "Exploration")
  // 3. In real app, we would weigh by (1 - mastery)
  
  Future<Video> getNextVideo(String childId) async {
    // Simulate latency
    await Future.delayed(const Duration(milliseconds: 200));
    
    // In MVP, dataService just returns all videos.
    // We will pick one randomly.
    // Since MockDataService already shuffles in getRecommendedVideos, we can just pick first.
    final videos = await dataService.getRecommendedVideos(childId);
    if (videos.isEmpty) {
      throw Exception('No videos available');
    }
    
    // To make it feel infinite, just pick random from list
    final random = Random();
    return videos[random.nextInt(videos.length)];
  }
}
