import 'package:flutter/material.dart';
import 'package:flutter_application_praticas/pages/pedidos_impressao_page.dart';
import 'package:flutter_application_praticas/pages/crud_pages/adm_page.dart';
import 'package:flutter_application_praticas/pages/faturamente_page.dart';
import 'package:flutter_application_praticas/pages/home_page.dart';
import 'package:flutter_application_praticas/pages/cardapio_page.dart';
import 'package:flutter_application_praticas/pages/login_page.dart';
import 'package:flutter_application_praticas/pages/mesas_page.dart';

import 'package:shared_preferences/shared_preferences.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  
  Future<bool> _isAdmin() async {
    final prefs = await SharedPreferences.getInstance();
    
    if (prefs.getString('email') == 'aldinho2307@gmail.com'){
      return true;
    }
    return false;
  }

  Future _logout() async {
    final prefs = await SharedPreferences.getInstance();
     prefs.setString('email', "");
  }

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
            leading: const Icon(Icons.table_restaurant),
            title: const Text('Mesas'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TelaMesas(),
                ),
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.receipt_long),
            title: const Text('Imprimir Pedidos'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TelaPedidosTxt(),
                ),
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.restaurant_menu),
            title: const Text('Cardápio'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TelaCardapio(),
                ),
              );
            },
          ),
          
          // Espaçamento flexível
          const Spacer(),
          
          Column(
            children: [
              FutureBuilder<bool>(
            future: _isAdmin(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox.shrink(); // Placeholder enquanto carrega
              } else if (snapshot.hasData && snapshot.data == true) {
                return ListTile(
                      leading: const Icon(Icons.book),
                      title: const Text('Histórico'),
                      onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const FaturamentoDiarioPage(),
                        ),
                      );
                    },
                  );
              } else {
                return const SizedBox.shrink(); // Não mostra nada se não for admin
              }
            },
          ),

            FutureBuilder<bool>(
            future: _isAdmin(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox.shrink(); // Placeholder enquanto carrega
              } else if (snapshot.hasData && snapshot.data == true) {
                return ListTile(
                  leading: const Icon(Icons.lock_person),
                  title: const Text('Admin'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AdminPage(),
                      ),
                    );
                  },
                );
              } else {
                return const SizedBox.shrink(); // Não mostra nada se não for admin
              }
            },
          ),
              ListTile(
                leading: const Icon(Icons.exit_to_app),
                title: const Text('Sair'),
                onTap: ()  {
                    _logout();
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginPage(),
                      ),
                    );
                  },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
