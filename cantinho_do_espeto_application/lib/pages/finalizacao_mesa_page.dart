import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_praticas/components/custom_drawer.dart';
import 'package:flutter_application_praticas/pages/finalizar_mesa_page.dart';

class TelaFinalizacaoMesas extends StatefulWidget {
  const TelaFinalizacaoMesas({super.key});

  @override
  TelaFinalizacaoMesasState createState() => TelaFinalizacaoMesasState();
}

class TelaFinalizacaoMesasState extends State<TelaFinalizacaoMesas> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String?> _getPedidoId(String mesaId) async {
  try {
    String? pedidoId;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final mesaRef = _firestore.collection('Mesas').doc(mesaId);
      final pedidoQuery = await _firestore
          .collection('Pedidos')
          .where('mesa', isEqualTo: mesaRef)
          .where('finalizado', isEqualTo: false)
          .get();

      if (pedidoQuery.docs.isNotEmpty) {
        pedidoId = pedidoQuery.docs.first.id;
      }
    });

    return pedidoId;
  } catch (e) {
    debugPrint('Erro ao buscar pedido: $e');
    return null;
  }
}


  void _handleMesaTap(BuildContext context, String mesaId) async {
    try {
      final pedidoId = await _getPedidoId(mesaId);
      
      if (!mounted) return;

      if (pedidoId != null) {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FinalizarMesaPage(
              mesaId: mesaId,
              pedidoId: pedidoId,
            ),
          ),
        );

        if (!mounted) return;

        if (result == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Mesa finalizada com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Nenhum pedido encontrado para esta mesa'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao processar mesa: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const CustomDrawer(),
      appBar: AppBar(
        title: const Text(
          'Finalizar Mesas',
          style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.bottomRight,
              colors: [Colors.orange[900]!.withOpacity(1), Colors.orange[900]!.withOpacity(0.9)],
              stops: const [0.6, 1],
            ),
          ),
        ),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Colors.grey[100],
        ),
        child: StreamBuilder<QuerySnapshot>(
          stream: _firestore
              .collection('Mesas')
              .where('status', isEqualTo: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                ),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 60, color: Colors.red[300]),
                    const SizedBox(height: 16),
                    const Text(
                      'Erro ao carregar mesas.',
                      style: TextStyle(fontSize: 18),
                    ),
                    TextButton(
                      onPressed: () => setState(() {}),
                      child: const Text('Tentar novamente'),
                    ),
                  ],
                ),
              );
            }

            final mesas = snapshot.data?.docs ?? [];

            if (mesas.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle_outline, size: 60, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    const Text(
                      'Nenhuma mesa para finalizar',
                      style: TextStyle(fontSize: 18),
                    ),
                  ],
                ),
              );
            }

            return GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.0,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: mesas.length,
              itemBuilder: (context, index) {
                var mesa = mesas[index];

                return Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: InkWell(
                    onTap: () => _handleMesaTap(context, mesa.id),
                    borderRadius: BorderRadius.circular(15),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Colors.blue[400]!, Colors.blue[600]!],
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.point_of_sale,
                            size: 40,
                            color: Colors.white,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Mesa ${mesa['numMesa']}',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'Toque para finalizar',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}