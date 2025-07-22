import 'package:app_ia/domain/entity/message.dart';
import 'package:flutter/material.dart';


class ChatList extends StatelessWidget {
  final List<Message> messages;
  final ScrollController scrollController;
  final bool isSendingMessage; // Para mostrar un indicador al final

  const ChatList({
    super.key,
    required this.messages,
    required this.scrollController,
    required this.isSendingMessage,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      itemCount: messages.length + (isSendingMessage ? 1 : 0), // Añade 1 si está enviando
      itemBuilder: (context, index) {
        if (index < messages.length) {
          final message = messages[index];
          final isUser = message.type == MessageType.user;

          return Align(
            alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 4.0),
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: isUser ? Colors.blueAccent : Colors.grey[800],
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Text(
                message.content,
                style: const TextStyle(color: Colors.white, fontSize: 16.0),
              ),
            ),
          );
        } else {
          // Mostrar indicador de carga si isSendingMessage es true y es el último elemento
          return const Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(
                color: Colors.white54,
                strokeWidth: 2.0,
              ),
            ),
          );
        }
      },
    );
  }
}