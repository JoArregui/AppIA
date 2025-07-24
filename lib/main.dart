import 'package:app_ia/core/injection_container.dart' as di;
import 'package:app_ia/presentation/bloc/chat_bloc.dart';
import 'package:app_ia/presentation/pages/chat_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; 

void main() async {
  // Asegúrate de que los widgets de Flutter estén inicializados
  WidgetsFlutterBinding.ensureInitialized();

  // Carga tu archivo .env
  // Asegúrate de que el archivo .env esté en la raíz de tu proyecto
  // (al mismo nivel que pubspec.yaml)
  await dotenv.load(fileName: ".env");

  await di.init(); // Inicializa tus dependencias GetIt después de cargar dotenv
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nexus AI',
      debugShowCheckedModeBanner: false,
      home: BlocProvider(
        create: (context) => di.sl<ChatBloc>(),
        child: ChatPage(),
      ),
    );
  }
}