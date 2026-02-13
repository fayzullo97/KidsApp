import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kids_learning_app/screens/admin/topic_management_screen.dart';
import 'package:kids_learning_app/screens/admin/unit_management_screen.dart';
import 'package:kids_learning_app/screens/admin/video_upload_screen.dart';

// Enum for Admin Tabs
enum AdminTab { topics, units, videos, questions }

final adminTabProvider = StateProvider<AdminTab>((ref) => AdminTab.topics);

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTab = ref.watch(adminTabProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kids App Admin CMS'),
        backgroundColor: Colors.blueGrey,
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            tooltip: 'Exit to App',
            onPressed: () => context.go('/'),
          ),
        ],
      ),
      body: Row(
        children: [
          // Sidebar
          NavigationRail(
            selectedIndex: currentTab.index,
            onDestinationSelected: (int index) {
              ref.read(adminTabProvider.notifier).state = AdminTab.values[index];
            },
            labelType: NavigationRailLabelType.all,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.category),
                label: Text('Topics'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.class_),
                label: Text('Units'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.video_library),
                label: Text('Videos'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.quiz),
                label: Text('Questions'),
              ),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          // Main Content Area
          Expanded(
            child: _buildContent(currentTab),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(AdminTab tab) {
    switch (tab) {
      case AdminTab.topics:
        return const TopicManagementScreen();
      case AdminTab.units:
        return const UnitManagementScreen();
      case AdminTab.videos:
        return const VideoUploadScreen();
      case AdminTab.questions:
         return const Center(child: Text('Question Management Coming Soon')); // Placeholder
    }
  }
}
