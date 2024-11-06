import 'package:flutter/material.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: TelaPratoPrincipal(),
    );
  }
}

class TelaPratoPrincipal extends StatelessWidget {
  const TelaPratoPrincipal({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prato Principal'),
        backgroundColor: Colors.grey, // orange
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
              title: const Text('Início - Cardápio'), // Início Cardápio
              onTap: () {
                // navega para a tela de entrada
                //Navigator.pop(context);

                // navega para a tela inicial de cardápio
                Navigator.pushNamed(context, 'cardapio');
              },
            ),

            ListTile(
              leading: const Icon(Icons.restaurant_menu), // home
              title: const Text('Entrada'), // Início
              onTap: () {
                // navega para a tela de entrada
                //Navigator.pushNamed(context, 'entrada');

                // navega para a tela de entrada
                _showLoadingThenNavigate(context, 'entrada');
              },
            ),
            ListTile(
              leading: const Icon(Icons.dinner_dining),
              title: const Text('Prato Principal'),
              onTap: () {
                // navega para a tela de prato principal
                //Navigator.pushNamed(context, 'prato principal');

                // navega para a tela de prato principal
                _showLoadingThenNavigate(context, 'prato principal');
              },
            ),
            ListTile(
              leading: const Icon(Icons.cake),
              title: const Text('Sobremesa'),
              onTap: () {
                // navega para a tela de sobremesa
                //Navigator.pushNamed(context, 'sobremesa');

                // navega para a tela de sobremesa
                _showLoadingThenNavigate(context, 'sobremesa');
              },
            ),
            ListTile(
              leading: const Icon(Icons.wine_bar),
              title: const Text('Bebida'),
              onTap: () {
                // navega para a tela de bebida
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
        child: GridView.count(
          crossAxisCount: 2, // Número de colunas
          crossAxisSpacing: 16.0, // Espaçamento horizontal
          mainAxisSpacing: 16.0, // Espaçamento vertical
          children: List.generate(4, (index) {
            // aqui podemos alterar a quantidade de cards que serão gerados
            return Column(
              children: [
                Expanded(
                  child: Container(
                    color: Colors.grey[
                        300], // Cor de fundo para representar a imagem do produto
                    child: Center(
                      child: Icon(
                        Icons.image, // Ícone para representar a imagem
                        size: 50,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8.0),
                const Text('Produto - Prato Principal'),
                const SizedBox(height: 8.0),
                ElevatedButton(
                  onPressed: () {
                    // Ação ao clicar em "Adicionar"
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey, // orange
                      foregroundColor: Colors.white),
                  child: const Text('ADICIONAR'),
                ),
              ],
            );
          }),
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
  Future.delayed(const Duration(seconds: 2), () {
    Navigator.pop(context); // Fecha o diálogo de loading
    Navigator.pushNamed(context, routeName); // Navega para a próxima tela
  });
}
