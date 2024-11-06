import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FinalizarComandaPage extends StatefulWidget {
  final String? pedidoId;

  const FinalizarComandaPage({super.key, required this.pedidoId});

  @override
  _FinalizarComandaPageState createState() => _FinalizarComandaPageState();
}

class _FinalizarComandaPageState extends State<FinalizarComandaPage> {
  List<DocumentReference> produtosSelecionados = [];
  double totalComanda = 0.0;
  double valorTotalAtual = 0.0;
  Map<String, int> quantidadeProdutos = {};
  List<Map<String, dynamic>> produtosDisponiveis = [];

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _carregarValorTotal();
    _carregarProdutosDoPedido();
  }

  Future<void> _carregarValorTotal() async {
    try {
      DocumentSnapshot pedidoSnapshot =
          await _firestore.collection('Pedidos').doc(widget.pedidoId).get();
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
      DocumentSnapshot pedidoSnapshot =
          await _firestore.collection('Pedidos').doc(widget.pedidoId).get();
      if (pedidoSnapshot.exists) {
        List<DocumentReference> listaProdutos =
            List.from(pedidoSnapshot['listaProdutos'] ?? []);
        for (var produtoRef in listaProdutos) {
          DocumentSnapshot produtoSnapshot = await produtoRef.get();
          if (produtoSnapshot.exists) {
            String produtoId = produtoRef.id;
            produtosSelecionados.add(produtoRef);
            quantidadeProdutos[produtoId] =
                (quantidadeProdutos[produtoId] ?? 0) + 1;
          }
        }
        setState(() {});
      }
    } catch (e) {
      print('Erro ao carregar produtos do pedido: $e');
    }
  }

  Future<void> _finalizarComanda() async {
    try {
      await _firestore.collection('Pedidos').doc(widget.pedidoId).update({
        'valorTotal': 0.0,
        'listaProdutos': [],
      });

      setState(() {
        totalComanda = 0.0;
        produtosSelecionados.clear();
        quantidadeProdutos.clear();
        produtosDisponiveis.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Comanda finalizada com sucesso!')));
    } catch (e) {
      print('Erro ao finalizar a comanda: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Finalizar Comanda"),
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

          // Verifica se totalComanda é zero para exibir uma mensagem
          if (totalComanda == 0.0) {
            return const Center(
                child: Text('Nenhum produto disponível na comanda.'));
          }

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
                      subtitle:
                          Text('R\$ ${produto['valor'].toStringAsFixed(2)}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('x$qtd'),
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
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: ElevatedButton(
                  onPressed: _finalizarComanda,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(
                        vertical: 15, horizontal: 50),
                    textStyle: const TextStyle(fontSize: 20),
                  ),
                  child: const Text('Finalizar Comanda',
                      style: TextStyle(color: Colors.white)),
                ),
              )
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
}
