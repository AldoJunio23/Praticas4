import 'package:flutter/material.dart';
import 'package:flutter_application_praticas/pages/login_page.dart';
import 'package:google_fonts/google_fonts.dart'; // Importa o Google Fonts
import 'package:flutter_application_praticas/pages/home_page.dart';
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
    return MaterialApp(
      theme: ThemeData(
        textTheme: GoogleFonts.montserratTextTheme( // Define a fonte padrão para todo o tema
          Theme.of(context).textTheme, // Mantém outros estilos de texto padrão
        ),
      ),
      debugShowCheckedModeBanner: false,
      title: 'Flutter Application PraticasIV',
      home: const HomePage(),
    );
  }
}
