// Card Componente - Main - 03/10/2024

// teste:
import 'package:flutter/material.dart';

// Componente que representa um item do menu
class MenuItemCard extends StatelessWidget {
  final String title; // Nome do item
  final String price; // Preço do item
  final String imageAsset; // Caminho da imagem
  final Function onAdd; // Função a ser chamada ao adicionar

  const MenuItemCard({
    Key? key,
    required this.title,
    required this.price,
    required this.imageAsset,
    required this.onAdd,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(imageAsset, height: 60), // Usando a imagem do assets
            const SizedBox(height: 8.0),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4.0),
            Text(
              price,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16.0),

            /*
            ElevatedButton(
              onPressed: () => onAdd(), // Chama a função passada
              child: const Text('ADICIONAR'),
            ),
            */

          ],
        ),
      ),
    );
  }
}

// Tela principal
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Práticas Profissionais IV - Componente',    // Menu de Restaurante
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Geral - Produtos'),    // Menu
          centerTitle: true,
          titleTextStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
          backgroundColor: Colors.blue,
        ),
        body: Padding(
          padding: const EdgeInsets.all(50.0),  // antes 16
          child: GridView.count(
            crossAxisCount: 3, // Alterado para 3 colunas
            crossAxisSpacing: 16.0, // Espaçamento horizontal
            mainAxisSpacing: 16.0, // Espaçamento vertical
            childAspectRatio: 0.75, // Ajustado para melhorar a proporção dos cards
            children: List.generate(6, (index) {

              // Lista de produtos
              final List<String> productTitles = [
                'Produto A',
                'Produto B',
                'Produto C',
                'Produto D',
                'Produto E',
                'Produto F'
              ];
              
              // Lista de preços
              final List<String> productPrices = [
                '\$5.99 reais',
                '\$10.49 reais',
                '\$15.99 reais',
                '\$20.99 reais',
                '\$25.49 reais',
                '\$30.99 reais',
              ];

              return MenuItemCard(
                title: productTitles[index], // Nome do produto
                price: productPrices[index], // Preço correspondente
                imageAsset: 'assets/comando-github-praticas4.png', // Caminho da imagem
                onAdd: () {
                  print('${productTitles[index]} adicionado'); // Mensagem no console
                },
              );
            }),
          ),
        ),
      ),
    );
  }
}

// Função principal que inicia o aplicativo
void main() {
  runApp(MyApp());
}


// Comandos github:
// cd cantinho_do_espeto_application
// flutter run