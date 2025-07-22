// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'open_router_request_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OpenRouterRequestModel _$OpenRouterRequestModelFromJson(
  Map<String, dynamic> json,
) => OpenRouterRequestModel(
  model: json['model'] as String,
  messages: (json['messages'] as List<dynamic>)
      .map((e) => Map<String, String>.from(e as Map))
      .toList(),
  temperature: (json['temperature'] as num?)?.toDouble(),
  maxTokens: (json['maxTokens'] as num?)?.toInt(),
);

Map<String, dynamic> _$OpenRouterRequestModelToJson(
  OpenRouterRequestModel instance,
) => <String, dynamic>{
  'model': instance.model,
  'messages': instance.messages,
  'temperature': instance.temperature,
  'maxTokens': instance.maxTokens,
};
