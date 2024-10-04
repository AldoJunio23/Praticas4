import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import necessário para FilteringTextInputFormatter

class AlterarProduto extends StatefulWidget {
  final String idProduto; // Adicionando idProduto como um parâmetro
  final String subCategoria;
  final String docName;

  const AlterarProduto({super.key, required this.idProduto, required this.subCategoria, required this.docName});

  @override
  _AlterarProdutoState createState() => _AlterarProdutoState();
}

class _AlterarProdutoState extends State<AlterarProduto> {
  // Controladores para os campos de texto
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _valorController = TextEditingController();
  String? _categoriaSelecionada; // Para o Dropdown de categorias
  List<String> _subprodutos = [];

  @override
  void initState() {
    super.initState();
    _carregarSubprodutos(); // Carrega subprodutos ao iniciar
    _carregarProduto(); // Carrega os dados do produto a ser editado
  }

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

  Future<void> _carregarProduto() async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('Produto')
          .doc(widget.docName)
          .collection(widget.subCategoria)
          .doc(widget.idProduto) // Usando o id do produto passado
          .get();

       DocumentSnapshot categoria = await FirebaseFirestore.instance
          .collection('Produto')
          .doc(widget.docName)
          .get();

      if (doc.exists) {
        _nomeController.text = doc['nome'];
        _valorController.text = doc['valor'].toString();
        _categoriaSelecionada = categoria['categoria'];
        setState(() {
          
        });
      }
    } catch (e) {
      print('Erro ao carregar produto: $e');
    }
  }

  // Função de validação dos campos
  void _validarCampos() {
    String nomeProduto = _nomeController.text.trim();
    String precoProduto = _valorController.text.trim();

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
      _atualizarProduto(nomeProduto, precoProduto); // Chama função para atualizar o produto
    }
  }

  // Função para validar se o preço contém apenas números
  bool _precoValido(String preco) {
    // Verifica se o preço contém apenas números
    final RegExp regExp = RegExp(r'^[0-9]+(\.[0-9]+)?$'); // Aceita valores decimais
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

      // Limpa os campos após a atualização
      _nomeController.clear();
      _valorController.clear();
      setState(() {
        _categoriaSelecionada = null; // Limpar a seleção da categoria
      });

      // Volta para a página anterior
      Navigator.pop(context); // Retorna para a página anterior
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
          title: const Text('Editar Produto', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          leading: Builder(
            builder: (BuildContext context) {
              return const Icon(Icons.brush, color: Colors.white);
            }
          ),
        ),
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(vertical: 30),
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
                          color: Colors.white
                        ),
                        controller: _nomeController,
                        decoration: const InputDecoration(
                          labelText: "Nome do produto",
                          focusColor: Colors.white,
                          labelStyle: const TextStyle(
                            color: Colors.white,
                            
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.white, // Cor da borda quando o campo está habilitado
                              width: 2,
                              style: BorderStyle.solid,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.white, // Cor da borda quando o campo está focado
                              width: 2,
                              style: BorderStyle.solid,
                            ),
                          ),
                          // Você pode adicionar também um border quando o campo está com erro, se desejar
                          errorBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
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
                            hint: const Padding(
                              padding: EdgeInsets.all(10),
                              child: Text(
                                "Selecione a Categoria", 
                                style: TextStyle(
                                  color: Colors.white
                                ),
                              )
                            ),
                            style: const TextStyle(
                              color: Colors.white,
                            ),
                            value: _categoriaSelecionada,
                            icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white,),
                            isExpanded: true,
                            underline: Container(
                              height: 0, // Altura do underline
                            ),
                            padding: const EdgeInsets.only(left: 10),
                            dropdownColor: Colors.orange[900],
                            items: _subprodutos.map((String subproduto) {
                              return DropdownMenuItem(
                                value: subproduto,
                                child: Text(subproduto)
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
                          labelStyle: const TextStyle(
                            color: Colors.white,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.white, // Cor da borda quando o campo está habilitado
                              width: 2,
                              style: BorderStyle.solid,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.white, // Cor da borda quando o campo está focado
                              width: 2,
                              style: BorderStyle.solid,
                            ),
                          ),
                          // Você pode adicionar também um border quando o campo está com erro, se desejar
                          errorBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
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
