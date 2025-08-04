import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_praticas/services/FirestoreHelper.dart';
import '../services/PrinterService.dart';

class TelaFecharMesas extends StatefulWidget {
  const TelaFecharMesas({super.key});

  @override
  State<TelaFecharMesas> createState() => _TelaFecharMesasState();
}

class _TelaFecharMesasState extends State<TelaFecharMesas> {
  bool _isLoading = false;
  String _loadingMesaId = '';
  final PrinterService _printerService = PrinterService();
  final List<Map<String, dynamic>> _mesasInfo = [];

  @override
  void initState() {
    super.initState();
    _initializePrinter();
  }

  Future<void> _initializePrinter() async {
    try {
      await _printerService.initializePrinter();
      if (mounted) {
        await _printerService.connectToPrinter(context);
      }
    } catch (e) {
      debugPrint('Erro ao inicializar impressora: $e');
    }
  }

  @override
  void dispose() {
    _printerService.disconnect();
    super.dispose();
  }

  Future<void> _loadMesasInfo(List<QueryDocumentSnapshot> mesasDocs) async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _mesasInfo.clear();
    });

    try {
      for (var mesaDoc in mesasDocs) {
        if (!mounted) break;

        final info = await _getMesaInfo(mesaDoc.id);
        if (mounted) {
          setState(() {
            _mesasInfo.add({
              'mesaId': mesaDoc.id,
              'mesaData': mesaDoc.data() as Map<String, dynamic>,
              'info': info,
            });
          });
        }
      }
    } catch (e) {
      debugPrint('Erro ao carregar informações das mesas: $e');
      if (mounted) {
        _showSnackBar('Erro ao carregar mesas', Colors.red);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildMesasAbertas() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirestoreHelper.getMesasStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.check_circle_outline,
                  size: 80,
                  color: Colors.green,
                ),
                SizedBox(height: 16),
                Text(
                  'Nenhuma mesa aberta',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Todas as mesas estão livres',
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          );
        }

        final docs = snapshot.data!.docs;
        docs.sort((a, b) {
          final aData = a.data() as Map<String, dynamic>;
          final bData = b.data() as Map<String, dynamic>;
          final aNum = aData['numMesa'] ?? 0;
          final bNum = bData['numMesa'] ?? 0;
          return aNum.compareTo(bNum);
        });

        // Carrega as informações apenas uma vez quando os dados chegam
        if (_mesasInfo.isEmpty && docs.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _loadMesasInfo(docs);
          });
        }

        if (_isLoading && _mesasInfo.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView.builder(
          itemCount: _mesasInfo.length,
          itemBuilder: (context, index) {
            final item = _mesasInfo[index];
            final mesaData = item['mesaData'];
            final info = item['info'] as Map<String, dynamic>;
            final numMesa = mesaData['numMesa']?.toString() ?? 'N/A';
            final horaAbertura = mesaData['horaAbertura'] as Timestamp?;
            final dataAbertura = horaAbertura?.toDate() ?? DateTime.now();
            final totalPedidos = info['totalPedidos'] as int;
            final valorTotal = info['valorTotal'] as double;
            final temPedidosPendentes = info['temPedidosPendentes'] as bool;

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: temPedidosPendentes 
                      ? Colors.orange[100] 
                      : Colors.green[100],
                  child: Text(
                    numMesa,
                    style: TextStyle(
                      color: temPedidosPendentes 
                          ? Colors.orange[800] 
                          : Colors.green[800],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text('Mesa $numMesa'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Aberta em: ${dataAbertura.day}/${dataAbertura.month}/${dataAbertura.year} ${dataAbertura.hour}:${dataAbertura.minute.toString().padLeft(2, '0')}',
                    ),
                    Text(
                      'Pedidos: $totalPedidos',
                    ),
                    if (temPedidosPendentes)
                      const Text(
                        'Possui pedidos pendentes',
                        style: TextStyle(
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'R\$ ${valorTotal.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: Colors.green[700],
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: _isLoading && _loadingMesaId == item['mesaId']
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.receipt_long),
                      onPressed: _isLoading
                          ? null
                          : () => _mostrarDialogoFechamento(
                              item['mesaId'], mesaData, info),
                    ),
                  ],
                ),
                onTap: _isLoading
                    ? null
                    : () => _mostrarDialogoFechamento(
                        item['mesaId'], mesaData, info),
              ),
            );
          },
        );
      },
    );
  }

  Future<Map<String, dynamic>> _getMesaInfo(String mesaId) async {
    try {
      final mesaRef = FirebaseFirestore.instance.collection('Mesas').doc(mesaId);
      
      final pedidosQuery = await FirebaseFirestore.instance
          .collection('Pedidos')
          .where('mesa', isEqualTo: mesaRef)
          .get();

      int totalPedidos = pedidosQuery.docs.length;
      double valorTotal = 0.0;
      bool temPedidosPendentes = false;

      for (var doc in pedidosQuery.docs) {
        final pedidoData = doc.data();
        valorTotal += (pedidoData['valorTotal']?.toDouble() ?? 0.0);
        
        if (!(pedidoData['finalizado'] ?? false)) {
          temPedidosPendentes = true;
        }
      }

      return {
        'totalPedidos': totalPedidos,
        'valorTotal': valorTotal,
        'temPedidosPendentes': temPedidosPendentes,
      };
    } catch (e) {
      debugPrint('Erro ao buscar informações da mesa: $e');
      return {
        'totalPedidos': 0,
        'valorTotal': 0.0,
        'temPedidosPendentes': false,
      };
    }
  }

  void _showSnackBar(String message, Color backgroundColor) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: backgroundColor,
        ),
      );
    }
  }

  Future<void> _mostrarDialogoFechamento(
      String mesaId, Map<String, dynamic> mesaData, Map<String, dynamic> info) async {
    final temPedidosPendentes = info['temPedidosPendentes'] as bool;
    
    if (temPedidosPendentes) {
      _mostrarDialogoPedidosPendentes();
      return;
    }

    final valorTotal = info['valorTotal'] as double;
    final numMesa = mesaData['numMesa']?.toString() ?? 'N/A';

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Fechar Mesa $numMesa'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Valor Total: R\$ ${valorTotal.toStringAsFixed(2)}'),
              const SizedBox(height: 16),
              const Text('Deseja fechar esta mesa e imprimir o olherite?'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _fecharMesa(mesaId, mesaData, info);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[800],
                foregroundColor: Colors.white,
              ),
              child: const Text('Fechar e Imprimir'),
            ),
          ],
        );
      },
    );
  }

  void _mostrarDialogoPedidosPendentes() {
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Não é possível fechar'),
          content: const Text(
            'Esta mesa possui pedidos pendentes. Finalize todos os pedidos antes de fechar a mesa.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _fecharMesa(
      String mesaId, Map<String, dynamic> mesaData, Map<String, dynamic> info) async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _loadingMesaId = mesaId;
    });

    try {
      final olherite = await _generateOlherite(mesaId, mesaData, info);
      
      if (!mounted) return;

      if (_printerService.isConnected) {
        await _printOlherite(olherite);
      }

      if (!mounted) return;

      await FirestoreHelper.fecharMesa(mesaId);

      _showSnackBar(
        _printerService.isConnected 
            ? 'Mesa fechada e olherite impresso com sucesso!'
            : 'Mesa fechada! Impressora não conectada.',
        _printerService.isConnected ? Colors.green : Colors.orange,
      );

      // Atualiza a lista após fechar a mesa
      final updatedMesas = _mesasInfo.where((m) => m['mesaId'] != mesaId).toList();
      if (mounted) {
        setState(() {
          _mesasInfo.clear();
          _mesasInfo.addAll(updatedMesas);
        });
      }
    } catch (e) {
      debugPrint('Erro ao fechar mesa: $e');
      _showSnackBar('Erro ao fechar mesa: $e', Colors.red);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _loadingMesaId = '';
        });
      }
    }
  }

  Future<String> _generateOlherite(
      String mesaId, Map<String, dynamic> mesaData, Map<String, dynamic> info) async {
    StringBuffer olherite = StringBuffer();
    
    final numMesa = mesaData['numMesa']?.toString() ?? 'N/A';
    final horaAbertura = mesaData['horaAbertura'] as Timestamp?;
    final dataAbertura = horaAbertura?.toDate() ?? DateTime.now();
    final horaFechamento = DateTime.now();
    final valorTotal = info['valorTotal'] as double;

    olherite.writeln('\n');
    olherite.writeln('=' * 30);
    olherite.writeln('         OLHERITE          '.toUpperCase());
    olherite.writeln('=' * 30);
    olherite.writeln('\n');

    olherite.writeln('MESA: $numMesa');
    olherite.writeln('ABERTURA: ${dataAbertura.day}/${dataAbertura.month}/${dataAbertura.year} ${dataAbertura.hour}:${dataAbertura.minute.toString().padLeft(2, '0')}');
    olherite.writeln('FECHAMENTO: ${horaFechamento.day}/${horaFechamento.month}/${horaFechamento.year} ${horaFechamento.hour}:${horaFechamento.minute.toString().padLeft(2, '0')}');
    olherite.writeln('\n');

    final duracao = horaFechamento.difference(dataAbertura);
    final horas = duracao.inHours;
    final minutos = duracao.inMinutes.remainder(60);
    olherite.writeln('TEMPO: ${horas}h ${minutos}min');
    olherite.writeln('\n');

    olherite.writeln('PEDIDOS CONSUMIDOS:');
    olherite.writeln('----------------------------');

    try {
      final pedidosQuery = await FirestoreHelper.getPedidosMesa(mesaId);

      for (var pedidoDoc in pedidosQuery) {
        if (!mounted) break;

        final Map<String, dynamic> pedidoData = pedidoDoc.data() as Map<String, dynamic>;
        final timestamp = pedidoData['dataCriacao'] as Timestamp?;
        final dataPedido = timestamp?.toDate() ?? DateTime.now();
        final valorPedido = pedidoData['valorTotal']?.toDouble() ?? 0.0;

        olherite.writeln('PEDIDO: ${pedidoDoc.id}');
        olherite.writeln('${dataPedido.hour}:${dataPedido.minute.toString().padLeft(2, '0')} - R\$ ${valorPedido.toStringAsFixed(2)}');

        final List<DocumentReference> produtosRefs = 
          List<DocumentReference>.from(pedidoData['listaProdutos'] ?? []);
        
        final produtos = await FirestoreHelper.getProdutosPedido(produtosRefs);
        
        for (var produto in produtos) {
          if (!mounted) break;

          final nome = produto['nome'] ?? 'Produto não encontrado';
          final valor = produto['valor']?.toDouble() ?? 0.0;
          
          olherite.writeln('  • $nome - R\$ ${valor.toStringAsFixed(2)}');
        }
        olherite.writeln('----------------------------');
      }
    } catch (e) {
      debugPrint('Erro ao gerar olherite: $e');
      olherite.writeln('Erro ao processar pedidos');
    }

    olherite.writeln('\n');
    olherite.writeln('TOTAL GERAL: R\$ ${valorTotal.toStringAsFixed(2)}');
    olherite.writeln('============================');
    olherite.writeln('\n');

    return olherite.toString();
  }

  Future<void> _printOlherite(String content) async {
    try {
      await _printerService.printContent(content);
    } catch (e) {
      debugPrint('Erro ao imprimir olherite: $e');
      _showSnackBar('Erro ao imprimir olherite: $e', Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fechar Mesas', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.red[800],
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _mesasInfo.clear();
              });
            },
          ),
        ],
      ),
      body: _buildMesasAbertas(),
    );
  }
}