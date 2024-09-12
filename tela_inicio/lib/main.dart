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
      drawer: Drawer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: Icon(Icons.attach_money, color: Colors.red),
              title: Text('Menu Lateral 1'),
              subtitle: Text('Selecione a opção no menu'),
              onTap: () => print('Menu Lateral 1 clicado'),
            ),
            ListTile(
              leading: Icon(Icons.attach_money, color: Colors.red),
              title: Text('Menu Lateral 2'),
              subtitle: Text('Selecione a opção no menu'),
              onTap: () => print('Menu Lateral 2 clicado'),
            ),
            SizedBox(height: 20), // Adiciona um espaçamento
            ListTile(
              title: Text('Opção 1'),
              onTap: () => print('Opção 1 clicada'),
            ),
            ListTile(
              title: Text('Opção 2'),
              onTap: () => print('Opção 2 clicada'),
            ),
          ],
        ),
      ),
      appBar: AppBar(
        backgroundColor: Colors.grey,
        title: const Text("Início"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(50),
        child: ElevatedButton(
          onPressed: () {
            // Adiciona uma ação para o botão
            print("Botão Mesa clicado");
          },
          child: const Text(
            "Mesa",
            style: TextStyle(fontSize: 20),
          ),
        ),
      ),
    );
  }
}
