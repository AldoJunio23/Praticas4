import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Cozinha_Page(),
    );
  }
}

class Cozinha_Page extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60.0), // Define a altura da AppBar
        child: AppBar(
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.orange[900]!.withOpacity(0.8),
                  Colors.orange[700]!.withOpacity(0.8),
                  Colors.orange[500]!.withOpacity(0.8),
                ],
                stops:const [0.0, 0.5, 1.0], // Pontos de parada para transição suave
              ),
            ),
          ),
          title: const Text('Comandas'),
          leading: const Icon(Icons.menu), // Ícone de menu à esquerda
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0), // Padding para o layout geral
        child: Column(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(12.0), // Bordas arredondadas
                ),
                padding: const EdgeInsets.all(16.0),
                child: Wrap(
                  spacing: 15.0, // Espaçamento horizontal entre os containers
                  runSpacing: 8.0, // Espaçamento vertical entre as linhas
                  children: [
                    for (int i = 0; i < 9; i++) // Exemplo de 9 "Pedidos"
                    Container(
                      width: 150,
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.0), // Bordas arredondadas
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Pedido ${i + 1}"), // Apenas layout, os produtos serão passados conforme os pedidos
                          Text("Produto X -> 1x"),
                          Text("Produto Y -> 2x"),
                          Text("Produto X -> 1x"),
                          Text("Produto X -> 1x"),
                          Text("Produto X -> 1x"),
                          Text("Produto X -> 1x"),

                          Spacer(), // Empurra o botão para a parte inferior
                          ElevatedButton(
                            onPressed: () {},  
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green, 
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                            child: const Text("Finalizado"),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange, 
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: const Text('PREPARAR'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
