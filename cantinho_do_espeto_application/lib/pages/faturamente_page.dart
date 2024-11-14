import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_praticas/components/custom_drawer.dart';

class FaturamentoDiarioPage extends StatefulWidget {
  const FaturamentoDiarioPage({super.key});

  @override
  _FaturamentoDiarioPageState createState() => _FaturamentoDiarioPageState();
}

class _FaturamentoDiarioPageState extends State<FaturamentoDiarioPage> {
  List<Map<String, dynamic>> _pedidosDoDia = [];
  double _faturamentoTotal = 0.0;
  DateTime _dataSelecionada = DateTime.now();

  @override
  void initState() {
    super.initState();
    _obterPedidosDoDia();
  }

  Future<void> _selecionarData() async {
    final DateTime? dataSelecionada = await showDatePicker(
      context: context,
      initialDate: _dataSelecionada,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.orange[900]!,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (dataSelecionada != null && dataSelecionada != _dataSelecionada) {
      setState(() {
        _dataSelecionada = dataSelecionada;
      });
      _obterPedidosDoDia();
    }
  }

  Future<void> _obterPedidosDoDia() async {
    // Ajuste a data para a meia-noite do dia selecionado
    final inicioDoDia = DateTime(_dataSelecionada.year, _dataSelecionada.month, _dataSelecionada.day);
    final fimDoDia = inicioDoDia.add(const Duration(days: 1));

    final snapshot = await FirebaseFirestore.instance
        .collection('Pedidos')
        .where('dataCriacao', isGreaterThanOrEqualTo: inicioDoDia)
        .where('dataCriacao', isLessThan: fimDoDia)
        .get();

    double faturamentoTotal = 0.0;
    List<Map<String, dynamic>> pedidosDoDia = [];

    for (var doc in snapshot.docs) {
      final pedido = doc.data();
      pedidosDoDia.add(pedido);
      faturamentoTotal += (pedido['valorTotal'] ?? 0);
    }

    setState(() {
      _pedidosDoDia = pedidosDoDia;
      _faturamentoTotal = faturamentoTotal;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const CustomDrawer(),
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
                  width: 1,
                ),
              ),
            ),
          ),
          title: const Text(
            'Histórico de Faturamento', 
            style: TextStyle(
              color: Colors.white, 
              fontSize: 22, 
              fontWeight: FontWeight.bold
            )
          ),
          leading: Builder(
            builder: (BuildContext context) {
              return IconButton(
                icon: const Icon(Icons.menu, color: Colors.white),
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
                tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
              );
            },
          ),
        ),
      ), 
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Botão para selecionar a data
            ElevatedButton.icon(
              onPressed: _selecionarData,
              icon: const Icon(Icons.calendar_today),
              label: Text(
                'Data: ${_dataSelecionada.day}/${_dataSelecionada.month}/${_dataSelecionada.year}',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange[900],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Faturamento do Dia: R\$ ${_faturamentoTotal.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Text(
              'Pedidos do Dia',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: _pedidosDoDia.isEmpty
                ? const Center(
                    child: Text(
                      'Nenhum pedido encontrado nesta data',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: _pedidosDoDia.length,
                    itemBuilder: (context, index) {
                      final pedido = _pedidosDoDia[index];
                      final valor = pedido['valorTotal'] ?? 0;
                      final dataCriacao = (pedido['dataCriacao'] as Timestamp).toDate();
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: ListTile(
                          title: Text(
                            'Pedido ${index + 1} - R\$ ${valor.toStringAsFixed(2)}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            'Data: ${dataCriacao.day}/${dataCriacao.month}/${dataCriacao.year}',
                          ),
                        ),
                      );
                    },
                  ),
            ),
          ],
        ),
      ),
    );
  }
}