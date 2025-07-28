import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../core/errors/exceptions.dart';

abstract class FirebaseAuthDataSource {
  Future<UserCredential> signInWithEmail(String email, String password);
  Future<UserCredential> signUpWithEmail(String email, String password);
  Future<UserCredential> signInWithGoogle();
  Future<void> signOut();
  Future<void> sendPasswordResetEmail(String email);
  Future<void> updateProfile({String? displayName, String? photoURL});
  Future<void> deleteAccount();
  Stream<User?> get authStateChanges;
  User? get currentUser;
}

class FirebaseAuthDataSourceImpl implements FirebaseAuthDataSource {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  FirebaseAuthDataSourceImpl({
    FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn();

  @override
  Future<UserCredential> signInWithEmail(String email, String password) async {
    try {
      return await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  @override
  Future<UserCredential> signUpWithEmail(String email, String password) async {
    try {
      return await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  @override
  Future<UserCredential> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw Exception('Google sign in was cancelled');
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return await _firebaseAuth.signInWithCredential(credential);
    } catch (e) {
      throw Exception('Google sign in failed: $e');
    }
  }

  @override
  Future<void> signOut() async {
    await Future.wait([
      _firebaseAuth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  @override
  Future<void> updateProfile({String? displayName, String? photoURL}) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw const AuthException('No authenticated user found');
      }
      
      await user.updateDisplayName(displayName);
      if (photoURL != null) {
        await user.updatePhotoURL(photoURL);
      }
      await user.reload();
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  @override
  Future<void> deleteAccount() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw const AuthException('No authenticated user found');
      }
      
      await user.delete();
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  @override
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  @override
  User? get currentUser => _firebaseAuth.currentUser;

  AuthException _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return const AuthException('No user found for that email.');
      case 'wrong-password':
        return const AuthException('Wrong password provided.');
      case 'email-already-in-use':
        return const AuthException('The account already exists for that email.');
      case 'weak-password':
        return const AuthException('The password provided is too weak.');
      case 'invalid-email':
        return const AuthException('The email address is not valid.');
      case 'user-disabled':
        return const AuthException('This user account has been disabled.');
      case 'too-many-requests':
        return const AuthException('Too many requests. Please try again later.');
      case 'operation-not-allowed':
        return const AuthException('This operation is not allowed.');
      case 'requires-recent-login':
        return const AuthException('This operation requires recent authentication.');
      default:
        return AuthException(e.message ?? 'An authentication error occurred.');
    }
  }
}