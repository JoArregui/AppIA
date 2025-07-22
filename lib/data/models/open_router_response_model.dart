import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'open_router_response_model.g.dart';

@JsonSerializable()
class OpenRouterResponseModel extends Equatable {
  final String id;
  final String model;
  final int created; // Unix timestamp
  final List<OpenRouterChoiceModel> choices;
  final OpenRouterUsageModel usage;

  const OpenRouterResponseModel({
    required this.id,
    required this.model,
    required this.created,
    required this.choices,
    required this.usage,
  });

  factory OpenRouterResponseModel.fromJson(Map<String, dynamic> json) =>
      _$OpenRouterResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$OpenRouterResponseModelToJson(this);

  @override
  List<Object?> get props => [id, model, created, choices, usage];
}

@JsonSerializable()
class OpenRouterChoiceModel extends Equatable {
  final int index;
  final OpenRouterMessageResponseModel message;
  final String? finishReason; // Ej: "stop", "length"

  const OpenRouterChoiceModel({
    required this.index,
    required this.message,
    this.finishReason,
  });

  factory OpenRouterChoiceModel.fromJson(Map<String, dynamic> json) =>
      _$OpenRouterChoiceModelFromJson(json);

  Map<String, dynamic> toJson() => _$OpenRouterChoiceModelToJson(this);

  @override
  List<Object?> get props => [index, message, finishReason];
}

@JsonSerializable()
class OpenRouterMessageResponseModel extends Equatable {
  final String role; // Ej: "assistant"
  final String content;

  const OpenRouterMessageResponseModel({
    required this.role,
    required this.content,
  });

  factory OpenRouterMessageResponseModel.fromJson(Map<String, dynamic> json) =>
      _$OpenRouterMessageResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$OpenRouterMessageResponseModelToJson(this);

  @override
  List<Object?> get props => [role, content];
}

@JsonSerializable()
class OpenRouterUsageModel extends Equatable {
  @JsonKey(name: 'prompt_tokens')
  final int promptTokens;
  @JsonKey(name: 'completion_tokens')
  final int completionTokens;
  @JsonKey(name: 'total_tokens')
  final int totalTokens;

  const OpenRouterUsageModel({
    required this.promptTokens,
    required this.completionTokens,
    required this.totalTokens,
  });

  factory OpenRouterUsageModel.fromJson(Map<String, dynamic> json) =>
      _$OpenRouterUsageModelFromJson(json);

  Map<String, dynamic> toJson() => _$OpenRouterUsageModelToJson(this);

  @override
  List<Object?> get props => [promptTokens, completionTokens, totalTokens];
}