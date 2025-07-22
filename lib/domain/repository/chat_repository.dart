import 'package:app_ia/core/error/failures.dart';
import 'package:app_ia/domain/entity/chat.dart';
import 'package:dartz/dartz.dart';

abstract class ChatRepository {
  Future<Either<Failure, List<Chat>>> getChats();

  Future<Either<Failure, Chat>> saveChat(Chat chat);

  Future<Either<Failure, void>> deleteChat(String chatId);

  Future<Either<Failure, Chat>> getChatById(String chatId);
}
