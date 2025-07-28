import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/firebase_auth_datasource.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuthDataSource _firebaseAuthDataSource;

  AuthRepositoryImpl(this._firebaseAuthDataSource);

  @override
  Stream<User?> get authStateChanges {
    return _firebaseAuthDataSource.authStateChanges.map((firebaseUser) {
      return firebaseUser != null 
          ? UserModel.fromFirebaseUser(firebaseUser).toDomain()
          : null;
    });
  }

  @override
  User? get currentUser {
    final firebaseUser = _firebaseAuthDataSource.currentUser;
    return firebaseUser != null 
        ? UserModel.fromFirebaseUser(firebaseUser).toDomain()
        : null;
  }

  @override
  Future<User> signInWithEmail(String email, String password) async {
    final userCredential = await _firebaseAuthDataSource.signInWithEmail(email, password);
    if (userCredential.user == null) {
      throw Exception('Sign in failed: No user returned');
    }
    return UserModel.fromFirebaseUser(userCredential.user!).toDomain();
  }

  @override
  Future<User> signUpWithEmail(String email, String password) async {
    final userCredential = await _firebaseAuthDataSource.signUpWithEmail(email, password);
    if (userCredential.user == null) {
      throw Exception('Sign up failed: No user returned');
    }
    return UserModel.fromFirebaseUser(userCredential.user!).toDomain();
  }

  @override
  Future<User> signInWithGoogle() async {
    final userCredential = await _firebaseAuthDataSource.signInWithGoogle();
    if (userCredential.user == null) {
      throw Exception('Google sign in failed: No user returned');
    }
    return UserModel.fromFirebaseUser(userCredential.user!).toDomain();
  }

  @override
  Future<void> signOut() async {
    await _firebaseAuthDataSource.signOut();
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    await _firebaseAuthDataSource.sendPasswordResetEmail(email);
  }

  @override
  Future<void> updateProfile({String? displayName, String? photoURL}) async {
    await _firebaseAuthDataSource.updateProfile(
      displayName: displayName,
      photoURL: photoURL,
    );
  }

  @override
  Future<void> deleteAccount() async {
    await _firebaseAuthDataSource.deleteAccount();
  }
}