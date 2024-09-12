import 'package:flutter/material.dart';

void main() {
  runApp(const MaterialApp(debugShowCheckedModeBanner: false, home: TelaInicio()));
}

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: TelaInicio(),
    );
  }

class TelaInicio extends StatefulWidget {
  const TelaInicio({super.key});

  @override
  TelaInicioState createState() => TelaInicioState();
}

class TelaInicioState extends State<TelaInicio> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Início"),
      ),
      body: Center(
        child: const Text('Hello World!'),
      ),
    );
  }
}
