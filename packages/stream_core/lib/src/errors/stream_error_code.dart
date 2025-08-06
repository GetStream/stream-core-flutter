import 'package:collection/collection.dart';

/// Complete list of errors that are returned by the API
/// together with the description and API code.
enum StreamErrorCode {
  // Client errors

  /// Unauthenticated, token not defined
  undefinedToken,

  // Bad Request

  /// Wrong data/parameter is sent to the API
  inputError,

  /// Duplicate username is sent while enforce_unique_usernames is enabled
  duplicateUsername,

  /// Message is too long
  messageTooLong,

  /// Event is not supported
  eventNotSupported,

  /// The feature is currently disabled
  /// on the dashboard (i.e. Reactions & Replies)
  channelFeatureNotSupported,

  /// Multiple Levels Reply is not supported
  /// the API only supports 1 level deep reply threads
  multipleNestling,

  /// Custom Command handler returned an error
  customCommandEndpointCall,

  /// App config does not have custom_action_handler_url
  customCommandEndpointMissing,

  // Unauthorised

  /// Unauthenticated, problem with authentication
  authenticationError,

  /// Unauthenticated, token expired
  tokenExpired,

  /// Unauthenticated, token date incorrect
  tokenBeforeIssuedAt,

  /// Unauthenticated, token not valid yet
  tokenNotValid,

  /// Unauthenticated, token signature invalid
  tokenSignatureInvalid,

  /// Access Key invalid
  accessKeyError,

  // Forbidden

  /// Unauthorised / forbidden to make request
  notAllowed,

  /// App suspended
  appSuspended,

  /// User tried to post a message during the cooldown period
  cooldownError,

  // Miscellaneous

  /// Resource not found
  doesNotExist,

  /// Request timed out
  requestTimeout,

  /// Payload too big
  payloadTooBig,

  /// Too many requests in a certain time frame
  rateLimitError,

  /// Request headers are too large
  maximumHeaderSizeExceeded,

  /// Something goes wrong in the system
  internalSystemError,

  /// No access to requested channels
  noAccessToChannels,
}

const _errorCodeWithDescription = {
  StreamErrorCode.internalSystemError:
      MapEntry(-1, 'Something goes wrong in the system'),
  StreamErrorCode.accessKeyError: MapEntry(2, 'Access Key invalid'),
  StreamErrorCode.inputError:
      MapEntry(4, 'Wrong data/parameter is sent to the API'),
  StreamErrorCode.authenticationError:
      MapEntry(5, 'Unauthenticated, problem with authentication'),
  StreamErrorCode.duplicateUsername: MapEntry(
    6,
    'Duplicate username is sent while enforce_unique_usernames is enabled',
  ),
  StreamErrorCode.rateLimitError:
      MapEntry(9, 'Too many requests in a certain time frame'),
  StreamErrorCode.doesNotExist: MapEntry(16, 'Resource not found'),
  StreamErrorCode.notAllowed:
      MapEntry(17, 'Unauthorised / forbidden to make request'),
  StreamErrorCode.eventNotSupported: MapEntry(18, 'Event is not supported'),
  StreamErrorCode.channelFeatureNotSupported: MapEntry(
    19,
    'The feature is currently disabled on the dashboard (i.e. Reactions & Replies)',
  ),
  StreamErrorCode.messageTooLong: MapEntry(20, 'Message is too long'),
  StreamErrorCode.multipleNestling: MapEntry(
    21,
    'Multiple Levels Reply is not supported - the API only supports 1 level deep reply threads',
  ),
  StreamErrorCode.payloadTooBig: MapEntry(22, 'Payload too big'),
  StreamErrorCode.requestTimeout: MapEntry(23, 'Request timed out'),
  StreamErrorCode.maximumHeaderSizeExceeded:
      MapEntry(24, 'Request headers are too large'),
  StreamErrorCode.tokenExpired: MapEntry(40, 'Unauthenticated, token expired'),
  StreamErrorCode.tokenNotValid:
      MapEntry(41, 'Unauthenticated, token not valid yet'),
  StreamErrorCode.tokenBeforeIssuedAt:
      MapEntry(42, 'Unauthenticated, token date incorrect'),
  StreamErrorCode.tokenSignatureInvalid:
      MapEntry(43, 'Unauthenticated, token signature invalid'),
  StreamErrorCode.customCommandEndpointMissing:
      MapEntry(44, 'App config does not have custom_action_handler_url'),
  StreamErrorCode.customCommandEndpointCall:
      MapEntry(45, 'Custom Command handler returned an error'),
  StreamErrorCode.cooldownError:
      MapEntry(60, 'User tried to post a message during the cooldown period'),
  StreamErrorCode.noAccessToChannels:
      MapEntry(70, 'No access to requested channels'),
  StreamErrorCode.appSuspended: MapEntry(99, 'App suspended'),
  StreamErrorCode.undefinedToken:
      MapEntry(1000, 'Unauthorised, token not defined'),
};

StreamErrorCode? streamErrorCodeFromCode(int code) =>
    _errorCodeWithDescription.keys
        .firstWhereOrNull((key) => _errorCodeWithDescription[key]!.key == code);

int codeFromStreamErrorCode(StreamErrorCode errorCode) =>
    _errorCodeWithDescription[errorCode]!.key;

String messageFromStreamErrorCode(StreamErrorCode errorCode) =>
    _errorCodeWithDescription[errorCode]!.value;
