// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'open_router_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OpenRouterResponseModel _$OpenRouterResponseModelFromJson(
  Map<String, dynamic> json,
) => OpenRouterResponseModel(
  id: json['id'] as String,
  model: json['model'] as String,
  created: (json['created'] as num).toInt(),
  choices: (json['choices'] as List<dynamic>)
      .map((e) => OpenRouterChoiceModel.fromJson(e as Map<String, dynamic>))
      .toList(),
  usage: OpenRouterUsageModel.fromJson(json['usage'] as Map<String, dynamic>),
);

Map<String, dynamic> _$OpenRouterResponseModelToJson(
  OpenRouterResponseModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'model': instance.model,
  'created': instance.created,
  'choices': instance.choices,
  'usage': instance.usage,
};

OpenRouterChoiceModel _$OpenRouterChoiceModelFromJson(
  Map<String, dynamic> json,
) => OpenRouterChoiceModel(
  index: (json['index'] as num).toInt(),
  message: OpenRouterMessageResponseModel.fromJson(
    json['message'] as Map<String, dynamic>,
  ),
  finishReason: json['finishReason'] as String?,
);

Map<String, dynamic> _$OpenRouterChoiceModelToJson(
  OpenRouterChoiceModel instance,
) => <String, dynamic>{
  'index': instance.index,
  'message': instance.message,
  'finishReason': instance.finishReason,
};

OpenRouterMessageResponseModel _$OpenRouterMessageResponseModelFromJson(
  Map<String, dynamic> json,
) => OpenRouterMessageResponseModel(
  role: json['role'] as String,
  content: json['content'] as String,
);

Map<String, dynamic> _$OpenRouterMessageResponseModelToJson(
  OpenRouterMessageResponseModel instance,
) => <String, dynamic>{'role': instance.role, 'content': instance.content};

OpenRouterUsageModel _$OpenRouterUsageModelFromJson(
  Map<String, dynamic> json,
) => OpenRouterUsageModel(
  promptTokens: (json['prompt_tokens'] as num).toInt(),
  completionTokens: (json['completion_tokens'] as num).toInt(),
  totalTokens: (json['total_tokens'] as num).toInt(),
);

Map<String, dynamic> _$OpenRouterUsageModelToJson(
  OpenRouterUsageModel instance,
) => <String, dynamic>{
  'prompt_tokens': instance.promptTokens,
  'completion_tokens': instance.completionTokens,
  'total_tokens': instance.totalTokens,
};
