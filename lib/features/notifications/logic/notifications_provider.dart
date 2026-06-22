import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/ws_events.dart';
import '../../../core/constants/ws_handlers.dart';
import '../../../core/network/ws_background_controller.dart';
import '../../../core/network/ws_event_bus.dart';

import '../data/app_notification_model.dart';
import 'notifications_state.dart';

final notificationsProvider =
    StateNotifierProvider<
        NotificationsController,
        NotificationsState>(
  (ref) {
    return NotificationsController();
  },
);

class NotificationsController
    extends StateNotifier<
        NotificationsState> {
  StreamSubscription? _subscription;

  NotificationsController()
      : super(
          const NotificationsState(),
        ) {
    _listen();
  }

  void _listen() {
    _subscription?.cancel();

    _subscription =
        WsEventBus.instance.stream.listen(
      (rawData) {
        if (rawData is! Map) {
          return;
        }

        final data =
            Map<String, dynamic>.from(
          rawData,
        );

        final handler =
            _text(
          data['handler'],
        );

        final eventType =
            _text(
          data['type'],
        ).toLowerCase();

        /*
          إشعارات التويتات تأتي من:
          notification_event
        */
        if (handler !=
                WsEvents.notificationEvent &&
            handler !=
                WsHandlers.notificationsList &&
            handler !=
                WsHandlers.notificationsRead) {
          return;
        }

        print(
          '🔔 NOTIFICATION WS EVENT => $data',
        );

        /*
          إشعار جديد مباشر.
        */
        if (eventType == 'new') {
          _handleNewNotification(
            data,
          );
          return;
        }

        /*
          قائمة الإشعارات من الباك.
        */
        if (data['notifications']
            is List) {
          _handleNotificationList(
            data,
          );
          return;
        }

        /*
          حذف الإشعار بعد فتحه.
        */
        if (eventType == 'deleted' ||
            eventType == 'read' ||
            eventType == 'opened') {
          final notificationId =
              _text(
            data['notificationId'] ??
                data['notification_id'] ??
                data['id'],
          );

          if (notificationId.isNotEmpty) {
            removeLocal(
              notificationId,
            );
          }

          return;
        }

        /*
          بعض الباك يرجع success عند الحذف.
        */
        if (eventType == 'success') {
          final notificationId =
              _text(
            data['notificationId'] ??
                data['notification_id'] ??
                data['id'],
          );

          if (notificationId.isNotEmpty) {
            removeLocal(
              notificationId,
            );
          }

          state = state.copyWith(
            loading: false,
            clearError: true,
          );

          return;
        }

        if (eventType == 'error') {
          state = state.copyWith(
            loading: false,
            error:
                _text(
                  data['reason'] ??
                      data['message'],
                ).isEmpty
                    ? 'notification_error'
                    : _text(
                        data['reason'] ??
                            data['message'],
                      ),
          );
        }
      },
      onError: (
        Object error,
        StackTrace stackTrace,
      ) {
        state = state.copyWith(
          loading: false,
          error:
              error.toString(),
        );
      },
    );
  }

  void _handleNewNotification(
    Map<String, dynamic> data,
  ) {
    final rawNotification =
        data['notification'];

    final notificationMap =
        rawNotification is Map
            ? Map<String, dynamic>.from(
                rawNotification,
              )
            : Map<String, dynamic>.from(
                data,
              );

    final notification =
        AppNotificationModel.fromMap(
      notificationMap,
    );

    if (notification.id.isEmpty) {
      print(
        '⚠️ NEW NOTIFICATION WITHOUT ID',
      );
      return;
    }

    if (!notification
        .isTweetNotification) {
      /*
        طلبات الصداقة تظل من usersProvider.
      */
      return;
    }

    final exists =
        state.tweetNotifications.any(
      (item) =>
          item.id ==
          notification.id,
    );

    if (exists) {
      return;
    }

    state = state.copyWith(
      clearError: true,
      tweetNotifications: [
        notification,
        ...state.tweetNotifications,
      ],
    );
  }

  void _handleNotificationList(
    Map<String, dynamic> data,
  ) {
    final rawList =
        data['notifications'];

    final notifications =
        rawList is List
            ? rawList
                .whereType<Map>()
                .map(
                  (item) =>
                      AppNotificationModel
                          .fromMap(
                    Map<String, dynamic>.from(
                      item,
                    ),
                  ),
                )
                .where(
                  (item) =>
                      item.id.isNotEmpty &&
                      item.isTweetNotification,
                )
                .toList()
            : <AppNotificationModel>[];

    notifications.sort(
      (first, second) {
        final firstDate =
            first.createdAt ??
            DateTime.fromMillisecondsSinceEpoch(
              0,
            );

        final secondDate =
            second.createdAt ??
            DateTime.fromMillisecondsSinceEpoch(
              0,
            );

        return secondDate.compareTo(
          firstDate,
        );
      },
    );

    state = state.copyWith(
      loading: false,
      clearError: true,
      tweetNotifications:
          notifications,
    );
  }

  void loadNotifications() {
    state = state.copyWith(
      loading: true,
      clearError: true,
    );

    sendBackgroundWs({
      'handler':
          WsHandlers.notificationsList,

      'request_id':
          const Uuid().v4(),

      'limit':
          100,
    });
  }

  /*
    عند الضغط على إشعار التويتة:
    - نحذفه محليًا.
    - نطلب من الباك حذفه نهائيًا.
  */
  void openNotification(
    AppNotificationModel notification,
  ) {
    final notificationId =
        notification.id.trim();

    if (notificationId.isEmpty) {
      return;
    }

    removeLocal(
      notificationId,
    );

    sendBackgroundWs({
      'handler':
          WsHandlers.notificationsRead,

      'request_id':
          const Uuid().v4(),

      'notificationId':
          notificationId,

      'notification_id':
          notificationId,
    });
  }

  void deleteNotification(
    AppNotificationModel notification,
  ) {
    openNotification(
      notification,
    );
  }

  void removeLocal(
    String notificationId,
  ) {
    final cleanId =
        notificationId.trim();

    if (cleanId.isEmpty) {
      return;
    }

    state = state.copyWith(
      tweetNotifications:
          state.tweetNotifications
              .where(
                (item) =>
                    item.id != cleanId,
              )
              .toList(),
    );
  }

  void clearLocal() {
    state = state.copyWith(
      tweetNotifications: const [],
    );
  }

  void clearError() {
    state = state.copyWith(
      clearError: true,
    );
  }

  String _text(
    dynamic value,
  ) {
    return value
            ?.toString()
            .trim() ??
        '';
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _subscription = null;

    super.dispose();
  }
}