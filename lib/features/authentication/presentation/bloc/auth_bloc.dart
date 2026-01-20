import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/auth_repository.dart';
import '../../../../managers/logger_manager.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  final LoggerManager _logger = LoggerManager();
  
  AuthBloc({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(const AuthInitial()) {
    
    // Check authentication status
    on<AuthCheckRequested>(_onAuthCheckRequested);
    
    // Sign up
    on<AuthSignUpRequested>(_onSignUpRequested);
    
    // Sign in
    on<AuthSignInRequested>(_onSignInRequested);
    
    // Sign out
    on<AuthSignOutRequested>(_onSignOutRequested);
  }
  
  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    _logger.info('Checking authentication status');
    
    final user = _authRepository.currentUser;
    
    if (user != null) {
      _logger.info('User is authenticated: ${user.email}');
      emit(AuthAuthenticated(user: user));
    } else {
      _logger.info('User is not authenticated');
      emit(const AuthUnauthenticated());
    }
  }
  
  Future<void> _onSignUpRequested(
    AuthSignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    
    try {
      _logger.info('Sign up requested for: ${event.email}');
      
      final user = await _authRepository.signUp(
        email: event.email,
        password: event.password,
        name: event.name,
      );
      
      _logger.info('Sign up successful');
      emit(AuthAuthenticated(user: user));
    } catch (e) {
      _logger.error('Sign up failed', e);
      emit(AuthError(message: e.toString()));
      emit(const AuthUnauthenticated());
    }
  }
  
  Future<void> _onSignInRequested(
    AuthSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    
    try {
      _logger.info('Sign in requested for: ${event.email}');
      
      final user = await _authRepository.signIn(
        email: event.email,
        password: event.password,
      );
      
      _logger.info('Sign in successful');
      emit(AuthAuthenticated(user: user));
    } catch (e) {
      _logger.error('Sign in failed', e);
      emit(AuthError(message: e.toString()));
      emit(const AuthUnauthenticated());
    }
  }
  
  Future<void> _onSignOutRequested(
    AuthSignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    
    try {
      _logger.info('Sign out requested');
      await _authRepository.signOut();
      _logger.info('Sign out successful');
      emit(const AuthUnauthenticated());
    } catch (e) {
      _logger.error('Sign out failed', e);
      emit(AuthError(message: e.toString()));
    }
  }
}