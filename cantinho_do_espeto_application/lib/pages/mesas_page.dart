import 'package:flutter/material.dart';

class TelaMesas extends StatefulWidget {
  const TelaMesas({super.key});

  @override
  TelaMesasState createState() => TelaMesasState();
}

class TelaMesasState extends State<TelaMesas> {

   // Lista de estados das mesas, sse está ocupada ou desocupada
  List<bool> mesaEstados = List.generate(18, (index) => false);

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(

        backgroundColor: Colors.grey,
        title: const Text("Mesas"),

      ),
      
      body: SingleChildScrollView(

        padding: const EdgeInsets.all(30),

        child: Wrap(

          spacing: 25, // Espaço horizontal entre os botões
          runSpacing: 25, // Espaço vertical entre as linhas de botões

          children: List.generate(18, (index) {

            // Define a cor do botão com base no estado da mesa
            Color buttonColor = mesaEstados[index] ? Colors.red : Colors.green;

            return ElevatedButton(
              onPressed: () {
 
                // muda o  estado da mesa quando o botão é pressionado
                setState(() {
                  mesaEstados[index] = !mesaEstados[index];
                });
              },

              style: ElevatedButton.styleFrom(

                padding: const EdgeInsets.all(25), // Distância entre elementos

                backgroundColor: buttonColor, // Usar a cor definida

                shape: RoundedRectangleBorder(

                  borderRadius: BorderRadius.circular(7.0),

                ),
              ),
              child: Text(

                (index + 1).toString().padLeft(2, '0'), // Exibe números 01, 02, etc.

                style: const TextStyle(fontSize: 20, color: Colors.white),
              ),
            );
          }),
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

}