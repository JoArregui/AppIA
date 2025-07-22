import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'open_router_request_model.g.dart';

@JsonSerializable()
class OpenRouterRequestModel extends Equatable {
  final String model;
  final List<Map<String, String>> messages;
  final double? temperature;
  final int? maxTokens;

  const OpenRouterRequestModel({
    required this.model,
    required this.messages,
    this.temperature,
    this.maxTokens,
  });

  factory OpenRouterRequestModel.fromJson(Map<String, dynamic> json) =>
      _$OpenRouterRequestModelFromJson(json);

  Map<String, dynamic> toJson() => _$OpenRouterRequestModelToJson(this);

  @override
  List<Object?> get props => [model, messages, temperature, maxTokens];
}