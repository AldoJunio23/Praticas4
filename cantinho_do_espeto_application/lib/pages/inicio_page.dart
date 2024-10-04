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
                    Navigator.pop(context);
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
          title: const Text('Início', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
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

      body:Container(
        padding: const EdgeInsets.symmetric(vertical: 30),
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
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: Image.asset(
                  'assets/logo.png',
                  height: 150, // Ajuste a altura conforme necessário
                  width: 150,  // Ajuste a largura conforme necessário
                ),
              ),
              const SizedBox(height: 30),
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

                  backgroundColor: const Color.fromARGB(255, 252, 191, 26)
                ),

                child: const Text( "Mesas", 

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
                  backgroundColor: const Color.fromARGB(255, 252, 191, 26)

                ),
                child: const Text(

                  "Comandas",

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

                  padding: const EdgeInsets.symmetric(horizontal: 120,vertical: 70),
                  shape: RoundedRectangleBorder(

                    borderRadius:  BorderRadius.circular(7.0),

                  ),
                  backgroundColor: const Color.fromARGB(255, 252, 191, 26)

                ),
                child: const Text(

                  "Cozinha",

                  style: TextStyle(fontSize: 30,color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      )
    );
  }
}