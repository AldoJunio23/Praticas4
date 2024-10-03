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

  @override
  void initState() {
    super.initState();
    _obterMesas();  // Carrega todas as mesas ao iniciar
  }

  // Usar o método _carregarNomesMesas para obter todas as mesas
  Future<void> _obterMesas() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('Mesas')
        .get();
    
    List<DocumentReference> mesasRefs = snapshot.docs.map((doc) => doc.reference).toList();
    List<String> nomes = await _carregarNomesMesas(mesasRefs);

    setState(() {
      todasMesas = nomes;
      isLoading = false;  // Finaliza o carregamento
    });
  }

  // Método fornecido que carrega os nomes das mesas
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

  void _criarPedido(){
    //criar um novo pedido com a mesa selecionada, horario de criação, finalizado = false e uma lista de produtos vazia
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
                    },
                    items: todasMesas.map((mesa) {
                      return DropdownMenuItem<String>(
                        value: mesa,
                        child: Text(mesa),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  const Text('Produtos e Quantidades:'),
                  const SizedBox(height: 10),
                 Container(
                    decoration: BoxDecoration(
                      color: Colors.grey, 
                      borderRadius: BorderRadius.circular(30), 
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.add, color: Colors.black),
                      onPressed: (){
                        if(mesaSelecionada != null){
                          _criarPedido();
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const AdicionarProdutosPage()),
                                );
                        }
                      },//onPressed
                    ),
                  )
                ],
              ),
            ),
    );
  }
}
