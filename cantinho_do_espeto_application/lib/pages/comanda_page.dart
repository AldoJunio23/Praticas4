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
  List<DocumentSnapshot>? pedidos;

  @override
  void initState() {
    super.initState();
    _obterMesas();
  }

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
      nomesMesas.add('Mesa: ${mesaData?['numMesa'] ?? 'sem nome'}');
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
    return novoPedidoRef.id;
  }

  Future<void> _listarPedidosDaMesa() async {
    if (mesaSelecionada != null) {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('Pedidos')
          .where('mesa', isEqualTo: mesaSelecionada)
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const CustomDrawer(),
      appBar: AppBar(
        title: const Text(
          'Comandas',
          style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.bottomRight,
              colors: [Colors.orange[900]!.withOpacity(1), Colors.orange[900]!.withOpacity(0.9)],
              stops: const [0.6, 1],
            ),
          ),
        ),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      body: Center(
        child: isLoading
            ? const CircularProgressIndicator()
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      'Selecione uma mesa:', 
                      textAlign: TextAlign.center,
                      style: TextStyle( fontSize: 24),
                      
                      ),
                    const SizedBox(height: 10),
                    Container(
                      width: 250,  // Definindo largura maior para o Dropdown
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: DropdownButton<String>(
                        hint: const Text('Escolha uma mesa'),
                        value: mesaSelecionada,
                        isExpanded: true,
                        underline: const SizedBox(),
                        onChanged: (novaMesa) {
                          setState(() {
                            mesaSelecionada = novaMesa;
                          });
                          _listarPedidosDaMesa();
                        },
                        items: todasMesas
                            .map((mesa) => DropdownMenuItem<String>(
                                  value: mesa,
                                  child: Text(mesa),
                                ))
                            .toList(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (mesaSelecionada != null) ...[
                      const Text('Adicionar Produtos:', textAlign: TextAlign.center),
                      const SizedBox(height: 10),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.add, color: Colors.black),
                          onPressed: () async {
                            String pedidoId = await _criarPedido();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => TelaAdicionarProdutosPedido(pedidoId: pedidoId),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text('Pedidos da Mesa:', textAlign: TextAlign.center),
                      const SizedBox(height: 10),
                      Expanded(
                        child: pedidos == null
                            ? const Text('Nenhum pedido encontrado.', textAlign: TextAlign.center)
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
                                        return const CircularProgressIndicator();
                                      }

                                      var produtos = snapshot.data ?? [];
                                      return Card(
                                        margin: const EdgeInsets.symmetric(vertical: 10),
                                        child: Padding(
                                          padding: const EdgeInsets.all(10),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Valor Total: R\$ ${pedido['valorTotal'].toStringAsFixed(2)}',
                                                style: const TextStyle(fontWeight: FontWeight.bold),
                                              ),
                                              const SizedBox(height: 10),
                                              const Text('Produtos:', style: TextStyle(fontWeight: FontWeight.bold)),
                                              const SizedBox(height: 10),
                                              ...produtos.map((produto) => ListTile(
                                                    title: Text(produto['nome']),
                                                    subtitle: Text(
                                                      'Valor: R\$ ${produto['valor']?.toStringAsFixed(2) ?? '0.00'}',
                                                    ),
                                                    trailing: IconButton(
                                                      icon: const Icon(Icons.edit, color: Colors.black),
                                                      onPressed: () {
                                                        // Implementar ação de edição, se necessário
                                                      },
                                                    ),
                                                  )),
                                            ],
                                          ),
                                        ),
                                      );
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
