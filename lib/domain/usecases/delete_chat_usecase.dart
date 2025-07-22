import 'package:app_ia/core/error/failures.dart';
import 'package:app_ia/domain/repository/chat_repository.dart';
import 'package:dartz/dartz.dart';

/// Caso de uso para eliminar un chat existente.
///
/// Este caso de uso delega la operación de eliminación al ChatRepository.
class DeleteChatUseCase {
  final ChatRepository chatRepository;

  DeleteChatUseCase({required this.chatRepository});

  /// Ejecuta el caso de uso.
  ///
  /// Recibe el [chatId] del chat a eliminar.
  /// Retorna un [Future] de [Either] con un [Failure] en caso de error
  /// o [void] en caso de éxito (indicando que la eliminación fue exitosa).
  Future<Either<Failure, void>> call(String chatId) async {
    return await chatRepository.deleteChat(chatId);
  }
}