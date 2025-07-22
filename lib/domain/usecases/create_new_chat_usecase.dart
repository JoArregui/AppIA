import 'package:app_ia/core/error/failures.dart';
import 'package:app_ia/domain/entity/chat.dart';
import 'package:app_ia/domain/repository/chat_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:uuid/uuid.dart'; // Para generar el ID del nuevo chat

/// Caso de uso para crear un nuevo chat vacío.
///
/// Este caso de uso crea una nueva entidad [Chat] y la guarda a través del ChatRepository.
class CreateNewChatUseCase {
  final ChatRepository chatRepository;
  final Uuid uuid;

  CreateNewChatUseCase({
    required this.chatRepository,
    Uuid? uuid,
  }) : uuid = uuid ?? const Uuid();

  /// Ejecuta el caso de uso.
  ///
  /// Retorna un [Future] de [Either] con un [Failure] en caso de error
  /// o el [Chat] recién creado en caso de éxito.
  Future<Either<Failure, Chat>> call() async {
    final newChat = Chat(
      id: uuid.v4(),
      messages: [], // Empieza vacío
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    return await chatRepository.saveChat(newChat);
  }
}