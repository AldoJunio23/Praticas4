import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TelaMesas extends StatefulWidget {
  const TelaMesas({super.key});

  @override
  TelaMesasState createState() => TelaMesasState();
}

class TelaMesasState extends State<TelaMesas> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey,
        title: const Text("Mesas"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(30),
        child: StreamBuilder<QuerySnapshot>(
          stream: _firestore.collection('Mesas').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return const Center(child: Text('Erro ao carregar mesas.'));
            }

            final mesas = snapshot.data?.docs ?? [];

            return Wrap(
              spacing: 25, // Espaço horizontal entre os botões
              runSpacing: 25, // Espaço vertical entre as linhas de botões
              children: List.generate(mesas.length, (index) {
                var mesa = mesas[index];
                var isOcupada = mesa['status'] ?? false; // Usar o campo 'status' para determinar a ocupação

                Color buttonColor = isOcupada ? Colors.red : Colors.green;

                return ElevatedButton(
                  onPressed: () {
                    // Altera o estado da mesa no Firestore
                    _firestore.collection('Mesas').doc(mesa.id).update({
                      'status': !isOcupada,
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(25),
                    backgroundColor: buttonColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(7.0),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Mesa ${mesa['numMesa']}', // Exibir o número da mesa
                        style: const TextStyle(fontSize: 20, color: Colors.white),
                      ),
                      const SizedBox(height: 5),
                      FutureBuilder<List<String>>(
                        future: _carregarPedidos(mesa['listaPedidos']),
                        builder: (context, pedidosSnapshot) {
                          if (pedidosSnapshot.connectionState == ConnectionState.waiting) {
                            return const CircularProgressIndicator();
                          } else if (pedidosSnapshot.hasError) {
                            return const Text('Erro ao carregar pedidos');
                          } else if (!pedidosSnapshot.hasData || pedidosSnapshot.data!.isEmpty) {
                            return const Text('Nenhum pedido');
                          }

                          final pedidos = pedidosSnapshot.data!;
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: pedidos.map((pedido) => Text(pedido)).toList(),
                          );
                        },
                      ),
                    ],
                  ),
                );
              }),
            );
          },
        ),
      ),
      drawer: const Drawer(
        backgroundColor: Color.fromARGB(200, 158, 158, 158),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20), // Adiciona um espaçamento
            ListTile(
              leading: Icon(Icons.home, color: Colors.white),
              title: Text('Início'),
              textColor: Colors.white,
            ),
            ListTile(
              leading: Icon(Icons.book, color: Colors.white),
              title: Text('Histórico'),
              textColor: Colors.white,
            ),
            ListTile(
              leading: Icon(Icons.restaurant, color: Colors.white),
              title: Text('Produtos'),
              textColor: Colors.white,
            ),
            ListTile(
              leading: Icon(Icons.restaurant_menu, color: Colors.white),
              title: Text('Cardápio'),
              textColor: Colors.white,
            ),
            ListTile(
              leading: Icon(Icons.exit_to_app, color: Colors.white),
              title: Text('Sair'),
              textColor: Colors.white,
            ),
          ],
        ),
      ),
    );
  }

  // Função para carregar os pedidos relacionados às mesas
  Future<List<String>> _carregarPedidos(List<dynamic> pedidosRefs) async {
    List<String> pedidos = [];

    for (var ref in pedidosRefs) {
      // Certifique-se de que 'ref' é uma instância de DocumentReference
      if (ref is DocumentReference) {
        // Obtenha o documento de cada referência de pedido
        DocumentSnapshot pedidoDoc = await ref.get();
        Map<String, dynamic>? pedidoData = pedidoDoc.data() as Map<String, dynamic>?;

        if (pedidoData != null) {
          pedidos.add('Total R\$ ${pedidoData['valorTotal']}');
        }
      }
    }

    return pedidos;
  }

}
