import 'package:flutter/material.dart';
import 'produto_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Práticas Profissionais IV - Componente', // Menu de Restaurante

      debugShowCheckedModeBanner: false,
      initialRoute: 'home', // // rota nominada, ao invés de usar Navigator

      routes: {
        'home': (context) => const PaginaProduto(), // Chama a tela de produtos
      },
    );
  }
}
