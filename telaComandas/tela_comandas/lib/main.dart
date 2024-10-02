
import 'package:flutter/material.dart';

void main() {
  runApp(
    const MaterialApp(

      debugShowCheckedModeBanner: false,

      home: TelaComandas(),
    ),
  );
}


class TelaComandas extends StatefulWidget {

  const TelaComandas({super.key});

  @override
  _TelaComandasState createState() => _TelaComandasState();
}

class _TelaComandasState extends State<TelaComandas> 
{
  List<int> comandas = [];

  void adicionarComanda() {

    setState(() {
      comandas.add(comandas.length + 1); // Adiciona um novo número de comanda
    });
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey,
        title: Row(

          mainAxisAlignment: MainAxisAlignment.start, // Alinha à esquerda
          children: const [

            Text("Comandas"),
          ]

        ),
        actions: [
          // Você pode manter o botão de adicionar na AppBar se quiser
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              adicionarComanda();
            },
          ),
        ],
      ),

      body: SingleChildScrollView(
        
        padding: const EdgeInsets.all(30.0),

        child: Wrap(

          spacing: 25,

          runSpacing: 25,

          children: [

            ElevatedButton(

              onPressed: adicionarComanda,

              style: ElevatedButton.styleFrom(

                padding: const EdgeInsets.all(25),

                backgroundColor: Colors.grey, // Cor do botão de adicionar
                shape: RoundedRectangleBorder(

                  borderRadius: BorderRadius.circular(7.0),

                ),
              ),
              child: const Text(
                '+',
                style: TextStyle(fontSize: 20, color: Colors.white),

              ),
            ),
            ...comandas.map((comanda) {

              return ElevatedButton(

                onPressed: () {

                  ScaffoldMessenger.of(context).showSnackBar(

                    SnackBar(content: Text('Comanda $comanda selecionada')),

                  );
                },
                style: ElevatedButton.styleFrom(

                  padding: const EdgeInsets.all(25),

                  backgroundColor:Color.fromARGB(255, 245, 180, 0), // Cor dos botões de comanda
                  shape: RoundedRectangleBorder(

                    borderRadius: BorderRadius.circular(7.0),
                  ),
                ),
                child: Text(
                  '$comanda',
                  style: const TextStyle(fontSize: 20, color: Colors.white),
                ),
              );
            }).toList(),
          ],
        ),
      ),
      
       drawer: Drawer(
        backgroundColor: const Color.fromARGB(200, 158, 158, 158),

        child: Column(

          crossAxisAlignment: CrossAxisAlignment.start,

          children: const [

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
}
