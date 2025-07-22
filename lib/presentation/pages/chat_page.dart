import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // Para BlocConsumer y context.read
import 'package:app_ia/presentation/bloc/chat_bloc.dart';

// --- Importa los widgets auxiliares ---
import 'package:app_ia/presentation/widgets/chat_header.dart';
import 'package:app_ia/presentation/widgets/chat_list.dart';
import 'package:app_ia/presentation/widgets/chat_input.dart';


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

  late AnimationController _gradientController;
  late Animation<double> _gradientAnimation;

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

    _gradientController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );
    _gradientAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _gradientController, curve: Curves.easeInOut),
    );
    _gradientController.repeat(reverse: true);

    context.read<ChatBloc>().add(LoadChatsEvent());
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    _fadeController.dispose();
    _gradientController.dispose();
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
    return Center(
      child: Scaffold(
        backgroundColor: Colors.transparent, // Fondo transparente para el gradiente
        body: AnimatedBuilder(
          animation: _gradientAnimation,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color.lerp(
                      const Color(0xFF001229),
                      const Color(0xFF002847),
                      _gradientAnimation.value,
                    )!,
                    Color.lerp(
                      const Color(0xFF000000),
                      const Color(0xFF1A1A2E),
                      _gradientAnimation.value,
                    )!,
                  ],
                  stops: const [0.0, 0.8],
                  transform: GradientRotation( // Usamos la clase GradientRotation corregida
                    _gradientAnimation.value * math.pi, // Multiplicar por pi para una rotación más natural
                  ),
                ),
              ),
              child: SafeArea(
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
            );
          },
        ),
      ),
    );
  }
}