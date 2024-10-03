import 'package:flutter/material.dart';
import 'produto_component.dart';  // Importando o arquivo ProdutoCard.dart

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Produto Card Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomeScreen(), // Referenciando a tela inicial
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PRODUTO CARD'),   // Produto Card
        titleTextStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: ProdutoCard(
          titulo: 'Criar Produto', // Passando o parâmetro titulo
          onSubmit: (String nome, String preco, String? categoria) {
            // Função de callback para lidar com a submissão
            print('Nome do produto: $nome');
            print('Preço: $preco');
            print('Categoria: ${categoria ?? 'Nenhuma'}');
          },
        ),
      ),
    );
  }
}