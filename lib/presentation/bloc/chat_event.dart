part of 'chat_bloc.dart';

/// Eventos base para el ChatBloc.
abstract class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object> get props => [];
}

/// Evento para cargar todos los chats al inicio de la aplicación o de la pantalla.
class LoadChatsEvent extends ChatEvent {}

/// Evento para seleccionar un chat existente o crear uno nuevo si el ID es nulo.
class SelectChatEvent extends ChatEvent {
  final String? chatId; // Si es nulo, se crea un nuevo chat
  const SelectChatEvent({this.chatId});

  @override
  List<Object> get props => [chatId ?? 'null'];
}

/// Evento para enviar un nuevo mensaje del usuario al chat actual.
class SendMessageEvent extends ChatEvent {
  final String messageContent;
  const SendMessageEvent(this.messageContent);

  @override
  List<Object> get props => [messageContent];
}

/// Evento para eliminar un chat específico.
class DeleteChatEvent extends ChatEvent {
  final String chatId;
  const DeleteChatEvent(this.chatId);

  @override
  List<Object> get props => [chatId];
}

// Puedes añadir más eventos según sea necesario, por ejemplo:
// class UpdateChatTitleEvent extends ChatEvent { ... }
// class ClearAllChatsEvent extends ChatEvent { ... }