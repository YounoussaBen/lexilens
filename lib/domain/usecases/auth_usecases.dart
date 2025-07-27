import '../entities/user.dart';
import '../repositories/auth_repository.dart';

/// Use case for signing in with email and password
class SignInWithEmailUseCase {
  final AuthRepository _authRepository;

  SignInWithEmailUseCase(this._authRepository);

  Future<User> call(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      throw Exception('Email and password are required');
    }
    if (!_isValidEmail(email)) {
      throw Exception('Invalid email format');
    }
    if (password.length < 6) {
      throw Exception('Password must be at least 6 characters');
    }
    
    return await _authRepository.signInWithEmail(email, password);
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email);
  }
}

/// Use case for signing up with email and password
class SignUpWithEmailUseCase {
  final AuthRepository _authRepository;

  SignUpWithEmailUseCase(this._authRepository);

  Future<User> call(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      throw Exception('Email and password are required');
    }
    if (!_isValidEmail(email)) {
      throw Exception('Invalid email format');
    }
    if (password.length < 6) {
      throw Exception('Password must be at least 6 characters');
    }
    
    return await _authRepository.signUpWithEmail(email, password);
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email);
  }
}

/// Use case for signing in with Google
class SignInWithGoogleUseCase {
  final AuthRepository _authRepository;

  SignInWithGoogleUseCase(this._authRepository);

  Future<User> call() async {
    return await _authRepository.signInWithGoogle();
  }
}

/// Use case for signing out
class SignOutUseCase {
  final AuthRepository _authRepository;

  SignOutUseCase(this._authRepository);

  Future<void> call() async {
    await _authRepository.signOut();
  }
}

/// Use case for getting current user
class GetCurrentUserUseCase {
  final AuthRepository _authRepository;

  GetCurrentUserUseCase(this._authRepository);

  User? call() {
    return _authRepository.currentUser;
  }
}

/// Use case for listening to auth state changes
class GetAuthStateChangesUseCase {
  final AuthRepository _authRepository;

  GetAuthStateChangesUseCase(this._authRepository);

  Stream<User?> call() {
    return _authRepository.authStateChanges;
  }
}

/// Use case for sending password reset email
class SendPasswordResetEmailUseCase {
  final AuthRepository _authRepository;

  SendPasswordResetEmailUseCase(this._authRepository);

  Future<void> call(String email) async {
    if (email.isEmpty) {
      throw Exception('Email is required');
    }
    if (!_isValidEmail(email)) {
      throw Exception('Invalid email format');
    }
    
    await _authRepository.sendPasswordResetEmail(email);
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email);
  }
}