import 'package:flutter/material.dart';
import 'package:flutter_application_praticas/pages/crud_pages/deletar_page.dart';
import 'package:flutter_application_praticas/pages/home_page.dart';
import 'package:flutter_application_praticas/pages/cardapio_page.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(

      
      child: Column(
        
        children: <Widget>[
          // Mantendo o gradiente do container como estava
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
          ListTile(
            leading: const Icon(Icons.home), // home
            title: const Text('Home'), // Início
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const HomePage(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.book),
            title: const Text('Histórico'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.restaurant_menu),
            title: const Text('Cardápio'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TelaCardapio(),
                ),
              );
            },
          ),
          
          // Espaçamento flexível
          const Spacer(),

          // ListTiles do Admin e Sair no final
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
              ),
              ListTile(
                leading: const Icon(Icons.exit_to_app),
                title: const Text('Sair'),
                onTap: () {
                  // ação de sair
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
