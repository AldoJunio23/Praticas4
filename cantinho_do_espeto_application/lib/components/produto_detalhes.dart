import 'package:flutter/material.dart';

class DetalhesProduto extends StatelessWidget {
  final String productName;
  final String productPrice;

  const DetalhesProduto({
    Key? key,
    required this.productName,
    required this.productPrice,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(productName),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              productName,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16.0),
            Text(
              productPrice,
              style: const TextStyle(fontSize: 20, color: Colors.grey),
            ),
            const SizedBox(height: 16.0),
            Image.asset('assets/comando-github-praticas4.png', height: 200),
            const SizedBox(height: 16.0),
            const Text(
              'Este é o detalhe do produto. Aqui você pode adicionar mais informações sobre o produto selecionado.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
