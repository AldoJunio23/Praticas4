
import 'package:flutter/material.dart';
import 'package:flutter_application_praticas/components/custom_drawer.dart';
import 'package:flutter_application_praticas/pages/criar_pedidos_page.dart';


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
      drawer: const CustomDrawer(), // Usando o CustomDrawer
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
          title: const Text('Comandas', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
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
      body: SingleChildScrollView(
        
        padding: const EdgeInsets.all(30.0),

        child: Wrap(

          spacing: 25,

          runSpacing: 25,

          children: [

            ElevatedButton(

              onPressed: (){
                  Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CriarPedidosPage()),
                  );
              },

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
  
    );

  }
}