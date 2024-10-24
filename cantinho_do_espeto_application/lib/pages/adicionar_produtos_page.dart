import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_praticas/services/pedido_service.dart';

class TelaAdicionarProdutosPedido extends StatefulWidget {
  final String? pedidoId;

  const TelaAdicionarProdutosPedido({super.key, required this.pedidoId});

  @override
  _TelaAdicionarProdutosPedidoState createState() => _TelaAdicionarProdutosPedidoState();
}

class _TelaAdicionarProdutosPedidoState extends State<TelaAdicionarProdutosPedido> {
  List<DocumentReference> produtosSelecionados = [];
  double totalComanda = 0.0;
  double valorTotalAtual = 0.0;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Lista para armazenar quantidades de produtos
  Map<String, int> quantidadeProdutos = {};

  @override
  void initState() {
    super.initState();
    // Carregar produtos já adicionados no pedido, se necessário
  }

  // Adiciona um produto ao pedido
  Future<void> _adicionarProduto(Map<String, dynamic> produto) async {
    try {
      // Busca o valor total da comanda no banco de dados
      DocumentSnapshot pedidoSnapshot = await _firestore.collection('Pedidos').doc(widget.pedidoId).get();

      if (pedidoSnapshot.exists) {
        valorTotalAtual = pedidoSnapshot['valorTotal'] ?? 0.0;
      }

      // Verifica se o produto já foi adicionado, se sim, aumenta a quantidade
      final produtoId = produto['id'];
      if (quantidadeProdutos.containsKey(produtoId)) {
        quantidadeProdutos[produtoId] = (quantidadeProdutos[produtoId] ?? 0) + 1;
      } else {
        quantidadeProdutos[produtoId] = 1;
      }

      // Adiciona o caminho do produto como referência à lista de produtos selecionados
      produtosSelecionados.add(_firestore
          .collection('Produto')
          .doc(produto['docName'])
          .collection(produto['collectionName'])
          .doc(produto['id'])
      );

      // Atualiza o valor total da comanda
      valorTotalAtual += produto['valor'];
      totalComanda = valorTotalAtual; // Atualiza o total da comanda

      // Chama setState apenas para atualizar a quantidade
      setState(() {});

    } catch (e) {
      print('Erro ao adicionar produto: $e');
    }
  }

  Future<void> _adicionarProdutosNaMesa() async {
    try {
      Map<String, dynamic>? pedido = await PedidoService().buscarPedidoPorId(widget.pedidoId);
      // Carrega a lista atual de produtos do pedido e faz a conversão para List<DocumentReference>
      List<DocumentReference<Object?>> listaProdutosAtuais = (pedido?['listaProdutos'] as List<dynamic>)
          .where((produto) => produto is DocumentReference<Object?>)
          .map((produto) => produto as DocumentReference<Object?>)
          .toList();

      listaProdutosAtuais.addAll(produtosSelecionados);
      // Atualiza o valor total no banco de dados e a lista de produtos
      await _firestore.collection('Pedidos').doc(widget.pedidoId).update({
        'valorTotal': totalComanda,
        'listaProdutos': listaProdutosAtuais, // Atualiza a lista de produtos como referências
      });

      setState(() {}); // Atualiza o estado para refletir a alteração
    } catch (e) {
      print('Erro ao adicionar produto: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Adicionar Produtos ao Pedido"),
        backgroundColor: Colors.grey,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _getAllProdutos(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Erro ao carregar produtos'));
          }

          List<Map<String, dynamic>> produtosDisponiveis = snapshot.data ?? [];

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: produtosDisponiveis.length,
                  itemBuilder: (context, index) {
                    final produto = produtosDisponiveis[index];
                    final produtoId = produto['id'];
                    int qtd = quantidadeProdutos[produtoId] ?? 0; // Obtém a quantidade atual
                    return ListTile(
                      title: Text(produto['nome']),
                      subtitle: Text('R\$ ${produto['valor'].toStringAsFixed(2)}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () => _adicionarProduto(produto), // Atualiza apenas a quantidade
                          ),
                          Text('x$qtd'), // Exibe a quantidade atual
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              // Exibe o total da comanda
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  'Total: R\$ ${totalComanda.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              // Botão para adicionar produtos
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: ElevatedButton(
                  onPressed: _adicionarProdutosNaMesa,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 50),
                    textStyle: const TextStyle(fontSize: 20),
                  ),
                  child: const Text('Adicionar Produtos'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // Método para buscar todos os produtos de várias coleções
  Future<List<Map<String, dynamic>>> _getAllProdutos() async {
    List<Map<String, dynamic>> allProdutos = [];
    final collectionNames = ['prod-bebida', 'prod-espetos'];
    final docNames = ['PoDiOnHmAULfo04IFIZy', 'r68ahS3Ck96LGZEVzZma'];

    for (int i = 0; i < collectionNames.length; i++) {
      QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore
          .collection("Produto")
          .doc(docNames[i])
          .collection(collectionNames[i])
          .get();

      for (var doc in snapshot.docs) {
        allProdutos.add({
          'id': doc.id,
          'docName': docNames[i],
          'collectionName': collectionNames[i],
          ...doc.data(),
        });
      }
    }

    return allProdutos;
  }
}
