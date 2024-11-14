import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_praticas/pages/adicionar_produtos_page.dart';
import 'package:flutter_application_praticas/pages/finalizar_comanda_page.dart';
import '../services/pedido_service.dart';

class TelaDetalhesMesas extends StatefulWidget {
  final String mesaId;

  const TelaDetalhesMesas({super.key, required this.mesaId});

  @override
  TelaDetalhesMesasState createState() => TelaDetalhesMesasState();
}

class TelaDetalhesMesasState extends State<TelaDetalhesMesas> {
  bool isOcupada = false;
  int? _numMesa;
  List<Map<String, dynamic>> produtos = [];
  String? pedidoID;
  DocumentReference? mesaRef;
  bool isLoading = true;
  double totalComanda = 0.0;

  @override
  void initState() {
    super.initState();
    _carregarDadosMesa();
  }

  Future<void> _finalizarPedido(String pedidoId, BuildContext context) async {
    try {
      await PedidoService().finalizarPedido(pedidoId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pedido finalizado com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao finalizar pedido: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _navigateToNextPage() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TelaAdicionarProdutosPedido(
          pedidoId: pedidoID,
          mesaReference: mesaRef,
        ),
      ),
    );

    if (result == true) {
      setState(() {
        _carregarDadosMesa();
      });
    }
  }

  Future<void> _carregarDadosMesa() async {
    setState(() => isLoading = true);
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('Mesas')
          .doc(widget.mesaId)
          .get();

      if (doc.exists) {
        setState(() {
          isOcupada = doc['status'] ?? false;
          _numMesa = doc['numMesa'];
        });

        mesaRef = doc.reference;
        Map<String, dynamic>? pedido =
            await PedidoService().buscarPedidoPorMesa(mesaRef!);
        pedidoID = pedido?['id'].toString();

        if (pedido != null) {
          List<DocumentReference<Object?>> listaProdutosRefs =
              List<DocumentReference<Object?>>.from(pedido['listaProdutos']);
          await _carregarProdutos(listaProdutosRefs);
        }
      }
    } catch (e) {
      _mostrarErro('Erro ao carregar dados da mesa: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

 Future<void> _carregarProdutos(
  List<DocumentReference<Object?>> produtosRefs) async {
    try {
      List<Map<String, dynamic>> produtosTemp = [];
      double novoTotalComanda = 0.0;
      for (DocumentReference<Object?> produtoRef in produtosRefs) {
        DocumentSnapshot produtoDoc = await produtoRef.get();
        if (produtoDoc.exists) {
          Map<String, dynamic>? produtoData =
              produtoDoc.data() as Map<String, dynamic>?;
          String nome = produtoData?['nome'] ?? 'Produto desconhecido';
          String imagemUrl = produtoData?['imagem'] ?? '';
          double preco = produtoData?['valor'] ?? 0.0;
          int qtd = 1;

          // Verifica se o produto já foi adicionado, caso positivo incrementa a quantidade
          bool jaAdicionado = false;
          for (var produto in produtosTemp) {
            if (produto['nome'] == nome) {
              produto['qtd'] += 1;
              jaAdicionado = true;
            }
          }
          if (!jaAdicionado) {
            produtosTemp.add({'nome': nome, 'imagem': imagemUrl, 'preco': preco, 'qtd': qtd});
          }

          // Calcula o subtotal e acumula no total da comanda
          novoTotalComanda += preco * qtd;
        }
      }

      setState(() {
        produtos = produtosTemp;
        totalComanda = novoTotalComanda;
      });
    } catch (e) {
      print('Erro ao carregar produtos: $e');
    }
  }


  void _mostrarErro(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        backgroundColor: Colors.red,
        
      ),
    );
  }

  

  Future<void> _alterarStatusMesa(bool novoStatus) async {
    try {
      await FirebaseFirestore.instance
          .collection('Mesas')
          .doc(widget.mesaId)
          .update({'status': novoStatus});
      
      setState(() => isOcupada = novoStatus);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(novoStatus ? 'Mesa ocupada' : 'Mesa liberada'),
          backgroundColor: novoStatus ? Colors.orange : Colors.green,
        ),
      );
    } catch (e) {
      _mostrarErro('Erro ao atualizar status da mesa');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.orange[900]!, Colors.orange[700]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Row(
          children: [
            Icon(
              isOcupada ? Icons.table_bar : Icons.table_restaurant,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Text(
              _numMesa != null ? 'Mesa $_numMesa' : 'Carregando...',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _carregarDadosMesa,
          ),
        ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
              ),
            )
          : Column(
              children: [
                _buildStatusCard(),
                Expanded(
                  child: _buildProdutosList(),
                ),
                _buildBottomActions(),
              ],
            ),
    );
  }

  Widget _buildStatusCard() {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isOcupada
                ? [Colors.orange[100]!, Colors.orange[50]!]
                : [Colors.green[100]!, Colors.green[50]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              'Status da Mesa',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isOcupada ? Colors.orange[900] : Colors.green[900],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildStatusButton(
                  'Ocupada',
                  true,
                  Icons.people,
                  Colors.orange,
                ),
                const SizedBox(width: 16),
                _buildStatusButton(
                  'Livre',
                  false,
                  Icons.check_circle,
                  Colors.green,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusButton(
      String label, bool status, IconData icon, MaterialColor color) {
    bool isSelected = isOcupada == status;
    return ElevatedButton.icon(
      icon: Icon(
        icon,
        color: isSelected ? Colors.white : color[900],
      ),
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : color[900],
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? color : Colors.white,
        foregroundColor: isSelected ? Colors.white : color,
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 12,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: color),
        ),
      ),
      onPressed: () => _alterarStatusMesa(status),
    );
  }

  Widget _buildProdutosList() {
    if (produtos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.restaurant_menu, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Nenhum produto adicionado',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Produtos',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Total: R\$ ${totalComanda.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: produtos.length,
            itemBuilder: (context, index) {
              final produto = produtos[index];
              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(8),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      produto['imagem'],
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 60,
                        height: 60,
                        color: Colors.grey[200],
                        child: const Icon(Icons.error),
                      ),
                    ),
                  ),
                  title: Text(
                    produto['nome'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Text(
                    'R\$ ${(produto['preco'] * produto['qtd']).toStringAsFixed(2)}',
                    style: TextStyle(
                      color: Colors.green[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.orange[100],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'x${produto['qtd']}',
                      style: TextStyle(
                        color: Colors.orange[900],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              icon: const Icon(Icons.add_shopping_cart, color: Colors.white,),
              label: const Text('Adicionar Produtos', style: TextStyle(color: Colors.white),),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange[900],
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: _navigateToNextPage,
            ),
          ),
          if (produtos.isNotEmpty) ...[
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.payment, color:  Colors.white,),
                label: const Text('Finalizar Comanda', style: TextStyle(color: Colors.white),),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          FinalizarComandaPage(pedidoId: pedidoID),
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}