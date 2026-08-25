import 'dart:convert';

import 'package:stream_core/stream_core.dart';

/// Builds an unsigned JWT carrying [userId] as its 'user_id' claim.
///
/// Unsigned is enough for [UserToken], which parses without verifying. Pass [nonce] to tell two
/// tokens for the same user apart, and [expiresAt] to give the token an 'exp' claim.
String generateTestJwt(String userId, {String? nonce, DateTime? expiresAt}) {
  String b64UrlNoPad(Object jsonObj) {
    final bytes = utf8.encode(jsonEncode(jsonObj));
    return base64Url.encode(bytes).replaceAll('=', '');
  }

  final header = {'alg': 'none', 'typ': 'JWT'};
  final payload = {
    'user_id': userId,
    'nonce': ?nonce,
    // 'exp' is in whole seconds since the epoch.
    'exp': ?expiresAt?.millisecondsSinceEpoch.let((it) => it ~/ 1000),
  };

  // The trailing dot is the empty signature that `alg: none` requires.
  return '${b64UrlNoPad(header)}.${b64UrlNoPad(payload)}.';
}

/// Builds a JWT [UserToken] carrying [userId] as its 'user_id' claim.
UserToken generateTestUserToken(String userId, {String? nonce, DateTime? expiresAt}) {
  return UserToken(generateTestJwt(userId, nonce: nonce, expiresAt: expiresAt));
}
