import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_praticas/pages/adicionar_produtos_page.dart';
import 'package:flutter_application_praticas/pages/finalizar_mesa_page.dart';
import '../services/pedido_service.dart';
import 'package:firebase_core/firebase_core.dart';
import '../firebase_options.dart';

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
  bool isPedidoFinalizado = false;
  List<Map<String, dynamic>> allProducts = [];
  double totalAllOrders = 0.0;

  @override
  void initState() {
    super.initState();
    _initializeFirebase();
  }

  Future<void> _initializeFirebase() async {
    try {
      if (!Firebase.apps.isNotEmpty) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      }
      await _carregarDadosMesa(); // Changed from _safeLoadMesaData to _carregarDadosMesa
    } catch (e) {
      print('Erro na inicialização do Firebase: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro na conexão com o banco de dados: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _carregarDadosMesa() async {
    if (!mounted) return;
    
    setState(() => isLoading = true);
    
    try {
       await Firebase.initializeApp();
      // Get mesa data
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('Mesas')
          .doc(widget.mesaId)
          .get();

      if (!doc.exists) {
        throw Exception('Mesa não encontrada');
      }

      // Get active orders
      QuerySnapshot pedidosSnapshot = await FirebaseFirestore.instance
          .collection('Pedidos')
          .where('mesa', isEqualTo: doc.reference)
          .where('finalizado', isEqualTo: false)
          .get();

      if (mounted) {
        setState(() {
          isOcupada = pedidosSnapshot.docs.isNotEmpty || doc['status'] == true;
          _numMesa = doc['numMesa'];
          mesaRef = doc.reference;
        });
      }

      await _carregarTodosPedidos();

    } catch (e) {
      if (mounted) {
        _mostrarErro('Erro ao carregar dados da mesa: $e');
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
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
    try {
        // Cria o pedido e obtém o ID
        String pedidoId = await _criarPedido();
        
        if (mounted) {  // Verifica se o widget ainda está montado
            final result = await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => TelaAdicionarProdutosPedido(
                        pedidoId: pedidoId,
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
    } catch (e) {
        if (mounted) {  // Verifica se o widget ainda está montado
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text('Erro ao criar pedido: $e'),
                    backgroundColor: Colors.red,
                ),
            );
        }
    }
}
  
  void _handleError(String message, {bool showSnackBar = true}) {
    print(message); // Log para console
    
    if (showSnackBar && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }


  Future<String> _criarPedido() async {
    // Primeiro, garante que temos a referência correta da mesa
    var querySnapshot = await FirebaseFirestore.instance
        .collection('Mesas')
        .doc(widget.mesaId)  // Usa o ID da mesa diretamente
        .get();

    if (querySnapshot.exists) {
        mesaRef = querySnapshot.reference;
    } else {
        throw Exception('Mesa não encontrada');
    }

    // Cria o pedido com a referência correta da mesa
    DocumentReference novoPedidoRef = await FirebaseFirestore.instance.collection('Pedidos').add({
        'mesa': mesaRef,
        'dataCriacao': FieldValue.serverTimestamp(),
        'finalizado': false,
        'listaProdutos': [],
        'valorTotal': 0.0,
    });
    
    return novoPedidoRef.id;
}

  Future<void> _carregarTodosPedidos() async {
    try {
      await Firebase.initializeApp();
      QuerySnapshot pedidosSnapshot = await FirebaseFirestore.instance
          .collection('Pedidos')
          .where('mesa', isEqualTo: mesaRef)
          .get();

      List<Map<String, dynamic>> todosProdutos = [];
      Map<String, int> produtoQuantidades = {};
      Map<String, double> produtoPrecos = {};
      double total = 0.0;

      for (var pedidoDoc in pedidosSnapshot.docs) {
        Map<String, dynamic> pedido = pedidoDoc.data() as Map<String, dynamic>;
        List<DocumentReference> produtosRefs = List<DocumentReference>.from(pedido['listaProdutos'] ?? []);

        for (var produtoRef in produtosRefs) {
          DocumentSnapshot produtoDoc = await produtoRef.get();
          if (produtoDoc.exists) {
            Map<String, dynamic> produtoData = produtoDoc.data() as Map<String, dynamic>;
            String produtoId = produtoDoc.id;
            String nome = produtoData['nome'] ?? 'Produto desconhecido';
            double preco = produtoData['valor']?.toDouble() ?? 0.0;
            String imagemUrl = produtoData['imagem'] ?? '';

            // Atualizar contagem e preço
            produtoQuantidades[produtoId] = (produtoQuantidades[produtoId] ?? 0) + 1;
            produtoPrecos[produtoId] = preco;

            // Adicionar produto se ainda não existe na lista
            if (!todosProdutos.any((p) => p['id'] == produtoId)) {
              todosProdutos.add({
                'id': produtoId,
                'nome': nome,
                'preco': preco,
                'imagem': imagemUrl,
              });
            }

            total += preco;
          }
        }
      }

      // Adicionar quantidades aos produtos
      for (var produto in todosProdutos) {
        String produtoId = produto['id'];
        produto['qtd'] = produtoQuantidades[produtoId] ?? 0;
        produto['subtotal'] = (produtoQuantidades[produtoId] ?? 0) * (produtoPrecos[produtoId] ?? 0.0);
      }

      setState(() {
        allProducts = todosProdutos;
        totalAllOrders = total;
      });

    } catch (e) {
      print('Erro ao carregar todos os pedidos: $e');
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
      if (!novoStatus) {
        QuerySnapshot pedidosSnapshot = await FirebaseFirestore.instance
            .collection('Pedidos')
            .where('mesa', isEqualTo: mesaRef)
            .where('finalizado', isEqualTo: false) 
            .get();

        if (pedidosSnapshot.docs.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Não é possível liberar a mesa com pedidos em aberto'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
      }

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
  return DefaultTabController(
    length: 2,
    child: Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
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
        bottom: const TabBar(
          tabs: [
            Tab(
              icon: Icon(Icons.restaurant_menu, color: Colors.white),
              text: "Produtos",
            ),
            Tab(
              icon: Icon(Icons.receipt_long, color: Colors.white),
              text: "Pedidos",
            ),
          ],
          labelStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          unselectedLabelStyle: TextStyle(color: Colors.white),
        ),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: TabBarView(
                    children: [
                      _buildProdutosList(),
                      _buildPedidosList(),
                    ],
                  ),
                ),
              ],
            ),
      bottomNavigationBar: _buildBottomActions(),
    ),
  );
}

  Widget _buildPedidosList() {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance
          .collection('Pedidos')
          .where('mesa', isEqualTo: mesaRef)
          .where('finalizado', isEqualTo: false)
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.receipt, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'Nenhum pedido em andamento',
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

        List<DocumentSnapshot> pedidos = snapshot.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: pedidos.length,
          itemBuilder: (context, index) {
            final pedido = pedidos[index].data() as Map<String, dynamic>;
            final pedidoId = pedidos[index].id;
            final bool isFinalizado = pedido['finalizado'] ?? false;
            final List<dynamic> listaProdutos = pedido['listaProdutos'] ?? [];
            
            return Card(
              elevation: 2,
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: InkWell( // Added InkWell for tap handling
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TelaAdicionarProdutosPedido(
                        pedidoId: pedidoId,
                        mesaReference: mesaRef,
                      ),
                    ),
                  ).then((result) {
                    if (result == true) {
                      setState(() {
                        _carregarDadosMesa();
                      });
                    }
                  });
                },
                child: ExpansionTile(
                  title: Row(
                    children: [
                      Text(
                        'Pedido ${index + 1}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        isFinalizado ? Icons.check_circle : Icons.pending,
                        color: isFinalizado ? Colors.green : Colors.orange,
                        size: 20,
                      ),
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Status: Em andamento',
                        style: TextStyle(
                          color: Colors.orange,
                        ),
                      ),
                      Text(
                        'Total: R\$ ${pedido['valorTotal']?.toStringAsFixed(2) ?? "0.00"}',
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        'Toque para editar',
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                  children: [
                    FutureBuilder<List<Widget>>(
                      future: _buildProdutosPedido(listaProdutos),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        return Column(children: snapshot.data ?? []);
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
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

  Future<List<Widget>> _buildProdutosPedido(List<dynamic> produtosRefs) async {
    List<Widget> produtosWidgets = [];
    
    for (var produtoRef in produtosRefs) {
      if (produtoRef is DocumentReference) {
        try {
          DocumentSnapshot produtoDoc = await produtoRef.get();
          if (produtoDoc.exists) {
            Map<String, dynamic> produtoData = produtoDoc.data() as Map<String, dynamic>;
            
            produtosWidgets.add(
              ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    produtoData['imagem'] ?? '',
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 40,
                      height: 40,
                      color: Colors.grey[200],
                      child: const Icon(Icons.error),
                    ),
                  ),
                ),
                title: Text(
                  produtoData['nome'] ?? 'Produto desconhecido',
                  style: const TextStyle(fontSize: 14),
                ),
                trailing: Text(
                  'R\$ ${produtoData['valor']?.toStringAsFixed(2) ?? "0.00"}',
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            );
          }
        } catch (e) {
          print('Erro ao carregar produto: $e');
        }
      }
    }
    
    return produtosWidgets;
  }

   Widget _buildProdutosList() {
    if (allProducts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.restaurant_menu, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Nenhum produto consumido nesta mesa',
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
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.orange[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Consumido',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'R\$ ${totalAllOrders.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange[900],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: allProducts.length,
            itemBuilder: (context, index) {
              final produto = allProducts[index];
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
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Preço unitário: R\$ ${produto['preco'].toStringAsFixed(2)}',
                        style: TextStyle(
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        'Subtotal: R\$ ${produto['subtotal'].toStringAsFixed(2)}',
                        style: TextStyle(
                          color: Colors.green[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
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
              icon: const Icon(Icons.add_shopping_cart, color: Colors.white),
              label: const Text('Criar pedido', style: TextStyle(color: Colors.white)),
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
          if (allProducts.isNotEmpty) ...[
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.payment, color: Colors.white),
                label: const Text('Finalizar Mesa', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () async {
                  // Get the current active pedido
                  Map<String, dynamic>? pedido =
                      await PedidoService().buscarPedidoPorMesa(mesaRef!);
                  String? currentPedidoId = pedido?['id'].toString();

                  if (currentPedidoId != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FinalizarMesaPage(
                          pedidoId: currentPedidoId,
                          mesaId: widget.mesaId,
                        ),
                      ),
                    ).then((value) {
                      if (value == true) {
                        _carregarDadosMesa(); // Reload data after finalizing
                      }
                    });
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Não foi possível encontrar o pedido atual'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}