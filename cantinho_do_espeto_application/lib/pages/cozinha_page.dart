import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_praticas/services/pedido_service.dart';

class CozinhaPage extends StatelessWidget {
  const CozinhaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60.0),
        child: AppBar(
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.orange[900]!.withOpacity(0.8),
                  Colors.orange[700]!.withOpacity(0.8),
                  Colors.orange[500]!.withOpacity(0.8),
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),
          title: const Text('Comandas'),
          leading: const Icon(Icons.menu),
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: PedidoService().buscarPedidos(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Nenhum pedido encontrado.'));
          }

          final pedidos = snapshot.data!;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView.builder(
              itemCount: pedidos.length,
              itemBuilder: (context, index) {
                final pedido = pedidos[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Mesa: ${pedido['mesa'].id}",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text("Data: ${pedido['horario'].toDate().toString()}"),
                      Text("Total: R\$ ${pedido['valorTotal']}"),
                      Text("Finalizado: ${pedido['finalizado'] ? 'Sim' : 'Não'}"),
                      const SizedBox(height: 10),
                      Text("Produtos:"),
                      FutureBuilder<List<String>>(
                        future: _carregarProdutos(pedido['listaProdutos']),
                        builder: (context, produtosSnapshot) {
                          if (produtosSnapshot.connectionState == ConnectionState.waiting) {
                            return CircularProgressIndicator();
                          } else if (produtosSnapshot.hasError) {
                            return Text('Erro ao carregar produtos');
                          } else if (!produtosSnapshot.hasData || produtosSnapshot.data!.isEmpty) {
                            return Text('Nenhum produto encontrado.');
                          }

                          final produtos = produtosSnapshot.data!;
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: produtos.map((produto) => Text(produto)).toList(),
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Future<List<String>> _carregarProdutos(List<DocumentReference> produtosRefs) async {
    List<String> produtos = [];

    for (var ref in produtosRefs) {
      DocumentSnapshot produtoDoc = await ref.get();
      Map<String, dynamic> produtoData = produtoDoc.data() as Map<String, dynamic>;

      produtos.add(produtoData['nome'] ?? 'Produto desconhecido');
    }

    return produtos;
  }
}
