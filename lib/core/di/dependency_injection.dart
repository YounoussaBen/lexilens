import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

// Data Sources
import '../../data/datasources/firebase_auth_datasource.dart';
import '../../data/datasources/firestore_datasource.dart';
import '../../data/datasources/yolo_detection_datasource.dart';

// Repositories
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/object_detection_repository.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/object_detection_repository_impl.dart';

// Use Cases
import '../../domain/usecases/auth_usecases.dart';
import '../../domain/usecases/detect_objects_usecase.dart';

// Firebase Instances
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

final googleSignInProvider = Provider<GoogleSignIn>((ref) {
  return GoogleSignIn();
});

// Data Sources
final firebaseAuthDataSourceProvider = Provider<FirebaseAuthDataSource>((ref) {
  return FirebaseAuthDataSourceImpl(
    firebaseAuth: ref.read(firebaseAuthProvider),
    googleSignIn: ref.read(googleSignInProvider),
  );
});

final firestoreDataSourceProvider = Provider<FirestoreDataSource>((ref) {
  return FirestoreDataSourceImpl(
    firestore: ref.read(firestoreProvider),
  );
});

final yoloDetectionDataSourceProvider = Provider<YoloDetectionDataSource>((ref) {
  return YoloDetectionDataSourceImpl();
});

// Repositories
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    ref.read(firebaseAuthDataSourceProvider),
  );
});

final objectDetectionRepositoryProvider = Provider<ObjectDetectionRepository>((ref) {
  return ObjectDetectionRepositoryImpl(
    ref.read(yoloDetectionDataSourceProvider),
  );
});

// Use Cases
final signInWithEmailUseCaseProvider = Provider<SignInWithEmailUseCase>((ref) {
  return SignInWithEmailUseCase(ref.read(authRepositoryProvider));
});

final signUpWithEmailUseCaseProvider = Provider<SignUpWithEmailUseCase>((ref) {
  return SignUpWithEmailUseCase(ref.read(authRepositoryProvider));
});

final signInWithGoogleUseCaseProvider = Provider<SignInWithGoogleUseCase>((ref) {
  return SignInWithGoogleUseCase(ref.read(authRepositoryProvider));
});

final signOutUseCaseProvider = Provider<SignOutUseCase>((ref) {
  return SignOutUseCase(ref.read(authRepositoryProvider));
});

final getCurrentUserUseCaseProvider = Provider<GetCurrentUserUseCase>((ref) {
  return GetCurrentUserUseCase(ref.read(authRepositoryProvider));
});

final getAuthStateChangesUseCaseProvider = Provider<GetAuthStateChangesUseCase>((ref) {
  return GetAuthStateChangesUseCase(ref.read(authRepositoryProvider));
});

final sendPasswordResetEmailUseCaseProvider = Provider<SendPasswordResetEmailUseCase>((ref) {
  return SendPasswordResetEmailUseCase(ref.read(authRepositoryProvider));
});

final detectObjectsUseCaseProvider = Provider<DetectObjectsUseCase>((ref) {
  return DetectObjectsUseCase(ref.read(objectDetectionRepositoryProvider));
});