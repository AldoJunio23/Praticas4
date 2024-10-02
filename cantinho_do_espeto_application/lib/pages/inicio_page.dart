import 'package:flutter/material.dart';
import 'package:flutter_application_praticas/pages/comandas_page.dart';
import 'package:flutter_application_praticas/pages/cozinha_page.dart';
import 'package:flutter_application_praticas/pages/mesas_page.dart';

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
      drawer: const Drawer(

        backgroundColor: Color.fromARGB(200, 158, 158, 158),
        
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

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // botões
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TelaMesas(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 129, vertical:70),
                shape: RoundedRectangleBorder(

                  borderRadius: BorderRadius.circular(7.0)
                ),

                backgroundColor: const Color.fromARGB(255, 212, 133, 14)
              ),

              child: const Text( "Mesa", 

                style: TextStyle(fontSize: 30,color: Colors.white),

              ),
            ),
            const SizedBox(height: 30), // Espaço entre os botões

            ElevatedButton(

              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TelaComandas(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(

                padding: const EdgeInsets.symmetric(horizontal: 100,vertical: 70),
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
            const SizedBox(height: 30), // Espaço entre os botões

            ElevatedButton(

              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CozinhaPage(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(

                padding: const EdgeInsets.symmetric(horizontal: 110,vertical: 70),
                shape: RoundedRectangleBorder(

                  borderRadius:  BorderRadius.circular(7.0),

                ),
                backgroundColor: const Color.fromARGB(255, 245, 180, 0)

              ),
              child: const Text(

                "Cozinha",

                style: TextStyle(fontSize: 30,color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}