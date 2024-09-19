import 'package:flutter/material.dart';

void main() {
  runApp(
    const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: TelaMesas(),
  ));
}

class TelaMesas extends StatefulWidget {
  
  const TelaMesas({super.key});

  @override
  TelaMesasState createState() => TelaMesasState();

}

class TelaMesasState extends State<TelaMesas>{

  @override 

  Widget build(BuildContext context){
   
    return Scaffold(  

     appBar : AppBar(

      backgroundColor: Colors.grey,
      title: const Text("Mesas"),
  

     ),

     body: SingleChildScrollView(

      padding: const EdgeInsets.all(30),

       child: Wrap(

          spacing: 25, // Espaço horizontal entre os botões

          runSpacing: 25, // Espaço vertical entre as linhas de botões
          
          children: [

            Row(

              children: [

          ElevatedButton(      

            onPressed: () { // botão chama um função


            },

            style: ElevatedButton.styleFrom(

              padding: EdgeInsets.all(25),


              backgroundColor: const Color.fromARGB(255, 67, 158, 70),

              shape: RoundedRectangleBorder(

                borderRadius: BorderRadius.circular(7.0)

              )

            ),

            child: const Text("01",
              style: TextStyle(fontSize: 20,color: Colors.white),
            ) 
            
            ),

             const SizedBox(width: 25),


              ElevatedButton(      

            onPressed: () { // botão chama um função


            },

            style: ElevatedButton.styleFrom(

              padding: EdgeInsets.all(25),
              backgroundColor: const Color.fromARGB(255, 67, 158, 70),

              shape: RoundedRectangleBorder(

                borderRadius: BorderRadius.circular(7.0)

              )

            ),

            child: const Text("02",
              style: TextStyle(fontSize: 20,color: Colors.white),
            ) 
            
            ),

               const SizedBox(width: 25),

              ElevatedButton(      

            onPressed: () { // botão chama um função


            },

            style: ElevatedButton.styleFrom(

              padding: EdgeInsets.all(25),
              backgroundColor: const Color.fromARGB(255, 67, 158, 70),

              shape: RoundedRectangleBorder(

                borderRadius: BorderRadius.circular(7.0)

              )

            ),   
            
            child: const Text("03",
              style: TextStyle(fontSize: 20,color: Colors.white),
            ) 
            
            ),

              const SizedBox(width: 25),

                  ElevatedButton(      

            onPressed: () { // botão chama um função


            },

            style: ElevatedButton.styleFrom(

              padding: EdgeInsets.all(25),
              backgroundColor: const Color.fromARGB(255, 67, 158, 70),

              shape: RoundedRectangleBorder(

                borderRadius: BorderRadius.circular(7.0)

              )

            ),   
            
            child: const Text("03",
              style: TextStyle(fontSize: 15,color: Colors.white),
            ) 
            
            ),

              const SizedBox(width: 25),

              ]
            )
        ],

      ),

     ),

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

    );
  }
}
