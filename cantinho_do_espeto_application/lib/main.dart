import 'package:flutter/material.dart';
import 'package:flutter_application_praticas/pages/cozinha_page.dart';
import 'package:flutter_application_praticas/pages/crud_pages/deletar_page.dart';
import 'package:flutter_application_praticas/pages/home_page.dart';
import 'package:flutter_application_praticas/pages/inicio_page.dart';
import 'options/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Application PraticasIV',
      home: TelaInicio(),
    );
  }
}