import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_praticas/pages/crud_pages/criar_page.dart';

class DeletarProduto extends StatefulWidget {
  const DeletarProduto({super.key});

  @override
  _DeletarProdutoState createState() => _DeletarProdutoState();
}

class _DeletarProdutoState extends State<DeletarProduto> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Controladores para o novo produto
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _valorController = TextEditingController();
  String? _categoriaSelecionada;

  Future<List<Map<String, dynamic>>> _getAllProdutos() async {
    List<Map<String, dynamic>> allProdutos = [];
    final collectionNames = ['prod-bebida', 'prod-espetos'];
    final docNames = ['PoDiOnHmAULfo04IFIZy', 'r68ahS3Ck96LGZEVzZma'];

    for (int i = 0; i < collectionNames.length; i++) {
      QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore.collection("Produto").doc(docNames[i]).collection(collectionNames[i]).get();

      for (var doc in snapshot.docs) {
        allProdutos.add({
          'id': doc.id, // ID do documento
          ...doc.data(),
        });
      }
    }

    return allProdutos;
  }

  void _deletarProduto(String docId) {
    // Lógica para deletar produto
    _firestore.collection('prod-bebidas').doc(docId).delete();
  }

  void _editarProduto(Map<String, dynamic> produto) {
    // Lógica para editar o produto
  }

  void _adicionarProduto() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CriarProduto(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Administração dos Produtos"),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Produtos: ",
                  style: TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    DropdownButton<String>(
                      hint: const Text("Selecione a Categoria"),
                      value: _categoriaSelecionada,
                      items: ['Bebidas', 'Espetos'].map((String categoria) {
                        return DropdownMenuItem(
                          value: categoria,
                          child: Text(categoria),
                        );
                      }).toList(),
                      onChanged: (String? novoValor) {
                        setState(() {
                          _categoriaSelecionada = novoValor;
                        });
                      },
                    ),
                    ElevatedButton(
                      onPressed: _adicionarProduto,
                      child: const Icon(Icons.add),
                    ),
                  ]
                )
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _getAllProdutos(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return const Center(child: Text("Erro ao carregar produtos"));
                }

                final produtos = snapshot.data!;

                return ListView.builder(
                  itemCount: produtos.length,
                  itemBuilder: (context, index) {
                    final produto = produtos[index];
                    final nome = produto['nome'];
                    final valor = produto['valor'];
                    final disponivel = produto['disponivel'];
                    final docId = produto['id'];

                    return Card(
                      margin: const EdgeInsets.all(8.0),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Nome: $nome", style: const TextStyle(fontSize: 18)),
                            Text("Preço: R\$ $valor", style: const TextStyle(fontSize: 16)),
                            Text("Disponível: ${disponivel ? "Sim" : "Não"}", style: const TextStyle(fontSize: 16)),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    foregroundColor: Colors.white,
                                  ),
                                  onPressed: () {
                                    _editarProduto(produto);
                                  },
                                  child: const Text("Editar"),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white,
                                  ),
                                  onPressed: () {
                                    _deletarProduto(docId);
                                  },
                                  child: const Text("Excluir"),
                                ),
                              ],
                            ),
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
      ),
    );
  }
}
