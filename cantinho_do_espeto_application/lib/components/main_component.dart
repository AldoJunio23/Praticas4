// Comandos github:
// cd cantinho_do_espeto_application
// flutter run

import 'package:flutter/material.dart';
import 'produto_page.dart'; // Importa o arquivo onde o componente de produto está definido

//import 'produto_detalhes.dart'; // Importa o arquivo onde o componente de produto está definido

// Função principal que inicia o aplicativo
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

        //'detalhes': (context) => const DetalhesProduto(),   // rotas nominadas com parâmetros
      },
    );
  }
}
