import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_praticas/components/custom_drawer.dart';
import 'package:flutter_application_praticas/pages/crud_pages/alterar_page.dart';
import 'package:flutter_application_praticas/pages/crud_pages/criar_page.dart';
import 'package:intl/intl.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> _getAllProdutos() async {
    List<Map<String, dynamic>> allProdutos = [];
    final collectionNames = ['prod-bebida', 'prod-espetos', 'prod-porcoes', 'prod-caldo', 'prod-adicional'];
    final docNames = ['PoDiOnHmAULfo04IFIZy', 'r68ahS3Ck96LGZEVzZma', 'QftnnSomGsxfDhSmkhDQ', 'EI0XR8FLCNQJXJ0EbzHL', 'FFgYAgy1ACxpqOPfekEi'];

    for (int i = 0; i < collectionNames.length; i++) {
      QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore
          .collection("Produto")
          .doc(docNames[i])
          .collection(collectionNames[i])
          .get();

      for (var doc in snapshot.docs) {
        allProdutos.add({
          'id': doc.id,
          'docName': docNames[i],
          'collectionName': collectionNames[i],
          ...doc.data(),
        });
      }
    }
    return allProdutos;
  }

  void _deletarProduto(Map<String, dynamic> produto) async {
    await _firestore
        .collection('Produto')
        .doc(produto['docName'])
        .collection(produto['collectionName'])
        .doc(produto['id'])
        .delete();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Produto Excluído com Sucesso!')),
    );

    setState(() {});
  }

  void _editarProduto(Map<String, dynamic> produto) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AlterarProduto(
          idProduto: produto['id'],
          docName: produto['docName'],
          subCategoria: produto['collectionName'],
        ),
      ),
    );
  }

  void _adicionarProduto() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CriarProduto(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const CustomDrawer(),
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.orange[900]!.withOpacity(1),
              Colors.orange[900]!.withOpacity(0.9),
            ],
            stops: const [0.6, 1],
          ),
        ),
      ),
      title: const Text(
        'Administração',
        style: TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
      leading: Builder(
        builder: (BuildContext context) {
          return IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
            tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
          );
        },
      ),
    );
  }

  Widget _buildBody() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildHeader(),
          const SizedBox(height: 16.0),
          Expanded(child: _buildProdutoGrid()),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
      
        IconButton(
          icon: const Icon(
            Icons.add, 
            color: Colors.orange, 
            ),
          onPressed: _adicionarProduto,
          color: Colors.orange,
          iconSize: 36,
        ),
      ],
    );
  }

  Widget _buildProdutoGrid() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _getAllProdutos(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text("Erro ao carregar produtos"));
        }

        final produtos = snapshot.data!;
        return GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.7,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: produtos.length,
          itemBuilder: (context, index) {
            final produto = produtos[index];
            return _buildProdutoCard(produto);
          },
        );
      },
    );
  }

  Widget _buildProdutoCard(Map<String, dynamic> produto) {
  final nome = produto['nome'];
  final valor = double.parse(produto['valor'].toString());
  final disponivel = produto['disponivel'];
  final imagem = produto['imagem'].toString();
  String valorFormatado = NumberFormat("#,##0.00", "pt_BR").format(valor);

  return Card(
    margin: const EdgeInsets.all(8.0),
    child: Column(
      children: [
        _buildDisponibilidadeLabel(disponivel),
        const SizedBox(height: 10),
        Expanded(
          child: Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16), // Arredonda as bordas da imagem
              child: Image.network(imagem, width: 120, height: 120, fit: BoxFit.cover),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                nome,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              Text(
                "R\$ $valorFormatado",
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        _buildActionButtons(produto),
      ],
    ),
  );
}

Widget _buildActionButtons(Map<String, dynamic> produto) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 8.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8), // Arredonda o botão
            ),
          ),
          onPressed: () => _editarProduto(produto),
          child: const Icon(Icons.brush, color: Colors.white),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8), // Arredonda o botão
            ),
          ),
          onPressed: () => _deletarProduto(produto),
          child: const Icon(Icons.delete, color: Colors.white,),
        ),
      ],
    ),
  );
}

  Widget _buildDisponibilidadeLabel(bool disponivel) {
    return Container(
      padding: const EdgeInsets.all(5),
      alignment: Alignment.center,
      width: double.infinity,
      color: disponivel ? Colors.green : Colors.red,
      child: Text(
        disponivel ? "Disponível" : "Não Disponível",
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
      ),
    );
  }

}