import 'package:kids_learning_app/models/child.dart';
import 'package:kids_learning_app/models/topic.dart';
import 'package:kids_learning_app/models/knowledge_unit.dart';
import 'package:kids_learning_app/models/video.dart';
import 'package:kids_learning_app/models/user_progress.dart';

class MockDataService {
  // Mock Data
  static final List<Topic> topics = [
    Topic(id: 't1', title: 'Animals'),
    Topic(id: 't2', title: 'Fruits'),
    Topic(id: 't3', title: 'Numbers'),
  ];

  static final List<KnowledgeUnit> units = [
    KnowledgeUnit(id: 'u1', topicId: 't1', title: 'Cat'),
    KnowledgeUnit(id: 'u2', topicId: 't1', title: 'Dog'),
    KnowledgeUnit(id: 'u3', topicId: 't2', title: 'Apple'),
    KnowledgeUnit(id: 'u4', topicId: 't2', title: 'Banana'),
    KnowledgeUnit(id: 'u5', topicId: 't3', title: 'One'),
  ];

  static final List<Video> videos = [
    // Using sample public videos for testing
    Video(
      id: 'v1',
      unitId: 'u1',
      videoUrl: 'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4', 
      thumbnailUrl: 'https://via.placeholder.com/150/0000FF/808080?Text=Cat',
    ),
    Video(
      id: 'v2',
      unitId: 'u2',
      videoUrl: 'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
      thumbnailUrl: 'https://via.placeholder.com/150/FF0000/FFFFFF?Text=Dog',
    ),
     Video(
      id: 'v3',
      unitId: 'u3',
      videoUrl: 'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
      thumbnailUrl: 'https://via.placeholder.com/150/FFFF00/000000?Text=Apple',
    ),
  ];

  static final Map<String, UserProgress> _progress = {};

  // Mock Methods
  Future<void> saveChild(Child child) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 500));
    print('Saved child: ${child.name}');
  }

  Future<List<Video>> getRecommendedVideos(String childId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    // For MVP, just return all videos shuffled
    List<Video> recommended = List.from(videos)..shuffle();
    return recommended;
  }
  
  Future<void> updateProgress(String childId, String unitId, bool correct) async {
      final key = '${childId}_$unitId';
      if (!_progress.containsKey(key)) {
        _progress[key] = UserProgress(childId: childId, unitId: unitId);
      }
      
      final progress = _progress[key]!;
      // Simple mastery increase
      if (correct) {
        progress.masteryScore = (progress.masteryScore + 0.1).clamp(0.0, 1.0);
      }
      print('Updated progress for unit $unitId: ${progress.masteryScore}');
  }
}
