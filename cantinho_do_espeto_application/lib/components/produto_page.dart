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

    final List<String> productImages = [
      'assets/comando-github-praticas4.png',
      'assets/comando-github-praticas4.png',
      'assets/comando-github-praticas4.png',
      'assets/comando-github-praticas4.png',
      'assets/comando-github-praticas4.png',
      'assets/comando-github-praticas4.png',
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Produtos'), // Geral - Produtos
        centerTitle: true,
        titleTextStyle:
            const TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
        backgroundColor: Colors.orange, // blue
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16.0,
          mainAxisSpacing: 16.0,
          children: List.generate(productTitles.length, (index) {
            return MenuItemCard(
              title: productTitles[index],
              price: productPrices[index],
              imageAsset: productImages[index],
              onAdd: () {
                setState(() {
                  // Adiciona o produto à lista de produtos selecionados
                  produtosSelecionados.add({
                    'title': productTitles[index],
                    'price': productPrices[index],
                    'image': productImages[index],
                  });
                });

                // Navega para a página de detalhes com todos os produtos selecionados
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DetalhesProdutos(
                      produtosSelecionados: produtosSelecionados,
                    ),
                  ),
                ).then((_) {
                  // Atualiza a página após voltar
                  setState(() {}); // Atualiza a interface, se necessário
                });
              },
            );
          }),
        ),
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
                  backgroundColor: Colors.green,
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(15),
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
