import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_praticas/pages/detalhes_cliente_page.dart';
import 'package:flutter_application_praticas/pages/new_pedido_cliente_page.dart';

class TelaClientesPedidos extends StatelessWidget {
  const TelaClientesPedidos({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pedidos de Clientes', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.orange[900],
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Pedidos')
            .orderBy('dataCriacao', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Nenhum pedido encontrado',
                    style: TextStyle(color: Colors.grey[600], fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NovoPedidoClientePage(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.add, color: Colors.white),
                    label: const Text(
                      'Novo Pedido',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange[900],
                    ),
                  ),
                ],
              ),
            );
          }

          // Filtrar apenas pedidos não finalizados e agrupar por cliente
          Map<String, List<DocumentSnapshot>> pedidosPorCliente = {};
          for (var doc in snapshot.data!.docs) {
            final data = doc.data() as Map<String, dynamic>;
            final nomeCliente = data['nomeCliente'] as String?;
            final finalizado = data['finalizado'] ?? false;
            
            if (nomeCliente != null && nomeCliente.isNotEmpty && !finalizado) {
              if (!pedidosPorCliente.containsKey(nomeCliente)) {
                pedidosPorCliente[nomeCliente] = [];
              }
              pedidosPorCliente[nomeCliente]!.add(doc);
            }
          }

          // Se não houver pedidos em andamento após a filtragem
          if (pedidosPorCliente.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Nenhum pedido de Cliente em andamento',
                    style: TextStyle(color: Colors.grey[600], fontSize: 16),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: pedidosPorCliente.length,
            itemBuilder: (context, index) {
              final nomeCliente = pedidosPorCliente.keys.elementAt(index);
              final pedidosCliente = pedidosPorCliente[nomeCliente]!;

              return Card(
                margin: const EdgeInsets.all(8),
                elevation: 4,
                child: ExpansionTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.orange[100],
                    child: Text(
                      nomeCliente[0].toUpperCase(),
                      style: TextStyle(
                        color: Colors.orange[900],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    nomeCliente,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  subtitle: Text(
                    '${pedidosCliente.length} pedido${pedidosCliente.length > 1 ? 's' : ''}',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  children: pedidosCliente.map((pedido) {
                    final data = pedido.data() as Map<String, dynamic>;
                    final timestamp = data['dataCriacao'] as Timestamp?;
                    final dataPedido = timestamp?.toDate() ?? DateTime.now();
                    final valorTotal = data['valorTotal']?.toDouble() ?? 0.0;

                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 8,
                      ),
                      title: Text(
                        'Pedido #${pedido.id.substring(0, 8)}',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Data: ${dataPedido.day}/${dataPedido.month}/${dataPedido.year} ${dataPedido.hour}:${dataPedido.minute}',
                          ),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.orange[100],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'Em andamento',
                                  style: TextStyle(
                                    color: Colors.orange[900],
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              Text(
                                'R\$ ${valorTotal.toStringAsFixed(2)}',
                                style: TextStyle(
                                  color: Colors.green[700],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetalhePedidoClientePage(
                              pedidoId: pedido.id,
                            ),
                          ),
                        );
                      },
                    );
                  }).toList(),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const NovoPedidoClientePage(),
            ),
          );
        },
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Novo Pedido', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.orange[900],
      ),
    );
  }
}