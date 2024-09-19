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
}
