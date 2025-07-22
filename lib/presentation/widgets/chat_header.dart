import 'package:app_ia/domain/entity/chat.dart';
import 'package:app_ia/presentation/bloc/chat_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // Asegúrate de importar Chat

class ChatHeader extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onClearChat;
  final VoidCallback onNewChat;
  final Function(String)? onSelectChat; // Función para seleccionar un chat existente
  final List<Chat> allChats; // Lista de todos los chats
  final String? currentChatId; // ID del chat actual

  const ChatHeader({
    super.key,
    required this.onClearChat,
    required this.onNewChat,
    this.onSelectChat,
    required this.allChats,
    this.currentChatId,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent, // Transparente para ver el gradiente de fondo
      elevation: 0,
      title: const Text(
        'Mi Asistente IA',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      actions: [
        // Botón para un nuevo chat
        IconButton(
          icon: const Icon(Icons.add_comment_outlined, color: Colors.white),
          onPressed: onNewChat,
          tooltip: 'Nuevo Chat',
        ),
        // Menú para seleccionar/eliminar chats
        if (allChats.isNotEmpty)
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) {
              if (value == 'clear_current') {
                onClearChat(); // Asumimos que "clear_current" crea un nuevo chat
              } else if (value.startsWith('delete_')) {
                final chatIdToDelete = value.substring('delete_'.length);
                // Lógica para eliminar chat, quizás un AlertDialog de confirmación
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Eliminar Chat'),
                    content: const Text('¿Estás seguro de que quieres eliminar este chat?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancelar'),
                      ),
                      TextButton(
                        onPressed: () {
                          // Llama a la función de eliminar en el Bloc a través del Page
                          // Esto se manejará en ChatPage, no directamente aquí
                          // Por ahora, solo cerramos el diálogo y asumimos que ChatPage lo hará
                          Navigator.of(context).pop();
                          // Aquí deberías llamar a un evento del Bloc para eliminar
                          // context.read<ChatBloc>().add(DeleteChatEvent(chatIdToDelete));
                          // Para que funcione, ChatPage debe pasar una función de eliminar por ID
                        },
                        child: const Text('Eliminar'),
                      ),
                    ],
                  ),
                );
              } else if (onSelectChat != null) {
                onSelectChat!(value); // Seleccionar chat
              }
            },
            itemBuilder: (context) {
              final List<PopupMenuEntry<String>> items = [
                const PopupMenuItem<String>(
                  value: 'clear_current',
                  child: Text('Nuevo Chat (Borrar Actual)'),
                ),
                const PopupMenuDivider(),
                const PopupMenuItem<String>(
                  enabled: false,
                  child: Text('Chats Guardados'),
                ),
              ];

              for (final chat in allChats) {
                items.add(
                  PopupMenuItem<String>(
                    value: chat.id,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            chat.messages.isNotEmpty
                                ? chat.messages.first.content.split('\n').first // Muestra la primera línea del primer mensaje
                                : 'Chat Vacío',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: chat.id == currentChatId ? FontWeight.bold : FontWeight.normal,
                              color: chat.id == currentChatId ? Colors.blueAccent : null,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, size: 18),
                          onPressed: () {
                            // Cierra el menú y maneja la eliminación
                            Navigator.pop(context); // Cierra el PopupMenu
                            // Dispara el evento de eliminación
                            context.read<ChatBloc>().add(DeleteChatEvent(chat.id));
                          },
                        ),
                      ],
                    ),
                  ),
                );
              }
              return items;
            },
          ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}