import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:kids_learning_app/models/knowledge_unit.dart';
// import 'package:kids_learning_app/models/topic.dart';

class UnitManagementScreen extends ConsumerStatefulWidget {
  const UnitManagementScreen({super.key});

  @override
  ConsumerState<UnitManagementScreen> createState() => _UnitManagementScreenState();
}

class _UnitManagementScreenState extends ConsumerState<UnitManagementScreen> {
  bool _isLoading = false;
  
  // Mock data for UI development
  final List<dynamic> _units = []; 

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
                  'Manage Knowledge Units',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                ElevatedButton.icon(
                  onPressed: () => _showAddUnitDialog(),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Unit'),
                ),
              ],
            ),
            const SizedBox(height: 24),
             // We need a topic selector here in real app to filter units
            Expanded(
              child: _isLoading 
                ? const Center(child: CircularProgressIndicator())
                : _units.isEmpty 
                  ? const Center(child: Text('No units found. Select a topic or add a unit.'))
                  : ListView.builder(
                      itemCount: _units.length,
                      itemBuilder: (context, index) {
                         // Placeholder for unit list item
                         return const Card(child: ListTile(title: Text('Unit Item')));
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddUnitDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Unit'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
             // Dropdown for Topic
            const TextField(
              decoration: InputDecoration(labelText: 'Unit Name'),
            ),
            const SizedBox(height: 16),
            const TextField(
              decoration: InputDecoration(labelText: 'Mastery Threshold (Default: 10)'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              // TODO: Call service to create unit
              Navigator.pop(context);
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}
