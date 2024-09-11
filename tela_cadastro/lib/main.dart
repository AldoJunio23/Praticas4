import 'package:flutter/material.dart';

void main() {
  runApp(const MaterialApp(debugShowCheckedModeBanner: false, home: TelaCadastro()));
}

class TelaCadastro extends StatefulWidget {
  const TelaCadastro({super.key});

  @override
  TelaCadastroState createState() => TelaCadastroState();
}

class TelaCadastroState extends State<TelaCadastro> {
  // Controladores para os campos de texto
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();
  final TextEditingController _confSenhaController = TextEditingController();

  // Função que será chamada ao pressionar o botão "Criar"
  void _criarConta() {
    final nome = _nomeController.text;
    final email = _emailController.text;
    final senha = _senhaController.text;
    final confSenha = _confSenhaController.text;

    
    if (nome.isEmpty || email.isEmpty || senha.isEmpty || confSenha.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Todos os campos devem ser preenchidos.")),
      );
      return;
    }

    if (senha != confSenha) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("As senhas não coincidem.")),
      );
      return;
    }

   
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Conta criada com sucesso!")),
    );
  }

 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     backgroundColor: Colors.orange, // Define a cor de fundo para laranja
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(70),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            // Título e subtítulo
            Column(
              children: [
                const Text(
                  "Cadastro",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Bem-Vindo ao Cantinho do Espeto",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 15),
              child: TextField(
                controller: _nomeController,
                decoration: const InputDecoration(
                  labelText: "Nome do Usuário",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 15),
              child: TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: "Email",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 15),
              child: TextField(
                controller: _senhaController,
                obscureText: true, // Esconde a senha
                decoration: const InputDecoration(
                  labelText: "Senha",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 15),
              child: TextField(
                controller: _confSenhaController,
                obscureText: true, // Esconde a senha
                decoration: const InputDecoration(
                  labelText: "Confirmar Senha",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 25),
              child: ElevatedButton(
                onPressed: _criarConta,
                child: const Text(
                  "Criar",
                  style: TextStyle(fontSize: 20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

