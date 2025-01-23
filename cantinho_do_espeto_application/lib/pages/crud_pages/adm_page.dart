import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_praticas/components/custom_drawer.dart';
import 'package:flutter_application_praticas/pages/crud_pages/alterar_page.dart';
import 'package:flutter_application_praticas/pages/crud_pages/criar_page.dart';
import 'package:intl/intl.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'Todas';
  final bool _showOnlyAvailable = false;
  String _searchQuery = '';

  final List<String> _categories = [
    'Todas',
    'Bebidas',
    'Espetos',
    'Porções',
    'Caldos',
    'Adicionais'
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<List<Map<String, dynamic>>> _getAllProdutos() async {
    List<Map<String, dynamic>> allProdutos = [];
    final collectionNames = ['prod-bebida', 'prod-espetos', 'prod-porcoes', 'prod-caldo', 'prod-adicional'];
    final docNames = ['PoDiOnHmAULfo04IFIZy', 'r68ahS3Ck96LGZEVzZma', 'QftnnSomGsxfDhSmkhDQ', 'EI0XR8FLCNQJXJ0EbzHL', 'FFgYAgy1ACxpqOPfekEi'];

    for (int i = 0; i < collectionNames.length; i++) {
      QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore
          .collection("Produto")
          .doc(docNames[i])
          .collection(collectionNames[i])
          .get();

      for (var doc in snapshot.docs) {
        allProdutos.add({
          'id': doc.id,
          'docName': docNames[i],
          'collectionName': collectionNames[i],
          ...doc.data(),
        });
      }
    }

    // Aplicar filtros
    return allProdutos.where((produto) {
      bool matchesSearch = produto['nome'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
      bool matchesCategory = _selectedCategory == 'Todas' || 
        _getCategoryName(produto['collectionName']) == _selectedCategory;
      bool matchesAvailability = !_showOnlyAvailable || produto['disponivel'] == true;
      
      return matchesSearch && matchesCategory && matchesAvailability;
    }).toList();
  }

  String _getCategoryName(String collectionName) {
    switch (collectionName) {
      case 'prod-bebida': return 'Bebidas';
      case 'prod-espetos': return 'Espetos';
      case 'prod-porcoes': return 'Porções';
      case 'prod-caldo': return 'Caldos';
      case 'prod-adicional': return 'Adicionais';
      default: return '';
    }
  }

  void _deletarProduto(Map<String, dynamic> produto) async {
    bool confirm = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar exclusão'),
          content: Text('Deseja realmente excluir ${produto['nome']}?'),
          actions: [
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: const Text('Excluir'),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );

    if (confirm) {
      await _firestore
          .collection('Produto')
          .doc(produto['docName'])
          .collection(produto['collectionName'])
          .doc(produto['id'])
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Produto excluído com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );

      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const CustomDrawer(),
      appBar: _buildAppBar(),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: _adicionarProduto,
        backgroundColor: Colors.orange[900],
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
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
        ),
      ),
      title: const Text(
        'Gerenciar Produtos',
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
            onPressed: () => Scaffold.of(context).openDrawer(),
            tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
          );
        },
      ),
    );
  }

  Widget _buildBody() {
    return Column(
      children: [
        _buildSearchBar(),
        _buildFilters(),
        Expanded(child: _buildProdutoGrid()),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Pesquisar produtos...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          filled: true,
          fillColor: Colors.grey[200],
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
      ),
    );
  }

  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _categories.map((category) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: FilterChip(
                    label: Text(category),
                    selected: _selectedCategory == category,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                    selectedColor: Colors.orange[200],
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildProdutoGrid() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _getAllProdutos(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 60, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  "Erro ao carregar produtos\n${snapshot.error}",
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text(
              "Nenhum produto encontrado",
              style: TextStyle(fontSize: 18),
            ),
          );
        }

        final produtos = snapshot.data!;
        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.7,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: produtos.length,
          itemBuilder: (context, index) => _buildProdutoCard(produtos[index]),
        );
      },
    );
  }

  Widget _buildProdutoCard(Map<String, dynamic> produto) {
    final nome = produto['nome'];
    final valor = double.parse(produto['valor'].toString());
    final disponivel = produto['disponivel'];
    final imagem = produto['imagem'].toString();
    String valorFormatado = NumberFormat("#,##0.00", "pt_BR").format(valor);
    final categoria = _getCategoryName(produto['collectionName']);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildDisponibilidadeLabel(disponivel),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      imagem,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const Center(child: CircularProgressIndicator());
                      },
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.error),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    nome,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    categoria,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    "R\$ $valorFormatado",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
          ),
          _buildActionButtons(produto),
        ],
      ),
    );
  }

  Widget _buildActionButtons(Map<String, dynamic> produto) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            icon: const Icon(Icons.edit),
            color: Colors.blue,
            onPressed: () => _editarProduto(produto),
          ),
          Container(
            width: 1,
            height: 24,
            color: Colors.grey[400],
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            color: Colors.red,
            onPressed: () => _deletarProduto(produto),
          ),
        ],
      ),
    );
  }

  Widget _buildDisponibilidadeLabel(bool disponivel) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: disponivel ? Colors.green : Colors.red,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Text(
        disponivel ? "Disponível" : "Indisponível",
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  void _editarProduto(Map<String, dynamic> produto) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AlterarProduto(
          idProduto: produto['id'],
          docName: produto['docName'],
          subCategoria: produto['collectionName'],
        ),
      ),
    );
  }

  void _adicionarProduto() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CriarProduto(),
      ),
    );
  }
}