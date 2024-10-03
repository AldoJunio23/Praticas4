import 'package:flutter/material.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: TelaCardapio(),
    );
  }
}

class TelaCardapio extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cardápio"),
        backgroundColor: Colors.grey,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: const BoxDecoration(color: Colors.orange),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Text(
                      "Menu",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white, fontSize: 24),
                    ),
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
            ListTile(
              leading: const Icon(Icons.home), // home
              title: const Text('Início - Cardápio'), // Início
              onTap: () {
                // navega para a tela de entrada
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.restaurant_menu), // home
              title: const Text('Entrada'), // Início
              onTap: () {
                //Navigator.pushNamed(context, 'entrada');

                // navega para a tela de entrada
                _showLoadingThenNavigate(context, 'entrada');
              },
            ),
            ListTile(
              leading: const Icon(Icons.dinner_dining),
              title: const Text('Prato Principal'),
              onTap: () {
                //Navigator.pushNamed(context, 'prato principal');

                // navega para a tela de prato principal
                _showLoadingThenNavigate(context, 'prato principal');
              },
            ),
            ListTile(
              leading: const Icon(Icons.cake),
              title: const Text('Sobremesa'),
              onTap: () {
                //Navigator.pushNamed(context, 'sobremesa');

                // navega para a tela de sobremesa
                _showLoadingThenNavigate(context, 'sobremesa');
              },
            ),
            ListTile(
              leading: const Icon(Icons.wine_bar),
              title: const Text('Bebida'),
              onTap: () {
                //Navigator.pushNamed(context, 'bebida');

                // navega para a tela de bebida
                _showLoadingThenNavigate(context, 'bebida');
              },
            ),
            const SizedBox(height: 20), // espaço entre os demais itens da lista
            ListTile(
              leading: const Icon(Icons.exit_to_app),
              title: const Text('Sair'),
              onTap: () {
                // ação
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Botão Entrada
            _buildCardButton(context, "Entrada"),

            const SizedBox(height: 16.0),

            // Botão Prato Principal
            _buildCardButton(context, "Prato Principal"),

            const SizedBox(height: 16.0),

            // Botão Sobremesa
            _buildCardButton(context, "Sobremesa"),

            const SizedBox(height: 16.0),

            // Botão Bebida
            _buildCardButton(context, "Bebida"),

            const SizedBox(height: 50.0),

            // Botão Finalizar
            _buildFinalizeButton(context),
          ],
        ),
      ),
    );
  }
}

// Função para exibir loading antes de navegar para uma nova tela
void _showLoadingThenNavigate(BuildContext context, String routeName) {
  showDialog(
    context: context,
    barrierDismissible: false, // Evita fechar o loading clicando fora
    builder: (BuildContext context) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize
              .min, // Para que o tamanho do dialog se ajuste ao conteúdo
          children: [
            CircularProgressIndicator(), // Indicador de loading
            SizedBox(height: 16), // Espaçamento entre o indicador e o texto
            Text(
              "LOADING...",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    },
  );

  // Simula um atraso de 2 segundos antes de navegar
  Future.delayed(Duration(seconds: 2), () {
    Navigator.pop(context); // Fecha o diálogo de loading
    Navigator.pushNamed(context, routeName); // Navega para a próxima tela
  });
}

// Função dos botões laranjas
Widget _buildCardButton(BuildContext context, String text) {
  return SizedBox(
    width: double.infinity,
    height: 80, // altura dos botões
    child: ElevatedButton(
      onPressed: () {
        // ação
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.orange, // cor de fundo dos botões
        foregroundColor: Colors.white, // cor do texto dos botões
        textStyle: const TextStyle(fontSize: 18), // tamanho de fonte
      ),
      child: Text(text),
    ),
  );
}

// Função para botão 'Finalizar'
Widget _buildFinalizeButton(BuildContext context) {
  return SizedBox(
    width: double.infinity,
    height: 60,
    child: ElevatedButton(
        onPressed: () {
          // ação
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          textStyle: const TextStyle(
            fontSize: 18,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        child: const Text("Finalizar")),
  );
}
