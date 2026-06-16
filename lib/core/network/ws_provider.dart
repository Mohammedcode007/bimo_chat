// import 'package:flutter_riverpod/flutter_riverpod.dart';

// import '../constants/api_constants.dart';
// import 'ws_client.dart';

// final wsClientProvider = Provider<WsClient>((ref) {
//   final client = WsClient();

//   client.connect(ApiConstants.wsUrl);

//   ref.onDispose(() {
//     client.dispose();
//   });

//   return client;
// });

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/api_constants.dart';
import 'ws_client.dart';

final wsClientProvider = Provider<WsClient>((ref) {
  final client = WsClient();

  client.connect(ApiConstants.wsUrl);

  ref.onDispose(() {
    client.dispose();
  });

  return client;
});