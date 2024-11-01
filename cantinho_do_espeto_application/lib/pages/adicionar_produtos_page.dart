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

  Map<String, int> quantidadeProdutos = {};
  List<Map<String, dynamic>> produtosDisponiveis = [];

  @override
  void initState() {
    super.initState();
    _carregarValorTotal();
    _carregarProdutosDoPedido();
  }

  Future<void> _carregarValorTotal() async {
    try {
      DocumentSnapshot pedidoSnapshot = await _firestore.collection('Pedidos').doc(widget.pedidoId).get();
      if (pedidoSnapshot.exists) {
        valorTotalAtual = pedidoSnapshot['valorTotal'] ?? 0.0;
        totalComanda = valorTotalAtual;
        setState(() {});
      }
    } catch (e) {
      print('Erro ao carregar valor total: $e');
    }
  }

  Future<void> _carregarProdutosDoPedido() async {
    try {
      DocumentSnapshot pedidoSnapshot = await _firestore.collection('Pedidos').doc(widget.pedidoId).get();
      if (pedidoSnapshot.exists) {
        List<DocumentReference> listaProdutos = List.from(pedidoSnapshot['listaProdutos'] ?? []);
        for (var produtoRef in listaProdutos) {
          DocumentSnapshot produtoSnapshot = await produtoRef.get();
          if (produtoSnapshot.exists) {
            String produtoId = produtoRef.id;
            produtosSelecionados.add(produtoRef);
            quantidadeProdutos[produtoId] = (quantidadeProdutos[produtoId] ?? 0) + 1;
          }
        }
        setState(() {});
      }
    } catch (e) {
      print('Erro ao carregar produtos do pedido: $e');
    }
  }

  Future<void> _adicionarProduto(Map<String, dynamic> produto) async {
    try {
      final produtoId = produto['id'];
      if (quantidadeProdutos.containsKey(produtoId)) {
        quantidadeProdutos[produtoId] = (quantidadeProdutos[produtoId] ?? 0) + 1;
      } else {
        quantidadeProdutos[produtoId] = 1;
      }

      produtosSelecionados.add(_firestore
          .collection('Produto')
          .doc(produto['docName'])
          .collection(produto['collectionName'])
          .doc(produto['id']));

      valorTotalAtual += produto['valor'];
      totalComanda = valorTotalAtual;

      setState(() {});
    } catch (e) {
      print('Erro ao adicionar produto: $e');
    }
  }

  void _removerProduto(Map<String, dynamic> produto) {
    final produtoId = produto['id'];
    if (quantidadeProdutos.containsKey(produtoId) && quantidadeProdutos[produtoId]! > 0) {
      quantidadeProdutos[produtoId] = quantidadeProdutos[produtoId]! - 1;

      if (quantidadeProdutos[produtoId] == 0) {
        quantidadeProdutos.remove(produtoId);
      }

      produtosSelecionados.remove(_firestore
        .collection('Produto')
        .doc(produto['docName'])
        .collection(produto['collectionName'])
        .doc(produto['id']));
      // Atualiza o valor total da comanda
      valorTotalAtual -= produto['valor'];
      totalComanda = valorTotalAtual;

      setState(() {});
    }
  }

  Future<void> _adicionarProdutosNaMesa() async {
    try {
      print(produtosSelecionados.toString());
      await _firestore.collection('Pedidos').doc(widget.pedidoId).update({
        'valorTotal': totalComanda,
        'listaProdutos': produtosSelecionados,
      });

      setState(() {});
    } catch (e) {
      print('Erro ao adicionar produtos: $e');
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

          produtosDisponiveis = snapshot.data ?? [];

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: produtosDisponiveis.length,
                  itemBuilder: (context, index) {
                    final produto = produtosDisponiveis[index];
                    final produtoId = produto['id'];
                    int qtd = quantidadeProdutos[produtoId] ?? 0;
                    return ListTile(
                      title: Text(produto['nome']),
                      subtitle: Text('R\$ ${produto['valor'].toStringAsFixed(2)}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () => _adicionarProduto(produto),
                          ),
                          Text('x$qtd'),
                          IconButton(
                            icon: const Icon(Icons.remove),
                            onPressed: () => _removerProduto(produto),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  'Total: R\$ ${totalComanda.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: ElevatedButton(
                      onPressed: _voltar,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 50),
                        textStyle: const TextStyle(fontSize: 20),
                      ),
                      child: const Text('Cancelar', style: TextStyle(color: Colors.white),),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: ElevatedButton(
                      onPressed: _adicionarProdutosNaMesa,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 50),
                        textStyle: const TextStyle(fontSize: 20),
                      ),
                      child: const Text('Confirmar', style: TextStyle(color: Colors.white),),
                    ),
                  )
                ],
              ),
            ],
          );
        },
      ),
    );
  }

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

  void _voltar(){
    Navigator.pop(context);
  }
}
