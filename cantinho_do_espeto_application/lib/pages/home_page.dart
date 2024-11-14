import 'package:flutter/material.dart';
import 'package:flutter_application_praticas/components/custom_drawer.dart';
import 'package:flutter_application_praticas/pages/cardapio_page.dart';
import 'package:flutter_application_praticas/pages/comanda_page.dart';
import 'package:flutter_application_praticas/pages/cozinha_page.dart';
import 'package:flutter_application_praticas/pages/mesas_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  
  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const CustomDrawer(),
      appBar: AppBar(
        title: const Text(
          'Cantinho do Espeto',
          style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.bottomRight,
              colors: [Colors.orange[900]!.withOpacity(1),
                Colors.orange[900]!.withOpacity(0.9)],
              stops: const [0.6, 1],
            ),
          ),
        ),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
                Colors.orange[900]!,
                Colors.orange[600]!,
              ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Center(
                  
                  child: Image.asset(
                    'assets/logo.png',
                    height: MediaQuery.of(context).size.height * 0.35,
                  ),
                ),
                
                const SizedBox(height: 30),
                const Padding(
                  padding: EdgeInsets.only(left: 8.0),
                  child: Text(
                    'Menu Principal',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  children: [
                    _buildMenuCard(
                      context: context,
                      title: 'Mesas',
                      icon: Icons.table_restaurant,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const TelaMesas()),
                      ),
                    ),
                    _buildMenuCard(
                      context: context,
                      title: 'Comandas',
                      icon: Icons.receipt_long,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ComandaPage()),
                      ),
                    ),
                    _buildMenuCard(
                      context: context,
                      title: 'Cozinha',
                      icon: Icons.restaurant,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const CozinhaPage()),
                      ),
                    ),
                    _buildMenuCard(
                      context: context,
                      title: 'Cardápio',
                      icon: Icons.restaurant_menu,
                     onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const TelaCardapio()),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                Colors.orange[50]!,
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 40,
                color: Colors.orange[800],
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange[900],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}