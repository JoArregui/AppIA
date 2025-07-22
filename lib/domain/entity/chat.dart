import 'package:app_ia/domain/entity/message.dart';
import 'package:equatable/equatable.dart'; // Asegúrate de importar Equatable

class Chat extends Equatable {
  final String id;
  final List<Message> messages;
  final DateTime createdAt;
  final DateTime? updatedAt; // Puede ser nulo

  const Chat({
    required this.id,
    required this.messages,
    required this.createdAt,
    this.updatedAt,
  });

  // Implementación de props para Equatable
  @override
  List<Object?> get props => [id, messages, createdAt, updatedAt];

  Chat copyWith({
    String? id,
    List<Message>? messages,
    DateTime? createdAt, // También puede ser nulo para copyWith
    DateTime? updatedAt, // También puede ser nulo para copyWith
  }) {
    return Chat(
      id: id ?? this.id,
      messages: messages ?? this.messages,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}