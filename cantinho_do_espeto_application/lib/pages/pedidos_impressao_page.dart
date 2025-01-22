import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class TelaPedidosTxt extends StatefulWidget {
  const TelaPedidosTxt({super.key});

  @override
  State<TelaPedidosTxt> createState() => _TelaPedidosTxtState();
}

class _TelaPedidosTxtState extends State<TelaPedidosTxt> with SingleTickerProviderStateMixin {
  bool _isLoading = false;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pedidos para Exportação', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.orange[900],
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Pedidos por Mesa'),
            Tab(text: 'Pedidos por Cliente'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPedidosList(true), // Lista de pedidos por mesa
          _buildPedidosList(false), // Lista de pedidos por cliente
        ],
      ),
    );
  }

  Widget _buildPedidosList(bool isMesaPedidos) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Pedidos')
          .orderBy('dataCriacao', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('Nenhum pedido encontrado'));
        }

        // Filtra os pedidos baseado na aba selecionada
        final filteredDocs = snapshot.data!.docs.where((doc) {
          final pedidoData = doc.data() as Map<String, dynamic>;
          final temMesa = pedidoData['mesa'] != null;
          final temNomeCliente = pedidoData['nomeCliente'] != null;
          
          if (isMesaPedidos) {
            return temMesa && !temNomeCliente; // Apenas pedidos por mesa
          } else {
            return temNomeCliente; // Apenas pedidos com nome de cliente
          }
        }).toList();

        if (filteredDocs.isEmpty) {
          return Center(
            child: Text(
              isMesaPedidos 
                ? 'Nenhum pedido por mesa encontrado' 
                : 'Nenhum pedido por cliente encontrado'
            ),
          );
        }

        return ListView.builder(
          itemCount: filteredDocs.length,
          itemBuilder: (context, index) {
            final pedido = filteredDocs[index];
            final pedidoData = pedido.data() as Map<String, dynamic>;
            final mesaRef = pedidoData['mesa'] as DocumentReference?;
            final valorTotal = pedidoData['valorTotal']?.toDouble() ?? 0.0;
            final timestamp = pedidoData['dataCriacao'] as Timestamp?;
            final data = timestamp?.toDate() ?? DateTime.now();
            final finalizado = pedidoData['finalizado'] ?? false;

            return FutureBuilder<String>(
              future: isMesaPedidos
                  ? _getNumMesa(mesaRef)
                  : Future.value(pedidoData['nomeCliente']),
              builder: (context, nomeSnapshot) {
                final nome = nomeSnapshot.data ?? 'Carregando...';

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.orange[100],
                      child: Text(nome.isNotEmpty ? nome[0].toUpperCase() : '?'),
                    ),
                    title: Text(nome),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Data: ${data.day}/${data.month}/${data.year} ${data.hour}:${data.minute}',
                        ),
                        Text(
                          'Status: ${finalizado ? 'Finalizado' : 'Em andamento'}',
                          style: TextStyle(
                            color: finalizado ? Colors.green : Colors.orange,
                          ),
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'R\$ ${valorTotal.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: Colors.green[700],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.text_snippet),
                          onPressed: _isLoading
                              ? null
                              : () => _gerarTxtPedido(pedido.id, pedidoData),
                        ),
                      ],
                    ),
                    onTap: _isLoading
                        ? null
                        : () => _gerarTxtPedido(pedido.id, pedidoData),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Future<String> _getNumMesa(DocumentReference? mesaRef) async {
    if (mesaRef == null) {
      return 'Mesa não encontrada';
    }

    try {
      final mesaDoc = await mesaRef.get();
      if (!mesaDoc.exists) {
        return 'Mesa não encontrada';
      }

      final mesaData = mesaDoc.data() as Map<String, dynamic>;
      return 'Mesa ${mesaData['numMesa']?.toString() ?? 'Número não definido'}';
    } catch (e) {
      return 'Erro ao buscar mesa';
    }
  }

  Future<void> _gerarTxtPedido(String pedidoId, Map<String, dynamic> pedidoData) async {
    setState(() => _isLoading = true);

    try {
      // Gerar conteúdo do texto
      StringBuffer conteudo = StringBuffer();

      // Cabeçalho
      conteudo.writeln('============================');
      conteudo.writeln('       PEDIDO #$pedidoId      ');
      conteudo.writeln('============================\n');

      // Data e hora
      final timestamp = pedidoData['dataCriacao'] as Timestamp?;
      final data = timestamp?.toDate() ?? DateTime.now();
      conteudo.writeln('Data: ${data.day}/${data.month}/${data.year}');
      conteudo.writeln('Hora: ${data.hour}:${data.minute}\n');

      // Dados do cliente
      conteudo.writeln('CLIENTE');
      conteudo.writeln('Nome: ${pedidoData['nomeCliente']}');
      if (pedidoData['telefoneCliente'] != null) {
        conteudo.writeln('Tel: ${pedidoData['telefoneCliente']}');
      }
      conteudo.writeln('\nPRODUTOS');
      conteudo.writeln('----------------------------');

      // Produtos
      final List<DocumentReference> produtosRefs = 
        List<DocumentReference>.from(pedidoData['listaProdutos'] ?? []);
      
      for (var ref in produtosRefs) {
        final doc = await ref.get();
        if (doc.exists) {
          final produto = doc.data() as Map<String, dynamic>;
          final nome = produto['nome'];
          final preco = produto['preco']?.toDouble() ?? 0.0;
          
          conteudo.writeln(nome);
          conteudo.writeln('R\$ ${preco.toStringAsFixed(2)}');
          conteudo.writeln('----------------------------');
        }
      }

      // Total
      final valorTotal = pedidoData['valorTotal']?.toDouble() ?? 0.0;
      conteudo.writeln('\nTOTAL: R\$ ${valorTotal.toStringAsFixed(2)}');
      conteudo.writeln('\n============================');

      // Salvar arquivo
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/pedido_$pedidoId.txt');
      await file.writeAsString(conteudo.toString());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Arquivo salvo em: ${file.path}'),
            action: SnackBarAction(
              label: 'OK',
              onPressed: () {},
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao gerar arquivo: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }
}