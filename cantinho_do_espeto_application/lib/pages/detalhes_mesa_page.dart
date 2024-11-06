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
  int? _selectedValue; // Para o estado da mesa (Ocupado ou Desocupado)
  int? _numMesa; // Para a comanda da mesa
  List<Map<String, dynamic>> produtos = []; // Lista de produtos
  String? pedidoID;

  @override
  void initState() {
    super.initState();
    _carregarDadosMesa(); // Carrega os dados da mesa ao iniciar
  }

  // Finaliza um pedido
  Future<void> _finalizarPedido(String pedidoId, BuildContext context) async {
    try {
      await PedidoService().finalizarPedido(pedidoId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pedido finalizado com sucesso!')),
      );
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao finalizar pedido: $e')),
      );
    }
  }

  // Método para buscar as informações da mesa no Firestore
  Future<void> _carregarDadosMesa() async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('Mesas') // Coleção onde as mesas estão armazenadas
          .doc(widget.mesaId) // Pega o documento da mesa baseado no mesaId
          .get();

      if (doc.exists) {
        setState(() {
          _selectedValue = doc['status'] ? 1 : 2;
          _numMesa = doc['numMesa'];
        });

        // Busca o pedido associado à mesa
        DocumentReference mesaRef = doc.reference;
        Map<String, dynamic>? pedido =
            await PedidoService().buscarPedidoPorMesa(mesaRef);
        pedidoID = pedido?['id'].toString();

        if (pedido != null) {
          List<DocumentReference<Object?>> listaProdutosRefs =
              pedido['listaProdutos'];
          _carregarProdutos(listaProdutosRefs);
        } else {
          print('Nenhum pedido encontrado para a mesa.');
        }
      } else {
        print('Mesa não encontrada');
      }
    } catch (e) {
      print('Erro ao carregar dados da mesa: $e');
    }
  }

  // Carrega produtos a partir da lista de DocumentReferences
  Future<void> _carregarProdutos(
      List<DocumentReference<Object?>> produtosRefs) async {
    try {
      List<Map<String, dynamic>> produtosTemp = [];
      for (DocumentReference<Object?> produtoRef in produtosRefs) {
        DocumentSnapshot produtoDoc = await produtoRef.get();
        if (produtoDoc.exists) {
          Map<String, dynamic>? produtoData =
              produtoDoc.data() as Map<String, dynamic>?;
          String nome = produtoData?['nome'] ?? 'Produto desconhecido';
          String imagemUrl = produtoData?['imagem'] ?? '';
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
            produtosTemp.add({'nome': nome, 'imagem': imagemUrl, 'qtd': qtd});
          }
        }
      }

      setState(() {
        produtos = produtosTemp;
      });
    } catch (e) {
      print('Erro ao carregar produtos: $e');
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _numMesa != null ? 'Mesa $_numMesa' : 'Carregando...',
          style: const TextStyle(
              color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
        ),
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
                width: 1,
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          height: 840,
          width: 500,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: [
                Colors.orange[900]!.withOpacity(1),
                Colors.orange[900]!.withOpacity(0.9),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          margin: const EdgeInsets.all(30),
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const Text(
                "Estado da Mesa:",
                style: TextStyle(fontSize: 30, color: Colors.white),
              ),
              // Coloque este código onde estão os RadioListTiles
              Container(
                decoration: BoxDecoration(
                  color: const Color.fromARGB(
                      255, 253, 255, 228), // Mesma cor de fundo do botão
                  borderRadius:
                      BorderRadius.circular(10), // Bordas arredondadas
                ),
                padding: const EdgeInsets.all(10), // Espaçamento interno
                child: Column(
                  children: [
                    RadioListTile<int>(
                      title: const Text(
                        'Ocupado',
                        style: TextStyle(color: Colors.orange, fontSize: 20),
                      ),
                      value: 1,
                      groupValue: _selectedValue,
                      activeColor: Colors.red,
                      onChanged: (value) async {
                        setState(() {
                          _selectedValue = value;
                        });
                        try {
                          await FirebaseFirestore.instance
                              .collection('Mesas')
                              .doc(widget.mesaId)
                              .update({'status': value == 1});
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(value == 1
                                  ? 'Mesa marcada como Ocupada'
                                  : 'Mesa marcada como Desocupada'),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content:
                                  Text('Erro ao atualizar o status da mesa'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 5),
                    RadioListTile<int>(
                      title: const Text(
                        'Desocupado',
                        style: TextStyle(color: Colors.orange, fontSize: 20),
                      ),
                      value: 2,
                      groupValue: _selectedValue,
                      activeColor: Colors.green,
                      onChanged: (value) async {
                        setState(() {
                          _selectedValue = value;
                        });
                        try {
                          await FirebaseFirestore.instance
                              .collection('Mesas')
                              .doc(widget.mesaId)
                              .update({'status': value == 1});
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(value == 1
                                  ? 'Mesa marcada como Ocupada'
                                  : 'Mesa marcada como Desocupada'),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content:
                                  Text('Erro ao atualizar o status da mesa'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                "Comanda:",
                style: TextStyle(fontSize: 25, color: Colors.white),
              ),
              const SizedBox(height: 15),
              produtos.isNotEmpty
                  ? SizedBox(
                      width: 500,
                      height: 475,
                      child: ListView.builder(
                        scrollDirection: Axis.vertical,
                        itemCount: produtos.length,
                        itemBuilder: (context, index) {
                          final produto = produtos[index];
                          final nome = produto['nome'].toString();
                          final imagem = produto['imagem'].toString();
                          final qtd = produto['qtd'].toString();
                          return Container(
                              margin: const EdgeInsets.all(5),
                              decoration: const BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5)),
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey,
                                    blurRadius: 2,
                                  ),
                                ],
                              ),
                              width: 170,
                              height: 110,
                              child: Row(children: [
                                const SizedBox(width: 5),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(5.0),
                                  child: SizedBox(
                                    width: 100,
                                    height: 100,
                                    child: Image.network(
                                      imagem,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return const Icon(Icons.error,
                                            size: 150, color: Colors.red);
                                      },
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                SizedBox(
                                  width: 190,
                                  child: Text(
                                    nome.toUpperCase(),
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                const SizedBox(width: 20),
                                Container(
                                  alignment: Alignment.center,
                                  decoration: const BoxDecoration(
                                    color: Color.fromARGB(255, 230, 81, 0),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(50)),
                                  ),
                                  width: 40,
                                  height: 40,
                                  child: Text(
                                    "x$qtd",
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                  ),
                                ),
                              ]));
                        },
                      ))
                  : const Center(
                      child: null,
                    ),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => TelaAdicionarProdutosPedido(
                                    pedidoId: pedidoID,
                                  )),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(7.0),
                        ),
                        backgroundColor:
                            const Color.fromARGB(255, 253, 255, 228),
                      ),
                      child: produtos.isNotEmpty
                          ? const Icon(
                              Icons.brush,
                              size: 32,
                              color: Colors.orange,
                            )
                          : const Text("Adicionar Produtos",
                              style: TextStyle(
                                  fontSize: 24, color: Colors.orange))),
                  produtos.isNotEmpty
                      ? const SizedBox(width: 68)
                      : const Text(""),
                  produtos.isNotEmpty
                      ? ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => FinalizarComandaPage(
                                        pedidoId: pedidoID,
                                      )),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.all(15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(7.0),
                            ),
                            backgroundColor:
                                const Color.fromARGB(255, 253, 255, 228),
                          ),
                          child: const Text(
                            "Finalizar Comanda",
                            style: TextStyle(fontSize: 24, color: Colors.white),
                          ),
                        )
                      : const Text(""),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
