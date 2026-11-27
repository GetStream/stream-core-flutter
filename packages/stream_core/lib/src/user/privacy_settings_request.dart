import 'package:json_annotation/json_annotation.dart';

part 'privacy_settings_request.g.dart';

/// The chat privacy settings to apply to the user on connect.
///
/// A setting left `null` keeps the value the user already has.
@JsonSerializable(createFactory: false, includeIfNull: false)
final class PrivacySettingsRequest {
  const PrivacySettingsRequest({
    this.typingIndicators,
    this.readReceipts,
    this.deliveryReceipts,
  });

  /// The typing indicator setting, or `null` to keep the current one.
  final TypingIndicatorsRequest? typingIndicators;

  /// The read receipt setting, or `null` to keep the current one.
  final ReadReceiptsRequest? readReceipts;

  /// The delivery receipt setting, or `null` to keep the current one.
  final DeliveryReceiptsRequest? deliveryReceipts;

  Map<String, Object?> toJson() => _$PrivacySettingsRequestToJson(this);
}

/// The settings for typing indicator events.
@JsonSerializable(createFactory: false)
final class TypingIndicatorsRequest {
  const TypingIndicatorsRequest({required this.enabled});

  /// Whether the user sends typing indicator events.
  final bool enabled;

  Map<String, Object?> toJson() => _$TypingIndicatorsRequestToJson(this);
}

/// The settings for read receipt events.
@JsonSerializable(createFactory: false)
final class ReadReceiptsRequest {
  const ReadReceiptsRequest({required this.enabled});

  /// Whether the user sends read receipt events.
  final bool enabled;

  Map<String, Object?> toJson() => _$ReadReceiptsRequestToJson(this);
}

/// The settings for delivery receipt events.
@JsonSerializable(createFactory: false)
final class DeliveryReceiptsRequest {
  const DeliveryReceiptsRequest({required this.enabled});

  /// Whether the user sends delivery receipt events.
  final bool enabled;

  Map<String, Object?> toJson() => _$DeliveryReceiptsRequestToJson(this);
}
