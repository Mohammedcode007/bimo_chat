enum RoomRole { none, member, admin, owner, banned }

extension RoomRoleX on RoomRole {
  String get label {
    switch (this) {
      case RoomRole.none:
        return 'none';
      case RoomRole.member:
        return 'member';
      case RoomRole.admin:
        return 'admin';
      case RoomRole.owner:
        return 'owner';
      case RoomRole.banned:
        return 'banned';
    }
  }

  int get rank {
    switch (this) {
      case RoomRole.none:
        return 0;
      case RoomRole.member:
        return 1;
      case RoomRole.admin:
        return 2;
      case RoomRole.owner:
        return 3;
      case RoomRole.banned:
        return -1;
    }
  }
}
