// ignore_for_file: prefer_const_constructors, sort_child_properties_last

import 'package:flutter/material.dart';

void main() {
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: TelaDetalhesMesas(),
    ),
  );
}

class TelaDetalhesMesas extends StatefulWidget {
  const TelaDetalhesMesas({super.key});

  @override
  TelaDetalhesMesasState createState() => TelaDetalhesMesasState();
}

class TelaDetalhesMesasState extends State<TelaDetalhesMesas> {
  int? _selectedValue;

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(

        title: const Text("Mesa 01"),
        
        backgroundColor: Colors.grey,

      ),

      body: SingleChildScrollView(

        child: Container(

          height: 600,
          width: 500,
          color: Colors.grey,
          margin: const EdgeInsets.all(30),
          padding: const EdgeInsets.all(20),

          child: Column(

            children: [

              const Text(

                "Estado da Mesa:",
                style: TextStyle(fontSize: 30, color: Colors.white),
              ),

              const SizedBox(height: 30),

              RadioListTile<int>(

                title: Text('Ocupado',style: TextStyle(color: Colors.white,fontSize: 20),),
                value: 1,
                groupValue: _selectedValue,
                activeColor: Colors.red,

                onChanged: (value) {
                  setState(() {
                    _selectedValue = value;
                  });
                },
              ),

              const SizedBox(height: 15),

              RadioListTile<int>(

                title: Text('Desocupado',style: TextStyle(color: Colors.white,fontSize: 20)),
                value: 2,
                groupValue: _selectedValue,
                activeColor: Colors.green,


                onChanged: (value) {

                  setState(() {
                    _selectedValue = value;
                  });
                },
              ),

              const SizedBox(height: 130),

              const Text(
                "Comanda:",
                style: TextStyle(fontSize: 25, color: Colors.white),
              ),

              const SizedBox(height: 40), // Aumente esta altura para mais espaçamento

              ElevatedButton(

                onPressed: () => {},

                child: const Text(

                  "01",

                  style: TextStyle(color: Colors.white,
                  fontSize: 20),
                ),

                style: ElevatedButton.styleFrom(

                  minimumSize: const Size(200, 80), // Ajuste a largura e altura aqui

                  backgroundColor: const Color.fromARGB(255, 231, 174, 15),

                  shape: RoundedRectangleBorder(

                    borderRadius: BorderRadius.circular(2),

                    //side: BorderSide(width: 1),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      
      drawer: Drawer(

        backgroundColor: const Color.fromARGB(200, 158, 158, 158),

        child: Column(

          crossAxisAlignment: CrossAxisAlignment.start,

          children: const [

            SizedBox(height: 20),

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
