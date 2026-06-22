import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/ws_events.dart';
import '../../../core/constants/ws_handlers.dart';
import '../../../core/network/ws_background_controller.dart';
import '../../../core/network/ws_event_bus.dart';
import '../../auth/logic/auth_provider.dart';
import 'store_state.dart';

final storeProvider = StateNotifierProvider<StoreController, StoreState>((ref) {
  return StoreController(ref);
});

class StoreController extends StateNotifier<StoreState> {
  final Ref ref;

  StreamSubscription? _sub;

  StoreController(this.ref) : super(const StoreState()) {
    _listen();
  }

  void _listen() {
    _sub?.cancel();

    _sub = WsEventBus.instance.stream.listen((data) {
      final handler = data['handler']?.toString();
      final type = data['type']?.toString();

      if (handler == WsEvents.storeItemsEvent) {
        _handleStoreItems(data, type);
        return;
      }

      if (handler == WsEvents.storeBuyEvent ||
          handler == WsEvents.storeActivateEvent ||
          handler == WsEvents.storePointsEvent) {
        _handleStoreAction(data, type);
        return;
      }
    });
  }

  void _handleStoreItems(Map<String, dynamic> data, String? type) {
    if (type != 'success') {
      state = state.copyWith(
        loading: false,
        error: data['reason']?.toString() ?? 'store_items_error',
      );
      return;
    }

    final items = _readList(data['items']);
    final inventory = _readList(data['inventory']);

    final points =
        int.tryParse(data['points']?.toString() ?? '') ??
        _readPointsFromUser(data) ??
        state.points;

    state = state.copyWith(
      loading: false,
      error: null,
      points: points,
      items: items,
      inventory: inventory,
    );

    _syncUser(data);
  }

  void _handleStoreAction(Map<String, dynamic> data, String? type) {
    if (type != 'success') {
      state = state.copyWith(
        loading: false,
        error: data['reason']?.toString() ?? 'store_error',
      );
      return;
    }

    _syncUser(data);

    final user = data['user'] is Map<String, dynamic>
        ? Map<String, dynamic>.from(data['user'])
        : <String, dynamic>{};

    final points =
        int.tryParse(user['points']?.toString() ?? '') ??
        int.tryParse(data['points']?.toString() ?? '') ??
        state.points;

    /*
      الباك ممكن يرجع inventory داخل user
      أو يرجع inventory مباشر
      لذلك نقرأ الاثنين
    */
    final inventoryFromUser = _readList(user['inventory']);
    final inventoryFromData = _readList(data['inventory']);

    final nextInventory = inventoryFromUser.isNotEmpty
        ? inventoryFromUser
        : inventoryFromData.isNotEmpty
            ? inventoryFromData
            : state.inventory;

    state = state.copyWith(
      loading: false,
      error: null,
      points: points,
      inventory: nextInventory,
    );
  }

  List<Map<String, dynamic>> _readList(dynamic value) {
    if (value is! List) return <Map<String, dynamic>>[];

    return value
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  int? _readPointsFromUser(Map<String, dynamic> data) {
    if (data['user'] is! Map<String, dynamic>) return null;

    final user = Map<String, dynamic>.from(data['user']);
    return int.tryParse(user['points']?.toString() ?? '');
  }

  void _syncUser(Map<String, dynamic> data) {
    if (data['user'] is! Map<String, dynamic>) return;

    final userMap = Map<String, dynamic>.from(data['user']);

    ref.read(authProvider.notifier).setUserFromServer(userMap);
  }

  void loadStore() {
    state = state.copyWith(
      loading: true,
      error: null,
    );

    sendBackgroundWs({
      'handler': WsHandlers.storeItemsList,
      'request_id': const Uuid().v4(),
    });
  }

  /*
    الشراء الآن يفعّل العنصر مباشرة من الباك
    يعني بعد buyItem لا تحتاج activateItem غالبًا
  */
  void buyItem(String itemId) {
    final cleanItemId = itemId.trim();

    if (cleanItemId.isEmpty) return;

    state = state.copyWith(
      loading: true,
      error: null,
    );

    sendBackgroundWs({
      'handler': WsHandlers.storeItemBuy,
      'request_id': const Uuid().v4(),
      'item_id': cleanItemId,
    });
  }

  /*
    اتركها لو احتجتها لاحقًا، لكن حسب النظام الجديد
    الشراء نفسه يفعّل العنصر مباشرة
  */
  void activateItem(String itemId) {
    final cleanItemId = itemId.trim();

    if (cleanItemId.isEmpty) return;

    state = state.copyWith(
      loading: true,
      error: null,
    );

    sendBackgroundWs({
      'handler': WsHandlers.storeItemActivate,
      'request_id': const Uuid().v4(),
      'item_id': cleanItemId,
    });
  }

  /*
    للتجربة فقط.
    بعد الدفع الحقيقي لا تتركها للمستخدم.
  */
  void addPoints(int amount) {
    if (amount <= 0) return;

    state = state.copyWith(
      loading: true,
      error: null,
    );

    sendBackgroundWs({
      'handler': WsHandlers.storePointsAdd,
      'request_id': const Uuid().v4(),
      'amount': amount,
    });
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}