import 'package:cloud_firestore/cloud_firestore.dart';

class Pedido {
  final String mesa;
  final DateTime dataCriacao;
  final bool finalizado;
  final List<DocumentReference> listaProdutos;
  final double valorTotal;

  Pedido({
    required this.mesa,
    required this.dataCriacao,
    required this.finalizado,
    required this.listaProdutos,
    required this.valorTotal,
  });

  Map<String, dynamic> toMap() {
    return {
      'mesa': mesa,
      'dataCriacao': FieldValue.serverTimestamp(),
      'finalizado': finalizado,
      'listaProdutos': listaProdutos,
      'valorTotal': valorTotal,
    };
  }

  static Pedido fromMap(Map<String, dynamic> map) {
    return Pedido(
      mesa: map['mesa'],
      dataCriacao: (map['dataCriacao'] as Timestamp).toDate(),
      finalizado: map['finalizado'],
      listaProdutos: List<DocumentReference>.from(map['listaProdutos']),
      valorTotal: map['valorTotal'],
    );
  }
}