// import 'dart:math' as math;

// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart'; // Para BlocConsumer y context.read
// import 'package:app_ia/presentation/bloc/chat_bloc.dart';

// // --- Importa los widgets auxiliares ---
// import 'package:app_ia/presentation/widgets/chat_header.dart';
// import 'package:app_ia/presentation/widgets/chat_list.dart';
// import 'package:app_ia/presentation/widgets/chat_input.dart';


// class ChatPage extends StatefulWidget {
//   const ChatPage({super.key});

//   @override
//   State<ChatPage> createState() => _ChatPageState();
// }

// class _ChatPageState extends State<ChatPage> with TickerProviderStateMixin {
//   final TextEditingController _messageController = TextEditingController();
//   final ScrollController _scrollController = ScrollController();
//   final FocusNode _focusNode = FocusNode();

//   late AnimationController _fadeController;
//   late Animation<double> _fadeAnimation;

//   late AnimationController _gradientController;
//   late Animation<double> _gradientAnimation;

//   @override
//   void initState() {
//     super.initState();

//     _fadeController = AnimationController(
//       duration: const Duration(milliseconds: 300),
//       vsync: this,
//     );
//     _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
//     );

//     _gradientController = AnimationController(
//       duration: const Duration(seconds: 4),
//       vsync: this,
//     );
//     _gradientAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(parent: _gradientController, curve: Curves.easeInOut),
//     );
//     _gradientController.repeat(reverse: true);

//     context.read<ChatBloc>().add(LoadChatsEvent());
//   }

//   @override
//   void dispose() {
//     _messageController.dispose();
//     _scrollController.dispose();
//     _focusNode.dispose();
//     _fadeController.dispose();
//     _gradientController.dispose();
//     super.dispose();
//   }

//   void _sendMessage() {
//     final message = _messageController.text.trim();
//     if (message.isNotEmpty) {
//       context.read<ChatBloc>().add(SendMessageEvent(message));
//       _messageController.clear();
//       _scrollToBottom();
//     }
//   }

//   void _clearChat() {
//     context.read<ChatBloc>().add(SelectChatEvent(chatId: null));
//     _fadeController.reset();
//   }

