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
  double valorTotalPedidos = 0.0;
  DocumentReference? mesaRef;
  

  @override
  void initState() {
    super.initState();
    _loadMesaReference();
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


  Future<List<Map<String, dynamic>>> _processarPedidos(List<QueryDocumentSnapshot> pedidos) async {
    Map<String, Map<String, dynamic>> produtosMap = {};
    double total = 0;

    for (var pedido in pedidos) {
      final pedidoData = pedido.data() as Map<String, dynamic>;
      final List<DocumentReference> produtosRefs = 
        List<DocumentReference>.from(pedidoData['listaProdutos'] ?? []);

      for (var ref in produtosRefs) {
        final doc = await ref.get();
        if (doc.exists) {
          final produto = doc.data() as Map<String, dynamic>;
          final produtoId = doc.id;
          
          if (produtosMap.containsKey(produtoId)) {
            produtosMap[produtoId]!['quantidade'] = 
              (produtosMap[produtoId]!['quantidade'] as int) + 1;
          } else {
            produtosMap[produtoId] = {
              ...produto,
              'quantidade': 1,
              'id': produtoId,
            };
          }
          
          total += produto['valor']?.toDouble() ?? 0.0;
        }
      }
    }

    setState(() {
      valorTotalPedidos = total;
      isLoading = false;
    });

    return produtosMap.values.toList();
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


  // Detalhes da Mesa
  final mesaDoc = await mesaRef?.get();
  final mesaData = mesaDoc?.data() as Map<String, dynamic>?;
  final numMesa = mesaData?['numMesa'] ?? 'N/A';
  conteudo.writeln('MESA: $numMesa');
  conteudo.writeln('\nPRODUTOS');
  conteudo.writeln('-' * 30);

  // Buscar produtos novamente para garantir dados atualizados
  QuerySnapshot pedidosSnapshot = await FirebaseFirestore.instance
      .collection('Pedidos')
      .where('mesa', isEqualTo: mesaRef)
      .where('finalizado', isEqualTo: false)
      .get();

  List<Map<String, dynamic>> produtos = await _processarPedidos(pedidosSnapshot.docs);

  for (var produto in produtos) {
    conteudo.writeln('${produto['nome']} (x${produto['quantidade']})');
    conteudo.writeln('UN: R\$ ${produto['valor'].toStringAsFixed(2)}');
    conteudo.writeln('SUB: R\$ ${(produto['valor'] * produto['quantidade']).toStringAsFixed(2)}');
    conteudo.writeln('-' * 30);
  }

  conteudo.writeln('\nTOTAL: R\$ ${valorTotalPedidos.toStringAsFixed(2)}');
  conteudo.writeln('\n${'=' * 30}');

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
            style: TextStyle(fontWeight: FontWeight.bold),
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
                'Total a pagar: R\$ ${valorTotalPedidos.toStringAsFixed(2)}',
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
              child: const Text('Cancelar', style: TextStyle(color: Colors.red)),
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
        title: const Text('Finalizar Mesa', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.orange[900],
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Pedidos')
            .where('mesa', isEqualTo: mesaRef)
            .where('finalizado', isEqualTo: false)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Nenhum pedido encontrado para esta mesa'));
          }

          final pedidos = snapshot.data!.docs;
          
          return FutureBuilder<List<Map<String, dynamic>>>(
            future: _processarPedidos(pedidos),
            builder: (context, processedSnapshot) {
              if (!processedSnapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final produtos = processedSnapshot.data!;
              
              return Column(
                children: [
                  _buildTotalHeader(),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: produtos.length,
                      itemBuilder: (context, index) => _buildProdutoCard(produtos[index]),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
      bottomNavigationBar: _buildBottomButton(),
    );
  }
  Widget _buildTotalHeader() {
    return Container(
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
            'R\$ ${valorTotalPedidos.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.orange[900],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProdutoCard(Map<String, dynamic> produto) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            produto['imagem'] ?? '',
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
              'Preço unitário: R\$ ${produto['valor'].toStringAsFixed(2)}',
              style: TextStyle(color: Colors.grey[600]),
            ),
            Text(
              'Subtotal: R\$ ${(produto['valor'] * produto['quantidade']).toStringAsFixed(2)}',
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
            'x${produto['quantidade']}',
            style: TextStyle(
              color: Colors.orange[900],
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomButton() {
    return Container(
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
        onPressed: _confirmarFinalizacao,
        child: const Text(
          'Finalizar Mesa',
          style: TextStyle(
            fontSize: 18,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

}