class UsersState {
  final bool loading;
  final String? error;

  final List<Map<String, dynamic>> searchResults;
  final Map<String, dynamic>? profile;

  final List<Map<String, dynamic>> incomingFriendRequests;

  final Set<String> pendingFriendUserIds;
  final Set<String> friendUserIds;

  const UsersState({
    this.loading = false,
    this.error,
    this.searchResults = const [],
    this.profile,
    this.incomingFriendRequests = const [],
    this.pendingFriendUserIds = const {},
    this.friendUserIds = const {},
  });

  UsersState copyWith({
    bool? loading,
    Object? error = _noChange,
    List<Map<String, dynamic>>? searchResults,
    Object? profile = _noChange,
    List<Map<String, dynamic>>? incomingFriendRequests,
    Set<String>? pendingFriendUserIds,
    Set<String>? friendUserIds,
  }) {
    return UsersState(
      loading: loading ?? this.loading,
      error: error == _noChange ? this.error : error as String?,
      searchResults: searchResults ?? this.searchResults,
      profile: profile == _noChange
          ? this.profile
          : profile as Map<String, dynamic>?,
      incomingFriendRequests:
          incomingFriendRequests ?? this.incomingFriendRequests,
      pendingFriendUserIds: pendingFriendUserIds ?? this.pendingFriendUserIds,
      friendUserIds: friendUserIds ?? this.friendUserIds,
    );
  }
}

class _NoChange {
  const _NoChange();
}

const _noChange = _NoChange();