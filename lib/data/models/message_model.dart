
import 'package:app_ia/domain/entity/message.dart';
import 'package:json_annotation/json_annotation.dart';

part 'message_model.g.dart'; // El archivo generado para este modelo

@JsonSerializable()
class MessageModel extends Message {
  const MessageModel({
    required String id,
    required String content,
    required MessageType type,
    required DateTime timestamp,
  }) : super(
          id: id,
          content: content,
          type: type,
          timestamp: timestamp,
        );

  factory MessageModel.fromJson(Map<String, dynamic> json) =>
      _$MessageModelFromJson(json);

  Map<String, dynamic> toJson() => _$MessageModelToJson(this);

  // Opcional: Un factory para crear un MessageModel a partir de una entidad Message
  factory MessageModel.fromEntity(Message entity) {
    return MessageModel(
      id: entity.id,
      content: entity.content,
      type: entity.type,
      timestamp: entity.timestamp,
    );
  }
}