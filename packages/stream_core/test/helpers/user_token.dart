import 'dart:convert';

import 'package:stream_core/stream_core.dart';

/// Builds an unsigned JWT carrying [userId] as its 'user_id' claim.
///
/// Sufficient for [UserToken]'s unverified parsing — nothing in these tests
/// checks a signature.
String generateTestJwt(String userId) {
  String b64UrlNoPad(Object jsonObj) {
    final bytes = utf8.encode(jsonEncode(jsonObj));
    return base64Url.encode(bytes).replaceAll('=', '');
  }

  final header = {'alg': 'none', 'typ': 'JWT'};
  final payload = {'user_id': userId};

  // Trailing dot = empty signature, which is what alg=none means.
  return '${b64UrlNoPad(header)}.${b64UrlNoPad(payload)}.';
}

/// Builds a JWT [UserToken] carrying [userId] as its 'user_id' claim.
UserToken generateTestUserToken(String userId) {
  return UserToken(generateTestJwt(userId));
}
