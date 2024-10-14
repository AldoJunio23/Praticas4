// Comandos github:
// cd cantinho_do_espeto_application
// flutter run

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


/*

// Tela de Resumo dos Produtos
class TelaResumo extends StatelessWidget {
  final List<Map<String, String>> produtosSelecionados;

  const TelaResumo({Key? key, required this.produtosSelecionados})
      : super(key: key);

  // Função para finalizar o pedido
  void avancarPedido(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Finalizar pedido'),
          content: const Text('Você realmente deseja fechar o pedido?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop(); // Fecha o diálogo
              },
            ),
            TextButton(
              child: const Text('Confirmar'),
              onPressed: () {
                // Fecha o diálogo
                Navigator.of(context).pop();
                // Navega para a nova tela de execução
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TelaProcessandoPedido(
                      produtosSelecionados: produtosSelecionados,
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resumo do Pedido'),
        backgroundColor: Colors.orange,
      ),
      body: ListView.builder(
        itemCount: produtosSelecionados.length,
        itemBuilder: (context, index) {
          final produto = produtosSelecionados[index];
          return ListTile(
            title: Text(produto['title']!),
            subtitle: Text(produto['price']!),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () =>
            avancarPedido(context), // Chama a função ao pressionar o botão
        backgroundColor: Colors.green,
        child: const Icon(Icons.check),
      ),
    );
  }
}
*/