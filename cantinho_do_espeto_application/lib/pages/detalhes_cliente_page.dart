import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_praticas/pages/adicionar_produtos_page.dart';

class DetalhePedidoClientePage extends StatefulWidget {
  final String pedidoId;
  
  const DetalhePedidoClientePage({
    super.key,
    required this.pedidoId,
  });

  @override
  DetalhePedidoClientePageState createState() => DetalhePedidoClientePageState();
}

class DetalhePedidoClientePageState extends State<DetalhePedidoClientePage> {
  bool isLoading = false;

  Future<void> _confirmarFinalizacao() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Confirmar Finalização',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Tem certeza que deseja finalizar este pedido?',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 12),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancelar',
                style: TextStyle(color: Colors.red),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _finalizarPedido();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: const Text('Confirmar'),
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        );
      },
    );
  }

  Future<void> _finalizarPedido() async {
    setState(() => isLoading = true);

    try {
      await FirebaseFirestore.instance
          .collection('Pedidos')
          .doc(widget.pedidoId)
          .update({
        'finalizado': true,
        'dataFinalizacao': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pedido finalizado com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.of(context).pop(true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao finalizar pedido: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes do Pedido', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.orange[900],
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TelaAdicionarProdutosPedido(
                    pedidoId: widget.pedidoId,
                    mesaReference: null,
                  ),
                ),
              ).then((_) => setState(() {}));
            },
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Pedidos')
            .doc(widget.pedidoId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Pedido não encontrado'));
          }

          final pedidoData = snapshot.data!.data() as Map<String, dynamic>;
          final nomeCliente = pedidoData['nomeCliente'] ?? 'Cliente sem nome';
          final telefoneCliente = pedidoData['telefoneCliente'] ?? 'Sem telefone';
          final valorTotal = pedidoData['valorTotal']?.toDouble() ?? 0.0;
          final timestamp = pedidoData['dataCriacao'] as Timestamp?;
          final data = timestamp?.toDate() ?? DateTime.now();
          final finalizado = pedidoData['finalizado'] ?? false;
          final List<DocumentReference> produtosRefs = List<DocumentReference>.from(pedidoData['listaProdutos'] ?? []);

          return SingleChildScrollView(
            child: Column(
              children: [
                // Card de Informações do Cliente
                Card(
                  margin: const EdgeInsets.all(16),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.orange[100],
                              child: Icon(
                                Icons.person,
                                color: Colors.orange[900],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    nomeCliente,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    telefoneCliente,
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 32),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Data do Pedido',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  '${data.day}/${data.month}/${data.year} ${data.hour}:${data.minute}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: finalizado ? Colors.green[100] : Colors.orange[100],
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                finalizado ? 'Finalizado' : 'Em Andamento',
                                style: TextStyle(
                                  color: finalizado ? Colors.green[900] : Colors.orange[900],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Lista de Produtos
                Card(
                  margin: const EdgeInsets.all(16),
                  elevation: 4,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Icon(Icons.shopping_cart, color: Colors.orange[900]),
                            const SizedBox(width: 8),
                            const Text(
                              'Produtos do Pedido',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1),
                      FutureBuilder<List<Widget>>(
                        future: _buildProdutosList(produtosRefs),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(16.0),
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }
                          return Column(children: snapshot.data ?? []);
                        },
                      ),
                      const Divider(height: 1),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total do Pedido',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'R\$ ${valorTotal.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.green[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _confirmarFinalizacao(); // Pass the actual total here
        },
        icon: const Icon(Icons.check, color: Colors.white),
        label: const Text('Finalizar Pedido', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 55, 163, 0),
      ),
    );
  }

  Future<List<Widget>> _buildProdutosList(List<DocumentReference> produtosRefs) async {
    List<Widget> produtosWidgets = [];

    for (var ref in produtosRefs) {
      try {
        final doc = await ref.get();
        if (!doc.exists) continue;

        final produtoData = doc.data() as Map<String, dynamic>;
        final nomeProduto = produtoData['nome'] ?? 'Produto sem nome';
        final preco = produtoData['valor']?.toDouble() ?? 0.0;

        produtosWidgets.add(
          Column(
            children: [
              ListTile(
                leading: Icon(Icons.fastfood, color: Colors.orange[900]),
                title: Text(
                  nomeProduto,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                trailing: Text(
                  'R\$ ${preco.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: Colors.green[700],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Divider(height: 1),
            ],
          ),
        );
      } catch (e) {
        print('Erro ao carregar produto: $e');
      }
    }

    if (produtosWidgets.isEmpty) {
      produtosWidgets.add(
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(
            child: Text(
              'Nenhum produto adicionado',
              style: TextStyle(
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ),
      );
    }

    return produtosWidgets;
  }
}