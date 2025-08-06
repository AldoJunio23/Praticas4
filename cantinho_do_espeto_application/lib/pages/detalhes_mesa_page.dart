import 'package:flutter/material.dart';
import 'package:flutter_application_praticas/pages/adicionar_produtos_page.dart';
import 'package:flutter_application_praticas/pages/finalizar_mesa_page.dart';
import '../services/pedido_service.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class TelaDetalhesMesas extends StatefulWidget {
  final String mesaId;

  const TelaDetalhesMesas({super.key, required this.mesaId});

  @override
  TelaDetalhesMesasState createState() => TelaDetalhesMesasState();
}

class TelaDetalhesMesasState extends State<TelaDetalhesMesas> {
  // URL base da API - ajuste conforme necessário
  static const String baseUrl = 'http://localhost:3000';
  
  bool isOcupada = false;
  int? _numMesa;
  List<Map<String, dynamic>> produtos = [];
  String? pedidoID;
  String? mesaRef;
  bool isLoading = true;
  double totalComanda = 0.0;
  bool isPedidoFinalizado = false;
  List<Map<String, dynamic>> allProducts = [];
  double totalAllOrders = 0.0;

  @override
  void initState() {
    super.initState();
    _carregarDadosMesa();
  }

  // Método para fazer requisições HTTP com tratamento de erro
  Future<http.Response> _makeRequest(String method, String endpoint, {Map<String, dynamic>? body}) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final headers = {'Content-Type': 'application/json'};
    
    try {
      switch (method.toUpperCase()) {
        case 'GET':
          return await http.get(url, headers: headers);
        case 'POST':
          return await http.post(url, headers: headers, body: jsonEncode(body ?? {}));
        case 'PUT':
          return await http.put(url, headers: headers, body: jsonEncode(body ?? {}));
        case 'DELETE':
          return await http.delete(url, headers: headers);
        default:
          throw Exception('Método HTTP não suportado: $method');
      }
    } catch (e) {
      throw Exception('Erro na conexão com a API: $e');
    }
  }

  Future<void> _carregarDadosMesa() async {
    if (!mounted) return;
    
    setState(() => isLoading = true);
    
    try {
      // Carregar dados da mesa
      final mesaResponse = await _makeRequest('GET', '/mesa/${widget.mesaId}');
      
      if (mesaResponse.statusCode == 200) {
        final mesaData = jsonDecode(mesaResponse.body);
        
        // Carregar pedidos ativos
        final pedidosResponse = await _makeRequest('GET', '/mesa/${widget.mesaId}/pedidos-ativos');
        List<dynamic> pedidosAtivos = [];
        
        if (pedidosResponse.statusCode == 200) {
          pedidosAtivos = jsonDecode(pedidosResponse.body);
        }

        if (mounted) {
          setState(() {
            isOcupada = pedidosAtivos.isNotEmpty || mesaData['status'] == true;
            _numMesa = mesaData['numMesa'];
            mesaRef = widget.mesaId;
          });
        }

        await _carregarTodosPedidos();
      } else {
        throw Exception('Mesa não encontrada');
      }

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
      final response = await _makeRequest('PUT', '/pedido/$pedidoId/finalizar');
      
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pedido finalizado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        _carregarDadosMesa();
      } else {
        throw Exception('Erro ao finalizar pedido');
      }
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
      
      if (mounted) {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TelaAdicionarProdutosPedido(
              pedidoId: pedidoId,
              mesaReference: null, // Não precisamos mais da referência do Firestore
            ),
          ),
        );

        if (result == true) {
          _carregarDadosMesa();
        }
      }
    } catch (e) {
      if (mounted) {
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
    print(message);
    
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
    try {
      final response = await _makeRequest('POST', '/pedido', body: {
        'mesaId': widget.mesaId,
      });

      if (response.statusCode == 200) {
        final pedidoData = jsonDecode(response.body);
        return pedidoData['id'];
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Erro ao criar pedido');
      }
    } catch (e) {
      throw Exception('Erro ao criar pedido: $e');
    }
  }

  Future<void> _carregarTodosPedidos() async {
    try {
      final response = await _makeRequest('GET', '/mesa/${widget.mesaId}/produtos-consumidos');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        setState(() {
          allProducts = List<Map<String, dynamic>>.from(data['produtos'] ?? []);
          totalAllOrders = (data['total'] ?? 0.0).toDouble();
        });
      }
    } catch (e) {
      print('Erro ao carregar todos os pedidos: $e');
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
      final response = await _makeRequest('PUT', '/mesa/${widget.mesaId}/status', body: {
        'status': novoStatus,
      });

      if (response.statusCode == 200) {
        setState(() => isOcupada = novoStatus);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(novoStatus ? 'Mesa ocupada' : 'Mesa liberada'),
            backgroundColor: novoStatus ? Colors.orange : Colors.green,
          ),
        );
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Erro ao atualizar status');
      }
    } catch (e) {
      _mostrarErro('Erro ao atualizar status da mesa: $e');
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
    return FutureBuilder<List<dynamic>>(
      future: _carregarPedidosAtivos(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
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

        List<dynamic> pedidos = snapshot.data!;

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: pedidos.length,
          itemBuilder: (context, index) {
            final pedido = pedidos[index];
            final pedidoId = pedido['id'];
            final bool isFinalizado = pedido['finalizado'] ?? false;
            final List<dynamic> produtos = pedido['produtos'] ?? [];
            
            return Card(
              elevation: 2,
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TelaAdicionarProdutosPedido(
                        pedidoId: pedidoId,
                        mesaReference: null,
                      ),
                    ),
                  ).then((result) {
                    if (result == true) {
                      _carregarDadosMesa();
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
                    ...produtos.map<Widget>((produto) => ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          produto['imagem'] ?? '',
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
                        produto['nome'] ?? 'Produto desconhecido',
                        style: const TextStyle(fontSize: 14),
                      ),
                      trailing: Text(
                        'R\$ ${produto['valor']?.toStringAsFixed(2) ?? "0.00"}',
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    )).toList(),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<List<dynamic>> _carregarPedidosAtivos() async {
    try {
      final response = await _makeRequest('GET', '/mesa/${widget.mesaId}/todos-pedidos');
      
      if (response.statusCode == 200) {
        final pedidos = jsonDecode(response.body) as List<dynamic>;
        return pedidos.where((pedido) => pedido['finalizado'] == false).toList();
      }
      
      return [];
    } catch (e) {
      print('Erro ao carregar pedidos ativos: $e');
      return [];
    }
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
                      produto['imagem'] ?? '',
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
                    produto['nome'] ?? 'Produto desconhecido',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Preço unitário: R\$ ${produto['preco']?.toStringAsFixed(2) ?? "0.00"}',
                        style: TextStyle(
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        'Subtotal: R\$ ${produto['subtotal']?.toStringAsFixed(2) ?? "0.00"}',
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
                      'x${produto['qtd'] ?? 0}',
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
                  try {
                    // Buscar pedido ativo da mesa via API
                    final response = await _makeRequest('GET', '/mesa/${widget.mesaId}/pedido-ativo');
                    
                    if (response.statusCode == 200) {
                      final pedido = jsonDecode(response.body);
                      final currentPedidoId = pedido['id'];

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
                          _carregarDadosMesa();
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
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Erro ao buscar pedido: $e'),
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