import 'package:app_ia/domain/entity/chat.dart';
import 'package:app_ia/domain/entity/message.dart';
import 'package:app_ia/core/error/failures.dart';
import 'package:app_ia/core/constants.dart';
import 'package:app_ia/data/datasources/chat_local_datasource.dart' hide CacheFailure;
import 'package:app_ia/data/models/chat_model.dart';
import 'package:app_ia/domain/repository/ai_repository.dart';
import 'package:app_ia/domain/repository/chat_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:uuid/uuid.dart';

class ChatRepositoryImpl implements ChatRepository {
  final AiRepository aiRepository;
  final ChatLocalDatasource localDatasource;
  final Uuid uuid;

  ChatRepositoryImpl({
    required this.aiRepository,
    required this.localDatasource,
    Uuid? uuid,
  }) : uuid = uuid ?? const Uuid();

  @override
  Future<Either<Failure, List<Chat>>> getChats() async {
    try {
      final localChats = await localDatasource.getChats();
      return Right(localChats);
    } on CacheFailure catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(AppConstants.unknownError));
    }
  }

  @override
  Future<Either<Failure, Chat>> saveChat(Chat chat) async {
    try {
      final chatModel = ChatModel.fromEntity(chat);
      await localDatasource.saveChat(chatModel);
      return Right(chat);
    } on CacheFailure catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(AppConstants.unknownError));
    }
  }

  @override
  Future<Either<Failure, void>> deleteChat(String chatId) async {
    try {
      final currentChats = await localDatasource.getChats();
      final updatedChats = currentChats.where((chat) => chat.id != chatId).toList();
      await localDatasource.saveChats(updatedChats);
      return const Right(null);
    } on CacheFailure catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(AppConstants.unknownError));
    }
  }

  @override
  Future<Either<Failure, Chat>> getChatById(String chatId) async {
    try {
      final chatModel = await localDatasource.getChatById(chatId);
      return Right(chatModel);
    } on CacheFailure catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(AppConstants.unknownError));
    }
  }

  @override
  Future<Either<Failure, Message>> getAIChatResponse(List<Message> messages) async {
    // Aquí es donde delegamos la llamada al AiRepository
    // para obtener la respuesta de la IA.
    return await aiRepository.getCompletion(messages);
  }
}