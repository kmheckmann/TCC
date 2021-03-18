import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tcc_3/acessorios/Cores.dart';
import 'package:tcc_3/controller/CategoriaController.dart';
import 'package:tcc_3/controller/ProdutoController.dart';
import 'package:tcc_3/model/Produto.dart';
import 'package:tcc_3/screens/TelaCRUDProduto.dart';

class TelaProdutos extends StatefulWidget {
  @override
  _TelaProdutosState createState() => _TelaProdutosState();
}

class _TelaProdutosState extends State<TelaProdutos> {
  ProdutoController _prodController = ProdutoController();
  Cores cores = Cores();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          backgroundColor: Theme.of(context).primaryColor,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => TelaCRUDProduto()),
            ).then((value) => setState(() {}));
          }),
      body: FutureBuilder<QuerySnapshot>(
          //O sistema ira acessar documentos e colecoes até chegar nos itens da categoria selecionada
          future: FirebaseFirestore.instance
              .collection("produtos")
              .orderBy("ativo", descending: true)
              .get(),
          //O FutureBuilder do tipo QuerySnapshot eh para obter todos os itens de uma colecao,
          //no caso a colecao itens dentro da categoria
          builder: (context, snapshot) {
            //Como os dados serao buscados do direbase, pode ser que demore para obter
            //entao, enquanto os dados nao sao obtidos sera apresentado um circulo na tela
            //indicando que esta carregando
            if (!snapshot.hasData)
              return Center(
                child: CircularProgressIndicator(),
              );
            else
              return ListView.builder(
                  padding: EdgeInsets.all(4.0),
                  //Pega a quantidade de produtos
                  itemCount: snapshot.data.docs.length,
                  //Ira pegar cada produto da categoria no firebase e retornar
                  itemBuilder: (context, index) {
                    Produto produto =
                        Produto.buscarFirebase(snapshot.data.docs[index]);
                    return _construirListaProdutos(
                        context, produto, snapshot.data.docs[index]);
                  });
          }),
    );
  }

  Widget _construirListaProdutos(
      contexto, Produto p, DocumentSnapshot snapshot) {
    return InkWell(
      //InkWell eh pra dar uma animacao quando clicar no produto
      child: Card(
        child: Row(
          children: <Widget>[
            //Flexible eh para quebrar a linha caso a descricao do produto seja maior que a largura da tela
            Flexible(
                //padding: EdgeInsets.all(8.0),
                child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    p.getDescricao,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: cores.corTitulo(p.getAtivo),
                        fontSize: 20.0),
                  ),
                  Text(
                    "Código: ${p.getID}",
                    style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w500,
                        color: cores.corSecundaria(p.getAtivo)),
                  ),
                  Text(
                    p.getAtivo ? "Ativo" : "Inativo",
                    style:
                        TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ))
          ],
        ),
      ),
      onTap: () async {
        CategoriaController _catController = CategoriaController();
        await _prodController.obterCategoria(p.getID);
        await _catController
            .obterCategoria(_prodController.getIdCategoriaProduto);
        p.setCategoria = _catController.getCategoria;
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  TelaCRUDProduto(produto: p, snapshot: snapshot)),
        ).then((value) => setState(() {}));
      },
    );
  }
}
