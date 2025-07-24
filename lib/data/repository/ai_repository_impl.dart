import 'package:app_ia/core/error/failures.dart';
import 'package:app_ia/core/constants.dart';
import 'package:app_ia/data/datasources/ai_remote_datasource.dart';
import 'package:app_ia/data/models/open_router_request_model.dart';
import 'package:app_ia/domain/entity/message.dart';
import 'package:app_ia/domain/repository/ai_repository.dart';
import 'package:dio/dio.dart';
import 'package:dartz/dartz.dart';
import 'package:uuid/uuid.dart';

/// Concrete implementation of [AiRepository] from the Domain Layer.
/// This is part of the Data Layer.
class AiRepositoryImpl implements AiRepository {
  final AiRemoteDatasource remoteDatasource;
  final Uuid uuid;

  AiRepositoryImpl({
    required this.remoteDatasource,
    Uuid? uuid,
  }) : uuid = uuid ?? const Uuid();

  @override
  Future<Either<Failure, Message>> getCompletion(List<Message> messages) async {
    final requestMessages = messages.map((msg) {
      return {"role": msg.type == MessageType.user ? "user" : "assistant", "content": msg.content};
    }).toList();

    final requestModel = OpenRouterRequestModel(
      model: AppConstants.defaultModel,
      messages: requestMessages,
      temperature: AppConstants.temperature,
      maxTokens: AppConstants.maxTokens,
    );

    try {
      final remoteResponse = await remoteDatasource.generateResponse(requestModel);
      final aiMessageContent = remoteResponse.choices.first.message.content;
      final aiMessage = Message(
        id: uuid.v4(),
        content: aiMessageContent,
        type: MessageType.assistant,
        timestamp: DateTime.now(),
      );
      return Right(aiMessage);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.badResponse) {
        return Left(ServerFailure(e.response?.data['error'] ?? AppConstants.serverError));
      } else if (e.type == DioExceptionType.connectionError || e.type == DioExceptionType.connectionTimeout) {
        return Left(NetworkFailure(AppConstants.networkError));
      }
      return Left(UnknownFailure(AppConstants.unknownError));
    } catch (e) {
      return Left(UnknownFailure(AppConstants.unknownError));
    }
  }
}