import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../../../../managers/logger_manager.dart';

class AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final LoggerManager _logger = LoggerManager();
  
  AuthRepository({FirebaseAuth? firebaseAuth})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;
  
  // Get current user
  UserModel? get currentUser {
    final user = _firebaseAuth.currentUser;
    return user != null ? UserModel.fromFirebaseUser(user) : null;
  }
  
  // Stream of auth state changes
  Stream<UserModel?> get authStateChanges {
    return _firebaseAuth.authStateChanges().map((user) {
      return user != null ? UserModel.fromFirebaseUser(user) : null;
    });
  }
  
  // Sign up with email and password
Future<UserModel> signUp({
  required String email,
  required String password,
  required String name,
}) async {
  try {
    _logger.info('Attempting to sign up user: $email');
    
    final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    
    // Update display name - FIXED VERSION
    if (userCredential.user != null) {
      await userCredential.user!.updateDisplayName(name);
      await userCredential.user!.reload(); // Reload to get updated info
      
      // Get the fresh user data
      final updatedUser = _firebaseAuth.currentUser;
      
      if (updatedUser == null) {
        throw Exception('User creation failed');
      }
      
      _logger.info('User signed up successfully: ${updatedUser.uid} with name: ${updatedUser.displayName}');
      return UserModel.fromFirebaseUser(updatedUser);
    }
    
    throw Exception('User creation failed');
  } on FirebaseAuthException catch (e) {
    _logger.error('Firebase Auth Error during sign up', e);
    throw _handleAuthException(e);
  } catch (e) {
    _logger.error('Unknown error during sign up', e);
    throw Exception('An unexpected error occurred. Please try again.');
  }
}
  
  // Sign in with email and password
  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    try {
      _logger.info('Attempting to sign in user: $email');
      
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (userCredential.user == null) {
        throw Exception('Sign in failed');
      }
      
      _logger.info('User signed in successfully: ${userCredential.user!.uid}');
      return UserModel.fromFirebaseUser(userCredential.user!);
    } on FirebaseAuthException catch (e) {
      _logger.error('Firebase Auth Error during sign in', e);
      throw _handleAuthException(e);
    } catch (e) {
      _logger.error('Unknown error during sign in', e);
      throw Exception('An unexpected error occurred. Please try again.');
    }
  }
  
  // Sign out
  Future<void> signOut() async {
    try {
      _logger.info('Signing out user');
      await _firebaseAuth.signOut();
      _logger.info('User signed out successfully');
    } catch (e) {
      _logger.error('Error during sign out', e);
      throw Exception('Failed to sign out. Please try again.');
    }
  }
  
  // Handle Firebase Auth exceptions
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'email-already-in-use':
        return 'An account already exists for this email.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'invalid-credential':
        return 'Invalid credentials. Please check your email and password.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'operation-not-allowed':
        return 'This operation is not allowed. Please contact support.';
      case 'network-request-failed':
        return 'Network error. Please check your internet connection.';
      default:
        return e.message ?? 'An authentication error occurred.';
    }
  }
}