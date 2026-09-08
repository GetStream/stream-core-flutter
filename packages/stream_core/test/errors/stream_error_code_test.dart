import 'package:stream_core/stream_core.dart';
import 'package:test/test.dart';

void main() {
  group('StreamErrorCode', () {
    test('behaves as its number, so an unknown code still reads', () {
      // The registry grows server-side. A code with no constant yet has to
      // survive the wire rather than fail the error it arrived on.
      const unknown = StreamErrorCode(9999);

      expect(unknown, 9999);
      expect(unknown.toString(), '9999');
      expect(StreamErrorCode.tokenExpired, 40);
    });

    test('reads an integral double, the shape a JSON number takes on web', () {
      expect(StreamErrorCode.fromJson(40), StreamErrorCode.tokenExpired);
      expect(StreamErrorCode.fromJson(40.0), StreamErrorCode.tokenExpired);
    });

    test('names the fix rather than the number', () {
      expect(StreamErrorCode.tokenExpired.isTokenExpired, isTrue);
      expect(StreamErrorCode.tokenSignatureInvalid.isTokenExpired, isFalse);

      // Two codes, one condition: a clock that disagrees with the token's
      // claims, which waiting fixes and a fresh token does not.
      expect(StreamErrorCode.tokenNotValidYet.isTokenNotYetValid, isTrue);
      expect(StreamErrorCode.tokenUsedBeforeIssuedAt.isTokenNotYetValid, isTrue);
      expect(StreamErrorCode.tokenExpired.isTokenNotYetValid, isFalse);

      expect(StreamErrorCode.tokenSignatureInvalid.isTokenSignatureInvalid, isTrue);
      expect(StreamErrorCode.apiKeyInvalid.isApiKeyInvalid, isTrue);
    });

    test('round-trips through json', () {
      expect(StreamErrorCode.toJson(StreamErrorCode.rateLimited), 9);
      expect(StreamErrorCode.fromJson(StreamErrorCode.toJson(StreamErrorCode.inputError)), StreamErrorCode.inputError);
    });
  });
}
