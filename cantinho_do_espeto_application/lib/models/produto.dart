// models/produto.dart
class Produto {
  final String nome;
  final double valor;

  Produto({
    required this.nome,
    required this.valor,
  });

  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'valor': valor,
    };
  }

  static Produto fromMap(Map<String, dynamic> map) {
    return Produto(
      nome: map['nome'],
      valor: map['valor'],
    );
  }
}
