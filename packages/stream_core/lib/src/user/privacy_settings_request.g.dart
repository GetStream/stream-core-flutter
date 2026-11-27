// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'privacy_settings_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Map<String, dynamic> _$PrivacySettingsRequestToJson(
  PrivacySettingsRequest instance,
) => <String, dynamic>{
  'typing_indicators': ?instance.typingIndicators?.toJson(),
  'read_receipts': ?instance.readReceipts?.toJson(),
  'delivery_receipts': ?instance.deliveryReceipts?.toJson(),
};

Map<String, dynamic> _$TypingIndicatorsRequestToJson(
  TypingIndicatorsRequest instance,
) => <String, dynamic>{'enabled': instance.enabled};

Map<String, dynamic> _$ReadReceiptsRequestToJson(
  ReadReceiptsRequest instance,
) => <String, dynamic>{'enabled': instance.enabled};

Map<String, dynamic> _$DeliveryReceiptsRequestToJson(
  DeliveryReceiptsRequest instance,
) => <String, dynamic>{'enabled': instance.enabled};
