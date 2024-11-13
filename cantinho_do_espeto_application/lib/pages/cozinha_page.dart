import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_praticas/components/custom_drawer.dart';
import 'package:flutter_application_praticas/services/pedido_service.dart';

class CozinhaPage extends StatefulWidget {
  const CozinhaPage({super.key});

  @override
  State<CozinhaPage> createState() => _CozinhaPageState();
}

class _CozinhaPageState extends State<CozinhaPage> {
  // Modificando a stream para uma consulta mais simples inicialmente
  late Stream<QuerySnapshot> _pedidosStream;

  @override
  void initState() {
    super.initState();
    _pedidosStream = FirebaseFirestore.instance
        .collection('Pedidos')
        .snapshots();
  }

  Future<void> _finalizarPedido(String pedidoId, BuildContext context) async {
    try {
      await PedidoService().finalizarPedido(pedidoId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pedido finalizado com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao finalizar pedido: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const CustomDrawer(),
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(60.0),
      child: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.orange[900]!,
                Colors.orange[800]!,
              ],
            ),
            border: const Border(
              bottom: BorderSide(color: Colors.white, width: 1),
            ),
          ),
        ),
        title: const Text(
          'Cozinha',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
            tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    return StreamBuilder<QuerySnapshot>(
      stream: _pedidosStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Erro ao carregar pedidos: ${snapshot.error}',
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text(
              'Nenhum pedido pendente',
              style: TextStyle(fontSize: 18),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final pedido = snapshot.data!.docs[index].data() as Map<String, dynamic>;
            final List<dynamic> produtosRefs = pedido['listaProdutos'] ?? [];
            
            if (produtosRefs.isEmpty) {
              return const SizedBox.shrink();
            }

            return _buildPedidoCard(pedido, snapshot.data!.docs[index].id);
            
          },
        );
      },
    );
  }

  Widget _buildPedidoCard(Map<String, dynamic> pedido, String pedidoId) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMesaInfo(pedido['mesa']),
            const Divider(height: 24),
            _buildProdutosList(pedido['listaProdutos']),
            const SizedBox(height: 16),
            _buildFinalizarButton(pedidoId),
          ],
        ),
      ),
    );
  }

  Widget _buildMesaInfo(dynamic mesaRef) {
    return FutureBuilder<String>(
      future: _carregarNomeMesa(mesaRef),
      builder: (context, snapshot) {
        return Row(
          children: [
            const Icon(Icons.table_restaurant, size: 24),
            const SizedBox(width: 8),
            Text(
              snapshot.data ?? 'Carregando mesa...',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildProdutosList(List<dynamic> produtosRefs) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _carregarProdutos(List<DocumentReference>.from(produtosRefs)),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Text('Nenhum produto encontrado');
        }

        return SizedBox(
          height: 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) => _buildProdutoCard(snapshot.data![index]),
          ),
        );
      },
    );
  }

  Widget _buildProdutoCard(Map<String, dynamic> produto) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            child: Image.network(
              produto['imagem']!,
              height: 120,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.error_outline,
                size: 60,
                color: Colors.red,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                Text(
                  produto['nome'].toString(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange[900],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'x${produto['qtd']}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinalizarButton(String pedidoId) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => _finalizarPedido(pedidoId, context),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: const Text(
          'Finalizar Pedido',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Future<String> _carregarNomeMesa(dynamic mesaRef) async {
    if (mesaRef is DocumentReference) {
      try {
        DocumentSnapshot mesaDoc = await mesaRef.get();
        Map<String, dynamic>? mesaData = mesaDoc.data() as Map<String, dynamic>?;
        return 'Mesa ${mesaData?['numMesa'] ?? 'sem número'}';
      } catch (e) {
        return 'Erro ao carregar mesa';
      }
    }
    return mesaRef?.toString() ?? 'Mesa desconhecida';
  }

  Future<List<Map<String, dynamic>>> _carregarProdutos(
    List<DocumentReference> produtosRefs,
  ) async {
    List<Map<String, dynamic>> produtos = [];
    Map<String, int> produtosContagem = {};

    for (var ref in produtosRefs) {
      try {
        DocumentSnapshot produtoDoc = await ref.get();
        if (produtoDoc.exists) {
          Map<String, dynamic>? produtoData = 
              produtoDoc.data() as Map<String, dynamic>?;
          String nome = produtoData?['nome'] ?? 'Produto desconhecido';
          
          produtosContagem[nome] = (produtosContagem[nome] ?? 0) + 1;
          
          if (!produtos.any((p) => p['nome'] == nome)) {
            produtos.add({
              'nome': nome,
              'imagem': produtoData?['imagem'] ?? '',
              'qtd': produtosContagem[nome],
            });
          } else {
            var produto = produtos.firstWhere((p) => p['nome'] == nome);
            produto['qtd'] = produtosContagem[nome];
          }
        }
      } catch (e) {
        // Skip invalid products
        continue;
      }
    }
    return produtos;
  }

  
}