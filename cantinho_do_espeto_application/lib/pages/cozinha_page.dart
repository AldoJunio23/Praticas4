import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_praticas/components/custom_drawer.dart';
import 'package:flutter_application_praticas/services/pedido_service.dart';

class CozinhaPage extends StatefulWidget {
  const CozinhaPage({super.key});

  @override
  _CozinhaPage createState() => _CozinhaPage();
}

class _CozinhaPage extends State<CozinhaPage> {

    Future<void> _finalizarPedido(String pedidoId, BuildContext context) async {
      try {
        await PedidoService().finalizarPedido(pedidoId);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pedido finalizado com sucesso!')),
        );

        setState((){});
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao finalizar pedido: $e')),
        );
      }
    }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     drawer: const CustomDrawer(), // Usando o CustomDrawer
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
                  width: 1,
                ),
              ),
            ),
          ),
          title: const Text('Cozinha', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
          leading: Builder(
            builder: (BuildContext context) {
              return IconButton(
                icon: const Icon(Icons.menu, color: Colors.white),
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
                tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
              );
            },
          ),
        ),
      ), 
      body: Container(
        padding: const EdgeInsets.symmetric(vertical:2),
        width: double.infinity,
        color: Colors.white,
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: PedidoService().buscarPedidos(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Erro: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('Nenhum pedido encontrado.'));
            }

            final pedidos = snapshot.data!;

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView.builder(
                itemCount: pedidos.length,
                itemBuilder: (context, index) {
                  final pedido = pedidos[index];

                  return FutureBuilder<String>(
                    future: _carregarNomeMesa(pedido['mesa']),
                    builder: (context, mesaSnapshot) {
                      if (mesaSnapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      } else if (mesaSnapshot.hasError) {
                        return const Text('Erro ao carregar mesa');
                      } else if (!mesaSnapshot.hasData) {
                        return const Text('Mesa desconhecida');
                      }

                      final nomeMesa = mesaSnapshot.data ?? 'Mesa não encontrada';

                      if(!pedido['finalizado']){
                        return Container(
                          margin: const EdgeInsets.only(bottom: 16.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Mesa: $nomeMesa",
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 10),
                              const Text("Produtos:"),
                              FutureBuilder<List<Map<String, dynamic>>>(
                                future: _carregarProdutos(pedido['listaProdutos']),
                                builder: (context, produtosSnapshot) {
                                  if (produtosSnapshot.connectionState == ConnectionState.waiting) {
                                    return const CircularProgressIndicator();
                                  } else if (produtosSnapshot.hasError) {
                                    return const Text('Erro ao carregar produtos');
                                  } else if (!produtosSnapshot.hasData || produtosSnapshot.data!.isEmpty) {
                                    return const Text('Nenhum produto encontrado.');
                                  }

                                  final produtos = produtosSnapshot.data!;
                                  return
                                  SizedBox(
                                    width: 500,
                                    height: 270,
                                    child:  ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: produtos.length,
                                      itemBuilder: (context, index)
                                      {
                                        final produto = produtos[index];
                                        final nome = produto['nome'].toString();
                                        final imagem = produto['imagem'].toString();
                                        final qtd = produto['qtd'].toString();
                                          
                                        return Container(
                                          margin: const EdgeInsets.all(5),
                                          decoration: BoxDecoration(
                                            borderRadius: const BorderRadius.all(Radius.circular(5)),
                                            color: Colors.white,
                                            boxShadow: List.filled(produtos.length, const BoxShadow(
                                              color: Colors.grey,
                                              blurRadius: 2,
                                              blurStyle: BlurStyle.normal
                                            ), growable: true)
                                          ),
                                          width: 170,
                                          height: 200,
                                          child: Column(
                                            children: [
                                              const SizedBox(height: 10),
                                              ClipRRect(
                                                borderRadius: BorderRadius.circular(5.0), // Define o quão arredondada será a borda
                                                child: SizedBox(
                                                  width: 150, // Largura da imagem
                                                  height: 150, // Altura da imagem
                                                  child: Image.network(
                                                    produto['imagem']!,
                                                    fit: BoxFit.cover,
                                                    errorBuilder: (context, error, stackTrace) {
                                                      return const Icon(Icons.error, size: 150, color: Colors.red);
                                                    },
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 10), // Espaço entre a imagem e o texto
                                              Text(
                                                nome.toUpperCase(), // Nome do produto
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold
                                                ), // Estilização do texto
                                              ),
                                              const SizedBox(height: 10), // Espaço entre a imagem e o texto
                                              Container(
                                                alignment: Alignment.center,
                                                decoration: const BoxDecoration(
                                                  color: Colors.amber,
                                                  borderRadius: BorderRadius.all(Radius.circular(50))
                                                ) ,
                                                width: 50,
                                                height: 50,
                                                child: Text(
                                                  "x$qtd", // Nome do produto
                                                  style: const TextStyle(
                                                    fontSize: 24,
                                                    fontWeight: FontWeight.bold
                                                  ), // Estilização do texto
                                                ),
                                              )
                                            ],
                                          )
                                        );
                                      }
                                    )
                                  );
                                },
                              ),
                              // Exibir o botão "Finalizar" se o pedido não estiver finalizado
                              if (!pedido['finalizado']) 
                                ElevatedButton(
                                  onPressed: () => _finalizarPedido(pedido['id'], context),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red, // Cor do botão
                                  ),
                                  child: const Text('Finalizar Pedido'),
                                ),
                            ],
                          ),
                        );
                      }
                      return Container();
                    },
                  );
                },
              ),
            );
          },
        ),
      )
    );
  }

// Função para finalizar o pedido
  

  Future<String> _carregarNomeMesa(DocumentReference mesaRef) async {
    try {
      DocumentSnapshot mesaDoc = await mesaRef.get();
      Map<String, dynamic>? mesaData = mesaDoc.data() as Map<String, dynamic>?;
      return mesaData?['numMesa'].toString() ?? 'Mesa sem nome';
    } catch (e) {
      return 'Erro ao carregar mesa';
    }
  }

  Future<List<Map<String, dynamic>>> _carregarProdutos(List<DocumentReference<Object?>> produtosRefs) async {
    List<Map<String, dynamic>> produtos = [];

    for (var ref in produtosRefs) {
      try {
        DocumentSnapshot produtoDoc = await ref.get();
        if (produtoDoc.exists) {
          Map<String, dynamic>? produtoData = produtoDoc.data() as Map<String, dynamic>?;
          String nome = produtoData?['nome'] ?? 'Produto desconhecido';
          String imagemUrl = produtoData?['imagem'] ?? '';
          int qtd = 1;
          bool jaadicionou = false;
          for(var pd in produtos)
          {
            if(nome == pd['nome'])
            {
              pd['qtd'] += 1;
              jaadicionou = true;
            }
          }
          if(!jaadicionou)
          {
            produtos.add({'nome': nome, 'imagem': imagemUrl, 'qtd': qtd});
          }
        } else {
          produtos.add({'nome': 'Produto não encontrado', 'imagem': ''});
        }
      } catch (e) {
        produtos.add({'nome': 'Erro ao carregar produto', 'imagem': ''});
      }
    }

    return produtos;
  }
}

