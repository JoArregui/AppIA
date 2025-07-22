import 'package:app_ia/data/models/open_router_request_model.dart';
import 'package:app_ia/data/models/open_router_response_model.dart';
import 'package:dio/dio.dart';
import 'package:app_ia/core/constants.dart'; 


abstract class AiRemoteDatasource {
  Future<OpenRouterResponseModel> generateResponse(
    OpenRouterRequestModel request,
  );
}

class AiRemoteDatasourceImpl implements AiRemoteDatasource {
  final Dio dio;
  final String apiKey;
  static const String baseUrl = 'https://openrouter.ai/api/v1';

  AiRemoteDatasourceImpl({
    required this.dio,
    required this.apiKey,
  });

  @override
  Future<OpenRouterResponseModel> generateResponse(
    OpenRouterRequestModel request,
  ) async {
    try {
      final response = await dio.post(
        '$baseUrl/chat/completions',
        data: request.toJson(),
        options: Options(
          headers: {
            'Authorization': 'Bearer $apiKey',
            'Content-Type': 'application/json',
            'HTTP-Referer': 'https://yourapp.com', // Mantener este o usar una constante si existe
            'X-Title': AppConstants.appTitle, // ¡Usando la constante aquí!
          },
        ),
      );

      if (response.statusCode == 200) {
        return OpenRouterResponseModel.fromJson(response.data);
      } else {
        // Podrías mapear esto a una Failure de dominio, usando AppConstants.serverError
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: AppConstants.serverError, // Usando la constante de error
        );
      }
    } on DioException catch (e) {
      print('Error en AiRemoteDatasourceImpl: $e');
      if (e.response != null) {
        print('Datos del error: ${e.response?.data}');
      }
      // Podrías lanzar una Failure específica aquí, como NetworkFailure o ServerFailure
      throw e; // Relanzar la excepción para que la capa de repositorio la capture
    } catch (e) {
      print('Error inesperado en AiRemoteDatasourceImpl: $e');
      // Podrías lanzar una UnknownFailure aquí, usando AppConstants.unknownError
      throw e;
    }
  }
}