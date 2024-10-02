import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import necessário para FilteringTextInputFormatter

class AlterarProduto extends StatefulWidget {
  const AlterarProduto({super.key});

  @override
  _AlterarProdutoState createState() => _AlterarProdutoState();
}

class _AlterarProdutoState extends State<AlterarProduto> {
  // Controladores para os campos de texto
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _precoController = TextEditingController();
  String? _categoriaSelecionada; // Para o Dropdown de categorias

  // Função de validação dos campos
  void _validarCampos() {
    String nomeProduto = _nomeController.text.trim();
    String precoProduto = _precoController.text.trim();

    if (nomeProduto.isEmpty ||
        precoProduto.isEmpty ||
        _categoriaSelecionada == null) {
      // Exibe um alerta informando que os campos estão vazios
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Preencha os campos antes de continuar!'),
          duration: Duration(seconds: 2),
        ),
      );
    } else if (!_precoValido(precoProduto)) {
      // Se o preço contiver caracteres inválidos, exibe um alerta
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Preço inválido! Por favor, insira apenas números.'),
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      // Se todos os campos estiverem preenchidos corretamente, exibe uma mensagem de sucesso
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Produto alterado com sucesso!'),
          duration: Duration(seconds: 2),
        ),
      );
      // Aqui você pode adicionar o código para continuar o processo de criação do produto
    }
  }

  // Função para validar se o preço contém apenas números
  bool _precoValido(String preco) {
    // Verifica se o preço contém apenas números
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
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Início'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('#'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('##'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('###'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
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
                    Options(
                      onCategoriaSelecionada: (String? categoria) {
                        setState(() {
                          _categoriaSelecionada = categoria;
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
