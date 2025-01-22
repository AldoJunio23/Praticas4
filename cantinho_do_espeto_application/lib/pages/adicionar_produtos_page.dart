import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TelaAdicionarProdutosPedido extends StatefulWidget {
  final String? pedidoId;
  final DocumentReference? mesaReference;

  const TelaAdicionarProdutosPedido({
    super.key, 
    required this.pedidoId, 
    required this.mesaReference
  });

  @override
  State<TelaAdicionarProdutosPedido> createState() => _TelaAdicionarProdutosPedidoState();
}

class _TelaAdicionarProdutosPedidoState extends State<TelaAdicionarProdutosPedido> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  List<DocumentReference> produtosSelecionados = [];
  List<Map<String, dynamic>> produtosDisponiveis = [];
  Map<String, int> quantidadeProdutos = {};
  
  double totalComanda = 0.0;
  double valorTotalAtual = 0.0;
  bool _isLoading = false;
  String _categoriaSelecionada = 'Todos';

  final Map<String, String> _categoriasMap = {
    'prod-bebida': 'Bebidas',
    'prod-espetos': 'Espetos',
    'prod-adicional': 'Adicionais',
    'prod-caldo': 'Caldos',
  };

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
      final pedidoSnapshot = await _firestore.collection('Pedidos').doc(widget.pedidoId).get();
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
      final pedidoSnapshot = await _firestore.collection('Pedidos').doc(widget.pedidoId).get();
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

  Future<void> _adicionarProduto(Map<String, dynamic> produto) async {
    try {
      final produtoId = produto['id'];
      setState(() {
        quantidadeProdutos[produtoId] = (quantidadeProdutos[produtoId] ?? 0) + 1;
        produtosSelecionados.add(_firestore
            .collection('Produto')
            .doc(produto['docName'])
            .collection(produto['collectionName'])
            .doc(produto['id']));
        valorTotalAtual += produto['valor'];
        totalComanda = valorTotalAtual;
      });
    } catch (e) {
      _mostrarErro('Erro ao adicionar produto: $e');
    }
  }

  void _removerProduto(Map<String, dynamic> produto) {
    final produtoId = produto['id'];
    if (quantidadeProdutos.containsKey(produtoId) && quantidadeProdutos[produtoId]! > 0) {
      setState(() {
        quantidadeProdutos[produtoId] = quantidadeProdutos[produtoId]! - 1;
        if (quantidadeProdutos[produtoId] == 0) {
          quantidadeProdutos.remove(produtoId);
        }
        produtosSelecionados.remove(_firestore
            .collection('Produto')
            .doc(produto['docName'])
            .collection(produto['collectionName'])
            .doc(produto['id']));
        valorTotalAtual -= produto['valor'];
        totalComanda = valorTotalAtual;
      });
    }
  }

  void _mostrarErro(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _adicionarProdutosNaMesa() async {
    setState(() => _isLoading = true);
    try {
      await _firestore.collection('Pedidos').doc(widget.pedidoId).update({
        'valorTotal': totalComanda,
        'listaProdutos': produtosSelecionados,
        'mesa': widget.mesaReference,
      });
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      _mostrarErro('Erro ao adicionar produtos: $e');
    }
    setState(() => _isLoading = false);
  }

   Future<List<Map<String, dynamic>>> _getAllProdutos() async {
    final collectionNames = ['prod-bebida', 'prod-espetos', 'prod-adicional', 'prod-caldo'];
    final docNames = ['PoDiOnHmAULfo04IFIZy', 'r68ahS3Ck96LGZEVzZma', 'FFgYAgy1ACxpqOPfekEi', 'EI0XR8FLCNQJXJ0EbzHL'];
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
          'categoria': _categoriasMap[collectionNames[i]] ?? 'Outros',
          ...doc.data(),
        }));
      }

      // Ordenar produtos em ordem alfabética
      allProdutos.sort((a, b) => a['nome'].toString().compareTo(b['nome'].toString()));
      
    } catch (e) {
      _mostrarErro('Erro ao carregar produtos: $e');
    }

    return allProdutos;
  }

  List<Map<String, dynamic>> _filtrarProdutos(List<Map<String, dynamic>> produtos) {
    if (_categoriaSelecionada == 'Todos') {
      return produtos;
    }
    return produtos.where((produto) => 
      _categoriasMap[produto['collectionName']] == _categoriaSelecionada
    ).toList();
  }

  Widget _buildCategoryFilter() {
    return Container(
      padding: const EdgeInsets.all(8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            FilterChip(
              label: const Text('Todos'),
              selected: _categoriaSelecionada == 'Todos',
              onSelected: (bool selected) {
                setState(() => _categoriaSelecionada = 'Todos');
              },
            ),
            const SizedBox(width: 8),
            ..._categoriasMap.values.map((categoria) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(categoria),
                selected: _categoriaSelecionada == categoria,
                onSelected: (bool selected) {
                  setState(() => _categoriaSelecionada = categoria);
                },
              ),
            )),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        title: const Text(
          "Adicionar Produtos ao Pedido",
          style: TextStyle(color: Colors.white),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.bottomRight,
              colors: [Colors.orange[900]!.withOpacity(1), Colors.orange[900]!.withOpacity(0.9)],
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

                produtosDisponiveis = _filtrarProdutos(snapshot.data ?? []);

                return Column(
                  children: [
                    _buildCategoryFilter(),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: produtosDisponiveis.length,
                        itemBuilder: (context, index) {
                          final produto = produtosDisponiveis[index];
                          final produtoId = produto['id'];
                          final qtd = quantidadeProdutos[produtoId] ?? 0;
                          
                          return Card(
                            elevation: 2,
                            margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
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
                                  Text(
                                    'R\$ ${produto['valor'].toStringAsFixed(2)}',
                                    style: TextStyle(
                                      color: Colors.green[700],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    _categoriasMap[produto['collectionName']] ?? 'Outros',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              trailing: Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.remove_circle_outline),
                                      color: Colors.red,
                                      onPressed: qtd > 0
                                          ? () => _removerProduto(produto)
                                          : null,
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 8,
                                      ),
                                      child: Text(
                                        qtd.toString(),
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.add_circle_outline),
                                      color: Colors.green,
                                      onPressed: () => _adicionarProduto(produto),
                                    ),
                                  ],
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
                            'Total: R\$ ${totalComanda.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ElevatedButton.icon(
                                onPressed: () => Navigator.pop(context),
                                icon: const Icon(Icons.cancel, color: Colors.white),
                                label: const Text('Cancelar'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 32,
                                    vertical: 16,
                                  ),
                                ),
                              ),
                              ElevatedButton.icon(
                                onPressed: produtosSelecionados.isNotEmpty 
                                  ? _adicionarProdutosNaMesa 
                                  : null, // Desabilita o botão se não houver produtos
                                icon: const Icon(Icons.check_circle, color: Colors.white),
                                label: const Text('Confirmar'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                  disabledBackgroundColor: Colors.grey[400], // Cor quando desabilitado
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 32,
                                    vertical: 16,
                                  ),
                                ),
                              ),
                            ],
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