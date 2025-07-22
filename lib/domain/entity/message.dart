import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'message.g.dart';

@JsonSerializable()
class Message extends Equatable {
  final String id;
  final String content;
  final MessageType type;
  final DateTime timestamp;

  const Message({
    required this.id,
    required this.content,
    required this.type,
    required this.timestamp,
  });
  factory Message.fromJson(Map<String, dynamic> json) =>
      _$MessageFromJson(json);
  Map<String, dynamic> toJson() => _$MessageToJson(this);

  @override
  List<Object?> get props => [id, content, type, timestamp];
}

enum MessageType { user, assistant }
