import '../entities/user.dart';

/// Abstract repository for authentication operations
abstract class AuthRepository {
  /// Stream of authentication state changes
  Stream<User?> get authStateChanges;

  /// Get the current authenticated user
  User? get currentUser;

  /// Sign in with email and password
  Future<User> signInWithEmail(String email, String password);

  /// Sign up with email and password
  Future<User> signUpWithEmail(String email, String password);

  /// Sign in with Google
  Future<User> signInWithGoogle();

  /// Sign out the current user
  Future<void> signOut();

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email);

  /// Update user profile
  Future<void> updateProfile({String? displayName, String? photoURL});

  /// Delete user account
  Future<void> deleteAccount();
}