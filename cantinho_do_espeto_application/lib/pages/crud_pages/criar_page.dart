import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CriarProduto extends StatefulWidget {
  const CriarProduto({super.key});

  @override
  _CriarProdutoState createState() => _CriarProdutoState();
}

class _CriarProdutoState extends State<CriarProduto> {
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _valorController = TextEditingController(); // Renomeado para valor
  final TextEditingController _imagemController = TextEditingController(); // Controlador para a URL da imagem
  String? _categoriaSelecionada;
  List<String> _subprodutos = [];

  @override
  void initState() {
    super.initState();
    _carregarSubprodutos();
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

  void _validarCampos() {
    String nomeProduto = _nomeController.text.trim();
    String valorProduto = _valorController.text.trim(); // Renomeado para valor
    String urlImagem = _imagemController.text.trim(); // Obter a URL da imagem

    if (nomeProduto.isEmpty || valorProduto.isEmpty || _categoriaSelecionada == null || urlImagem.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Preencha todos os campos antes de continuar!'),
          duration: Duration(seconds: 2),
        ),
      );
    } else if (!_valorValido(valorProduto)) { // Alterado para valor
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Valor inválido! Por favor, insira apenas números.'),
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      _adicionarProduto(nomeProduto, valorProduto, urlImagem); // Passa a URL da imagem
    }
  }

  bool _valorValido(String valor) { // Alterado para valor
    final RegExp regExp = RegExp(r'^[0-9]+$');
    return regExp.hasMatch(valor);
  }

  Future<void> _adicionarProduto(String nome, String valor, String urlImagem) async { // Recebe a URL da imagem
    try {
      if (_categoriaSelecionada == "Bebidas") {
        await FirebaseFirestore.instance.collection('Produto').doc('PoDiOnHmAULfo04IFIZy').collection('prod-bebida').add({
          'nome': nome,
          'valor': double.parse(valor),
          'disponivel': true,
          'imagem': urlImagem, // Adiciona a URL da imagem
        });
      } else if (_categoriaSelecionada == "Espetos") {
        await FirebaseFirestore.instance.collection('Produto').doc('r68ahS3Ck96LGZEVzZma').collection('prod-espetos').add({
          'nome': nome,
          'valor': double.parse(valor),
          'disponivel': true,
          'imagem': urlImagem, // Adiciona a URL da imagem
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Produto criado com sucesso!'),
          duration: Duration(seconds: 2),
        ),
      );

      // Limpar campos após a adição
      _nomeController.clear();
      _valorController.clear(); // Alterado para valor
      _imagemController.clear(); // Limpa a URL da imagem
      setState(() {
        _categoriaSelecionada = null; // Limpar a seleção da categoria
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao adicionar produto: $e'),
        ),
      );
    }
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
          title: const Text('Adicionar Produto', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          leading: Builder(
            builder: (BuildContext context) {
              return const Icon(Icons.add_box, color: Colors.white);
            }
          ),
        ),
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(vertical: 3),
        width: double.infinity,
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
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
              child: Align(
                alignment: Alignment.topCenter,
                child: Container(
                  width: 750,
                  height: 1250,
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                        controller: _nomeController,
                        decoration: const InputDecoration(
                          labelText: "Nome do produto",
                          focusColor: Colors.white,
                          labelStyle: TextStyle(
                            color: Colors.white,
                            
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.white, // Cor da borda quando o campo está habilitado
                              width: 2,
                              style: BorderStyle.solid,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.white, // Cor da borda quando o campo está focado
                              width: 2,
                              style: BorderStyle.solid,
                            ),
                          ),
                          // Você pode adicionar também um border quando o campo está com erro, se desejar
                          errorBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.red, // Cor da borda quando há erro
                              width: 2,
                              style: BorderStyle.solid,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 25),
                      Center(
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.white, // Cor da borda
                              width: 2, // Largura da borda
                            ),
                            borderRadius: BorderRadius.circular(5), // Arredondar bordas (opcional)
                          ),
                          child: DropdownButton<String>(
                            hint: const Text(
                                "Selecione a Categoria", 
                                style: TextStyle(
                                  color: Colors.white
                                ),
                              ),
                            style: const TextStyle(
                              color: Colors.white,
                            ),
                            value: _categoriaSelecionada,
                            icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white,),
                            isExpanded: true,
                            padding: const EdgeInsets.only(left: 10),
                            underline: Container(
                              height: 0, // Altura do underline
                            ),
                            dropdownColor: Colors.orange[900],
                            items: _subprodutos.map((String subproduto) {
                              return DropdownMenuItem(
                                value: subproduto,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 10),
                                  child: Text(subproduto),
                                )
                              );
                            }).toList(),
                            onChanged: (String? novoValor) {
                              _categoriaSelecionada = novoValor;
                              setState(() {
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 25),
                      TextField(
                        style: const TextStyle(
                          color: Colors.white
                        ),
                        controller: _valorController, // Renomeado para valor
                        decoration: const InputDecoration(
                          labelText: "Valor do Produto",
                          focusColor: Colors.white,
                          labelStyle: TextStyle(
                            color: Colors.white,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.white, // Cor da borda quando o campo está habilitado
                              width: 2,
                              style: BorderStyle.solid,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.white, // Cor da borda quando o campo está focado
                              width: 2,
                              style: BorderStyle.solid,
                            ),
                          ),
                          // Você pode adicionar também um border quando o campo está com erro, se desejar
                          errorBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.red, // Cor da borda quando há erro
                              width: 2,
                              style: BorderStyle.solid,
                            ),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                      ),
                      const SizedBox(height: 25),
                      TextField(
                        style: const TextStyle(
                          color: Colors.white
                        ),
                        controller: _imagemController, // Controlador para a URL da imagem
                        decoration: const InputDecoration(
                          labelText: "URL da Imagem Do Produto",
                          focusColor: Colors.white,
                          labelStyle: TextStyle(
                            color: Colors.white,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.white, // Cor da borda quando o campo está habilitado
                              width: 2,
                              style: BorderStyle.solid,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.white, // Cor da borda quando o campo está focado
                              width: 2,
                              style: BorderStyle.solid,
                            ),
                          ),
                          // Você pode adicionar também um border quando o campo está com erro, se desejar
                          errorBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.red, // Cor da borda quando há erro
                              width: 2,
                              style: BorderStyle.solid,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 25),
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
                    _validarCampos();
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
                    Navigator.pop(context);// Use pop para voltar
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
      )
    );
  }
}
