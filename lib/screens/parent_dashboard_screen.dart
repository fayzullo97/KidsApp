import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kids_learning_app/providers/providers.dart';
import 'package:kids_learning_app/services/supabase_service.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:go_router/go_router.dart';

class ParentDashboardScreen extends ConsumerStatefulWidget {
  const ParentDashboardScreen({super.key});

  @override
  ConsumerState<ParentDashboardScreen> createState() => _ParentDashboardScreenState();
}

class _ParentDashboardScreenState extends ConsumerState<ParentDashboardScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _progressData = [];

  @override
  void initState() {
    super.initState();
    _fetchProgress();
  }

  Future<void> _fetchProgress() async {
    final prefs = ref.read(sharedPreferencesProvider);
    // Try to get current child from state, or fallback to last active child
    final childState = ref.read(childProvider).value;
    String? childId = childState?.id ?? prefs.getString('last_child_id'); 

    if (childId == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    // Creating a temporary instance to access the new method
    // In a real app, we should cast the provider request
    final service = ref.read(mockDataServiceProvider);
    
    if (service is SupabaseService) {
      final data = await service.getChildProgress(childId);
      setState(() {
        _progressData = data;
        _isLoading = false;
      });
    } else {
       setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Parent Dashboard'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : _progressData.isEmpty 
              ? const Center(child: Text("No progress recorded yet."))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _progressData.length,
                  itemBuilder: (context, index) {
                    final item = _progressData[index];
                    final unit = item['knowledge_units'];
                    final topic = unit?['topics'];
                    final double mastery = (item['mastery_score'] as num).toDouble();
                    final int correct = item['correct_count'];
                    final int wrong = item['wrong_count'];

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('${topic?['name']} - ${unit?['name']}', 
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                Text('Mastery: ${(mastery * 100).toInt()}%',
                                  style: TextStyle(
                                    color: mastery > 0.7 ? Colors.green : Colors.orange,
                                    fontWeight: FontWeight.bold,
                                  )),
                              ],
                            ),
                            const SizedBox(height: 8),
                            LinearPercentIndicator(
                              lineHeight: 14.0,
                              percent: mastery,
                              backgroundColor: Colors.grey[300],
                              progressColor: mastery > 0.7 ? Colors.green : Colors.orange,
                              barRadius: const Radius.circular(7),
                            ),
                            const SizedBox(height: 8),
                            Text('Correct: $correct | Wrong: $wrong', style: TextStyle(color: Colors.grey[600])),
                          ],
                        ),
                      ),
                    );
                  },
                ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/feed'), // Use go to reset stack/mode
        icon: const Icon(Icons.play_arrow),
        label: const Text('Resume Learning'),
        backgroundColor: Colors.pinkAccent,
        foregroundColor: Colors.white,
      ),
    );
  }
}
