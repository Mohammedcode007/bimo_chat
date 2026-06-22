import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/responsive.dart';

import '../../users/logic/users_provider.dart';
import '../../users/presentation/public_profile_screen.dart';

import '../../feed/data/tweet_models.dart';
import '../../feed/logic/tweets_provider.dart';
import '../../feed/presentation/tweet_details_screen.dart';

import '../data/app_notification_model.dart';
import '../logic/notifications_provider.dart';

import 'widgets/notification_card.dart';
import 'widgets/notifications_header.dart';

class NotificationsScreen
    extends ConsumerStatefulWidget {
  const NotificationsScreen({
    super.key,
  });

  @override
  ConsumerState<NotificationsScreen>
      createState() {
    return _NotificationsScreenState();
  }
}

class _NotificationsScreenState
    extends ConsumerState<
        NotificationsScreen> {
  String selectedFilter =
      'all';

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      /*
        طلبات الصداقة الحالية.
      */
      ref
          .read(
            usersProvider.notifier,
          )
          .getIncomingFriendRequests();

      /*
        إشعارات التويتات الحقيقية.
      */
      ref
          .read(
            notificationsProvider
                .notifier,
          )
          .loadNotifications();
    });
  }

  /*
    تحويل طلبات الصداقة إلى نفس موديل العرض.

    هذا الجزء لم يتغير.
  */
  List<AppNotificationModel>
      friendRequestNotifications(
    List<Map<String, dynamic>>
        requests,
  ) {
    return requests.map(
      (request) {
        final fromUser =
            request['fromUser']
                    is Map
                ? Map<String, dynamic>.from(
                    request['fromUser'],
                  )
                : <String, dynamic>{};

        final requestId =
            request['requestId']
                    ?.toString() ??
                '';

        final username =
            fromUser['username']
                    ?.toString() ??
                'User';

        final avatarUrl =
            fromUser['photoUrl']
                    ?.toString() ??
                fromUser['avatarUrl']
                    ?.toString() ??
                '';

        return AppNotificationModel(
          id:
              requestId,

          type:
              AppNotificationType
                  .friendRequest,

          senderUserId:
              fromUser['userId']
                      ?.toString() ??
                  '',

          userName:
              username,

          username:
              username,

          avatarUrl:
              avatarUrl,

          title:
              'sent you a friend request',

          body:
              '$username wants to add you as a friend.',

          time:
              'now',

          isUnread:
              true,
        );
      },
    ).toList();
  }

  /*
    دمج طلبات الصداقة مع إشعارات
    التويتات الحقيقية القادمة من الباك.
  */
  List<AppNotificationModel>
      allNotifications(
    List<Map<String, dynamic>>
        incomingRequests,
    List<AppNotificationModel>
        tweetNotifications,
  ) {
    return [
      ...friendRequestNotifications(
        incomingRequests,
      ),
      ...tweetNotifications,
    ];
  }

  List<AppNotificationModel>
      filteredNotifications(
    List<Map<String, dynamic>>
        incomingRequests,
    List<AppNotificationModel>
        tweetNotifications,
  ) {
    final notifications =
        allNotifications(
      incomingRequests,
      tweetNotifications,
    );

    if (selectedFilter ==
        'unread') {
      return notifications
          .where(
            (item) =>
                item.isUnread,
          )
          .toList();
    }

    if (selectedFilter ==
        'requests') {
      return notifications
          .where(
            (item) =>
                item.type ==
                AppNotificationType
                    .friendRequest,
          )
          .toList();
    }

    if (selectedFilter ==
        'tweets') {
      return notifications
          .where(
            (item) =>
                item.isTweetNotification,
          )
          .toList();
    }

    return notifications;
  }

  Map<String, dynamic>?
      findRequestById(
    String requestId,
  ) {
    final requests =
        ref
            .read(
              usersProvider,
            )
            .incomingFriendRequests;

    for (final request
        in requests) {
      if (request['requestId']
              ?.toString() ==
          requestId) {
        return request;
      }
    }

    return null;
  }

  Future<void> openNotification(
    AppNotificationModel notification,
  ) async {
    /*
      طلبات الصداقة تظل كما هي:
      الضغط عليها يفتح بروفايل المرسل.
    */
    if (notification.type ==
        AppNotificationType.friendRequest) {
      final request =
          findRequestById(
        notification.id,
      );

      if (request == null) {
        return;
      }

      final fromUser =
          request['fromUser'] is Map
              ? Map<String, dynamic>.from(
                  request['fromUser'],
                )
              : <String, dynamic>{};

      final userId =
          fromUser['userId']
                  ?.toString()
                  .trim() ??
              '';

      if (userId.isEmpty) {
        return;
      }

      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) {
            return PublicProfileScreen(
              userId: userId,
            );
          },
        ),
      );

      return;
    }

    final tweetId =
        notification.tweetId.trim();

    if (tweetId.isEmpty) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text(
              'Tweet ID is missing',
            ),
            behavior:
                SnackBarBehavior.floating,
          ),
        );

      return;
    }

    /*
      نحذف الإشعار من القائمة ومن الباك
      بمجرد الضغط عليه.
    */
    ref
        .read(
          notificationsProvider.notifier,
        )
        .openNotification(
          notification,
        );

    /*
      لو التويتة موجودة بالفعل داخل الـ feed،
      نفتحها مباشرة.
    */
    final tweetsState =
        ref.read(
      tweetsProvider,
    );

    TweetModel? existingTweet;

    for (final tweet
        in tweetsState.tweets) {
      if (tweet.tweetId == tweetId) {
        existingTweet = tweet;
        break;
      }
    }

    if (existingTweet != null) {
      if (!mounted) {
        return;
      }

      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) {
            return TweetDetailsScreen(
              tweet: existingTweet!,
            );
          },
        ),
      );

      return;
    }

    /*
      لو التويتة غير موجودة داخل الـ feed،
      نفتح شاشة تحميل تجلبها من الباك بالـ tweetId
      ثم تنتقل تلقائيًا إلى صفحة التفاصيل.
    */
    if (!mounted) {
      return;
    }

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) {
          return _TweetFromNotificationScreen(
            tweetId: tweetId,
          );
        },
      ),
    );
  }

  void deleteNotification(
    AppNotificationModel notification,
  ) {
    /*
      طلبات الصداقة تظل بنفس السلوك.
    */
    if (notification.type ==
        AppNotificationType
            .friendRequest) {
      final request =
          findRequestById(
        notification.id,
      );

      if (request != null) {
        ref
            .read(
              usersProvider.notifier,
            )
            .respondFriendRequest(
              requestId:
                  notification.id,
              action:
                  'reject',
            );
      }

      return;
    }

    /*
      إشعار التويتة يحذف من الباك أيضًا.
    */
    ref
        .read(
          notificationsProvider
              .notifier,
        )
        .deleteNotification(
          notification,
        );
  }

  void markAllRead() {
    /*
      لأن فتح الإشعار يعني حذفه،
      سنحذف جميع إشعارات التويتات محليًا
      ونرسل طلب حذف لكل إشعار.
    */
    final tweetNotifications =
        ref
            .read(
              notificationsProvider,
            )
            .tweetNotifications;

    for (final notification
        in tweetNotifications) {
      ref
          .read(
            notificationsProvider
                .notifier,
          )
          .deleteNotification(
            notification,
          );
    }
  }

  void acceptFriend(
    AppNotificationModel notification,
  ) {
    ref
        .read(
          usersProvider.notifier,
        )
        .respondFriendRequest(
          requestId:
              notification.id,
          action:
              'accept',
        );

    Future.delayed(
      const Duration(
        milliseconds:
            400,
      ),
      () {
        if (!mounted) {
          return;
        }

        ref
            .read(
              usersProvider.notifier,
            )
            .getFriends();
      },
    );

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(
      const SnackBar(
        content: Text(
          'Friend request accepted',
        ),
        behavior:
            SnackBarBehavior.floating,
      ),
    );
  }

  void rejectFriend(
    AppNotificationModel notification,
  ) {
    ref
        .read(
          usersProvider.notifier,
        )
        .respondFriendRequest(
          requestId:
              notification.id,
          action:
              'reject',
        );

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(
      const SnackBar(
        content: Text(
          'Friend request rejected',
        ),
        behavior:
            SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final usersState =
        ref.watch(
      usersProvider,
    );

    final notificationsState =
        ref.watch(
      notificationsProvider,
    );

    final incomingRequests =
        usersState
            .incomingFriendRequests;

    final tweetNotifications =
        notificationsState
            .tweetNotifications;

    final items =
        filteredNotifications(
      incomingRequests,
      tweetNotifications,
    );

    final colorScheme =
        Theme.of(
      context,
    ).colorScheme;

    ref.listen(
      usersProvider,
      (
        previous,
        next,
      ) {
        if (next.error != null &&
            next.error!.isNotEmpty) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(
            SnackBar(
              content:
                  Text(
                next.error!,
              ),
              behavior:
                  SnackBarBehavior.floating,
            ),
          );

          ref
              .read(
                usersProvider.notifier,
              )
              .clearError();
        }
      },
    );

    ref.listen(
      notificationsProvider,
      (
        previous,
        next,
      ) {
        if (next.error != null &&
            next.error!.isNotEmpty) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(
            SnackBar(
              content:
                  Text(
                next.error!,
              ),
              behavior:
                  SnackBarBehavior.floating,
            ),
          );

          ref
              .read(
                notificationsProvider
                    .notifier,
              )
              .clearError();
        }
      },
    );

    return Scaffold(
      backgroundColor:
          Theme.of(
        context,
      ).scaffoldBackgroundColor,

      body: Column(
        children: [
          NotificationsHeader(
            onBackTap:
                () =>
                    Navigator.pop(
              context,
            ),
            onMarkAllReadTap:
                markAllRead,
          ),

          SizedBox(
            height:
                R.size(
              context,
              54,
            ),
            child:
                ListView(
              scrollDirection:
                  Axis.horizontal,

              padding:
                  EdgeInsetsDirectional
                      .fromSTEB(
                R.size(
                  context,
                  12,
                ),
                R.size(
                  context,
                  8,
                ),
                R.size(
                  context,
                  12,
                ),
                R.size(
                  context,
                  8,
                ),
              ),

              children: [
                _FilterChip(
                  title:
                      'All',
                  selected:
                      selectedFilter ==
                      'all',
                  onTap:
                      () => setState(
                    () =>
                        selectedFilter =
                            'all',
                  ),
                ),

                _FilterChip(
                  title:
                      'Unread',
                  selected:
                      selectedFilter ==
                      'unread',
                  onTap:
                      () => setState(
                    () =>
                        selectedFilter =
                            'unread',
                  ),
                ),

                _FilterChip(
                  title:
                      'Requests',
                  selected:
                      selectedFilter ==
                      'requests',
                  onTap:
                      () => setState(
                    () =>
                        selectedFilter =
                            'requests',
                  ),
                ),

                _FilterChip(
                  title:
                      'Tweets',
                  selected:
                      selectedFilter ==
                      'tweets',
                  onTap:
                      () => setState(
                    () =>
                        selectedFilter =
                            'tweets',
                  ),
                ),
              ],
            ),
          ),

          Divider(
            height:
                1,
            color:
                colorScheme
                    .outlineVariant
                    .withValues(
              alpha:
                  0.45,
            ),
          ),

          if (usersState.loading ||
              notificationsState
                  .loading)
            const LinearProgressIndicator(),

          Expanded(
            child:
                RefreshIndicator(
              onRefresh:
                  () async {
                ref
                    .read(
                      usersProvider
                          .notifier,
                    )
                    .getIncomingFriendRequests();

                ref
                    .read(
                      notificationsProvider
                          .notifier,
                    )
                    .loadNotifications();

                await Future.delayed(
                  const Duration(
                    milliseconds:
                        500,
                  ),
                );
              },

              child:
                  items.isEmpty
                      ? ListView(
                          children: [
                            SizedBox(
                              height:
                                  MediaQuery.sizeOf(
                                            context,
                                          )
                                          .height *
                                      0.55,
                              child:
                                  Center(
                                child:
                                    Text(
                                  'No notifications',
                                  style:
                                      TextStyle(
                                    color:
                                        colorScheme
                                            .onSurfaceVariant,
                                    fontSize:
                                        R.sp(
                                      context,
                                      16,
                                    ),
                                    fontWeight:
                                        FontWeight
                                            .w700,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      : ListView.separated(
                          padding:
                              EdgeInsets.zero,

                          itemCount:
                              items.length,

                          separatorBuilder:
                              (
                            _,
                            __,
                          ) {
                            return Divider(
                              height:
                                  1,
                              color:
                                  colorScheme
                                      .outlineVariant
                                      .withValues(
                                alpha:
                                    0.35,
                              ),
                            );
                          },

                          itemBuilder:
                              (
                            context,
                            index,
                          ) {
                            final notification =
                                items[
                                    index];

                            return NotificationCard(
                              notification:
                                  notification,

                              onTap:
                                  () =>
                                      openNotification(
                                notification,
                              ),

                              onDeleteTap:
                                  () =>
                                      deleteNotification(
                                notification,
                              ),

                              onAcceptFriendTap:
                                  () =>
                                      acceptFriend(
                                notification,
                              ),

                              onRejectFriendTap:
                                  () =>
                                      rejectFriend(
                                notification,
                              ),
                            );
                          },
                        ),
            ),
          ),
        ],
      ),
    );
  }
}


class _TweetFromNotificationScreen
    extends ConsumerStatefulWidget {
  final String tweetId;

  const _TweetFromNotificationScreen({
    required this.tweetId,
  });

  @override
  ConsumerState<
      _TweetFromNotificationScreen>
  createState() {
    return _TweetFromNotificationScreenState();
  }
}

class _TweetFromNotificationScreenState
    extends ConsumerState<
        _TweetFromNotificationScreen> {
  bool _requested = false;
  bool _opened = false;

  @override
  void initState() {
    super.initState();

    Future.microtask(
      _requestTweet,
    );
  }

  void _requestTweet() {
    if (_requested) {
      return;
    }

    _requested = true;

    ref
        .read(
          tweetsProvider.notifier,
        )
        .clearError();

    ref
        .read(
          tweetsProvider.notifier,
        )
        .loadTweetDetails(
          tweetId:
              widget.tweetId,
        );

    print(
      '🔔 LOAD TWEET FROM NOTIFICATION: '
      '${widget.tweetId}',
    );
  }

  TweetModel? _findTweet(
    dynamic tweetsState,
  ) {
    final selectedTweet =
        tweetsState.selectedTweet;

    if (selectedTweet != null &&
        selectedTweet.tweetId ==
            widget.tweetId) {
      return selectedTweet;
    }

    for (final item
        in tweetsState.tweets) {
      if (item is TweetModel &&
          item.tweetId ==
              widget.tweetId) {
        return item;
      }
    }

    return null;
  }

  void _openTweet(
    TweetModel tweet,
  ) {
    if (_opened || !mounted) {
      return;
    }

    _opened = true;

    WidgetsBinding.instance
        .addPostFrameCallback(
      (_) {
        if (!mounted) {
          return;
        }

        Navigator.of(context)
            .pushReplacement(
          MaterialPageRoute(
            builder: (_) {
              return TweetDetailsScreen(
                tweet: tweet,
              );
            },
          ),
        );
      },
    );
  }

  void _retry() {
    ref
        .read(
          tweetsProvider.notifier,
        )
        .clearError();

    setState(() {
      _requested = false;
      _opened = false;
    });

    _requestTweet();
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final tweetsState =
        ref.watch(
      tweetsProvider,
    );

    final tweet =
        _findTweet(
      tweetsState,
    );

    if (tweet != null) {
      _openTweet(
        tweet,
      );
    }

    final error =
        tweetsState.error
            ?.toString()
            .trim();

    return Scaffold(
      appBar: AppBar(
        title:
            const Text(
          'Post',
        ),
      ),
      body: Center(
        child:
            error != null &&
                    error.isNotEmpty
                ? Padding(
                    padding:
                        const EdgeInsets.all(
                      24,
                    ),
                    child:
                        Column(
                      mainAxisSize:
                          MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 46,
                        ),
                        const SizedBox(
                          height: 12,
                        ),
                        Text(
                          error ==
                                  'tweet_not_found'
                              ? 'This tweet is no longer available'
                              : error,
                          textAlign:
                              TextAlign.center,
                        ),
                        const SizedBox(
                          height: 16,
                        ),
                        FilledButton(
                          onPressed:
                              _retry,
                          child:
                              const Text(
                            'Retry',
                          ),
                        ),
                      ],
                    ),
                  )
                : const CircularProgressIndicator(),
      ),
    );
  }
}

class _FilterChip
    extends StatelessWidget {
  final String title;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.title,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    final colorScheme =
        Theme.of(
      context,
    ).colorScheme;

    return Padding(
      padding:
          EdgeInsetsDirectional.only(
        end:
            R.size(
          context,
          8,
        ),
      ),

      child:
          InkWell(
        onTap:
            onTap,

        borderRadius:
            BorderRadius.circular(
          999,
        ),

        child:
            Container(
          padding:
              EdgeInsets.symmetric(
            horizontal:
                R.size(
              context,
              16,
            ),
            vertical:
                R.size(
              context,
              8,
            ),
          ),

          decoration:
              BoxDecoration(
            color:
                selected
                    ? const Color(
                        0xFF087887,
                      )
                    : colorScheme
                        .surfaceContainerHighest,

            borderRadius:
                BorderRadius.circular(
              999,
            ),
          ),

          child:
              Text(
            title,

            style:
                TextStyle(
              color:
                  selected
                      ? Colors.white
                      : colorScheme
                          .onSurfaceVariant,

              fontSize:
                  R.sp(
                context,
                14,
              ),

              fontWeight:
                  FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}