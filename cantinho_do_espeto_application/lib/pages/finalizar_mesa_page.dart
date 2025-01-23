import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/PrinterService.dart';

class FinalizarMesaPage extends StatefulWidget {
  final String mesaId;
  final String pedidoId;

  const FinalizarMesaPage({
    super.key,
    required this.mesaId,
    required this.pedidoId,
  });

  @override
  State<FinalizarMesaPage> createState() => _FinalizarMesaPageState();
}

class _FinalizarMesaPageState extends State<FinalizarMesaPage> {
  final PrinterService _printerService = PrinterService();
  bool isLoading = true;
  List<Map<String, dynamic>> allProducts = [];
  double totalAllOrders = 0.0;
  DocumentReference? mesaRef;

  @override
  void initState() {
    super.initState();
    _loadMesaReference();
    _carregarTodosPedidos();
    _initializePrinter();
  }

  Future<void> _initializePrinter() async {
    await _printerService.initializePrinter();
    if (mounted) {
      await _printerService.connectToPrinter(context);
    }
  }

  @override
  void dispose() {
    _printerService.disconnect();
    super.dispose();
  }

  Future<void> _loadMesaReference() async {
    mesaRef = FirebaseFirestore.instance.collection('Mesas').doc(widget.mesaId);
  }

  Future<void> _carregarTodosPedidos() async {
    setState(() => isLoading = true);
    try {
      QuerySnapshot pedidosSnapshot = await FirebaseFirestore.instance
          .collection('Pedidos')
          .where('mesa', isEqualTo: mesaRef)
          .get();

      List<Map<String, dynamic>> todosProdutos = [];
      Map<String, int> produtoQuantidades = {};
      Map<String, double> produtoPrecos = {};
      double total = 0.0;

      for (var pedidoDoc in pedidosSnapshot.docs) {
        Map<String, dynamic> pedido = pedidoDoc.data() as Map<String, dynamic>;
        List<DocumentReference> produtosRefs = List<DocumentReference>.from(pedido['listaProdutos'] ?? []);

        for (var produtoRef in produtosRefs) {
          DocumentSnapshot produtoDoc = await produtoRef.get();
          if (produtoDoc.exists) {
            Map<String, dynamic> produtoData = produtoDoc.data() as Map<String, dynamic>;
            String produtoId = produtoDoc.id;
            String nome = produtoData['nome'] ?? 'Produto desconhecido';
            double preco = produtoData['valor']?.toDouble() ?? 0.0;
            String imagemUrl = produtoData['imagem'] ?? '';

            produtoQuantidades[produtoId] = (produtoQuantidades[produtoId] ?? 0) + 1;
            produtoPrecos[produtoId] = preco;

            if (!todosProdutos.any((p) => p['id'] == produtoId)) {
              todosProdutos.add({
                'id': produtoId,
                'nome': nome,
                'preco': preco,
                'imagem': imagemUrl,
              });
            }

            total += preco;
          }
        }
      }

      for (var produto in todosProdutos) {
        String produtoId = produto['id'];
        produto['qtd'] = produtoQuantidades[produtoId] ?? 0;
        produto['subtotal'] = (produtoQuantidades[produtoId] ?? 0) * (produtoPrecos[produtoId] ?? 0.0);
      }

      setState(() {
        allProducts = todosProdutos;
        totalAllOrders = total;
        isLoading = false;
      });

    } catch (e) {
      print('Erro ao carregar todos os pedidos: $e');
      setState(() => isLoading = false);
    }
  }

