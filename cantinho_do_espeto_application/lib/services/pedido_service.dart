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
              .whereType<DocumentReference<Object?>>()
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

  // Busca um pedido específico pelo ID da mesa
  Future<Map<String, dynamic>?> buscarPedidoPorMesa(DocumentReference mesaRef) async {
    try {
      QuerySnapshot pedidosSnapshot = await _firestore
          .collection('Pedidos')
          .where('mesa', isEqualTo: mesaRef)  // Filtra os pedidos pela referência da mesa
          .get();

      if (pedidosSnapshot.docs.isNotEmpty) {
        // Se houver pedidos relacionados à mesa, retorna o primeiro (pode ajustar conforme necessário)
        QueryDocumentSnapshot pedidoDoc = pedidosSnapshot.docs.first;
        Map<String, dynamic> pedidoData = pedidoDoc.data() as Map<String, dynamic>;

        // Converte a lista de produtos para uma lista de DocumentReference<Object?>
        List<DocumentReference<Object?>> listaProdutos = [];
        if (pedidoData['listaProdutos'] is List) {
          listaProdutos = (pedidoData['listaProdutos'] as List)
              .whereType<DocumentReference<Object?>>()
              .map((produto) => produto as DocumentReference<Object?>)
              .toList();
        }

        return {
          'id': pedidoDoc.id,
          'mesa': pedidoData['mesa'], // Certifique-se de que a referência da mesa está correta
          'listaProdutos': listaProdutos, // Lista de produtos corrigida
          'horario': pedidoData['horario'],
          'valorTotal': pedidoData['valorTotal'],
          'finalizado': pedidoData['finalizado'],
        };
      } else {
        print("Nenhum pedido encontrado para essa mesa.");
        return null;
      }
    } catch (e) {
      print("Erro ao buscar pedido por mesa: $e");
      return null;
    }
  }

  // Busca um pedido específico pelo ID do pedido
  Future<Map<String, dynamic>?> buscarPedidoPorId(String? pedidoId) async {
    try {
      // Pega o documento do pedido com o ID fornecido
      DocumentSnapshot pedidoDoc = await _firestore.collection('Pedidos').doc(pedidoId).get();

      if (pedidoDoc.exists) {
        Map<String, dynamic> pedidoData = pedidoDoc.data() as Map<String, dynamic>;

        // Converte a lista de produtos para uma lista de DocumentReference<Object?>
        List<DocumentReference<Object?>> listaProdutos = [];
        if (pedidoData['listaProdutos'] is List) {
          listaProdutos = (pedidoData['listaProdutos'] as List)
              .whereType<DocumentReference<Object?>>()
              .map((produto) => produto as DocumentReference<Object?>)
              .toList();
        }

        return {
          'id': pedidoDoc.id,
          'mesa': pedidoData['mesa'], // Certifique-se de que a referência da mesa está correta
          'listaProdutos': listaProdutos, // Lista de produtos corrigida
          'horario': pedidoData['horario'],
          'valorTotal': pedidoData['valorTotal'],
          'finalizado': pedidoData['finalizado'],
        };
      } else {
        print("Pedido não encontrado.");
        return null;
      }
    } catch (e) {
      print("Erro ao buscar pedido por ID: $e");
      return null;
    }
  }

}
