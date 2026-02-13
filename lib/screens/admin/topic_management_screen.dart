import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kids_learning_app/models/topic.dart';
// import 'package:kids_learning_app/services/supabase_service.dart'; // Will use later
// For MVP UI, we'll confirm layout first

class TopicManagementScreen extends ConsumerStatefulWidget {
  const TopicManagementScreen({super.key});

  @override
  ConsumerState<TopicManagementScreen> createState() => _TopicManagementScreenState();
}

class _TopicManagementScreenState extends ConsumerState<TopicManagementScreen> {
  // Placeholder data until we connect to backend service methods (need to add admin methods)
  // For now, let's just use empty list or mock
  final List<Topic> _topics = []; 
  bool _isLoading = false; // set to true when fetching

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Manage Topics',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                ElevatedButton.icon(
                  onPressed: () => _showAddTopicDialog(),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Topic'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: _isLoading 
                ? const Center(child: CircularProgressIndicator())
                : _topics.isEmpty 
                  ? const Center(child: Text('No topics found. Add one to get started.'))
                  : ListView.builder(
                      itemCount: _topics.length,
                      itemBuilder: (context, index) {
                        final topic = _topics[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: CircleAvatar(child: Text(topic.title[0])),
                            title: Text(topic.title),
                            subtitle: Text('ID: ${topic.id}'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () {}),
                                IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () {}),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddTopicDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Topic'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(labelText: 'Topic Name'),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(labelText: 'Age Range (e.g., 1-4)'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              // TODO: Call service to create topic
              Navigator.pop(context);
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}
