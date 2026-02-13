import 'package:kids_learning_app/models/video.dart';
import 'package:kids_learning_app/models/knowledge_unit.dart';

abstract class FeedItem {}

class VideoItemData extends FeedItem {
  final Video video;
  VideoItemData(this.video);
}

class QuestionItemData extends FeedItem {
  final KnowledgeUnit unit;
  final List<String> options; // For MVP, just strings or image URLs
  final int correctIndex;
  final String questionText;

  QuestionItemData({
    required this.unit,
    required this.options,
    required this.correctIndex,
    required this.questionText,
  });
}
