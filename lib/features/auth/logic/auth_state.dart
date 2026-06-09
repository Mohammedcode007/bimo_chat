class AuthState {
  final bool loading;
  final bool loggedIn;
  final String? userId;
  final String? username;
  final String? photoUrl;
  final String? error;

  const AuthState({
    this.loading = false,
    this.loggedIn = false,
    this.userId,
    this.username,
    this.photoUrl,
    this.error,
  });

  AuthState copyWith({
    bool? loading,
    bool? loggedIn,
    String? userId,
    String? username,
    String? photoUrl,
    String? error,
  }) {
    return AuthState(
      loading: loading ?? this.loading,
      loggedIn: loggedIn ?? this.loggedIn,
      userId: userId ?? this.userId,
      username: username ?? this.username,
      photoUrl: photoUrl ?? this.photoUrl,
      error: error,
    );
  }
}
