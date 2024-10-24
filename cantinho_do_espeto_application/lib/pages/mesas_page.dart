import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_praticas/pages/detalhes_mesa_page.dart';

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
      drawer: Drawer(
        child: ListView(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.fromLTRB(15, 5, 5, 5),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.orange[900]!.withOpacity(0.8),
                    Colors.orange[700]!.withOpacity(0.8),
                    Colors.orange[500]!.withOpacity(0.8),
                  ],
                  stops: const [0.0, 0.3, 1.0],
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Menu",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 24),
                  ),
                  Builder(
                    builder: (context) {
                      return IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
                ],
            ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
               Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.home), // home
                    title: const Text('Início'), // Início
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.book), // home
                    title: const Text('Histórico'), // Início
                    onTap: () {

                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.restaurant_menu),
                    title: const Text('Cardápio'),
                    onTap: () {

                    },
                  ),
                ],
              ),
              const Padding(padding: EdgeInsets.symmetric(vertical: 270)),
              Column(
                children: [ // espaço entre os demais itens da lista
                ListTile(
                  leading: const Icon(Icons.exit_to_app),
                  title: const Text('Sair'),
                  onTap: () {
                    // ação
                  },
                ),],
              ) 
            ],  
            )
          ],
        ),
      ),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60.0),
        child: AppBar(
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.orange[900]!.withOpacity(1),
                  Colors.orange[900]!.withOpacity(0.9),
                ],
                stops: const [0.6, 1],
              ),
              border: const Border(
                bottom: BorderSide(
                  color: Colors.white,
                  width: 1
                )
              )
            ),
          ),
          title: const Text('Mesas', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          leading: Builder(
            builder: (BuildContext context) {
              return IconButton(
                icon: const Icon(Icons.menu, color: Colors.white,),
                onPressed: () { Scaffold.of(context).openDrawer(); },
                tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
              );
            },
          ),
        ),
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(vertical: 2),
        height: double.infinity,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            colors: [
              Colors.orange[900]!,
              Colors.orange[800]!,
              Colors.orange[400]!,
            ],
          ),
        ),
        child: SingleChildScrollView(
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TelaDetalhesMesas( mesaId: mesa.id,),
                        ),
                      );
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
      )
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
