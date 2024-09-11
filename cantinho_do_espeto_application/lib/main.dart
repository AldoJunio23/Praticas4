import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.symmetric(vertical: 30),
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            colors: [
              Colors.orange[900]!,
              Colors.orange[800]!,
              Colors.orange[400]!,
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const SizedBox(
              height: 20,
            ),
            const Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                children: <Widget>[
                  SizedBox(
                    height: 10,
                  ),

                  /////////////////////////////////////////////////////////////////////////////////////////////
                  /*
                  Text(
                    "Login",
                    style: TextStyle(
                        color: Colors.white,
                        //fontSize: 40,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                  */

                  /*
                  Text(
                    "Bem-Vindo ao Cantinho do Espeto",
                    //"Welcome Back",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                  */
                  /////////////////////////////////////////////////////////////////////////////////////////////

                  Center(
                    child: Text(
                      "Login - 08.09.2024",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 40,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Center(
                    child: Text(
                      "Bem-Vindo ao Cantinho do Espeto",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(60),
                    topRight: Radius.circular(60),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: <Widget>[
                      const SizedBox(
                        height: 20,
                      ),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: const [
                            BoxShadow(
                              color: Color.fromRGBO(225, 95, 27, .3),
                              blurRadius: 20,
                              offset: Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          children: <Widget>[
                            //const SizedBox(
                            //  height: 35,
                            //),
                            Container(
                              decoration: BoxDecoration(
                                border: Border(
                                    bottom:
                                        BorderSide(color: Colors.grey[200]!)),
                              ),
                              child: const TextField(
                                decoration: InputDecoration(
                                    hintText: "Email",
                                    hintStyle: TextStyle(color: Colors.grey),
                                    border: InputBorder.none),
                              ),
                            ),
                            const SizedBox(
                              height: 25.5,
                            ),

                            Container(
                              decoration: BoxDecoration(
                                border: Border(
                                    bottom:
                                        BorderSide(color: Colors.grey[200]!)),
                              ),
                              child: const TextField(
                                decoration: InputDecoration(
                                    hintText: "Password",
                                    hintStyle: TextStyle(color: Colors.grey),
                                    border: InputBorder.none),
                              ),
                            ),
                            const SizedBox(
                              height: 25.5,
                            ),
                            // aqui colocamos o PasswordField:
                            const PasswordField(),
                            const Text("App atual - 08.09.2024"),
                            const Text(
                              "Esqueceu sua senha? Clique aqui",
                              style: TextStyle(color: Colors.grey),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            const Text("Ainda não possui cadastro? Clique aqui",
                                style: TextStyle(color: Colors.grey)),
                            const SizedBox(
                              height: 25.5,
                            ),
                            Container(
                              height: 50,
                              width: 250,
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 50),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(50),
                                  color: Colors.orange[900]!),
                              child: const Center(
                                child: Text("Login",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    )),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//////////////////////////////////////////////////////////////////////////////////////////////////

// Widget para o campo de senha com o botão de mostrar e esconder a senha informada pelo usuário:

class PasswordField extends StatefulWidget {
  const PasswordField({super.key});

  @override
  _PasswordFieldState createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _obscureText = true;

  void _tooglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText; // passa a valer false
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      child: TextField(
        obscureText: _obscureText,
        decoration: InputDecoration(
            hintText: "Password",
            hintStyle: const TextStyle(color: Colors.grey),
            border: InputBorder.none,
            suffixIcon: IconButton(
              icon: Icon(
                _obscureText ? Icons.visibility_off : Icons.visibility,
              ),
              onPressed: _tooglePasswordVisibility,
            )),
      ),
    );
  }
}