  Future<void> _finalizarMesa() async {
  setState(() => isLoading = true);

  try {
    // Existing finalization logic...
    await FirebaseFirestore.instance
        .collection('Mesas')
        .doc(widget.mesaId)
        .update({'status': false});

    // Finalizar todos os pedidos da mesa
    QuerySnapshot pedidosSnapshot = await FirebaseFirestore.instance
        .collection('Pedidos')
        .where('mesa', isEqualTo: mesaRef)
        .where('finalizado', isEqualTo: false)
        .get();

    WriteBatch batch = FirebaseFirestore.instance.batch();
    
    for (var doc in pedidosSnapshot.docs) {
      batch.update(doc.reference, {
        'finalizado': true,
        'listaProdutos': [],
        'dataFinalizacao': FieldValue.serverTimestamp(),
      });
    }
    
    await batch.commit();

    // Print the order if printer is connected
    if (_printerService.isConnected) {
      final conteudo = await _generateFinalizacaoContent();
      await _printOrder(conteudo);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Impressora não está conectada'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Mesa finalizada com sucesso!'),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.of(context).pop(true);
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Erro ao finalizar mesa: $e'),
        backgroundColor: Colors.red,
      ),
    );
    setState(() => isLoading = false);
  }
}

Future<String> _generateFinalizacaoContent() async {
  StringBuffer conteudo = StringBuffer();

  conteudo.writeln('\n');  
  conteudo.writeln('=' * 30); 
  conteudo.writeln('    FECHAMENTO DE MESA    '.toUpperCase());
  conteudo.writeln('=' * 30);
  conteudo.writeln('\n');

  // Date and Time
  final now = DateTime.now();
  conteudo.writeln('DATA: ${now.day}/${now.month}/${now.year}'.toUpperCase());
  conteudo.writeln('HORA: ${now.hour}:${_formatMinute(now.minute)}'.toUpperCase());
  conteudo.writeln('\n');

  // Mesa Details
  conteudo.writeln('MESA: ${widget.mesaId}');
  conteudo.writeln('\n');

  // Products Details
  conteudo.writeln('DETALHAMENTO');
  conteudo.writeln('----------------------------');

  for (var produto in allProducts) {
    conteudo.writeln('${produto['nome']} (x${produto['qtd']})');
    conteudo.writeln('UN: R\$ ${produto['preco'].toStringAsFixed(2)}');
    conteudo.writeln('SUBTOTAL: R\$ ${produto['subtotal'].toStringAsFixed(2)}');
    conteudo.writeln('----------------------------');
  }

  // Total
  conteudo.writeln('\nTOTAL: R\$ ${totalAllOrders.toStringAsFixed(2)}');
  conteudo.writeln('\n============================');

  return conteudo.toString();
}

// Helper method to format minute with leading zero
String _formatMinute(int minute) {
  return minute < 10 ? '0$minute' : minute.toString();
}

// Add this method to handle printing
Future<void> _printOrder(String content) async {
  try {
    final bytes = await _printerService.printContent(content);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Fechamento de mesa enviado para impressora'),
          backgroundColor: Colors.green,
        ),
      );
    }
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao imprimir: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

  Future<void> _confirmarFinalizacao() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Confirmar Finalização',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Tem certeza que deseja finalizar esta mesa?',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 12),
              Text(
                'Total a pagar: R\$ ${totalAllOrders.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancelar',
                style: TextStyle(color: Colors.red),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _finalizarMesa();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: const Text('Confirmar'),
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        title: const Text(
          'Finalizar Mesa',
          style: TextStyle(color: Colors.white),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.orange[900]!, Colors.orange[800]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total a Pagar',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'R\$ ${totalAllOrders.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange[900],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: allProducts.length,
                    itemBuilder: (context, index) {
                      final produto = allProducts[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              produto['imagem'],
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(
                                width: 50,
                                height: 50,
                                color: Colors.grey[200],
                                child: const Icon(Icons.error),
                              ),
                            ),
                          ),
                          title: Text(
                            produto['nome'],
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Preço unitário: R\$ ${produto['preco'].toStringAsFixed(2)}',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                ),
                              ),
                              Text(
                                'Subtotal: R\$ ${produto['subtotal'].toStringAsFixed(2)}',
                                style: const TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          trailing: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.orange[100],
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'x${produto['qtd']}',
                              style: TextStyle(
                                color: Colors.orange[900],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: _confirmarFinalizacao, // Alterado para chamar o diálogo de confirmação
          child: const Text(
            'Finalizar Mesa',
            style: TextStyle(
              fontSize: 18,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}