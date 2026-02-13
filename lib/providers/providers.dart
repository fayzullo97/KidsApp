import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kids_learning_app/models/child.dart';
import 'package:kids_learning_app/services/mock_data_service.dart';
import 'package:kids_learning_app/services/adaptive_service.dart';
import 'package:kids_learning_app/services/supabase_service.dart';
import 'dart:convert';

// Service Provider
final mockDataServiceProvider = Provider<MockDataService>((ref) {
  // Return SupabaseService which extends MockDataService for compatibility
  return SupabaseService(); 
});

// Shared Preferences Provider (Initialize in main and override)
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError();
});

// Child State Management
class ChildNotifier extends StateNotifier<AsyncValue<Child?>> {
  final SharedPreferences prefs;
  final MockDataService dataService;

  ChildNotifier(this.prefs, this.dataService) : super(const AsyncValue.loading()) {
    _loadChild();
  }

  Future<void> _loadChild() async {
    try {
      final childJson = prefs.getString('current_child');
      if (childJson != null) {
        final Map<String, dynamic> map = jsonDecode(childJson);
        final child = Child(
          id: map['id'],
          name: map['name'],
          age: map['age'],
        );
        state = AsyncValue.data(child);
      } else {
        // Auto-provision a "Guest" child for immediate access (Toddler Mode)
        final guestChild = Child(
          id: 'guest_${DateTime.now().millisecondsSinceEpoch}',
          name: 'Guest',
          age: 2, // Default age
        );
        await createChild(guestChild.name, guestChild.age);
        // createChild updates state, so no need to set state here again
        // But createChild is async and updates state.
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> createChild(String name, int age) async {
    state = const AsyncValue.loading();
    try {
      final newChild = Child(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        age: age,
      );
      
      await dataService.saveChild(newChild);
      
      // Save to local storage
      final map = {'id': newChild.id, 'name': newChild.name, 'age': newChild.age};
      await prefs.setString('current_child', jsonEncode(map));
      await prefs.setString('last_child_id', newChild.id); // For parent dashboard access after logout
      
      state = AsyncValue.data(newChild);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> logout() async {
    await prefs.remove('current_child');
    state = const AsyncValue.data(null);
  }
}

// Adaptive Service Provider
final adaptiveServiceProvider = Provider<AdaptiveService>((ref) {
  final dataService = ref.watch(mockDataServiceProvider);
  return AdaptiveService(dataService);
});

final childProvider = StateNotifierProvider<ChildNotifier, AsyncValue<Child?>>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  final dataService = ref.watch(mockDataServiceProvider);
  return ChildNotifier(prefs, dataService);
});
