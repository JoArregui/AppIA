import 'package:app_ia/domain/entity/chat.dart';
import 'package:app_ia/domain/entity/message.dart';
import 'package:app_ia/core/error/failures.dart';
import 'package:app_ia/domain/repository/ai_repository.dart';
import 'package:app_ia/domain/repository/chat_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:uuid/uuid.dart'; // Para generar IDs únicos

/// Caso de uso para enviar un nuevo mensaje en un chat.
///
/// Este caso de uso orquesta la adición del mensaje del usuario,
/// la obtención de la respuesta de la IA a través del AiRepository,
/// y la actualización del chat en el ChatRepository.
class SendMessageUseCase {
  final ChatRepository chatRepository;
  final AiRepository aiRepository;
  final Uuid uuid;

  SendMessageUseCase({
    required this.chatRepository,
    required this.aiRepository,
    Uuid? uuid,
  }) : uuid = uuid ?? const Uuid();

  /// Ejecuta el caso de uso para enviar un mensaje.
  ///
  /// Recibe el [chatId] del chat actual y el [messageContent] del usuario.
  ///
  /// Retorna un [Future] de [Either] con un [Failure] en caso de error
  /// o el [Chat] actualizado con ambos mensajes (usuario y IA) en caso de éxito.
  Future<Either<Failure, Chat>> call(String chatId, String messageContent) async {
    // 1. Obtener el chat actual
    final chatResult = await chatRepository.getChatById(chatId);

    return await chatResult.fold(
      (failure) => Left(failure), // Si falla obtener el chat, propaga el error
      (currentChat) async {
        // 2. Añadir el mensaje del usuario
        final userMessage = Message(
          id: uuid.v4(),
          content: messageContent,
          type: MessageType.user,
          timestamp: DateTime.now(),
        );

        final updatedMessages = List<Message>.from(currentChat.messages)..add(userMessage);
        final chatWithUserMessage = currentChat.copyWith(
          messages: updatedMessages,
          updatedAt: DateTime.now(),
        );

        // Opcional: Guardar el chat con el mensaje del usuario inmediatamente
        // Esto puede ser útil si quieres mostrar el mensaje del usuario en la UI
        // antes de que llegue la respuesta de la IA.
        // const saveUserMessageChat = await chatRepository.saveChat(chatWithUserMessage);
        // saveUserMessageChat.fold(
        //   (saveFailure) => print('Error al guardar mensaje de usuario: ${saveFailure.message}'),
        //   (_) => null,
        // );


        // 3. Obtener respuesta de la IA
        final aiResult = await aiRepository.getCompletion(updatedMessages); // Envía todo el historial

        return await aiResult.fold(
          (failure) => Left(failure), // Si falla la IA, propaga el error
          (aiResponse) async {
            // 4. Añadir el mensaje de la IA
            final finalMessages = List<Message>.from(chatWithUserMessage.messages)..add(aiResponse);
            final finalChat = chatWithUserMessage.copyWith(
              messages: finalMessages,
              updatedAt: DateTime.now(),
            );

            // 5. Guardar el chat actualizado (con mensaje de usuario y de IA)
            final saveResult = await chatRepository.saveChat(finalChat);

            return saveResult.fold(
              (saveFailure) => Left(saveFailure), // Si falla al guardar, propaga el error
              (_) => Right(finalChat), // ¡Éxito! Devuelve el chat completo
            );
          },
        );
      },
    );
  }
}