import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/di/dependency_injection.dart';
import '../../domain/entities/user.dart';
import '../../core/errors/exceptions.dart';

/// Provider for authentication state
final authStateProvider = StreamProvider<User?>((ref) {
  final getAuthStateChangesUseCase = ref.read(getAuthStateChangesUseCaseProvider);
  return getAuthStateChangesUseCase();
});

/// Provider for current user
final currentUserProvider = Provider<User?>((ref) {
  final getCurrentUserUseCase = ref.read(getCurrentUserUseCaseProvider);
  return getCurrentUserUseCase();
});

/// Notifier for authentication operations
class AuthNotifier extends StateNotifier<AsyncValue<User?>> {
  final Ref _ref;

  AuthNotifier(this._ref) : super(const AsyncValue.data(null));

  /// Sign in with email and password
  Future<void> signInWithEmail(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final signInUseCase = _ref.read(signInWithEmailUseCaseProvider);
      final user = await signInUseCase(email, password);
      state = AsyncValue.data(user);
    } on AuthException catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    } catch (e) {
      state = AsyncValue.error(
        AuthException('Sign in failed: $e'),
        StackTrace.current,
      );
    }
  }

  /// Sign up with email and password
  Future<void> signUpWithEmail(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final signUpUseCase = _ref.read(signUpWithEmailUseCaseProvider);
      final user = await signUpUseCase(email, password);
      state = AsyncValue.data(user);
    } on AuthException catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    } catch (e) {
      state = AsyncValue.error(
        AuthException('Sign up failed: $e'),
        StackTrace.current,
      );
    }
  }

  /// Sign in with Google
  Future<void> signInWithGoogle() async {
    state = const AsyncValue.loading();
    try {
      final signInWithGoogleUseCase = _ref.read(signInWithGoogleUseCaseProvider);
      final user = await signInWithGoogleUseCase();
      state = AsyncValue.data(user);
    } on AuthException catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    } catch (e) {
      state = AsyncValue.error(
        AuthException('Google sign in failed: $e'),
        StackTrace.current,
      );
    }
  }

  /// Sign out
  Future<void> signOut() async {
    state = const AsyncValue.loading();
    try {
      final signOutUseCase = _ref.read(signOutUseCaseProvider);
      await signOutUseCase();
      state = const AsyncValue.data(null);
    } on AuthException catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    } catch (e) {
      state = AsyncValue.error(
        AuthException('Sign out failed: $e'),
        StackTrace.current,
      );
    }
  }

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      final sendPasswordResetUseCase = _ref.read(sendPasswordResetEmailUseCaseProvider);
      await sendPasswordResetUseCase(email);
    } on AuthException catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    } catch (e) {
      final error = AuthException('Password reset failed: $e');
      state = AsyncValue.error(error, StackTrace.current);
      throw error;
    }
  }

  /// Clear error state
  void clearError() {
    if (state.hasError) {
      state = const AsyncValue.data(null);
    }
  }
}

/// Provider for auth notifier
final authNotifierProvider = StateNotifierProvider<AuthNotifier, AsyncValue<User?>>((ref) {
  return AuthNotifier(ref);
});