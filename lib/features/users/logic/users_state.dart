class UsersState {
  final bool loading;
  final String? error;

  final List<Map<String, dynamic>> searchResults;
  final Map<String, dynamic>? profile;

  final List<Map<String, dynamic>> incomingFriendRequests;
  final List<Map<String, dynamic>> friends;
  final List<Map<String, dynamic>> blockedUsers;

  final Set<String> pendingFriendUserIds;
  final Set<String> friendUserIds;
  final Set<String> blockedUserIds;

  const UsersState({
    this.loading = false,
    this.error,
    this.searchResults = const [],
    this.profile,
    this.incomingFriendRequests = const [],
    this.friends = const [],
    this.blockedUsers = const [],
    this.pendingFriendUserIds = const {},
    this.friendUserIds = const {},
    this.blockedUserIds = const {},
  });

  UsersState copyWith({
    bool? loading,
    Object? error = _noChange,
    List<Map<String, dynamic>>? searchResults,
    Object? profile = _noChange,
    List<Map<String, dynamic>>? incomingFriendRequests,
    List<Map<String, dynamic>>? friends,
    List<Map<String, dynamic>>? blockedUsers,
    Set<String>? pendingFriendUserIds,
    Set<String>? friendUserIds,
    Set<String>? blockedUserIds,
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
      friends: friends ?? this.friends,
      blockedUsers: blockedUsers ?? this.blockedUsers,
      pendingFriendUserIds: pendingFriendUserIds ?? this.pendingFriendUserIds,
      friendUserIds: friendUserIds ?? this.friendUserIds,
      blockedUserIds: blockedUserIds ?? this.blockedUserIds,
    );
  }
}

class _NoChange {
  const _NoChange();
}

const _noChange = _NoChange();
