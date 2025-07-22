import 'package:app_ia/core/error/failures.dart';
import 'package:app_ia/domain/entity/message.dart';
import 'package:dartz/dartz.dart';

/// Abstract class defining the contract for AI-related operations.
/// This is part of the Domain Layer.
abstract class AiRepository {
  /// Generates a response from the AI model based on a list of messages.
  ///
  /// Returns a [Future] of [Either] a [Failure] on the left,
  /// or a [Message] (the AI's generated response) on the right.
  Future<Either<Failure, Message>> getCompletion(List<Message> messages);
}