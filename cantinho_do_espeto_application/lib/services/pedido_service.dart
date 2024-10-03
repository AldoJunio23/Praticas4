import 'package:cloud_firestore/cloud_firestore.dart';

class PedidoService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Cria um novo pedido
  Future<void> criarPedido({
    required List<DocumentReference<Object?>> listaProdutos,
    required DocumentReference mesa,
    required double valorTotal,
  }) async {
    try {
      await _firestore.collection('Pedidos').add({
        'finalizado': false,
        'horario': FieldValue.serverTimestamp(),
        'listaProdutos': listaProdutos, // Aqui estamos passando a lista correta de DocumentReference
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
        // Conversão manual de lista dinâmica para lista de DocumentReference<Object?>
        List<DocumentReference<Object?>> listaProdutos = [];
        if (pedidoData['listaProdutos'] is List) {
          listaProdutos = (pedidoData['listaProdutos'] as List)
              .where((produto) => produto is DocumentReference<Object?>)
              .map((produto) => produto as DocumentReference<Object?>)
              .toList();
        }

        pedidos.add({
          'id': pedidoDoc.id,
          'mesa': pedidoData['mesa'], // Certifique-se de que mesa está sendo recuperado corretamente
          'listaProdutos': listaProdutos, // Passa a lista corrigida
          'horario': pedidoData['horario'],
          'valorTotal': pedidoData['valorTotal'],
          'finalizado': pedidoData['finalizado'],
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
      await _firestore.collection('Pedidos').doc(pedidoId).update({
        'finalizado': true,
      });
      print('Pedido finalizado com sucesso!');
    } catch (e) {
      print("Erro ao finalizar pedido: $e");
    }
  }
}
