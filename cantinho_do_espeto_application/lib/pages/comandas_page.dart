
import 'package:flutter/material.dart';


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
                children: [
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
          title: const Text('Comandas', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
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
              }),
            ],
          ),
        ),
      )
    );
  }
}