import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kids_learning_app/models/dashboard/topic_stats.dart';
import 'package:kids_learning_app/providers/providers.dart';
import 'package:kids_learning_app/screens/dashboard/topic_detail_screen.dart';
import 'package:kids_learning_app/services/supabase_service.dart';
import 'package:kids_learning_app/widgets/dashboard/topic_card.dart';
import 'package:go_router/go_router.dart';

class DashboardOverviewScreen extends ConsumerStatefulWidget {
  const DashboardOverviewScreen({super.key});

  @override
  ConsumerState<DashboardOverviewScreen> createState() => _DashboardOverviewScreenState();
}

class _DashboardOverviewScreenState extends ConsumerState<DashboardOverviewScreen> {
  bool _isLoading = true;
  List<TopicStats> _topics = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final prefs = ref.read(sharedPreferencesProvider);
      final childState = ref.read(childProvider).value;
      String? childId = childState?.id ?? prefs.getString('last_child_id');

      if (childId == null) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      final service = ref.read(mockDataServiceProvider);
      if (service is SupabaseService) {
        final stats = await service.getDashboardStats(childId);
        if (mounted) {
          setState(() {
            _topics = stats;
            _isLoading = false;
          });
        }
      } else {
         // Fallback for mock service if needed
         if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      print('Error loading dashboard: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Learning Progress', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black87,
        actions: [
          IconButton(
            icon: const Icon(Icons.play_circle_fill, color: Colors.pinkAccent, size: 32),
            onPressed: () => context.go('/feed'),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _topics.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.bar_chart, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text(
                        'No progress data available yet.',
                         style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () => context.go('/feed'),
                        icon: const Icon(Icons.play_arrow),
                        label: const Text('Start Learning'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.pinkAccent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _topics.length,
                  itemBuilder: (context, index) {
                    final topic = _topics[index];
                    return TopicCard(
                      topic: topic,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TopicDetailScreen(topic: topic),
                          ),
                        );
                      },
                    );
                  },
                ),
    );
  }
}
