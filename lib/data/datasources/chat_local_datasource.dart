import 'dart:convert';

import 'package:app_ia/data/models/chat_model.dart';
import 'package:app_ia/core/constants.dart'; 
import 'package:shared_preferences/shared_preferences.dart'; 
import 'package:equatable/equatable.dart'; 

// --- Fallos personalizados para la capa de datos local ---
// Aunque podrías tener fallos genéricos, es bueno ser específico.
abstract class LocalDataSourceFailure extends Equatable {
  final String message;
  const LocalDataSourceFailure(this.message);

  @override
  List<Object> get props => [message];
}

class CacheFailure extends LocalDataSourceFailure {
  const CacheFailure(String message) : super(message);
}

// --- Interfaz de la Fuente de Datos Local ---
abstract class ChatLocalDatasource {
  /// Obtiene la lista de todos los chats almacenados localmente.
  /// Lanza un [CacheFailure] si no hay chats o si ocurre un error de caché.
  Future<List<ChatModel>> getChats();

  /// Guarda una lista de chats en la caché local.
  /// Lanza un [CacheFailure] si ocurre un error al guardar.
  Future<void> saveChats(List<ChatModel> chats);

  /// Obtiene un chat específico por su ID.
  /// Lanza un [CacheFailure] si el chat no se encuentra.
  Future<ChatModel> getChatById(String chatId);

  /// Guarda o actualiza un chat específico en la caché local.
  /// Lanza un [CacheFailure] si ocurre un error al guardar.
  Future<void> saveChat(ChatModel chat);
}

// --- Implementación de la Fuente de Datos Local ---
class ChatLocalDatasourceImpl implements ChatLocalDatasource {
  final SharedPreferences sharedPreferences;
  static const String _cachedChatsKey = 'CACHED_CHATS'; // Clave para SharedPrefs

  ChatLocalDatasourceImpl({required this.sharedPreferences});

  @override
  Future<List<ChatModel>> getChats() async {
    final jsonString = sharedPreferences.getString(_cachedChatsKey);
    if (jsonString != null) {
      try {
        final List<dynamic> jsonList = json.decode(jsonString);
        return jsonList.map((json) => ChatModel.fromJson(json)).toList();
      } catch (e) {
        throw const CacheFailure(AppConstants.unknownError); // O un error más específico
      }
    } else {
      // Si no hay datos, puedes devolver una lista vacía o lanzar un error si es un requisito.
      // Aquí, asumiremos que no encontrar datos no es un fallo crítico al obtener.
      return [];
      // Si prefieres lanzar un error cuando no hay datos iniciales:
      // throw const CacheFailure(AppConstants.networkError); // Podría ser 'NoDataFound'
    }
  }

  @override
  Future<void> saveChats(List<ChatModel> chats) async {
    try {
      final jsonString = json.encode(chats.map((chat) => chat.toJson()).toList());
      await sharedPreferences.setString(_cachedChatsKey, jsonString);
    } catch (e) {
      throw const CacheFailure(AppConstants.unknownError); // O un error más específico
    }
  }

  @override
  Future<ChatModel> getChatById(String chatId) async {
    final chats = await getChats(); // Obtiene todos los chats y busca
    final chat = chats.firstWhere((c) => c.id == chatId,
        orElse: () => throw const CacheFailure('Chat no encontrado en caché.'));
    return chat;
  }

  @override
  Future<void> saveChat(ChatModel chat) async {
    final currentChats = await getChats();
    final List<ChatModel> updatedChats = List.from(currentChats);

    // Si el chat ya existe, lo reemplazamos; si no, lo añadimos.
    final index = updatedChats.indexWhere((c) => c.id == chat.id);
    if (index != -1) {
      updatedChats[index] = chat;
    } else {
      updatedChats.add(chat);
    }
    await saveChats(updatedChats); // Guarda la lista actualizada
  }
}