import 'package:cloud_firestore/cloud_firestore.dart';

class PedidoService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Cria um novo pedido
  Future<void> criarPedido({
    required List<DocumentReference> listaProdutos,
    required DocumentReference mesa,
    required double valorTotal,
  }) async {
    try {
      // Cria um novo documento na coleção 'pedidos'
      await _firestore.collection('pedidos').add({
        'finalizado': false,
        'horario': FieldValue.serverTimestamp(), // Define o horário como timestamp do servidor
        'listaProdutos': listaProdutos,
        'mesa': mesa,
        'valorTotal': valorTotal,
      });
      print('Pedido criado com sucesso!');
    } catch (e) {
      print("Erro ao criar pedido: $e");
    }
  }

  // Busca todos os pedidos
  Future<List<Map<String, dynamic>>> buscarPedidos() async {
    try {
      QuerySnapshot pedidosSnapshot = await _firestore.collection('Pedidos').get();
      List<Map<String, dynamic>> pedidos = [];

      for (QueryDocumentSnapshot pedidoDoc in pedidosSnapshot.docs) {
        Map<String, dynamic> pedidoData = pedidoDoc.data() as Map<String, dynamic>;

        pedidos.add({
          'id': pedidoDoc.id,
          ...pedidoData,
        });
      }

      return pedidos;
    } catch (e) {
      print("Erro ao buscar pedidos: $e");
      return [];
    }
  }

  // Finaliza um pedido
  Future<void> finalizarPedido(String pedidoId) async {
    try {
      await _firestore.collection('pedidos').doc(pedidoId).update({
        'finalizado': true,
      });
      print('Pedido finalizado com sucesso!');
    } catch (e) {
      print("Erro ao finalizar pedido: $e");
    }
  }
}
