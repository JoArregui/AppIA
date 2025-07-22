import 'package:app_ia/core/error/failures.dart';
import 'package:app_ia/domain/entity/chat.dart';
import 'package:app_ia/domain/repository/chat_repository.dart';
import 'package:dartz/dartz.dart';

/// Caso de uso para obtener todos los chats almacenados.
///
/// Este caso de uso delega la operación al ChatRepository.
class GetChatsUseCase {
  final ChatRepository chatRepository;

  GetChatsUseCase({required this.chatRepository});

  /// Ejecuta el caso de uso.
  ///
  /// Retorna un [Future] de [Either] con un [Failure] en caso de error
  /// o una [List<Chat>] en caso de éxito.
  Future<Either<Failure, List<Chat>>> call() async {
    return await chatRepository.getChats();
  }
}