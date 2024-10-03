import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Importação do Firestore

class CriarProduto extends StatefulWidget {
  const CriarProduto({super.key});

  @override
  _CriarProdutoState createState() => _CriarProdutoState();
}

class _CriarProdutoState extends State<CriarProduto> {
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _precoController = TextEditingController();
  String? _categoriaSelecionada;
  List<String> _subprodutos = []; // Lista para armazenar subprodutos

  @override
  void initState() {
    super.initState();
    _carregarSubprodutos(); // Carrega subprodutos ao iniciar
  }

  // Função para carregar subprodutos do Firestore
  Future<void> _carregarSubprodutos() async {
    try {
      final QuerySnapshot result = await FirebaseFirestore.instance
          .collection('Produto') // Nome da coleção
          .get();
      setState(() {
        _subprodutos = result.docs.map((doc) => doc['categoria'] as String).toList(); // 'categoria' é o campo que contém o subproduto
      });
    } catch (e) {
      // Tratamento de erro, caso algo dê errado
      print('Erro ao carregar subprodutos: $e');
    }
  }

  void _validarCampos() {
    String nomeProduto = _nomeController.text.trim();
    String precoProduto = _precoController.text.trim();

    if (nomeProduto.isEmpty ||
        precoProduto.isEmpty ||
        _categoriaSelecionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Preencha os campos antes de continuar!'),
          duration: Duration(seconds: 2),
        ),
      );
    } else if (!_precoValido(precoProduto)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Preço inválido! Por favor, insira apenas números.'),
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Produto criado com sucesso!'),
          duration: Duration(seconds: 2),
        ),
      );
      // Aqui você pode adicionar o código para continuar o processo de criação do produto
    }
  }

  bool _precoValido(String preco) {
    final RegExp regExp = RegExp(r'^[0-9]+$');
    return regExp.hasMatch(preco);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Novo produto"),
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: const BoxDecoration(color: Colors.orange),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Text(
                      'Menu',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white, fontSize: 24),
                    ),
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
            // Adicione suas opções de menu aqui
          ],
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Expanded(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: 750,
                height: 1250,
                color: Colors.grey[300],
                padding: const EdgeInsets.all(16.0),
                margin: const EdgeInsets.only(bottom: 200),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Campo Nome do Produto
                    TextField(
                      controller: _nomeController,
                      decoration: const InputDecoration(
                        labelText: "Nome do produto",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 25),
                    // Dropdown de Categoria
                    DropdownButton<String>(
                      hint: const Text("Selecione a Categoria"),
                      value: _categoriaSelecionada,
                      icon: const Icon(Icons.keyboard_arrow_down),
                      isExpanded: true,
                      items: _subprodutos.map((String subproduto) {
                        return DropdownMenuItem(
                          value: subproduto,
                          child: Text(subproduto),
                        );
                      }).toList(),
                      onChanged: (String? novoValor) {
                        setState(() {
                          _categoriaSelecionada = novoValor;
                        });
                      },
                    ),
                    const SizedBox(height: 25),
                    // Campo Preço do Produto
                    TextField(
                      controller: _precoController,
                      decoration: const InputDecoration(
                        labelText: "Preço do produto",
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                    ),
                    const SizedBox(height: 25),
                    // Dropdown de Subprodutos
                    
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 20.0,
                    horizontal: 40.0,
                  ),
                  textStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: () {
                  _validarCampos(); // Chama o método de validação
                },
                child: const Text(
                  'Criar',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 20.0,
                    horizontal: 40.0,
                  ),
                  textStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: () {
                  Navigator.pushNamed(context, 'home');
                },
                child: const Text(
                  "Voltar",
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
          const SizedBox(height: 60),
        ],
      ),
    );
  }
}

class Options extends StatefulWidget {
  final ValueChanged<String?> onCategoriaSelecionada;

  const Options({required this.onCategoriaSelecionada, Key? key})
      : super(key: key);

  @override
  _OptionsState createState() => _OptionsState();
}

class _OptionsState extends State<Options> {
  String? _selecionarOpcoes;

  final List<String> _opcoes = [
    "Entrada",
    "Prato Principal",
    "Sobremesa",
    "Bebida"
  ];

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      hint: const Text("Selecione a categoria do produto"),
      value: _selecionarOpcoes,
      icon: const Icon(Icons.keyboard_arrow_down),
      isExpanded: true,
      items: _opcoes.map((String opcao) {
        return DropdownMenuItem(
          value: opcao,
          child: Text(opcao),
        );
      }).toList(),
      onChanged: (String? novoValor) {
        setState(() {
          _selecionarOpcoes = novoValor;
        });
        widget.onCategoriaSelecionada(novoValor);
      },
    );
  }
}
