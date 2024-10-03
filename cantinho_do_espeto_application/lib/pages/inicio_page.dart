import 'package:flutter/material.dart';
import 'package:flutter_application_praticas/pages/admin_page.dart';
import 'package:flutter_application_praticas/pages/comandas_page.dart';
import 'package:flutter_application_praticas/pages/cozinha_page.dart';
import 'package:flutter_application_praticas/pages/crud_pages/deletar_page.dart';
import 'package:flutter_application_praticas/pages/mesas_page.dart';

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
        child: ListView(
          
          children: <Widget>[
            Container(
              padding: const EdgeInsets.fromLTRB(15, 5, 5, 5),
              color: Colors.orange,
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
                ),],
              ),
              const Padding(padding: EdgeInsets.symmetric(vertical: 270)),
              Column(
                children: [
                  ListTile(
                  leading: const Icon(Icons.lock_person),
                  title: const Text('Admin'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DeletarProduto(),
                      ),
                    );
                  },
                ), // espaço entre os demais itens da lista
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

                backgroundColor: const Color.fromARGB(255, 245, 180, 0)
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