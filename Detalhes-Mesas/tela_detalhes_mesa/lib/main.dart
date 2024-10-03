// ignore_for_file: prefer_const_constructors, dead_code, sort_child_properties_last

import 'package:flutter/material.dart';

void main()
 {
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
          margin: EdgeInsets.all(30),
          padding: EdgeInsets.all(20),
          

          child: Column(

            children: [
              
              const Text(

                "Estado da Mesa:",
                style: TextStyle(fontSize: 20, color: Colors.white),
                

              ),

              SizedBox(height: 20), 

              RadioListTile<int>(

                title: Text('Ocupado'),
                value: 1,
                groupValue: _selectedValue,
                onChanged: (value) {
                  setState(() {
                    _selectedValue = value;
                  });
                },
              ),
              RadioListTile<int>(
                title: Text('Desocupado'),
                value: 2,
                groupValue: _selectedValue,
                onChanged: (value) {
                  setState(() {
                    _selectedValue = value;
                  });
                },
              ),
             
               SizedBox(height: 50), 

                const Text(
                "Comanda:",
                style: TextStyle(fontSize: 20, color: Colors.white),
              ),

              SizedBox(height: 50), 

              ElevatedButton(
              
                onPressed: () => {}, 

                child: const Text("01", 
                
                style: TextStyle(color: Colors.white),
                ),

                style: ElevatedButton.styleFrom(

                  backgroundColor: const Color.fromARGB(255, 255, 188, 5),
              
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(02),

                    side: BorderSide(width: 50),
                  )
                ),
                )


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
