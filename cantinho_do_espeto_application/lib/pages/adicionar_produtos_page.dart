import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class AdicionarProdutosPage extends StatefulWidget {
  const AdicionarProdutosPage({super.key});

  @override
  State<StatefulWidget> createState() => _AdicionarProdutosState();
}

class _AdicionarProdutosState extends State<AdicionarProdutosPage> {

  @override
  void initState() {
    super.initState();
  }

   @override
  Widget build(BuildContext context) {
    return Scaffold(
         appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60.0),
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
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),
          title: const Text('Adicionar Produtos ao Pedido'),
          leading: const Icon(Icons.menu),
        ),
      ),

      //Implementar o seletor de produtos
    );
  }
}