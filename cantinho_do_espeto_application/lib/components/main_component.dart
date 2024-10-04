// Comandos github:
// cd cantinho_do_espeto_application
// flutter run

import 'package:flutter/material.dart';
import 'produto_component.dart'; // Importa o arquivo onde o componente de produto está definido

// Função principal que inicia o aplicativo
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Práticas Profissionais IV - Componente', // Menu de Restaurante
      home: ProductPage(), // Chama a tela de produtos
    );
  }
}
