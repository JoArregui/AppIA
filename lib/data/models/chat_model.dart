
import 'package:app_ia/data/models/message_model.dart'; // Importa el modelo MessageModel
import 'package:app_ia/domain/entity/chat.dart';
import 'package:app_ia/domain/entity/message.dart';
import 'package:json_annotation/json_annotation.dart';

part 'chat_model.g.dart'; // El archivo generado para este modelo

@JsonSerializable()
class ChatModel extends Chat {
  const ChatModel({
    required String id,
    required List<MessageModel> messages, // Usa MessageModel aquí
    required DateTime createdAt,
    DateTime? updatedAt,
  }) : super(
          id: id,
          messages: messages, // Se espera List<Message> en el super
          createdAt: createdAt,
          updatedAt: updatedAt,
        );

  // Un mapeador desde el JSON a ChatModel (y luego a Chat)
  factory ChatModel.fromJson(Map<String, dynamic> json) =>
      _$ChatModelFromJson(json);

  // Un mapeador desde ChatModel (que extiende Chat) a JSON
  Map<String, dynamic> toJson() => _$ChatModelToJson(this);

  // Opcional: Un factory para crear un ChatModel a partir de una entidad Chat
  factory ChatModel.fromEntity(Chat entity) {
    return ChatModel(
      id: entity.id,
      messages: entity.messages.map((msg) => MessageModel.fromEntity(msg)).toList(),
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  // Sobreescribe copyWith para que devuelva ChatModel, manteniendo la consistencia
  @override
  ChatModel copyWith({
    String? id,
    List<Message>? messages, // Aquí se espera List<Message> para la entidad
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ChatModel(
      id: id ?? this.id,
      messages: (messages ?? this.messages).map((msg) => MessageModel.fromEntity(msg)).toList(),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}