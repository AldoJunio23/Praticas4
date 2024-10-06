import 'package:flutter/material.dart';

class DetalhesProdutos extends StatefulWidget {
  final List<Map<String, String>> produtosSelecionados;

  const DetalhesProdutos({
    Key? key,
    required this.produtosSelecionados,
  }) : super(key: key);

  @override
  _DetalhesProdutosState createState() => _DetalhesProdutosState();
}

class _DetalhesProdutosState extends State<DetalhesProdutos> {
  // Função para remover um produto da lista
  void removerProduto(int index) {
    setState(() {
      widget.produtosSelecionados.removeAt(index); // Remove o item da lista
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Produtos Selecionados"),
        centerTitle: true,
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: widget.produtosSelecionados.isNotEmpty
            ? ListView.builder(
                itemCount: widget.produtosSelecionados.length,
                itemBuilder: (context, index) {
                  final produto = widget.produtosSelecionados[index];
                  return Card(
                    elevation: 4.0,
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Detalhes do produto
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                produto['title']!,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8.0),
                              Text(
                                produto['price']!,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),

                          // Botão de remover
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline,
                                color: Colors.red),
                            onPressed: () {
                              removerProduto(index); // Remove o produto
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              )
            : const Center(
                child: Text(
                  "Nenhum produto selecionado.",
                  style: TextStyle(fontSize: 18),
                ),
              ),
      ),
    );
  }
}



/*
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
        title: Text("Detalhes do pedido"), // productName
        centerTitle: true,
        titleTextStyle:
            const TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
        backgroundColor: Colors.orange, // blue
      ),
      body: Center(
        child: Card(
          elevation: 4.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          margin: const EdgeInsets.all(16.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  productName,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16.0),
                Text(
                  productPrice,
                  style: const TextStyle(
                    fontSize: 20,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16.0),
                Image.asset(
                  'assets/comando-github-praticas4.png',
                  height: 200,
                ),
                const SizedBox(height: 16.0),
                Align(
                  alignment: Alignment.bottomRight,
                  child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red, // Cor de fundo laranja
                        shape: const CircleBorder(), // Botão circular
                        padding: const EdgeInsets.all(15), // Tamanho do botão
                      ),
                      child: const Icon(
                        Icons.remove,
                        color: Colors.white,
                      )),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

*/