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
    try {
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        _logger.info('Current user: ${user.email}, displayName: ${user.displayName}');
      }
      return user != null ? UserModel.fromFirebaseUser(user) : null;
    } catch (e) {
      _logger.error('Error getting current user', e);
      return null;
    }
  }
  
  // Stream of auth state changes
  Stream<UserModel?> get authStateChanges {
    return _firebaseAuth.authStateChanges().map((user) {
      return user != null ? UserModel.fromFirebaseUser(user) : null;
    });
  }
  
  // Sign up with email and password - SIMPLIFIED
  Future<UserModel> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      _logger.info('Attempting to sign up user: $email with name: $name');
      
      // Create user
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      final user = userCredential.user;
      if (user == null) {
        throw Exception('User creation failed');
      }
      
      _logger.info('User created successfully: ${user.uid}');
      
      // Update display name
      try {
        await user.updateDisplayName(name);
        _logger.info('Display name updated to: $name');
      } catch (e) {
        _logger.warning('Failed to update display name: $e');
        // Continue anyway - not critical
      }
      
      // Wait for Firebase to sync
      await Future.delayed(const Duration(milliseconds: 800));
      
      // Get updated user
      final currentUser = _firebaseAuth.currentUser;
      if (currentUser == null) {
        throw Exception('Failed to get updated user');
      }
      
      _logger.info('Sign up complete. Display name: ${currentUser.displayName}');
      return UserModel.fromFirebaseUser(currentUser);
      
    } on FirebaseAuthException catch (e) {
      _logger.error('Firebase Auth Error during sign up', e);
      throw _handleAuthException(e);
    } catch (e) {
      _logger.error('Unknown error during sign up', e);
      throw Exception('An unexpected error occurred. Please try again.');
    }
  }
  
  // Sign in with email and password - SIMPLIFIED
  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    try {
      _logger.info('Attempting to sign in user: $email');
      
      // Sign in
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      final user = userCredential.user;
      if (user == null) {
        throw Exception('Sign in failed - no user returned');
      }
      
      _logger.info('User signed in successfully: ${user.uid}, displayName: ${user.displayName}');
      
      // Wait for Firebase to be ready
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Get current user
      final currentUser = _firebaseAuth.currentUser;
      if (currentUser == null) {
        throw Exception('Failed to get current user after sign in');
      }
      
      return UserModel.fromFirebaseUser(currentUser);
      
    } on FirebaseAuthException catch (e) {
      _logger.error('Firebase Auth Error during sign in', e);
      throw _handleAuthException(e);
    } catch (e) {
      _logger.error('Unknown error during sign in', e);
      throw Exception('Failed to sign in. Please try again.');
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
    _logger.warning('Firebase Auth Exception: ${e.code} - ${e.message}');
    
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
        return 'Invalid email or password. Please try again.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'operation-not-allowed':
        return 'This operation is not allowed.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      default:
        return e.message ?? 'Authentication failed. Please try again.';
    }
  }
}