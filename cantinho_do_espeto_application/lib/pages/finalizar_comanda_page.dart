import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FinalizarComandaPage extends StatefulWidget {
  final String? pedidoId;

  const FinalizarComandaPage({super.key, required this.pedidoId});

  @override
  State<FinalizarComandaPage> createState() => _FinalizarComandaPageState();
}

class _FinalizarComandaPageState extends State<FinalizarComandaPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  List<DocumentReference> produtosSelecionados = [];
  List<Map<String, dynamic>> produtosDisponiveis = [];
  Map<String, int> quantidadeProdutos = {};
  
  double totalComanda = 0.0;
  double valorTotalAtual = 0.0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _inicializarDados();
  }

  Future<void> _inicializarDados() async {
    setState(() => _isLoading = true);
    await Future.wait([
      _carregarValorTotal(),
      _carregarProdutosDoPedido(),
    ]);
    setState(() => _isLoading = false);
  }

  Future<void> _carregarValorTotal() async {
    try {
      final pedidoSnapshot = await _firestore
          .collection('Pedidos')
          .doc(widget.pedidoId)
          .get();
          
      if (pedidoSnapshot.exists) {
        setState(() {
          valorTotalAtual = pedidoSnapshot['valorTotal'] ?? 0.0;
          totalComanda = valorTotalAtual;
        });
      }
    } catch (e) {
      _mostrarErro('Erro ao carregar valor total: $e');
    }
  }

  Future<void> _carregarProdutosDoPedido() async {
    try {
      final pedidoSnapshot = await _firestore
          .collection('Pedidos')
          .doc(widget.pedidoId)
          .get();
          
      if (pedidoSnapshot.exists) {
        List<DocumentReference> listaProdutos = List.from(pedidoSnapshot['listaProdutos'] ?? []);
        
        for (var produtoRef in listaProdutos) {
          final produtoSnapshot = await produtoRef.get();
          if (produtoSnapshot.exists) {
            setState(() {
              String produtoId = produtoRef.id;
              produtosSelecionados.add(produtoRef);
              quantidadeProdutos[produtoId] = (quantidadeProdutos[produtoId] ?? 0) + 1;
            });
          }
        }
      }
    } catch (e) {
      _mostrarErro('Erro ao carregar produtos do pedido: $e');
    }
  }

  Future<void> _finalizarComanda() async {
    setState(() => _isLoading = true);
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

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Comanda finalizada com sucesso!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      _mostrarErro('Erro ao finalizar a comanda: $e');
    }
    setState(() => _isLoading = false);
  }

  Future<List<Map<String, dynamic>>> _getAllProdutos() async {
    final collectionNames = ['prod-bebida', 'prod-espetos', 'prod-caldos', ''];
    final docNames = ['PoDiOnHmAULfo04IFIZy', 'r68ahS3Ck96LGZEVzZma'];
    List<Map<String, dynamic>> allProdutos = [];

    try {
      for (int i = 0; i < collectionNames.length; i++) {
        final snapshot = await _firestore
            .collection("Produto")
            .doc(docNames[i])
            .collection(collectionNames[i])
            .get();

        allProdutos.addAll(snapshot.docs.map((doc) => {
          'id': doc.id,
          'docName': docNames[i],
          'collectionName': collectionNames[i],
          ...doc.data(),
        }));
      }
    } catch (e) {
      _mostrarErro('Erro ao carregar produtos: $e');
    }

    return allProdutos;
  }

  void _mostrarErro(String mensagem) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(mensagem),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _mostrarDialogConfirmacao() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar Finalização'),
          content: const Text('Deseja realmente finalizar esta comanda?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              onPressed: () {
                Navigator.pop(context);
                _finalizarComanda();
              },
              child: const Text('Finalizar'),
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
        title: const Text(
          "Finalizar Comanda",
          style: TextStyle(color: Colors.white),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.orange[900]!.withOpacity(1),
                Colors.orange[900]!.withOpacity(0.9)
              ],
              stops: const [0.6, 1],
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : FutureBuilder<List<Map<String, dynamic>>>(
              future: _getAllProdutos(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 48, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(
                          'Erro ao carregar produtos',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ],
                    ),
                  );
                }

                produtosDisponiveis = snapshot.data ?? [];

                if (totalComanda == 0.0) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.shopping_cart_outlined,
                          size: 64,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Nenhum produto na comanda',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: produtosSelecionados.length,
                        itemBuilder: (context, index) {
                          final produto = produtosDisponiveis[index];
                          final produtoId = produto['id'];
                          final qtd = quantidadeProdutos[produtoId] ?? 0;
                          final valorTotal = produto['valor'] * qtd;

                          return Card(
                            elevation: 2,
                            margin: const EdgeInsets.symmetric(
                              vertical: 4,
                              horizontal: 8,
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              title: Text(
                                produto['nome'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text(
                                    'Valor unitário: R\$ ${produto['valor'].toStringAsFixed(2)}',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  Text(
                                    'Total: R\$ ${valorTotal.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      color: Colors.green[700],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              trailing: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'x$qtd',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 1,
                            blurRadius: 6,
                            offset: const Offset(0, -3),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Total a pagar: R\$ ${totalComanda.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _mostrarDialogConfirmacao,
                              icon: const Icon(Icons.check_circle),
                              label: const Text('Finalizar Comanda'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                textStyle: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }
}