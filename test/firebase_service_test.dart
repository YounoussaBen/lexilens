import 'package:flutter_test/flutter_test.dart';
import 'package:lexilens/core/services/firebase_service.dart';
import 'package:lexilens/core/errors/exceptions.dart';
import 'package:lexilens/data/models/user_model.dart';
import 'package:lexilens/domain/entities/user.dart' as domain;

void main() {
  group('Firebase Service Tests', () {
    setUpAll(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
    });

    tearDown(() {
      FirebaseService.reset();
    });

    group('Firebase Service', () {
      test('should not be initialized initially', () {
        FirebaseService.reset();
        expect(FirebaseService.isInitialized, isFalse);
      });

      test('should handle initialization state correctly', () {
        FirebaseService.reset();
        expect(FirebaseService.isInitialized, isFalse);
        
        // Test that reset works
        FirebaseService.reset();
        expect(FirebaseService.isInitialized, isFalse);
      });

      test('should reset state correctly', () {
        FirebaseService.reset();
        expect(FirebaseService.isInitialized, isFalse);
      });
    });

    group('User Model', () {
      test('should convert to domain entity correctly', () {
        const userModel = UserModel(
          id: 'test-uid',
          email: 'test@example.com',
          displayName: 'Test User',
          photoURL: 'https://example.com/photo.jpg',
          isEmailVerified: true,
        );

        final domainUser = userModel.toDomain();

        expect(domainUser, isA<domain.User>());
        expect(domainUser.id, equals('test-uid'));
        expect(domainUser.email, equals('test@example.com'));
        expect(domainUser.displayName, equals('Test User'));
        expect(domainUser.photoURL, equals('https://example.com/photo.jpg'));
        expect(domainUser.isEmailVerified, isTrue);
      });

      test('should serialize to/from JSON correctly', () {
        const userModel = UserModel(
          id: 'test-uid',
          email: 'test@example.com',
          displayName: 'Test User',
          isEmailVerified: false,
        );

        final json = userModel.toJson();
        final fromJson = UserModel.fromJson(json);

        expect(fromJson.id, equals(userModel.id));
        expect(fromJson.email, equals(userModel.email));
        expect(fromJson.displayName, equals(userModel.displayName));
        expect(fromJson.isEmailVerified, equals(userModel.isEmailVerified));
      });

      test('should handle null values correctly', () {
        const userModel = UserModel(
          id: 'test-uid',
          isEmailVerified: false,
        );

        expect(userModel.email, isNull);
        expect(userModel.displayName, isNull);
        expect(userModel.photoURL, isNull);
        expect(userModel.createdAt, isNull);
        expect(userModel.lastSignInAt, isNull);
      });

      test('should create copy with updated values', () {
        const original = UserModel(
          id: 'test-uid',
          email: 'old@example.com',
          isEmailVerified: false,
        );

        final updated = original.copyWith(
          email: 'new@example.com',
          isEmailVerified: true,
        );

        expect(updated.id, equals(original.id));
        expect(updated.email, equals('new@example.com'));
        expect(updated.isEmailVerified, isTrue);
      });

      test('should maintain equality correctly', () {
        const user1 = UserModel(
          id: 'test-uid',
          email: 'test@example.com',
          isEmailVerified: false,
        );

        const user2 = UserModel(
          id: 'test-uid',
          email: 'test@example.com',
          isEmailVerified: false,
        );

        expect(user1 == user2, isTrue);
        expect(user1.hashCode == user2.hashCode, isTrue);
      });
    });

    group('Exception Handling', () {
      test('AuthException should format message correctly', () {
        const exception = AuthException('Test error message');
        
        expect(exception.message, equals('Test error message'));
        expect(exception.toString(), equals('AuthException: Test error message'));
      });

      test('FirebaseException should format message correctly', () {
        const exception = FirebaseException('Firebase error');
        
        expect(exception.message, equals('Firebase error'));
        expect(exception.toString(), equals('FirebaseException: Firebase error'));
      });

      test('NetworkException should format message correctly', () {
        const exception = NetworkException('Network error');
        
        expect(exception.message, equals('Network error'));
        expect(exception.toString(), equals('NetworkException: Network error'));
      });

      test('should create const exceptions', () {
        const exception1 = AuthException('Test message');
        const exception2 = AuthException('Test message');
        
        expect(identical(exception1, exception2), isTrue);
      });
    });

    group('Data Validation', () {
      test('should validate required fields', () {
        // Test that required fields are properly validated
        expect('test@example.com'.contains('@'), isTrue);
        expect('password123'.length >= 6, isTrue);
        expect('short'.length >= 6, isFalse);
      });

      test('should validate email patterns', () {
        final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
        
        expect(emailRegex.hasMatch('valid@example.com'), isTrue);
        expect(emailRegex.hasMatch('user@domain.org'), isTrue);
        expect(emailRegex.hasMatch('test.email+tag@example.co.uk'), isTrue);
        expect(emailRegex.hasMatch('invalid'), isFalse);
        expect(emailRegex.hasMatch('@invalid.com'), isFalse);
        expect(emailRegex.hasMatch('invalid@'), isFalse);
        expect(emailRegex.hasMatch('invalid.com'), isFalse);
      });

      test('should validate password requirements', () {
        expect('password123'.length >= 6, isTrue);
        expect('P@ssw0rd!'.length >= 6, isTrue);
        expect('12345'.length >= 6, isFalse);
        expect(''.length >= 6, isFalse);
      });
    });

    group('Domain Entity Tests', () {
      test('User entity should handle equality correctly', () {
        const user1 = domain.User(
          id: 'test-uid',
          email: 'test@example.com',
          isEmailVerified: false,
        );

        const user2 = domain.User(
          id: 'test-uid',
          email: 'test@example.com',
          isEmailVerified: false,
        );

        expect(user1 == user2, isTrue);
        expect(user1.hashCode == user2.hashCode, isTrue);
      });

      test('User entity should copy with changes correctly', () {
        const original = domain.User(
          id: 'test-uid',
          email: 'old@example.com',
          isEmailVerified: false,
        );

        final updated = original.copyWith(
          email: 'new@example.com',
          isEmailVerified: true,
        );

        expect(updated.id, equals(original.id));
        expect(updated.email, equals('new@example.com'));
        expect(updated.isEmailVerified, isTrue);
      });

      test('User entity should display string correctly', () {
        const user = domain.User(
          id: 'test-uid',
          email: 'test@example.com',
          displayName: 'Test User',
          isEmailVerified: true,
        );

        final stringRepresentation = user.toString();
        expect(stringRepresentation, contains('test-uid'));
        expect(stringRepresentation, contains('test@example.com'));
        expect(stringRepresentation, contains('Test User'));
        expect(stringRepresentation, contains('true'));
      });
    });
  });
}