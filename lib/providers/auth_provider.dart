import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../entities/user.dart';

class AuthState {
  final User? currentUser;
  final List<User> registeredUsers;
  final String? errorMessage;

  AuthState({
    this.currentUser,
    required this.registeredUsers,
    this.errorMessage,
  });

  bool get isAuthenticated => currentUser != null;

  AuthState copyWith({
    User? currentUser,
    bool clearCurrentUser = false,
    List<User>? registeredUsers,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AuthState(
      currentUser: clearCurrentUser ? null : (currentUser ?? this.currentUser),
      registeredUsers: registeredUsers ?? this.registeredUsers,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    return AuthState(
      currentUser: null,
      registeredUsers: [],
    );
  }

  bool login(String email, String password) {
    final cleanEmail = email.trim().toLowerCase();
    final user = state.registeredUsers.cast<User?>().firstWhere(
          (u) => u?.email.toLowerCase() == cleanEmail && u?.password == password,
          orElse: () => null,
        );

    if (user != null) {
      state = state.copyWith(
        currentUser: user,
        clearError: true,
      );
      return true;
    } else {
      state = state.copyWith(
        errorMessage: 'Correo o contraseña incorrectos',
      );
      return false;
    }
  }

  bool register({
    required String name,
    required String email,
    required String password,
  }) {
    final cleanEmail = email.trim().toLowerCase();
    final userExists = state.registeredUsers.any(
      (u) => u.email.toLowerCase() == cleanEmail,
    );

    if (userExists) {
      state = state.copyWith(
        errorMessage: 'El correo electrónico ya se encuentra registrado',
      );
      return false;
    }

    final newUser = User(
      id: const Uuid().v4(),
      name: name.trim(),
      email: cleanEmail,
      password: password,
    );

    state = state.copyWith(
      registeredUsers: [...state.registeredUsers, newUser],
      currentUser: newUser, // Inicia sesión automáticamente tras el registro
      clearError: true,
    );
    return true;
  }

  void logout() {
    state = state.copyWith(
      clearCurrentUser: true,
      clearError: true,
    );
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(() {
  return AuthNotifier();
});
