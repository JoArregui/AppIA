part of 'chat_bloc.dart';

/// Estados base para el ChatBloc.
abstract class ChatState extends Equatable {
  const ChatState();

  @override
  List<Object> get props => [];
}

/// Estado inicial del ChatBloc.
class ChatInitial extends ChatState {}

/// Estado cuando se está cargando información (ej. chats, respuesta de IA).
class ChatLoading extends ChatState {}

/// Estado cuando los chats se han cargado exitosamente.
/// Contiene una lista de todos los chats disponibles y el chat actualmente seleccionado.
class ChatLoaded extends ChatState {
  final List<Chat> allChats;
  final Chat? currentChat; // El chat que se está visualizando/editando actualmente
  final bool isSendingMessage; // Para mostrar un indicador de carga solo para el mensaje

  const ChatLoaded({
    required this.allChats,
    this.currentChat,
    this.isSendingMessage = false,
  });

  // Permite crear una nueva instancia de ChatLoaded con propiedades modificadas
  ChatLoaded copyWith({
    List<Chat>? allChats,
    Chat? currentChat,
    bool? isSendingMessage,
  }) {
    return ChatLoaded(
      allChats: allChats ?? this.allChats,
      currentChat: currentChat ?? this.currentChat,
      isSendingMessage: isSendingMessage ?? this.isSendingMessage,
    );
  }

  @override
  List<Object> get props => [allChats, currentChat ?? Object(), isSendingMessage];
}

/// Estado cuando ha ocurrido un error.
class ChatError extends ChatState {
  final String message;
  const ChatError(this.message);

  @override
  List<Object> get props => [message];
}