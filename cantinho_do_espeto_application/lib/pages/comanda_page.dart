import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_praticas/components/custom_drawer.dart';
import 'package:flutter_application_praticas/pages/adicionar_produtos_page.dart';

class ComandaPage extends StatefulWidget {
  const ComandaPage({super.key});

  @override
  State<StatefulWidget> createState() => _CriarPedidosState();
}

class _CriarPedidosState extends State<ComandaPage> {
  String? mesaSelecionada;
  List<String> todasMesas = [];
  bool isLoading = true;
  DocumentReference? mesaReference;
  List<DocumentSnapshot>? pedidos;

  @override
  void initState() {
    super.initState();
    _obterMesas();
  }

  // Mantendo os métodos existentes inalterados...
  Future<void> _obterMesas() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('Mesas').get();
      List<String> nomes = await _carregarNomesMesas(snapshot.docs.map((doc) => doc.reference).toList());

      setState(() {
        todasMesas = nomes;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        todasMesas = ['Erro ao carregar mesas'];
        isLoading = false;
      });
    }
  }

  Future<List<String>> _carregarNomesMesas(List<DocumentReference> mesasRefs) async {
    List<String> nomesMesas = [];
    for (var mesaRef in mesasRefs) {
      DocumentSnapshot mesaDoc = await mesaRef.get();
      var mesaData = mesaDoc.data() as Map<String, dynamic>?;
      nomesMesas.add('${mesaData?['numMesa'] ?? '0'}');
    }
    return nomesMesas;
  }

  Future<String> _criarPedido() async {
    var querySnapshot = await FirebaseFirestore.instance
        .collection('Mesas')
        .where('numMesa', isEqualTo: int.parse(mesaSelecionada!))
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      mesaReference = querySnapshot.docs.first.reference;
    } else {
      print('Documento não encontrado');
    }

    DocumentReference novoPedidoRef = await FirebaseFirestore.instance.collection('Pedidos').add({
      'mesa': mesaReference,
      'dataCriacao': FieldValue.serverTimestamp(),
      'finalizado': false,
      'listaProdutos': [],
      'valorTotal': 0.0,
    });
    return novoPedidoRef.id;
  }

  Future<void> _listarPedidosDaMesa() async {
    if (mesaSelecionada != null) {
      var querySnapshot = await FirebaseFirestore.instance
          .collection('Mesas')
          .where('numMesa', isEqualTo: int.parse(mesaSelecionada!))
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        mesaReference = querySnapshot.docs.first.reference;
      }

      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('Pedidos')
          .where('mesa', isEqualTo: mesaReference)
          .get();

      setState(() {
        pedidos = snapshot.docs;
      });
    }
  }

  Future<List<Map<String, dynamic>>> _obterListaProdutos(List<DocumentReference> listaProdutosRefs) async {
    List<Map<String, dynamic>> produtos = [];
    for (var produtoRef in listaProdutosRefs) {
      DocumentSnapshot produtoSnapshot = await produtoRef.get();
      produtos.add(produtoSnapshot.data() as Map<String, dynamic>);
    }
    return produtos;
  }

  Widget _buildProdutoCard(Map<String, dynamic> produto) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(
          produto['nome'],
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          'R\$ ${produto['valor']?.toStringAsFixed(2) ?? '0.00'}',
          style: TextStyle(
            color: Colors.orange[900],
            fontWeight: FontWeight.bold,
          ),
        ),
        trailing: IconButton(
          icon: Icon(Icons.edit, color: Colors.orange[900]),
          onPressed: () {
            // Implementar ação de edição
          },
        ),
      ),
    );
  }

  Widget _buildPedidoCard(Map<String, dynamic> pedido, List<Map<String, dynamic>> produtos) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Valor Total:',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[700],
                  ),
                ),
                Text(
                  'R\$ ${pedido['valorTotal'].toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange[900],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            const Text(
              'Produtos:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ...produtos.map((produto) => _buildProdutoCard(produto)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const CustomDrawer(),
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          'Comandas',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        flexibleSpace: Container(
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
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white, size: 28),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: Colors.orange[900],
              ),
            )
          : Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            const Text(
                              'Selecione uma mesa',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey[300]!),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  hint: const Text('Escolha uma mesa'),
                                  value: mesaSelecionada,
                                  isExpanded: true,
                                  icon: Icon(Icons.arrow_drop_down, color: Colors.orange[900]),
                                  onChanged: (novaMesa) {
                                    setState(() {
                                      mesaSelecionada = novaMesa;
                                    });
                                    _listarPedidosDaMesa();
                                  },
                                  items: todasMesas
                                      .map((mesa) => DropdownMenuItem<String>(
                                            value: mesa,
                                            child: Text(
                                              'Mesa $mesa',
                                              style: const TextStyle(fontSize: 16),
                                            ),
                                          ))
                                      .toList(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (mesaSelecionada != null) ...[
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () async {
                          String pedidoId = await _criarPedido();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TelaAdicionarProdutosPedido(
                                pedidoId: pedidoId,
                                mesaReference: mesaReference,
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange[900],
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        icon: const Icon(Icons.add_shopping_cart, color: Colors.white),
                        label: const Text(
                          'Adicionar Produtos',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Pedidos da Mesa',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: pedidos == null
                            ? Center(
                                child: Text(
                                  'Nenhum pedido encontrado.',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              )
                            : ListView.builder(
                                itemCount: pedidos!.length,
                                itemBuilder: (context, index) {
                                  var pedido = pedidos![index].data() as Map<String, dynamic>;
                                  List<DocumentReference> listaProdutosRefs =
                                      List<DocumentReference>.from(pedido['listaProdutos']);

                                  return FutureBuilder<List<Map<String, dynamic>>>(
                                    future: _obterListaProdutos(listaProdutosRefs),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState == ConnectionState.waiting) {
                                        return const Center(
                                          child: CircularProgressIndicator(),
                                        );
                                      }

                                      var produtos = snapshot.data ?? [];
                                      return _buildPedidoCard(pedido, produtos);
                                    },
                                  );
                                },
                              ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
    );
  }
}