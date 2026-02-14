import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/firebase_service.dart';

// Auth state
class AuthState {
  final UserModel? user;
  final bool isLoading;
  final String? error;

  AuthState({
    this.user,
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({
    UserModel? user,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  bool get isLoggedIn => user != null;
}

// Auth notifier
class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState()) {
    _init();
  }

  void _init() {
    // Listen to auth state changes
    AuthService.authStateChanges.listen((firebaseUser) async {
      if (firebaseUser != null) {
        final user = await AuthService.getUserById(firebaseUser.uid);
        state = state.copyWith(user: user);
      } else {
        state = state.copyWith(user: null);
      }
    });

    // Initialize system data
    FirebaseService.initializeSystemData();
  }

  Future<void> login(String username, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await AuthService.login(
        username: username,
        password: password,
      );
      state = state.copyWith(user: user, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> register({
    required String username,
    required String nickname,
    required String phone,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await AuthService.register(
        username: username,
        nickname: nickname,
        phone: phone,
        password: password,
      );
      state = state.copyWith(user: user, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> logout() async {
    await AuthService.logout();
    state = state.copyWith(user: null);
  }

  Future<void> updateUser(UserModel user) async {
    await AuthService.updateUser(user);
    state = state.copyWith(user: user);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

// Current user stream
final currentUserProvider = StreamProvider<UserModel?>((ref) {
  return AuthService.authStateChanges.asyncMap((firebaseUser) async {
    if (firebaseUser != null) {
      return await AuthService.getUserById(firebaseUser.uid);
    }
    return null;
  });
});
