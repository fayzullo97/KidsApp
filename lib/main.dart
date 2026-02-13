import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:kids_learning_app/providers/providers.dart';
import 'package:kids_learning_app/screens/onboarding_screen.dart';
import 'package:kids_learning_app/screens/video_feed_screen.dart';
import 'package:kids_learning_app/screens/dashboard/dashboard_overview_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // TODO: Replace with your actual Supabase URL and Anon Key
  await Supabase.initialize(
    url: 'https://zueoevkcfbmukmjfgehu.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inp1ZW9ldmtjZmJtdWttamZnZWh1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzA5MTQ5ODAsImV4cCI6MjA4NjQ5MDk4MH0.syQMu-YSHG1GPMsIdG7fxATzlbSS3m8PtWUV0uf0aI8',
  );

  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const KidsApp(),
    ),
  );
}

class KidsApp extends ConsumerWidget {
  const KidsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/onboarding',
          builder: (context, state) => const OnboardingScreen(),
        ),
        GoRoute(
          path: '/feed',
          builder: (context, state) => const VideoFeedScreen(),
        ),
        GoRoute(
          path: '/dashboard',
          builder: (context, state) => const DashboardOverviewScreen(),
        ),

        GoRoute(
          path: '/',
          builder: (context, state) => const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          ),
        ),
      ],
      redirect: (context, state) {
        final childAsync = ref.read(childProvider);
        
        // If loading, stay or show splash (not handled here specifically)
        if (childAsync.isLoading) return null;

        final isLoggedIn = childAsync.value != null;
        final isLoggingIn = state.uri.toString() == '/onboarding';
        final isDashboard = state.uri.toString() == '/dashboard';

        // Default to feed if logged in (which is auto-provisioned now)
        if (isLoggedIn && (state.uri.toString() == '/' || isLoggingIn)) return '/feed';

        // Allow dashboard access
        if (isDashboard) return null;

        // Fallback (though ChildNotifier auto-creates child now)
        if (!isLoggedIn && !isLoggingIn) return null; 

        return null;
      },
      // This is crucial: listen to the provider to trigger redirects!
      refreshListenable: GoRouterRefreshStream(ref.watch(childProvider.notifier).stream),
    );

    return MaterialApp.router(
      title: 'Kids Learning App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFFF6B6B)),
        useMaterial3: true,
      ),
      routerConfig: router,
    );
  }
}

// Helper for Riverpod + GoRouter listening
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
      (dynamic _) => notifyListeners(),
    );
  }

  late final dynamic _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
