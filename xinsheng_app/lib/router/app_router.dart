import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../screens/splash_screen.dart';
import '../screens/login_screen.dart';
import '../screens/register_screen.dart';
import '../screens/forgot_password_screen.dart';
import '../screens/main_screen.dart';
import '../screens/note_detail_screen.dart';
import '../screens/user_profile_screen.dart';
import '../screens/following_screen.dart';
import '../screens/likes_received_screen.dart';
import '../screens/my_notes_screen.dart';
import '../screens/my_favorites_screen.dart';
import '../screens/my_comments_screen.dart';
import '../screens/account_profile_screen.dart';
import '../screens/terms_screen.dart';
import '../screens/privacy_screen.dart';
import '../screens/settings_screen.dart';

// Router configuration
final appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/forgot-password',
      builder: (context, state) => const ForgotPasswordScreen(),
    ),
    GoRoute(
      path: '/',
      builder: (context, state) => const MainScreen(),
    ),
    GoRoute(
      path: '/note/:id',
      builder: (context, state) {
        final noteId = state.pathParameters['id']!;
        final returnPath = state.uri.queryParameters['return'] ?? '/';
        return NoteDetailScreen(noteId: noteId, returnPath: returnPath);
      },
    ),
    GoRoute(
      path: '/user/:id',
      builder: (context, state) {
        final userId = state.pathParameters['id']!;
        return UserProfileScreen(userId: userId);
      },
    ),
    GoRoute(
      path: '/following',
      builder: (context, state) => const FollowingScreen(),
    ),
    GoRoute(
      path: '/likes-received',
      builder: (context, state) => const LikesReceivedScreen(),
    ),
    GoRoute(
      path: '/my-notes',
      builder: (context, state) => const MyNotesScreen(),
    ),
    GoRoute(
      path: '/my-favorites',
      builder: (context, state) => const MyFavoritesScreen(),
    ),
    GoRoute(
      path: '/my-comments',
      builder: (context, state) => const MyCommentsScreen(),
    ),
    GoRoute(
      path: '/account-profile',
      builder: (context, state) => const AccountProfileScreen(),
    ),
    GoRoute(
      path: '/terms',
      builder: (context, state) => const TermsScreen(),
    ),
    GoRoute(
      path: '/privacy',
      builder: (context, state) => const PrivacyScreen(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
  ],
);
