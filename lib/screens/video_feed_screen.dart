import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kids_learning_app/models/video.dart';
import 'package:kids_learning_app/models/feed_item.dart';
import 'package:kids_learning_app/models/knowledge_unit.dart';
import 'package:kids_learning_app/providers/providers.dart';
import 'package:kids_learning_app/widgets/video_item.dart';
import 'package:kids_learning_app/widgets/question_widget.dart';

class VideoFeedScreen extends ConsumerStatefulWidget {
  const VideoFeedScreen({super.key});

  @override
  ConsumerState<VideoFeedScreen> createState() => _VideoFeedScreenState();
}

class _VideoFeedScreenState extends ConsumerState<VideoFeedScreen> {
  final PageController _pageController = PageController();
  final List<FeedItem> _items = [];
  bool _isLoading = false;
  int _videoCountSinceLastQuestion = 0;

  @override
  void initState() {
    super.initState();
    _loadInitialContent();
  }

  Future<void> _loadInitialContent() async {
    if (_isLoading) return;
    setState(() { _isLoading = true; });

    try {
      final child = ref.read(childProvider).value;
      if (child != null) {
        final service = ref.read(adaptiveServiceProvider);
        for (int i = 0; i < 3; i++) {
          final video = await service.getNextVideo(child.id);
          _addItem(VideoItemData(video));
        }
      }
    } catch (e) {
      print('Error loading content: $e');
    } finally {
      if (mounted) setState(() { _isLoading = false; });
    }
  }

  void _addItem(VideoItemData videoItem) {
    _items.add(videoItem);
    _videoCountSinceLastQuestion++;

    // Logic: Every 5 videos, add a question
    if (_videoCountSinceLastQuestion >= 5) {
       // Create a mock question for MVP
       // In real app, AdaptiveService would provide this
       _items.add(QuestionItemData(
         unit: KnowledgeUnit(id: 'q1', topicId: 't1', title: 'Test Mock'),
         options: ['Apple', 'Cat', 'Dog', 'Car'],
         correctIndex: 1, // Logic should match unit
         questionText: 'Which one is a Cat?',
       ));
       _videoCountSinceLastQuestion = 0;
    }
  }

  Future<void> _loadMoreContent() async {
    if (_isLoading) return;
    
    try {
      final child = ref.read(childProvider).value;
      if (child != null) {
        final service = ref.read(adaptiveServiceProvider);
        final video = await service.getNextVideo(child.id);
        if (mounted) {
          setState(() {
            _addItem(VideoItemData(video));
          });
        }
      }
    } catch (e) {
      print('Error loading more content: $e');
    }
  }

  void _onPageChanged(int index) {
    // Load next content when we are close to end
    if (index >= _items.length - 2) {
      _loadMoreContent();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_items.isEmpty && _isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()),
      );
    }
    
    if (_items.isEmpty && !_isLoading) {
       return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: Text('No content found', style: TextStyle(color: Colors.white))),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            scrollDirection: Axis.vertical,
            onPageChanged: _onPageChanged,
            itemCount: _items.length,
            itemBuilder: (context, index) {
              final item = _items[index];
              if (item is VideoItemData) {
                return VideoItem(
                  // Use URL as key segment to force recreation if needed, but better use ID
                  key: ValueKey('video_${item.video.id}_$index'), 
                  video: item.video,
                );
              } else if (item is QuestionItemData) {
                return QuestionWidget(
                  key: ValueKey('question_$index'),
                  question: item,
                  onCorrect: () {
                    // Update mastery score via provider/service
                    // ref.read(adaptiveServiceProvider).reportSuccess(...)
                    print('Question Correct!');
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
          // Close button (Go to Dashboard)
          Positioned(
            top: 40, right: 20,
            child: CircleAvatar(
               backgroundColor: Colors.black54,
               child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () => context.push('/dashboard'),
              ),
            ),
          ),
          Positioned(
             top: 40, left: 20,
             child: Consumer(
               builder: (context, ref, _) {
                 final child = ref.read(childProvider).value;
                 return Text(
                   child?.name ?? '',
                   style: const TextStyle(
                     color: Colors.white, 
                     fontSize: 18, 
                     fontWeight: FontWeight.bold,
                     shadows: [Shadow(blurRadius: 4, color: Colors.black)],
                   ),
                 );
               }
             ),
          ),
        ],
      ),
    );
  }
}
