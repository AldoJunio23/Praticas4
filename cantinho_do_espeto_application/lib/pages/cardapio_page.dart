import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_praticas/components/custom_drawer.dart';

class TelaCardapio extends StatefulWidget {
  const TelaCardapio({super.key});

  @override
  _TelaCardapioState createState() => _TelaCardapioState();
}

class _TelaCardapioState extends State<TelaCardapio> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ScrollController _scrollController = ScrollController();
  final Map<String, GlobalKey> _categoryKeys = {};

  final Map<String, Map<String, String>> categorias = {
    'Caldos': {
      'docId': 'EI0XR8FLCNQJXJ0EbzHL',
      'collection': 'prod-caldo',
    },
    'Bebidas': {
      'docId': 'PoDiOnHmAULfo04IFIZy',
      'collection': 'prod-bebida',
    },
    'Espetos': {
      'docId': 'r68ahS3Ck96LGZEVzZma',
      'collection': 'prod-espetos',
    },
  };

  @override
  void initState() {
    super.initState();
    for (var categoria in categorias.keys) {
      _categoryKeys[categoria] = GlobalKey();
    }
  }

  Future<Map<String, List<Map<String, dynamic>>>> _getAllProdutos() async {
    Map<String, List<Map<String, dynamic>>> produtosPorCategoria = {};

    for (var category in categorias.keys) {
      final docId = categorias[category]?['docId'] ?? '';
      final collectionName = categorias[category]?['collection'] ?? '';

      List<Map<String, dynamic>> produtos = [];
      QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore
          .collection("Produto")
          .doc(docId)
          .collection(collectionName)
          .get();

      for (var doc in snapshot.docs) {
        if (doc['disponivel'] == true) {
          produtos.add({
            'id': doc.id,
            'nome': doc['nome'],
            'valor': doc['valor'],
            'imagem': doc['imagem'],
          });
        }
      }

      produtosPorCategoria[category] = produtos;
    }

    return produtosPorCategoria;
  }

  void _scrollToCategory(String category) {
    final categoryKey = _categoryKeys[category];
    if (categoryKey != null) {
      Scrollable.ensureVisible(
        categoryKey.currentContext!,
        duration: const Duration(seconds: 1),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const CustomDrawer(),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60.0),
        child: AppBar(
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.orange[900]!.withOpacity(1),
                  Colors.orange[900]!.withOpacity(0.9),
                ],
                stops: const [0.6, 1],
              ),
              border: const Border(
                bottom: BorderSide(
                  color: Colors.white,
                  width: 1,
                ),
              ),
            ),
          ),
          title: const Text(
            'Cardápio',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          leading: Builder(
            builder: (BuildContext context) {
              return IconButton(
                icon: const Icon(Icons.menu, color: Colors.white),
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
                tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
              );
            },
          ),
        ),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 80,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: categorias.keys.map((category) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.orange[900],
                        backgroundColor: Colors.white,
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                          side: BorderSide(color: Colors.orange[900]!),
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: 12.0,
                          horizontal: 20.0,
                        ),
                      ),
                      onPressed: () => _scrollToCategory(category),
                      child: Text(
                        category,
                        style: const TextStyle(fontWeight: FontWeight.bold,
                        fontSize: 16
                         ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<Map<String, List<Map<String, dynamic>>>>(
              future: _getAllProdutos(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return const Center(child: Text('Erro ao carregar produtos'));
                }

                final produtosPorCategoria = snapshot.data ?? {};

                return ListView.builder(
                  controller: _scrollController,
                  itemCount: produtosPorCategoria.keys.length,
                  itemBuilder: (context, index) {
                    final category = produtosPorCategoria.keys.elementAt(index);
                    final produtos = produtosPorCategoria[category] ?? [];

                    return Column(
                      key: _categoryKeys[category],
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Text(
                            category,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 255, 115, 0),
                            ),
                          ),
                        ),
                        Column(
                          children: produtos.map((produto) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 8.0,
                              ),
                              child: Card(
                                elevation: 10,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ClipRRect(
                                      borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(15),
                                      ),
                                      child: CachedNetworkImage(
                                        imageUrl: produto['imagem'],
                                        placeholder: (context, url) =>
                                            const Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                        errorWidget: (context, url, error) =>
                                            const Icon(Icons.error),
                                        width: double.infinity,
                                        height: 200,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              produto['nome'],
                                              style: const TextStyle(
                                                fontSize: 24,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 6,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.orange[900],
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            child: Text(
                                              'R\$ ${produto['valor'].toStringAsFixed(2)}',
                                              style: const TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          const Icon(
                                            Icons.fastfood,
                                            color: Colors.orange,
                                            size: 28,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}