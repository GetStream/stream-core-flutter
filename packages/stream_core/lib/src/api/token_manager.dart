import '../../stream_core.dart';

/// A function which can be used to request a Stream API token from your
/// own backend server.
/// Function requires a single [userId].
typedef TokenProvider = Future<String> Function(String userId);

/// Handles common token operations
class TokenManager {
  /// Initialize a new token manager with a static token
  TokenManager.static({
    required this.user,
    required String token,
  }) : _token = token;

  /// Initialize a new token manager with a token provider
  TokenManager.provider({
    required this.user,
    required TokenProvider provider,
    String? token,
  })  : _provider = provider,
        _token = token;

  /// User to which this TokenManager is configured to
  final User user;

  /// User id to which this TokenManager is configured to
  String get userId => user.id;

  /// Auth type to which this TokenManager is configured to
  String get authType => switch (user.type) {
        UserAuthType.regular || UserAuthType.guest => 'jwt',
        UserAuthType.anonymous => 'anonymous',
      };

  /// True if it's a static token and can't be refreshed
  bool get isStatic => _provider == null;

  String? _token;

  TokenProvider? _provider;

  /// Returns the token refreshing the existing one if [refresh] is true
  Future<String> loadToken({bool refresh = false}) async {
    if ((refresh && _provider != null) || _token == null) {
      _token = await _provider!(userId);
    }
    return _token!;
  }
}
