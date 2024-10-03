// Card Componente - 03/10/2024

/*
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import necessário para FilteringTextInputFormatter

class ProdutoCard extends StatefulWidget {
  final String titulo; // Pode ser "Criar Produto" ou "Alterar Produto"
  final Function(String nome, String preco, String? categoria) onSubmit; // Função de submissão
  final String? nomeInicial;
  final String? precoInicial;
  final String? categoriaInicial;

  const ProdutoCard({
    required this.titulo,
    required this.onSubmit,
    this.nomeInicial,
    this.precoInicial,
    this.categoriaInicial,
    super.key,
  });

  @override
  _ProdutoCardState createState() => _ProdutoCardState();
}

class _ProdutoCardState extends State<ProdutoCard> {
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _precoController = TextEditingController();
  String? _categoriaSelecionada;

  @override
  void initState() {
    super.initState();
    if (widget.nomeInicial != null) _nomeController.text = widget.nomeInicial!;
    if (widget.precoInicial != null) _precoController.text = widget.precoInicial!;
    _categoriaSelecionada = widget.categoriaInicial;
  }

  // Função de validação dos campos
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
      widget.onSubmit(nomeProduto, precoProduto, _categoriaSelecionada);
    }
  }

  // Função para validar se o preço contém apenas números
  bool _precoValido(String preco) {
    final RegExp regExp = RegExp(r'^[0-9]+$');
    return regExp.hasMatch(preco);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.titulo),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
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
              categoriaInicial: _categoriaSelecionada,
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
            const SizedBox(height: 25),
            // Botão de Ação
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
                  onPressed: _validarCampos,
                  child: Text(widget.titulo),
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
                    Navigator.pop(context);
                  },
                  child: const Text(
                    "Cancelar",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class Options extends StatefulWidget {
  final ValueChanged<String?> onCategoriaSelecionada;
  final String? categoriaInicial;

  const Options({required this.onCategoriaSelecionada, this.categoriaInicial, Key? key})
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
  void initState() {
    super.initState();
    _selecionarOpcoes = widget.categoriaInicial;
  }

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
*/