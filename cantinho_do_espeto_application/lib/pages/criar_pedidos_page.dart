import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_praticas/pages/adicionar_produtos_page.dart';

class CriarPedidosPage extends StatefulWidget {
  const CriarPedidosPage({super.key});

  @override
  State<StatefulWidget> createState() => _CriarPedidosState();
}

class _CriarPedidosState extends State<CriarPedidosPage> {
  String? mesaSelecionada;
  List<String> todasMesas = [];
  bool isLoading = true;
  List<DocumentSnapshot>? pedidos;

  @override
  void initState() {
    super.initState();
    _obterMesas();  // Carrega todas as mesas ao iniciar
  }

  Future<void> _obterMesas() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('Mesas').get();

    List<DocumentReference> mesasRefs = snapshot.docs.map((doc) => doc.reference).toList();
    List<String> nomes = await _carregarNomesMesas(mesasRefs);

    setState(() {
      todasMesas = nomes;
      isLoading = false;  // Finaliza o carregamento
    });
  }

  Future<List<String>> _carregarNomesMesas(List<DocumentReference> mesasRefs) async {
    List<String> nomesMesas = [];

    try {
      for (DocumentReference mesaRef in mesasRefs) {
        DocumentSnapshot mesaDoc = await mesaRef.get();
        Map<String, dynamic>? mesaData = mesaDoc.data() as Map<String, dynamic>?;
        String nomeMesa = "Mesa: ";
        nomeMesa += mesaData?['numMesa'].toString() ?? 'sem nome';
        nomesMesas.add(nomeMesa);
      }
    } catch (e) {
      nomesMesas.add('Erro ao carregar algumas mesas');
    }

    return nomesMesas;
  }

  Future<String> _criarPedido() async {
    DocumentReference novoPedidoRef = await FirebaseFirestore.instance.collection('Pedidos').add({
      'mesa': mesaSelecionada,
      'dataCriacao': FieldValue.serverTimestamp(),
      'finalizado': false,
      'listaProdutos': [],
      'valorTotal': 0.0,
    });

    return novoPedidoRef.id; // Retorna o ID do novo pedido
  }

  Future<void> _listarPedidosDaMesa() async {
    if (mesaSelecionada != null) {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('Pedidos')
          .where('mesa', isEqualTo: mesaSelecionada)
          .get();

      setState(() {
        pedidos = snapshot.docs; // Armazena os pedidos da mesa
      });
    }
  }

  Future<Map<String, dynamic>> _obterDetalhesProduto(DocumentReference produtoRef) async {
    DocumentSnapshot produtoSnapshot = await produtoRef.get();
    return produtoSnapshot.data() as Map<String, dynamic>;
  }

  Future<List<Map<String, dynamic>>> _obterListaProdutos(List<DocumentReference> listaProdutosRefs) async {
    List<Map<String, dynamic>> produtos = [];

    for (DocumentReference produtoRef in listaProdutosRefs) {
      Map<String, dynamic> produto = await _obterDetalhesProduto(produtoRef);
      produtos.add(produto);
    }

    return produtos;
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
          title: const Text('Comandas'),
          leading: const Icon(Icons.menu),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Selecione uma mesa:'),
                  const SizedBox(height: 10),
                  DropdownButton<String>(
                    hint: const Text('Escolha uma mesa'),
                    value: mesaSelecionada,
                    onChanged: (String? novaMesa) {
                      setState(() {
                        mesaSelecionada = novaMesa;
                      });
                      _listarPedidosDaMesa(); // Lista pedidos da mesa selecionada
                    },
                    items: todasMesas.map((mesa) {
                      return DropdownMenuItem<String>(
                        value: mesa,
                        child: Text(mesa),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  const Text('Adicionar Produtos:'),
                  const SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.add, color: Colors.black),
                      onPressed: () async {
                        if (mesaSelecionada != null) {
                          String pedidoId = await _criarPedido();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TelaAdicionarProdutosPedido(pedidoId: pedidoId),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Por favor, selecione uma mesa.')),
                          );
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text('Pedidos da Mesa:'),
                  const SizedBox(height: 10),
                  Expanded(
                    child: pedidos == null
                        ? const Text('Nenhum pedido encontrado.')
                        : ListView.builder(
                            itemCount: pedidos!.length,
                            itemBuilder: (context, index) {
                              var pedido = pedidos![index].data() as Map<String, dynamic>;

                              // Obtém a lista de produtos para o pedido
                              List<DocumentReference> listaProdutosRefs =
                                  List<DocumentReference>.from(pedido['listaProdutos']);

                              return FutureBuilder<List<Map<String, dynamic>>>(
                                future: _obterListaProdutos(listaProdutosRefs),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                    return const CircularProgressIndicator();
                                  }

                                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                    return const Text('Nenhum produto encontrado.');
                                  }

                                  var produtos = snapshot.data!;

                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                   children: [
                                      Text(
                                    'Pedido ID: ${pedidos![index].id}',
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    'Valor Total: R\$ ${pedido['valorTotal'].toStringAsFixed(2)}',
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  const Text(
                                    'Produtos:',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                      for (var produto in produtos)
                                        ListTile(
                                          title: Text(produto['nome']),
                                          subtitle: Text(
                                            'Valor: R\$ ${pedido['valorTotal']?.toStringAsFixed(2) ?? '0.00'}',
                                          ), 
                                        ),
                                          IconButton(
                                            icon: const Icon(Icons.edit, color: Colors.black),
                                            onPressed: () async {
                                              if (mesaSelecionada != null) {
                                                String pedidoId = await _criarPedido();
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) => TelaAdicionarProdutosPedido(pedidoId: pedidoId),
                                                  ),
                                                );
                                              } else {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(content: Text('Por favor, selecione uma mesa.')),
                                                );
                                              }
                                            },
                                          ),
                                      const SizedBox(height: 20),
                                    ],

                                  );
                                },
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
    );
  }
}
