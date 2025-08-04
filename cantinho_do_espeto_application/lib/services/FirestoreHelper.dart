import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreHelper {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Método para buscar documentos de forma segura
  static Future<QuerySnapshot> safeQuery(Query query) async {
    try {
      return await query.get();
    } catch (e) {
      print('Erro na consulta Firestore: $e');
      rethrow;
    }
  }

  // Método para buscar um documento específico
  static Future<DocumentSnapshot> safeGetDocument(DocumentReference ref) async {
    try {
      return await ref.get();
    } catch (e) {
      print('Erro ao buscar documento: $e');
      rethrow;
    }
  }

  // Método para atualizar documento
  static Future<void> safeUpdate(DocumentReference ref, Map<String, dynamic> data) async {
    try {
      await ref.update(data);
    } catch (e) {
      print('Erro ao atualizar documento: $e');
      rethrow;
    }
  }

  // Stream wrapper para mesas
  static Stream<QuerySnapshot> getMesasStream() {
    return _firestore
        .collection('Mesas')
        .where('status', isEqualTo: true)
        .snapshots();
  }

  // Stream wrapper para pedidos
  static Stream<QuerySnapshot> getPedidosStream() {
    return _firestore
        .collection('Pedidos')
        .orderBy('dataCriacao', descending: true)
        .snapshots();
  }

  // Método para buscar informações da mesa
  static Future<Map<String, dynamic>> getMesaInfo(String mesaId) async {
    try {
      final mesaRef = _firestore.collection('Mesas').doc(mesaId);
      
      final pedidosQuery = await _firestore
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
      print('Erro ao buscar informações da mesa: $e');
      return {
        'totalPedidos': 0,
        'valorTotal': 0.0,
        'temPedidosPendentes': false,
      };
    }
  }

  // Método para fechar mesa
  static Future<void> fecharMesa(String mesaId) async {
    try {
      await _firestore.collection('Mesas').doc(mesaId).update({
        'status': false,
        'horaFechamento': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Erro ao fechar mesa: $e');
      rethrow;
    }
  }

  // Método para buscar pedidos de uma mesa
  static Future<List<QueryDocumentSnapshot>> getPedidosMesa(String mesaId) async {
    try {
      final mesaRef = _firestore.collection('Mesas').doc(mesaId);
      final pedidosQuery = await _firestore
          .collection('Pedidos')
          .where('mesa', isEqualTo: mesaRef)
          .get();
      
      return pedidosQuery.docs;
    } catch (e) {
      print('Erro ao buscar pedidos da mesa: $e');
      return [];
    }
  }

  // Método para buscar produtos de um pedido
  static Future<List<Map<String, dynamic>>> getProdutosPedido(List<DocumentReference> produtosRefs) async {
    List<Map<String, dynamic>> produtos = [];
    
    for (var ref in produtosRefs) {
      try {
        final doc = await ref.get();
        if (doc.exists) {
          final produto = doc.data() as Map<String, dynamic>;
          produtos.add(produto);
        }
      } catch (e) {
        print('Erro ao buscar produto: $e');
        produtos.add({
          'nome': 'Produto não encontrado',
          'valor': 0.0,
        });
      }
    }
    
    return produtos;
  }
}