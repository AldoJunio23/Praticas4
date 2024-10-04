import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_praticas/pages/crud_pages/alterar_page.dart';
import 'package:flutter_application_praticas/pages/crud_pages/criar_page.dart';
import 'package:intl/intl.dart';

class DeletarProduto extends StatefulWidget {
  const DeletarProduto({super.key});

  @override
  _DeletarProdutoState createState() => _DeletarProdutoState();
}

class _DeletarProdutoState extends State<DeletarProduto> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _valorController = TextEditingController();
  String? _categoriaSelecionada;

  Future<List<Map<String, dynamic>>> _getAllProdutos() async {
    List<Map<String, dynamic>> allProdutos = [];
    final collectionNames = ['prod-bebida', 'prod-espetos'];
    final docNames = ['PoDiOnHmAULfo04IFIZy', 'r68ahS3Ck96LGZEVzZma'];

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

    return allProdutos;
  }

  void _deletarProduto(Map<String, dynamic> produto) {
    _firestore
      .collection('Produto').doc(produto['docName'])
      .collection(produto['collectionName']).
      doc(produto['id']).
      delete();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Produto Excluído com Sucesso!')),
    );

    setState(() {
      
    });
  }

  void _editarProduto(Map<String, dynamic> produto) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AlterarProduto(idProduto: produto['id'], docName: produto['docName'], subCategoria: produto['collectionName'],),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.fromLTRB(15, 5, 5, 5),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.orange[900]!.withOpacity(0.8),
                    Colors.orange[700]!.withOpacity(0.8),
                    Colors.orange[500]!.withOpacity(0.8),
                  ],
                  stops: const [0.0, 0.3, 1.0],
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Menu",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 24),
                  ),
                  Builder(
                    builder: (context) {
                      return IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
                ],
            ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
               Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.home), // home
                    title: const Text('Início'), // Início
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.book), // home
                    title: const Text('Histórico'), // Início
                    onTap: () {

                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.restaurant_menu),
                    title: const Text('Cardápio'),
                    onTap: () {

                    },
                  ),
                ],
              ),
              const Padding(padding: EdgeInsets.symmetric(vertical: 270)),
              Column(
                children: [
                  ListTile(
                  leading: const Icon(Icons.lock_person),
                  title: const Text('Admin'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DeletarProduto(),
                      ),
                    );
                  },
                ), // espaço entre os demais itens da lista
                ListTile(
                  leading: const Icon(Icons.exit_to_app),
                  title: const Text('Sair'),
                  onTap: () {
                    // ação
                  },
                ),],
              ) 
            ],  
            )
          ],
        ),
      ),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60.0),
        child: AppBar(
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
              border: const Border(
                bottom: BorderSide(
                  color: Colors.white,
                  width: 1
                )
              )
            ),
          ),
          title: const Text('Administração dos Produtos', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          leading: Builder(
            builder: (BuildContext context) {
              return IconButton(
                icon: const Icon(Icons.menu, color: Colors.white,),
                onPressed: () { Scaffold.of(context).openDrawer(); },
                tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
              );
            },
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            colors: [
              Colors.orange[900]!,
              Colors.orange[800]!,
              Colors.orange[400]!,
            ],
          ),
        ),
        child: Column(
          children: [
            Padding(
            padding: const EdgeInsets.fromLTRB( 24.0, 24.0, 24.0, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Produtos: ",
                  style: TextStyle(fontSize: 24, color: Colors.white),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    /*DropdownButton<String>(
                      hint: const Text("Selecione a Categoria", style: TextStyle(color: Colors.white),),
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
                    ),*/
                    const SizedBox(width: 50),
                   Container(
                    decoration: BoxDecoration(
                      color: Colors.orange, // Cor de fundo do botão
                      borderRadius: BorderRadius.circular(30), // Bordas arredondadas
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.add, color: Colors.white),
                      onPressed: () { 
                        _adicionarProduto();
                      },
                    ),
                  )
                  ],
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

                return GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // Número de colunas na grid
                    childAspectRatio: 0.590, // Define a proporção dos cards quadrados
                    crossAxisSpacing: 1, // Espaço horizontal entre os cards
                    mainAxisSpacing: 1, // Espaço vertical entre os cards
                  ),
                  padding: const EdgeInsets.all(16.0),
                  itemCount: produtos.length,
                  itemBuilder: (context, index) {
                    final produto = produtos[index];
                    final nome = produto['nome'];
                    final valor = double.parse(produto['valor'].toString());
                    final disponivel = produto['disponivel'];
                    final docId = produto['id'];
                    final imagem = produto['imagem'].toString();
                    String valorFormatado = NumberFormat("#,##0.00", "pt_BR").format(valor);

                    return Card(
                      margin: const EdgeInsets.all(8.0),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(5),
                              alignment: Alignment.center,
                              width: 250,
                              color: disponivel ? Colors.green : Colors.red,
                              child:
                                Text(
                                  disponivel ? "Disponivel" : "Não Disponivel",
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white
                                  ),
                                )
                            ),
                            const SizedBox(height: 10),
                            Image.network(
                              imagem,
                              width: 150,
                              height: 150,
                              fit: BoxFit.cover,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              "$nome",
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              "R\$ $valorFormatado",
                              style: const TextStyle(fontSize: 16),
                            ),
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
                                  child: const Icon(
                                    Icons.brush
                                  )
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white,
                                  ),
                                  onPressed: () {
                                    _deletarProduto(produto);
                                  },
                                  child: const Icon(
                                    Icons.delete
                                  ),
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
          ),]
        ),
      ),
    );
  }
}
