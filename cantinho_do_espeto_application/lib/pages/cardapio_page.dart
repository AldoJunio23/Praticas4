import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_praticas/components/custom_drawer.dart';

class TelaCardapio extends StatefulWidget {
  const TelaCardapio({super.key});

  @override
  _TelaCardapioState createState() => _TelaCardapioState();
}

class _TelaCardapioState extends State<TelaCardapio> with SingleTickerProviderStateMixin {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ScrollController _scrollController = ScrollController();
  final Map<String, GlobalKey> _categoryKeys = {};
  late TabController _tabController;
  String _searchQuery = '';
  bool _isLoading = false;
  Map<String, List<Map<String, dynamic>>> _produtosPorCategoria = {};

  final Map<String, Map<String, String>> categorias = {
    'Caldos': {
      'docId': 'EI0XR8FLCNQJXJ0EbzHL',
      'collection': 'prod-caldo',
    },
    'Adicionais': {
      'docId': 'FFgYAgy1ACxpqOPfekEi',
      'collection': 'prod-adicional',
    },
    'Espetos': {
      'docId': 'r68ahS3Ck96LGZEVzZma',
      'collection': 'prod-espetos',
    },
    'Bebidas': {
      'docId': 'PoDiOnHmAULfo04IFIZy',
      'collection': 'prod-bebida',
    }
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: categorias.length, vsync: this);
    for (var categoria in categorias.keys) {
      _categoryKeys[categoria] = GlobalKey();
    }
    _carregarProdutos();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _carregarProdutos() async {
    setState(() => _isLoading = true);
    try {
      _produtosPorCategoria = await _getAllProdutos();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao carregar produtos: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
    setState(() => _isLoading = false);
  }

  Future<Map<String, List<Map<String, dynamic>>>> _getAllProdutos() async {
    Map<String, List<Map<String, dynamic>>> produtosPorCategoria = {};

    for (var entry in categorias.entries) {
      final category = entry.key;
      final docId = entry.value['docId'] ?? '';
      final collectionName = entry.value['collection'] ?? '';

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
            'categoria': category,
          });
        }
      }

      produtosPorCategoria[category] = produtos;
    }

    return produtosPorCategoria;
  }

  List<Map<String, dynamic>> _getProdutosFiltrados() {
    if (_searchQuery.isEmpty) return [];
    
    List<Map<String, dynamic>> produtosFiltrados = [];
    _produtosPorCategoria.forEach((categoria, produtos) {
      produtosFiltrados.addAll(
        produtos.where((produto) =>
          produto['nome'].toLowerCase().contains(_searchQuery.toLowerCase()))
      );
    });
    return produtosFiltrados;
  }

  Widget _buildProdutoCard(Map<String, dynamic> produto) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        height: 120,
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(15),
              ),
              child: CachedNetworkImage(
                imageUrl: produto['imagem'],
                width: 120,
                height: 120,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey[200],
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[200],
                  child: const Icon(Icons.error),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      produto['nome'],
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange[900],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'R\$ ${produto['valor'].toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final produtosFiltrados = _getProdutosFiltrados();
    
    return Scaffold(
      drawer: const CustomDrawer(),
      
      body: NestedScrollView(
        
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              title: const Text(
                'Cardápio',
                style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
              ),
              expandedHeight: 120,
              floating: true,
              pinned: true,
              snap: false,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.orange[900]!,
                        Colors.orange[800]!,
                      ],
                    ),
                  ),
                ),
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(60),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    onChanged: (value) => setState(() => _searchQuery = value),
                    decoration: InputDecoration(
                      hintText: 'Buscar produtos...',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () => setState(() => _searchQuery = ''),
                            )
                          : null,
                    ),
                  ),
                ),
              ),
            ),
          ];
        },
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    tabs: categorias.keys
                        .map((category) => Tab(text: category))
                        .toList(),
                    labelColor: Colors.orange[900],
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: Colors.orange[900],
                  ),
                  Expanded(
                    child: _searchQuery.isNotEmpty
                        ? ListView.builder(
                            itemCount: produtosFiltrados.length,
                            itemBuilder: (context, index) {
                              return _buildProdutoCard(produtosFiltrados[index]);
                            },
                          )
                        : TabBarView(
                            controller: _tabController,
                            children: categorias.keys.map((category) {
                              final produtos =
                                  _produtosPorCategoria[category] ?? [];
                              return ListView.builder(
                                itemCount: produtos.length,
                                itemBuilder: (context, index) {
                                  return _buildProdutoCard(produtos[index]);
                                },
                              );
                            }).toList(),
                          ),
                  ),
                ],
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _carregarProdutos,
        backgroundColor: Colors.orange[900],
        child: const Icon(Icons.refresh),
      ),
    );
  }
}