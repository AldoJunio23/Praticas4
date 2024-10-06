import 'package:flutter/material.dart';
import 'produto_detalhes.dart';

class PaginaProduto extends StatefulWidget {
  const PaginaProduto({Key? key}) : super(key: key);

  @override
  _PaginaProdutoState createState() => _PaginaProdutoState();
}

class _PaginaProdutoState extends State<PaginaProduto> {
  // Lista para armazenar os produtos selecionados
  List<Map<String, String>> produtosSelecionados = [];

  @override
  Widget build(BuildContext context) {
    final List<String> productTitles = [
      'Produto A',
      'Produto B',
      'Produto C',
      'Produto D',
      'Produto E',
      'Produto F'
    ];

    final List<String> productPrices = [
      '\$5.99',
      '\$10.49',
      '\$15.99',
      '\$20.99',
      '\$25.49',
      '\$30.99'
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Geral - Produtos'),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2, // Exibe 2 cards por linha
          crossAxisSpacing: 16.0,
          mainAxisSpacing: 16.0,
          children: List.generate(productTitles.length, (index) {
            return MenuItemCard(
              title: productTitles[index],
              price: productPrices[index],
              imageAsset: 'assets/comando-github-praticas4.png',
              onAdd: () {
                setState(() {
                  // Adiciona o produto à lista
                  produtosSelecionados.add({
                    'title': productTitles[index],
                    'price': productPrices[index],
                  });
                });
              },
            );
          }),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orange,
        onPressed: () {
          // Ao pressionar, vá para a página de detalhes e passe a lista de produtos
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetalhesProdutos(
                produtosSelecionados: produtosSelecionados,
              ),
            ),
          );
        },
        child: const Icon(Icons.shopping_cart),
      ),
    );
  }
}

class MenuItemCard extends StatelessWidget {
  final String title;
  final String price;
  final String imageAsset;
  final VoidCallback onAdd;

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
            Image.asset(imageAsset, height: 60),
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
            Align(
              alignment: Alignment.bottomRight,
              child: ElevatedButton(
                onPressed: onAdd,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(10),
                ),
                child: const Icon(Icons.add, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}



/*

import 'package:flutter/material.dart';
import 'produto_detalhes.dart';

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

            Align(
              alignment:
                  Alignment.bottomRight, // Posiciona no canto inferior direito
              child: ElevatedButton(
                onPressed: () {
                  // Função ao clicar no botão: Navega para a página de detalhes
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetalhesProduto(
                          productName: title, productPrice: price),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green, // Cor de fundo laranja
                  shape: const CircleBorder(), // Botão circular
                  padding: const EdgeInsets.all(15), // Tamanho do botão
                ),
                child: const Icon(
                  Icons.add,
                  color: Colors.white,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

// Tela principal
class PaginaProduto extends StatelessWidget {
  const PaginaProduto({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Geral - Produtos'), // Menu
        centerTitle: true,
        titleTextStyle:
            const TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
        backgroundColor: Colors.orange, // blue
      ),
      body: Padding(
        padding: const EdgeInsets.all(50.0), // antes 16
        child: GridView.count(
          crossAxisCount: 3, // Alterado para 3 colunas
          crossAxisSpacing: 16.0, // Espaçamento horizontal
          mainAxisSpacing: 16.0, // Espaçamento vertical
          childAspectRatio:
              0.75, // Ajustado para melhorar a proporção dos cards
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
              '\$30.99 reais'
            ];

            return MenuItemCard(
              title: productTitles[index], // Nome do produto
              price: productPrices[index], // Preço correspondente
              imageAsset:
                  'assets/comando-github-praticas4.png', // Caminho da imagem
              onAdd: () {
                // Aqui navega para a página de detalhes do produto
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => DetalhesProduto(
                            productName: productTitles[
                                index], // Passando o nome do produto
                            productPrice: productPrices[
                                index] // Passando o preço do produto
                            )));
              },
            );
          }),
        ),
      ),
    );
  }
}

*/