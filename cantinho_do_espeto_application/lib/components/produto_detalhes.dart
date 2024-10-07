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
        titleTextStyle:
            const TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
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
                              const SizedBox(height: 8.0),
                              Image.asset(
                                produto['image']!,
                                height: 100,
                              ),
                            ],
                          ),

                          // Botão de remover
                          IconButton(
                            //Icons.remove_circle_outline
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              removerProduto(index);
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
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
                ),
              ),
      ),

      // Botão para voltar à página de produtos
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pop(
              context,
              widget
                  .produtosSelecionados); // Volta para a tela anterior com a lista de produtos
        },
        backgroundColor: Colors.orange, // blue
        child: const Icon(Icons.arrow_back),
      ),
    );
  }
}
