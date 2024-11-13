import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_praticas/components/custom_drawer.dart';
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
      drawer: const CustomDrawer(), // Usando o nosso CustomDrawer
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
                  width: 1,
                ),
              ),
            ),
          ),
          title: const Text('Mesas', style: TextStyle(color: Colors.white, 
          fontSize: 22, fontWeight: FontWeight.bold)),
          leading: Builder(
            builder: (BuildContext context) {
              return IconButton(
                icon: const Icon(Icons.menu, color: Colors.white),
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
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
        color: Colors.white,
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
                        Text(isOcupada ? "Ocupada" : "Disponível", style: const TextStyle(color: Colors.white),)
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

}
