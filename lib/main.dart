import 'package:app_ia/core/injection_container.dart' as di;
import 'package:app_ia/presentation/bloc/chat_bloc.dart';
import 'package:app_ia/presentation/pages/chat_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}): super(key:key);

  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      title: 'Nexus AI',
      debugShowCheckedModeBanner: false,
      home: BlocProvider(
        create: (context) => di.sl<ChatBloc>(),
        child: ChatPage(),
      ),
    );
  }
}
