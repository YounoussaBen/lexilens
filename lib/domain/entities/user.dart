/// Domain entity representing a user in the application
class User {
  final String id;
  final String? email;
  final String? displayName;
  final String? photoURL;
  final bool isEmailVerified;
  final DateTime? createdAt;
  final DateTime? lastSignInAt;

  const User({
    required this.id,
    this.email,
    this.displayName,
    this.photoURL,
    required this.isEmailVerified,
    this.createdAt,
    this.lastSignInAt,
  });

  User copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoURL,
    bool? isEmailVerified,
    DateTime? createdAt,
    DateTime? lastSignInAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoURL: photoURL ?? this.photoURL,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      createdAt: createdAt ?? this.createdAt,
      lastSignInAt: lastSignInAt ?? this.lastSignInAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          email == other.email &&
          displayName == other.displayName &&
          photoURL == other.photoURL &&
          isEmailVerified == other.isEmailVerified &&
          createdAt == other.createdAt &&
          lastSignInAt == other.lastSignInAt;

  @override
  int get hashCode =>
      id.hashCode ^
      email.hashCode ^
      displayName.hashCode ^
      photoURL.hashCode ^
      isEmailVerified.hashCode ^
      createdAt.hashCode ^
      lastSignInAt.hashCode;

  @override
  String toString() {
    return 'User{id: $id, email: $email, displayName: $displayName, isEmailVerified: $isEmailVerified}';
  }
}