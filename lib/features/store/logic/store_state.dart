class StoreState {
  final bool loading;
  final String? error;

  final int points;

  final List<Map<String, dynamic>> items;
  final List<Map<String, dynamic>> inventory;

  const StoreState({
    this.loading = false,
    this.error,
    this.points = 0,
    this.items = const [],
    this.inventory = const [],
  });

  StoreState copyWith({
    bool? loading,
    Object? error = _noChange,
    int? points,
    List<Map<String, dynamic>>? items,
    List<Map<String, dynamic>>? inventory,
  }) {
    return StoreState(
      loading: loading ?? this.loading,
      error: error == _noChange ? this.error : error as String?,
      points: points ?? this.points,
      items: items ?? this.items,
      inventory: inventory ?? this.inventory,
    );
  }

  bool isOwned(String itemId) {
    return inventory.any((item) {
      return item['itemId']?.toString() == itemId;
    });
  }

  bool isActive(String itemId) {
    return inventory.any((item) {
      return item['itemId']?.toString() == itemId &&
          item['isActive'] == true;
    });
  }

  Map<String, dynamic>? ownedItem(String itemId) {
    for (final item in inventory) {
      if (item['itemId']?.toString() == itemId) {
        return item;
      }
    }

    return null;
  }

  String? expiresAt(String itemId) {
    final item = ownedItem(itemId);
    return item?['expiresAt']?.toString();
  }

  int? daysLeft(String itemId) {
    final expires = expiresAt(itemId);

    if (expires == null || expires.isEmpty) {
      return null;
    }

    final date = DateTime.tryParse(expires);

    if (date == null) {
      return null;
    }

    final diff = date.difference(DateTime.now()).inDays;

    if (diff < 0) {
      return 0;
    }

    return diff + 1;
  }
}

class _NoChange {
  const _NoChange();
}

const _noChange = _NoChange();