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

  // Função para finalizar o pedido
  void avancarPedido() {
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
                            produtosSelecionados: widget.produtosSelecionados,
                          )),
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
        title: const Text("Produtos selecionados"), // Produtos Selecionados
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
                            icon: const Icon(Icons.delete,
                                color: Colors.red), // Ícone de lixeira
                            onPressed: () {
                              // Exibir um diálogo de confirmação
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text(
                                        'Confirmar exclusão de item:'), // "ALERTA, a página diz:"
                                    content: const Text(
                                        'Você tem certeza que deseja remover este produto?'),
                                    actions: <Widget>[
                                      TextButton(
                                        child: const Text('Cancelar'),
                                        onPressed: () {
                                          Navigator.of(context)
                                              .pop(); // Fecha o diálogo
                                        },
                                      ),
                                      TextButton(
                                        child: const Text('Excluir'),
                                        onPressed: () {
                                          removerProduto(
                                              index); // Remove o produto após confirmação
                                          Navigator.of(context)
                                              .pop(); // Fecha o diálogo
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
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
      floatingActionButton: Stack(
        children: <Widget>[
          Positioned(
            bottom: 16,
            right: 80, // Ajuste a posição como preferir
            child: FloatingActionButton(
              onPressed: () {
                Navigator.pop(context, widget.produtosSelecionados);
              },
              backgroundColor: Colors.orange,
              child: const Icon(Icons.arrow_back),
            ),
          ),
          Positioned(
            bottom: 16,
            right: 16, // Ajuste a posição como preferir
            child: FloatingActionButton(
              onPressed: avancarPedido,
              backgroundColor: Colors.green,
              child: const Icon(Icons.check),
            ),
          ),
        ],
      ),
    );
  }
}

/*

// Tela de Processamento de pedidos
class TelaProcessandoPedido extends StatelessWidget {
  final List<Map<String, String>> produtosSelecionados;

  // Construtor para receber os produtos selecionados
  TelaProcessandoPedido({required this.produtosSelecionados});

  // Função para calcular a soma dos preços dos produtos
  double calcularPrecoTotal() {
    double total = 0.0;
    for (var produto in produtosSelecionados) {
      // Remove o símbolo '$' e converte a string em double
      double preco = double.parse(produto['price']!.replaceAll('\$', ''));
      total += preco;
    }
    return total;
  }


  // Função para exibir uma mensagem na tela usando SnackBar
  void mostrarMensagem2(String mensagem) {
    final snackBar = SnackBar(
      content: Text(mensagem),
      duration:
          const Duration(seconds: 2), // Tempo que a mensagem ficará visível
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    // Calcula o preço total dos produtos
    double precoTotal = calcularPrecoTotal();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Processando pedido'), // Processando Pedido
        centerTitle: true,
        titleTextStyle:
            const TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.spaceBetween, // Distribui os itens na tela
          children: [
            // Lista de produtos
            Expanded(
              child: produtosSelecionados.isNotEmpty
                  ? ListView.builder(
                      itemCount: produtosSelecionados.length,
                      itemBuilder: (context, index) {
                        final produto = produtosSelecionados[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  // Nome do produto
                                  Text(
                                    produto['title']!,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  // Preço do produto
                                  Text(
                                    produto['price']!,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8.0),
                            ],
                          ),
                        );
                      },
                    )
                  : const Center(
                      child: Text(
                        'Nenhum produto selecionado.',
                        style: TextStyle(fontSize: 24),
                      ),
                    ),
            ),
            // Textos fixos no final da tela
            Column(
              //crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Mesa: XX",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 8.0),
                Text(
                  "Preço total: \$${precoTotal.toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: Stack(
        children: <Widget>[
          Positioned(
            bottom: 16,
            right: 80, // Ajuste a posição como preferir
            child: FloatingActionButton(
              onPressed: () {
                //Navigator.pop(context, widget.produtosSelecionados);
                mostrarMensagem("Próxima");
              },
              backgroundColor: Colors.orange,
              child: const Icon(Icons.arrow_forward),
            ),
          ),
          Positioned(
            bottom: 16,
            right: 16, // Ajuste a posição como preferir
            child: FloatingActionButton(
              //onPressed: finalizarPedido,
              onPressed: () {
                mostrarMensagem2("Deletar");
              }, 
              backgroundColor: Colors.green,
              child: const Icon(Icons.check),
            ),
          ),
        ],
      ),
    );
  }
}

*/

class TelaProcessandoPedido extends StatefulWidget {
  final List<Map<String, String>> produtosSelecionados;

  // Construtor para receber os produtos selecionados
  TelaProcessandoPedido({required this.produtosSelecionados});

  @override
  _TelaProcessandoPedidoState createState() => _TelaProcessandoPedidoState();
}

class _TelaProcessandoPedidoState extends State<TelaProcessandoPedido> {
  // Função para calcular a soma dos preços dos produtos
  double calcularPrecoTotal() {
    double total = 0.0;
    for (var produto in widget.produtosSelecionados) {
      // Remove o símbolo '$' e converte a string em double
      double preco = double.parse(produto['price']!.replaceAll('\$', ''));
      total += preco;
    }
    return total;
  }

  // Função para exibir uma mensagem na tela usando SnackBar
  void mostrarMensagem2(BuildContext context, String mensagem) {
    final snackBar = SnackBar(
      content: Text(mensagem),
      duration:
          const Duration(seconds: 2), // Tempo que a mensagem ficará visível
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    // Calcula o preço total dos produtos
    double precoTotal = calcularPrecoTotal();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Processando pedido'), // Processando Pedido
        centerTitle: true,
        titleTextStyle:
            const TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.spaceBetween, // Distribui os itens na tela
          children: [
            // Lista de produtos
            Expanded(
              child: widget.produtosSelecionados.isNotEmpty
                  ? ListView.builder(
                      itemCount: widget.produtosSelecionados.length,
                      itemBuilder: (context, index) {
                        final produto = widget.produtosSelecionados[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  // Nome do produto
                                  Text(
                                    produto['title']!,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  // Preço do produto
                                  Text(
                                    produto['price']!,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8.0),
                            ],
                          ),
                        );
                      },
                    )
                  : const Center(
                      child: Text(
                        'Nenhum produto selecionado.',
                        style: TextStyle(fontSize: 24),
                      ),
                    ),
            ),
            // Textos fixos no final da tela
            Column(
              children: [
                const Text(
                  "Mesa: XX",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 8.0),
                Text(
                  "Preço total: \$${precoTotal.toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: Stack(
        children: <Widget>[
          Positioned(
            bottom: 16,
            right: 80, // Ajuste a posição como preferir
            child: FloatingActionButton(
              onPressed: () {
                mostrarMensagem2(context, "Fechar - Voltar para tela inicial");
              },
              backgroundColor: Colors.orange,
              child: const Icon(Icons.exit_to_app),
            ),
          ),
          Positioned(
            bottom: 16,
            right: 16, // Ajuste a posição como preferir
            child: FloatingActionButton(
              onPressed: () {
                mostrarMensagem2(
                    context, "Finalizar pedido - Ir para próxima tela");
              },
              backgroundColor: Colors.green,
              child: const Icon(Icons.check),
            ),
          ),
        ],
      ),
    );
  }
}
