import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AlterarProduto extends StatefulWidget {
  final String idProduto;
  final String subCategoria;
  final String docName;

  const AlterarProduto({super.key, required this.idProduto, required this.subCategoria, required this.docName});

  @override
  _AlterarProdutoState createState() => _AlterarProdutoState();
}

class _AlterarProdutoState extends State<AlterarProduto> {
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _valorController = TextEditingController();
  String? _categoriaSelecionada;
  List<String> _subprodutos = [];

  @override
  void initState() {
    super.initState();
    _carregarSubprodutos();
    _carregarProduto();
  }

  Future<void> _carregarSubprodutos() async {
    try {
      final QuerySnapshot result = await FirebaseFirestore.instance
          .collection('Produto')
          .get();
      setState(() {
        _subprodutos = result.docs.map((doc) => doc['categoria'] as String).toList();
      });
    } catch (e) {
      print('Erro ao carregar subprodutos: $e');
    }
  }

  Future<void> _carregarProduto() async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('Produto')
          .doc(widget.docName)
          .collection(widget.subCategoria)
          .doc(widget.idProduto)
          .get();

      DocumentSnapshot categoria = await FirebaseFirestore.instance
          .collection('Produto')
          .doc(widget.docName)
          .get();

      if (doc.exists) {
        _nomeController.text = doc['nome'];
        _valorController.text = doc['valor'].toString();
        _categoriaSelecionada = categoria['categoria'];
        setState(() {});
      }
    } catch (e) {
      print('Erro ao carregar produto: $e');
    }
  }

  void _validarCampos() {
    String nomeProduto = _nomeController.text.trim();
    String precoProduto = _valorController.text.trim();

    if (nomeProduto.isEmpty || precoProduto.isEmpty || _categoriaSelecionada == null) {
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
      _atualizarProduto(nomeProduto, precoProduto);
    }
  }

  bool _precoValido(String preco) {
    final RegExp regExp = RegExp(r'^[0-9]+(\.[0-9]+)?$');
    return regExp.hasMatch(preco);
  }

  Future<void> _atualizarProduto(String nome, String preco) async {
    try {
      await FirebaseFirestore.instance.collection('Produto').doc(widget.idProduto).update({
        'nome': nome,
        'valor': double.parse(preco),
        'categoria': _categoriaSelecionada,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Produto alterado com sucesso!'),
          duration: Duration(seconds: 2),
        ),
      );

      _nomeController.clear();
      _valorController.clear();
      setState(() {
        _categoriaSelecionada = null;
      });

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao atualizar produto: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Produto', style: TextStyle(color: Colors.white)),
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
        ),
      ),
        elevation: 1,
        leading: const Icon(Icons.brush, color: Colors.white),
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _nomeController,
              decoration: const InputDecoration(
                labelText: "Nome do produto",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              hint: const Text("Selecione a Categoria"),
              value: _categoriaSelecionada,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
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
            const SizedBox(height: 20),
            TextField(
              controller: _valorController,
              decoration: const InputDecoration(
                labelText: "Valor do Produto",
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly,
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _validarCampos,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                  ),
                  child: const Text("Confirmar", style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                  ),
                  child: const Text("Voltar", style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}