// class AuthState {
//   final bool loading;
//   final bool loggedIn;

//   final String? userId;
//   final String? username;
//   final String? photoUrl;

//   // كل بيانات اليوزر القادمة من الباك بدون password
//   final Map<String, dynamic>? user;

//   final String? error;

//   const AuthState({
//     this.loading = false,
//     this.loggedIn = false,
//     this.userId,
//     this.username,
//     this.photoUrl,
//     this.user,
//     this.error,
//   });

//   AuthState copyWith({
//     bool? loading,
//     bool? loggedIn,
//     String? userId,
//     String? username,
//     String? photoUrl,
//     Map<String, dynamic>? user,
//     String? error,
//   }) {
//     return AuthState(
//       loading: loading ?? this.loading,
//       loggedIn: loggedIn ?? this.loggedIn,
//       userId: userId ?? this.userId,
//       username: username ?? this.username,
//       photoUrl: photoUrl ?? this.photoUrl,
//       user: user ?? this.user,
//       error: error,
//     );
//   }
// }

class AuthState {
  final bool initialized;
  final bool loading;
  final bool loggedIn;

  final String? userId;
  final String? username;
  final String? photoUrl;

  // كل بيانات اليوزر القادمة من الباك بدون password
  final Map<String, dynamic>? user;

  final String? error;

  const AuthState({
    this.initialized = false,
    this.loading = false,
    this.loggedIn = false,
    this.userId,
    this.username,
    this.photoUrl,
    this.user,
    this.error,
  });

  AuthState copyWith({
    bool? initialized,
    bool? loading,
    bool? loggedIn,
    String? userId,
    String? username,
    String? photoUrl,
    Map<String, dynamic>? user,
    String? error,
  }) {
    return AuthState(
      initialized: initialized ?? this.initialized,
      loading: loading ?? this.loading,
      loggedIn: loggedIn ?? this.loggedIn,
      userId: userId ?? this.userId,
      username: username ?? this.username,
      photoUrl: photoUrl ?? this.photoUrl,
      user: user ?? this.user,
      error: error,
    );
  }
}