import 'package:flutter/material.dart';
//import 'package:firebase_auth/firebase_auth.dart'; // Importar o FirebaseAuth

class TelaEsqueci extends StatefulWidget {
  const TelaEsqueci({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _TelaEsqueciState createState() => _TelaEsqueciState();
}

class _TelaEsqueciState extends State<TelaEsqueci> {
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;
  String _statusMessage = '';

  // Método para enviar o link de redefinição de senha
  Future<void> _resetPassword() async {
    setState(() {
      _isLoading = true;
      _statusMessage = '';
    });

    /*try {
      // Chama o método do Firebase para enviar o link de redefinição de senha
      await FirebaseAuth.instance.sendPasswordResetEmail(email: _emailController.text.trim());
      setState(() {
        _statusMessage = 'Link de redefinição de senha enviado para o e-mail!';
        _isLoading = false;
      });
    } on FirebaseAuthException catch (e) {
      // Tratamento de erros comuns
      setState(() {
        if (e.code == 'user-not-found') {
          _statusMessage = 'Usuário não encontrado para este e-mail.';
        } else {
          _statusMessage = 'Erro: ${e.message}';
        }
        _isLoading = false;
      });
    }*/
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange[900], // Cor do AppBar da tela de login
        elevation: 0,
        title: const Text(
          "Redefinir Senha",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            colors: [
              Colors.orange[900]!, // Cor superior da tela de login
              Colors.orange[800]!, // Cor intermediária da tela de login
              Colors.orange[400]!, // Cor inferior da tela de login
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Informe seu e-mail para receber um link de redefinição de senha:",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: "E-mail",
                  labelStyle: const TextStyle(color: Colors.white),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.white),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.white),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.white),
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 20),
              _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: _resetPassword,
                        child: const Text(
                          "Enviar Link de Redefinição",
                          style: TextStyle(color: Colors.orangeAccent),
                        ),
                      ),
                    ),
              const SizedBox(height: 20),
              Text(
                _statusMessage,
                style: TextStyle(
                  fontSize: 16,
                  color: _statusMessage.contains('Erro') ? Colors.red : Colors.green,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}