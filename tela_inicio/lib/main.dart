import 'package:flutter/material.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: TelaInicio(),
  ));
}

class TelaInicio extends StatefulWidget {
  const TelaInicio({super.key});

  @override
  TelaInicioState createState() => TelaInicioState();
}

class TelaInicioState extends State<TelaInicio> {
  @override
  Widget build(BuildContext context) {

    return Scaffold(
    // tela lateral que exibe as opções
      drawer: Drawer(

        backgroundColor: const Color.fromARGB(200, 158, 158, 158),
        
        child: Column( // coluna de componetes

          crossAxisAlignment: CrossAxisAlignment.start,

          children: [ // "filho" conteúdo de dentro

              SizedBox(height: 20), // Adiciona um espaçamento
        

            ListTile(  // cria uma lista de titulos

              leading: Icon(Icons.home, color: Colors.white),
              title: Text('ínicio'),
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
      //titulo da tela
      appBar: AppBar(

        backgroundColor: Colors.grey,

        title: const Text("Início"),
        
      ),

      body: SingleChildScrollView(

        padding: const EdgeInsets.all(50),

        child: Column(

          crossAxisAlignment: CrossAxisAlignment.center, // Alinha os widgets horizontalmente
           
          children: [
            // botões
            ElevatedButton(
              onPressed: () {

                print("Botão Mesa foi clicado");
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 130, vertical:70),
                shape: RoundedRectangleBorder(

                  borderRadius: BorderRadius.circular(7.0)
                ),

                backgroundColor: const Color.fromARGB(255, 212, 133, 14)
              ),

              child: const Text( "Mesa", 

                style: TextStyle(fontSize: 30,color: Colors.white),

              ),
            ),
            SizedBox(height: 30), // Espaço entre os botões

            ElevatedButton(

              onPressed: () {

                print("Botão Comanda foi clicado");
              },
              style: ElevatedButton.styleFrom(

                padding: EdgeInsets.symmetric(horizontal: 100,vertical: 70),
                shape: RoundedRectangleBorder(

                  borderRadius:  BorderRadius.circular(7.0),

                ),
                backgroundColor: const Color.fromARGB(255, 245, 180, 0)

              ),
              child: const Text(

                "Comanda",

                style: TextStyle(fontSize: 30,color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
