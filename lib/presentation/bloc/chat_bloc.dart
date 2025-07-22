import 'package:app_ia/domain/entity/chat.dart';
import 'package:app_ia/domain/entity/message.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_ia/core/error/failures.dart';
import 'package:app_ia/domain/usecases/send_message_usecase.dart';
import 'package:app_ia/domain/usecases/get_chats_usecase.dart';
import 'package:app_ia/domain/usecases/create_new_chat_usecase.dart';
import 'package:app_ia/domain/usecases/delete_chat_usecase.dart';

part 'chat_event.dart';
part 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final SendMessageUseCase sendMessageUseCase;
  final GetChatsUseCase getChatsUseCase;
  final CreateNewChatUseCase createNewChatUseCase;
  final DeleteChatUseCase deleteChatUseCase;

  ChatBloc({
    required this.sendMessageUseCase,
    required this.getChatsUseCase,
    required this.createNewChatUseCase,
    required this.deleteChatUseCase,
  }) : super(ChatInitial()) {
    on<LoadChatsEvent>(_onLoadChats);
    on<SelectChatEvent>(_onSelectChat);
    on<SendMessageEvent>(_onSendMessage);
    on<DeleteChatEvent>(_onDeleteChat);
  }

  /// Manejador para el evento LoadChatsEvent
  Future<void> _onLoadChats(LoadChatsEvent event, Emitter<ChatState> emit) async {
    emit(ChatLoading()); // Indica que se están cargando los chats

    final result = await getChatsUseCase();

    await result.fold(
      (failure) async => emit(ChatError(_mapFailureToMessage(failure))),
      (chats) async {
        Chat? selectedChat;
        List<Chat> updatedAllChats = List.from(chats);

        if (chats.isNotEmpty) {
          // Si hay chats, selecciona el primero (o el más reciente, si tienes lógica para eso)
          selectedChat = chats.first;
        } else {
          // *** IMPORTANTE: Si NO hay chats, crea uno nuevo. ***
          final newChatResult = await createNewChatUseCase();
          newChatResult.fold(
            (createFailure) => emit(ChatError(_mapFailureToMessage(createFailure))),
            (newChat) {
              selectedChat = newChat;
              updatedAllChats.insert(0, newChat); // Añade el nuevo chat a la lista
            },
          );
        }

        // Si después de todo, todavía no hay un chat seleccionado (ej. si la creación falló)
        if (selectedChat == null && updatedAllChats.isEmpty) {
          emit(ChatError('No se pudo cargar ni crear un chat inicial.'));
          return; // Detiene la ejecución para evitar emitir ChatLoaded con null
        }

        emit(ChatLoaded(
          allChats: updatedAllChats,
          currentChat: selectedChat,
          isSendingMessage: false,
        ));
      },
    );
  }

  /// Manejador para el evento SelectChatEvent
  Future<void> _onSelectChat(SelectChatEvent event, Emitter<ChatState> emit) async {
    final currentState = state;

    if (currentState is ChatLoaded) {
      if (event.chatId == null) {
        // Crear un nuevo chat
        final newChatResult = await createNewChatUseCase();
        newChatResult.fold(
          (failure) => emit(ChatError(_mapFailureToMessage(failure))),
          (newChat) {
            final updatedChats = List<Chat>.from(currentState.allChats)..insert(0, newChat); // Añadir al principio
            emit(ChatLoaded(
              allChats: updatedChats,
              currentChat: newChat,
              isSendingMessage: false,
            ));
          },
        );
      } else {
        // Seleccionar un chat existente
        final selectedChat = currentState.allChats.firstWhere(
          (chat) => chat.id == event.chatId,
          orElse: () => currentState.currentChat ?? currentState.allChats.first, // Fallback
        );
        emit(currentState.copyWith(currentChat: selectedChat, isSendingMessage: false));
      }
    } else {
      // Si el estado no es ChatLoaded al intentar seleccionar, primero carga todos los chats.
      // Esto asegura que la lógica de selección/creación se ejecute con una lista de chats disponible.
      add(LoadChatsEvent());
      // Nota: Aquí no podemos garantizar la selección inmediata si LoadChatsEvent es asíncrono
      // y no emite el ChatLoaded sincrónicamente. Para un comportamiento más robusto,
      // SelectChatEvent podría manejar la carga inicial si no hay chats o estado.
      // Por simplicidad, por ahora confiaremos en que LoadChatsEvent hará su trabajo.
    }
  }


  /// Manejador para el evento SendMessageEvent
  Future<void> _onSendMessage(SendMessageEvent event, Emitter<ChatState> emit) async {
    final currentState = state;
    if (currentState is ChatLoaded && currentState.currentChat != null) {
      // 1. Mostrar el mensaje del usuario inmediatamente en la UI
      final userMessage = Message(
        id: DateTime.now().millisecondsSinceEpoch.toString(), // ID temporal
        content: event.messageContent,
        type: MessageType.user,
        timestamp: DateTime.now(),
      );
      final updatedMessagesForUI = List<Message>.from(currentState.currentChat!.messages)..add(userMessage);
      final chatWithUserMessageForUI = currentState.currentChat!.copyWith(messages: updatedMessagesForUI);

      emit(currentState.copyWith(
        currentChat: chatWithUserMessageForUI,
        isSendingMessage: true, // Indica que se está esperando la respuesta de la IA
      ));

      // 2. Llamar al caso de uso para enviar el mensaje y obtener la respuesta de la IA
      final result = await sendMessageUseCase(
        currentState.currentChat!.id,
        event.messageContent,
      );

      result.fold(
        (failure) {
          // Si hay un error, emite el estado de error y restablece el indicador de envío
          emit(ChatError(_mapFailureToMessage(failure)));
          // Opcional: Podrías querer volver al estado anterior o un ChatLoaded con un mensaje de error en el chat
          emit(currentState.copyWith(isSendingMessage: false)); // Restablece el indicador
        },
        (updatedChat) {
          // Si es exitoso, actualiza el chat en la lista de todos los chats
          final updatedAllChats = currentState.allChats.map((chat) {
            return chat.id == updatedChat.id ? updatedChat : chat;
          }).toList();

          emit(ChatLoaded(
            allChats: updatedAllChats,
            currentChat: updatedChat,
            isSendingMessage: false, // La respuesta de la IA ha llegado
          ));
        },
      );
    } else {
      // Manejar el caso donde no hay un chat actual seleccionado
      // Esta rama solo debería activarse si el estado no es ChatLoaded O currentChat es null
      // después de la carga inicial. La corrección en _onLoadChats debería prevenir esto.
      emit(ChatError('No hay un chat seleccionado para enviar el mensaje.'));
    }
  }

  /// Manejador para el evento DeleteChatEvent
  Future<void> _onDeleteChat(DeleteChatEvent event, Emitter<ChatState> emit) async {
    final currentState = state;
    if (currentState is ChatLoaded) {
      emit(ChatLoading()); // Opcional: Mostrar carga mientras se elimina

      final result = await deleteChatUseCase(event.chatId);

      result.fold(
        (failure) => emit(ChatError(_mapFailureToMessage(failure))),
        (_) {
          // Eliminar el chat de la lista local
          final updatedAllChats = currentState.allChats.where((chat) => chat.id != event.chatId).toList();

          // Si el chat eliminado era el chat actual, selecciona el primero disponible o ninguno
          Chat? newCurrentChat = currentState.currentChat?.id == event.chatId
              ? (updatedAllChats.isNotEmpty ? updatedAllChats.first : null)
              : currentState.currentChat;

          // Si no queda ningún chat después de eliminar, crea uno nuevo.
          if (updatedAllChats.isEmpty && newCurrentChat == null) {
            add(SelectChatEvent(chatId: null)); // Dispara el evento para crear un nuevo chat
          } else {
            emit(ChatLoaded(
              allChats: updatedAllChats,
              currentChat: newCurrentChat,
              isSendingMessage: false,
            ));
          }
        },
      );
    }
  }

  /// Helper para mapear fallos a mensajes de error legibles.
  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        return 'Error del servidor: ${failure.message}';
      case CacheFailure:
        return 'Error de caché: ${failure.message}';
      case NetworkFailure:
        return 'Error de red: Por favor, revisa tu conexión a internet.';
      default:
        return 'Error inesperado: ${failure.message}';
    }
  }
}

// Los archivos chat_event.dart y chat_state.dart no necesitan cambios para esta corrección.