import 'package:app_ia/data/repository/ai_repository_impl.dart';
import 'package:app_ia/data/repository/chat_repository_impl.dart';
import 'package:app_ia/domain/repository/ai_repository.dart';
import 'package:app_ia/domain/repository/chat_repository.dart';
import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart'; // Asegúrate de que esta dependencia esté en tu pubspec.yaml

// ----------------------------------------------------
// ! Data Sources
// ----------------------------------------------------
import 'package:app_ia/data/datasources/ai_remote_datasource.dart';
import 'package:app_ia/data/datasources/chat_local_datasource.dart';


// ----------------------------------------------------
// ! Use Cases
// ----------------------------------------------------
import 'package:app_ia/domain/usecases/send_message_usecase.dart';
import 'package:app_ia/domain/usecases/get_chats_usecase.dart';
import 'package:app_ia/domain/usecases/create_new_chat_usecase.dart';
import 'package:app_ia/domain/usecases/delete_chat_usecase.dart';
// Si tuvieras un GetAiChatResponseUseCase independiente, iría aquí:
// import 'package:app_ia/domain/usecases/get_ai_chat_response_usecase.dart';


// ----------------------------------------------------
// ! Presentation (Blocs/Cubits)
// ----------------------------------------------------
import 'package:app_ia/presentation/bloc/chat_bloc.dart';


final sl = GetIt.instance; // 'sl' es la abreviatura de Service Locator

Future<void> init() async {
  // ----------------------------------------------------
  // ! Core - Dependencias externas y comunes
  // ----------------------------------------------------
  sl.registerLazySingleton(() => Dio()); // Cliente HTTP
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences); // Almacenamiento local
  sl.registerLazySingleton(() => const Uuid()); // Generador de IDs únicos

  // ----------------------------------------------------
  // ! Data Sources - Implementaciones concretas de las interfaces de Data Source
  // ----------------------------------------------------
  sl.registerLazySingleton<AiRemoteDatasource>(
    () => AiRemoteDatasourceImpl(
      dio: sl(),
      apiKey: 'TU_API_KEY_DE_OPENROUTER', // ¡IMPORTANTE! Reemplaza con tu clave API real
    ),
  );
  sl.registerLazySingleton<ChatLocalDatasource>(
    () => ChatLocalDatasourceImpl(
      sharedPreferences: sl(),
    ),
  );

  // ----------------------------------------------------
  // ! Repositories - Implementaciones concretas de las interfaces de Repositorios
  // ----------------------------------------------------
  sl.registerLazySingleton<AiRepository>(
    () => AiRepositoryImpl(
      remoteDatasource: sl(), // Inyecta el AiRemoteDatasource
      uuid: sl(), // Inyecta Uuid para generar IDs de mensajes de IA
    ),
  );
  sl.registerLazySingleton<ChatRepository>(
    () => ChatRepositoryImpl(
      aiRepository: sl(), // ChatRepository usa AiRepository internamente
      localDatasource: sl(), // Inyecta el ChatLocalDatasource
      uuid: sl(), // Inyecta Uuid para generar IDs de chat si es necesario
    ),
  );

  // ----------------------------------------------------
  // ! Use Cases - Lógica de negocio orquestando los Repositorios
  // ----------------------------------------------------
  sl.registerLazySingleton(() => SendMessageUseCase(
        chatRepository: sl(), // Inyecta ChatRepository
        aiRepository: sl(), // Inyecta AiRepository
        uuid: sl(), // Inyecta Uuid
      ));
  sl.registerLazySingleton(() => GetChatsUseCase(
        chatRepository: sl(), // Inyecta ChatRepository
      ));
  sl.registerLazySingleton(() => CreateNewChatUseCase(
        chatRepository: sl(), // Inyecta ChatRepository
        uuid: sl(), // Inyecta Uuid
      ));
  sl.registerLazySingleton(() => DeleteChatUseCase(
        chatRepository: sl(), // Inyecta ChatRepository
      ));
  // Si tuvieras un GetAiChatResponseUseCase independiente y fuera usado directamente:
  // sl.registerLazySingleton(() => GetAiChatResponseUseCase(aiRepository: sl()));


  // ----------------------------------------------------
  // ! Presentation (Blocs/Cubits) - Inyecta los Casos de Uso
  // ----------------------------------------------------
  // Usamos registerFactory para Blocs/Cubits, porque cada vez que se necesite
  // una instancia (ej. en un BlocProvider), GetIt creará una nueva.
  sl.registerFactory(() => ChatBloc(
        sendMessageUseCase: sl(), // Inyecta SendMessageUseCase
        getChatsUseCase: sl(), // Inyecta GetChatsUseCase
        createNewChatUseCase: sl(), // Inyecta CreateNewChatUseCase
        deleteChatUseCase: sl(), // Inyecta DeleteChatUseCase
      ));
}