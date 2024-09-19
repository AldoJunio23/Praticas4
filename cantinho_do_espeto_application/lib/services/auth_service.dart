// ignore_for_file: avoid_print

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // ignore: unused_field
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<User?> cadastrarUsuario({
    required String senha,
    required String email,
  }) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: senha,
      );
      return userCredential.user;
    } catch (e) {
      print("Erro no cadastro: $e");
      return null;
    }
  }

  Future<User?> login({
    required String email,
    required String senha,
  }) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: senha,
      );
      return userCredential.user;
    } catch (e) {
      print("Erro no login: $e");
      return null;
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
      print('Usuário desconectado');
    } catch (e) {
      print('Erro ao fazer logout: $e');
    }
  }

  Future<void> resetPassword({required String email}) async {
  try {
    // Chama o método do Firebase para enviar o link de redefinição de senha
    await FirebaseAuth.instance.sendPasswordResetEmail(email: email.trim());
      print('Link de redefinição de senha enviado para o e-mail!');
  } on FirebaseAuthException catch (e) {
    // Tratamento de erros comuns
    if (e.code == 'user-not-found') {
      print('Usuário não encontrado para este e-mail.');
    } else {
      print('Erro: ${e.message}');
    }
  }

  }
}