//   void _scrollToBottom() {
//     if (_scrollController.hasClients) {
//       Future.delayed(const Duration(milliseconds: 200), () {
//         if (_scrollController.hasClients) {
//           _scrollController.animateTo(
//             _scrollController.position.maxScrollExtent,
//             duration: const Duration(milliseconds: 300),
//             curve: Curves.easeOut,
//           );
//         }
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Scaffold(
//         backgroundColor: Colors.transparent, // Fondo transparente para el gradiente
//         body: AnimatedBuilder(
//           animation: _gradientAnimation,
//           builder: (context, child) {
//             return Container(
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   begin: Alignment.topCenter,
//                   end: Alignment.bottomCenter,
//                   colors: [
//                     Color.lerp(
//                       const Color(0xFF001229),
//                       const Color(0xFF002847),
//                       _gradientAnimation.value,
//                     )!,
//                     Color.lerp(
//                       const Color(0xFF000000),
//                       const Color(0xFF1A1A2E),
//                       _gradientAnimation.value,
//                     )!,
//                   ],
//                   stops: const [0.0, 0.8],
//                   transform: GradientRotation( // Usamos la clase GradientRotation corregida
//                     _gradientAnimation.value * math.pi, // Multiplicar por pi para una rotación más natural
//                   ),
//                 ),
//               ),
//               child: SafeArea(
//                 bottom: false,
//                 child: BlocConsumer<ChatBloc, ChatState>(
//                   listener: (context, state) {
//                     if (state is ChatLoaded && state.currentChat != null && state.currentChat!.messages.isNotEmpty) {
//                       _fadeController.forward();
//                     }

//                     WidgetsBinding.instance.addPostFrameCallback((_) {
//                       _scrollToBottom();
//                     });

//                     if (state is ChatError) {
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         SnackBar(
//                           content: Text(state.message),
//                           backgroundColor: Colors.red.withOpacity(0.9),
//                           behavior: SnackBarBehavior.floating,
//                           duration: const Duration(seconds: 3),
//                         ),
//                       );
//                     }
//                   },
//                   builder: (context, state) {
//                     if (state is ChatLoading) {
//                       return const Center(
//                         child: CircularProgressIndicator(
//                           color: Colors.blueAccent,
//                         ),
//                       );
//                     }

//                     if (state is ChatLoaded) {
//                       final chat = state.currentChat;
//                       final hasMessages = chat != null && chat.messages.isNotEmpty;
//                       final isSending = state.isSendingMessage;

//                       return Column(
//                         children: [
//                           ChatHeader(
//                             onClearChat: _clearChat,
//                             onNewChat: () => context.read<ChatBloc>().add(SelectChatEvent(chatId: null)),
//                             onSelectChat: (id) => context.read<ChatBloc>().add(SelectChatEvent(chatId: id)),
//                             allChats: state.allChats,
//                             currentChatId: state.currentChat?.id,
//                           ),
//                           Expanded(
//                             child: FadeTransition(
//                               opacity: _fadeAnimation,
//                               child: hasMessages && chat != null
//                                   ? ChatList(
//                                       messages: chat.messages,
//                                       scrollController: _scrollController,
//                                       isSendingMessage: isSending,
//                                     )
//                                   : const Center(
//                                       child: Text(
//                                         '¡Hola! Hazme una pregunta para empezar.',
//                                         style: TextStyle(color: Colors.white70, fontSize: 16),
//                                         textAlign: TextAlign.center,
//                                       ),
//                                     ),
//                             ),
//                           ),
//                           ChatInput(
//                             messageController: _messageController,
//                             focusNode: _focusNode,
//                             onSendMessage: _sendMessage,
//                             isSending: isSending,
//                           ),
//                         ],
//                       );
//                     }

//                     return Center(
//                       child: Text(
//                         'Estado no manejado: $state',
//                         style: const TextStyle(color: Colors.red),
//                       ),
//                     );
//                   },
//                 ),
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }
// }


//************************************************************************************************

// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart'; 
// import 'package:app_ia/presentation/bloc/chat_bloc.dart';

// // --- Importa los widgets auxiliares ---
// import 'package:app_ia/presentation/widgets/chat_header.dart';
// import 'package:app_ia/presentation/widgets/chat_list.dart';
// import 'package:app_ia/presentation/widgets/chat_input.dart';


// class ChatPage extends StatefulWidget {
//   const ChatPage({super.key});

//   @override
//   State<ChatPage> createState() => _ChatPageState();
// }

// class _ChatPageState extends State<ChatPage> with TickerProviderStateMixin {
//   final TextEditingController _messageController = TextEditingController();
//   final ScrollController _scrollController = ScrollController();
//   final FocusNode _focusNode = FocusNode();

//   late AnimationController _fadeController;
//   late Animation<double> _fadeAnimation;

//   // Las siguientes animaciones de gradiente ya no son necesarias para el fondo con imagen,
//   // pero las mantengo comentadas por si las quieres reutilizar para otra cosa.
//   // late AnimationController _gradientController;
//   // late Animation<double> _gradientAnimation;

//   @override
//   void initState() {
//     super.initState();

//     _fadeController = AnimationController(
//       duration: const Duration(milliseconds: 300),
//       vsync: this,
//     );
//     _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
//     );

//     // Si no vas a usar el gradiente animado, puedes eliminar estas líneas.
//     // _gradientController = AnimationController(
//     //   duration: const Duration(seconds: 4),
//     //   vsync: this,
//     // );
//     // _gradientAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
//     //   CurvedAnimation(parent: _gradientController, curve: Curves.easeInOut),
//     // );
//     // _gradientController.repeat(reverse: true);

//     context.read<ChatBloc>().add(LoadChatsEvent());
//   }

//   @override
//   void dispose() {
//     _messageController.dispose();
//     _scrollController.dispose();
//     _focusNode.dispose();
//     _fadeController.dispose();
//     // Asegúrate de disponer de los controladores si los eliminas del initState.
//     // _gradientController.dispose();
//     super.dispose();
//   }

//   void _sendMessage() {
//     final message = _messageController.text.trim();
//     if (message.isNotEmpty) {
//       context.read<ChatBloc>().add(SendMessageEvent(message));
//       _messageController.clear();
//       _scrollToBottom();
//     }
//   }

//   void _clearChat() {
//     context.read<ChatBloc>().add(SelectChatEvent(chatId: null));
//     _fadeController.reset();
//   }

//   void _scrollToBottom() {
//     if (_scrollController.hasClients) {
//       Future.delayed(const Duration(milliseconds: 200), () {
//         if (_scrollController.hasClients) {
//           _scrollController.animateTo(
//             _scrollController.position.maxScrollExtent,
//             duration: const Duration(milliseconds: 300),
//             curve: Curves.easeOut,
//           );
//         }
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.transparent, // Fondo transparente para que se vea la imagen
//       body: Stack( // Usamos Stack para superponer la imagen de fondo y el contenido del chat
//         children: [
//           // 1. Fondo de la cara futurista
//           Positioned.fill( // Esto hace que la imagen ocupe todo el espacio disponible
//             child: Image.asset(
//               'assets/images/futuristic_face.png', // <-- ¡ACTUALIZA ESTA RUTA CON TU IMAGEN/GIF!
//               fit: BoxFit.cover, // Para que la imagen cubra el área sin deformarse
//               // Si es un GIF, se reproducirá automáticamente.
//             ),
//           ),

//           // 2. Contenido del chat (encima de la imagen)
//           SafeArea(
//             bottom: false,
//             child: BlocConsumer<ChatBloc, ChatState>(
//               listener: (context, state) {
//                 if (state is ChatLoaded && state.currentChat != null && state.currentChat!.messages.isNotEmpty) {
//                   _fadeController.forward();
//                 }

//                 WidgetsBinding.instance.addPostFrameCallback((_) {
//                   _scrollToBottom();
//                 });

//                 if (state is ChatError) {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(
//                       content: Text(state.message),
//                       backgroundColor: Colors.red.withOpacity(0.9),
//                       behavior: SnackBarBehavior.floating,
//                       duration: const Duration(seconds: 3),
//                     ),
//                   );
//                 }
//               },
//               builder: (context, state) {
//                 if (state is ChatLoading) {
//                   return const Center(
//                     child: CircularProgressIndicator(
//                       color: Colors.blueAccent,
//                     ),
//                   );
//                 }

//                 if (state is ChatLoaded) {
//                   final chat = state.currentChat;
//                   final hasMessages = chat != null && chat.messages.isNotEmpty;
//                   final isSending = state.isSendingMessage;

//                   return Column(
//                     children: [
//                       ChatHeader(
//                         onClearChat: _clearChat,
//                         onNewChat: () => context.read<ChatBloc>().add(SelectChatEvent(chatId: null)),
//                         onSelectChat: (id) => context.read<ChatBloc>().add(SelectChatEvent(chatId: id)),
//                         allChats: state.allChats,
//                         currentChatId: state.currentChat?.id,
//                       ),
//                       Expanded(
//                         child: FadeTransition(
//                           opacity: _fadeAnimation,
//                           child: hasMessages && chat != null
//                               ? ChatList(
//                                   messages: chat.messages,
//                                   scrollController: _scrollController,
//                                   isSendingMessage: isSending,
//                                 )
//                               : const Center(
//                                   child: Text(
//                                     '¡Hola! Hazme una pregunta para empezar.',
//                                     style: TextStyle(color: Colors.white70, fontSize: 16),
//                                     textAlign: TextAlign.center,
//                                   ),
//                                 ),
//                         ),
//                       ),
//                       ChatInput(
//                         messageController: _messageController,
//                         focusNode: _focusNode,
//                         onSendMessage: _sendMessage,
//                         isSending: isSending,
//                       ),
//                     ],
//                   );
//                 }

//                 return Center(
//                   child: Text(
//                     'Estado no manejado: $state',
//                     style: const TextStyle(color: Colors.red),
//                   ),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

//****************************************************************************************************** */

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // Para BlocConsumer y context.read

// --- Importa los widgets auxiliares ---
import 'package:app_ia/presentation/bloc/chat_bloc.dart';
import 'package:app_ia/presentation/widgets/chat_header.dart';
import 'package:app_ia/presentation/widgets/chat_list.dart';
import 'package:app_ia/presentation/widgets/chat_input.dart';
import 'package:app_ia/presentation/widgets/futuristic_face_animation.dart'; // ¡Importa el nuevo widget!


class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    context.read<ChatBloc>().add(LoadChatsEvent());
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final message = _messageController.text.trim();
    if (message.isNotEmpty) {
      context.read<ChatBloc>().add(SendMessageEvent(message));
      _messageController.clear();
      _scrollToBottom();
    }
  }

  void _clearChat() {
    context.read<ChatBloc>().add(SelectChatEvent(chatId: null));
    _fadeController.reset();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 200), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Opcional: Establece un color de fondo para que la animación destaque
      body: Stack( // Usamos Stack para superponer la animación de fondo y el contenido del chat
        children: [
          // 1. Fondo de la cara futurista con tu nueva animación Flutter
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient( // Un gradiente para el fondo, similar a tu CSS
                  colors: [Color(0xFF0a0a0a), Color(0xFF1a1a2e), Color(0xFF16213e)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: BlocBuilder<ChatBloc, ChatState>(
                builder: (context, state) {
                  bool isSpeaking = false;
                  if (state is ChatLoaded) {
                    // La cara "habla" cuando la IA está pensando/enviando un mensaje
                    isSpeaking = state.isSendingMessage;
                  }
                  return FuturisticFaceAnimation(isSpeaking: isSpeaking);
                },
              ),
            ),
          ),

          // 2. Contenido del chat (encima de la animación)
          SafeArea(
            bottom: false,
            child: BlocConsumer<ChatBloc, ChatState>(
              listener: (context, state) {
                if (state is ChatLoaded && state.currentChat != null && state.currentChat!.messages.isNotEmpty) {
                  _fadeController.forward();
                }

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _scrollToBottom();
                });

                if (state is ChatError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.red.withOpacity(0.9),
                      behavior: SnackBarBehavior.floating,
                      duration: const Duration(seconds: 3),
                    ),
                  );
                }
              },
              builder: (context, state) {
                if (state is ChatLoading) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Colors.blueAccent,
                    ),
                  );
                }

                if (state is ChatLoaded) {
                  final chat = state.currentChat;
                  final hasMessages = chat != null && chat.messages.isNotEmpty;
                  final isSending = state.isSendingMessage;

                  return Column(
                    children: [
                      ChatHeader(
                        onClearChat: _clearChat,
                        onNewChat: () => context.read<ChatBloc>().add(SelectChatEvent(chatId: null)),
                        onSelectChat: (id) => context.read<ChatBloc>().add(SelectChatEvent(chatId: id)),
                        allChats: state.allChats,
                        currentChatId: state.currentChat?.id,
                      ),
                      Expanded(
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: hasMessages && chat != null
                              ? ChatList(
                                  messages: chat.messages,
                                  scrollController: _scrollController,
                                  isSendingMessage: isSending,
                                )
                              : const Center(
                                  child: Text(
                                    '¡Hola! Hazme una pregunta para empezar.',
                                    style: TextStyle(color: Colors.white70, fontSize: 16),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                        ),
                      ),
                      ChatInput(
                        messageController: _messageController,
                        focusNode: _focusNode,
                        onSendMessage: _sendMessage,
                        isSending: isSending,
                      ),
                    ],
                  );
                }

                return Center(
                  child: Text(
                    'Estado no manejado: $state',
                    style: const TextStyle(color: Colors.red),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}