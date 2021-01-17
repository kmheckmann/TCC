import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tcc_3/acessorios/Cores.dart';
import 'package:tcc_3/controller/ProdutoController.dart';
import 'package:tcc_3/model/Produto.dart';
import 'package:tcc_3/screens/TelaCRUDProduto.dart';

class TelaProdutos extends StatefulWidget {
  @override
  _TelaProdutosState createState() => _TelaProdutosState();
}

class _TelaProdutosState extends State<TelaProdutos> {
  Cores cores = Cores();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          backgroundColor: Theme.of(context).primaryColor,
          onPressed: () {
            Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => TelaCRUDProduto()));
          }),
      body: FutureBuilder<QuerySnapshot>(
          //O sistema ira acessar documentos e colecoes até chegar nos itens da categoria selecionada
          future: Firestore.instance.collection("produtos").orderBy("ativo",descending: true).getDocuments(),
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
                  itemCount: snapshot.data.documents.length,
                  //Ira pegar cada produto da categoria no firebase e retornar
                  itemBuilder: (context, index) {
                    Produto produto =
                        Produto.buscarFirebase(snapshot.data.documents[index]);
                    return _construirListaProdutos(
                        context, produto, snapshot.data.documents[index]);
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
                    p.descricao,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: cores.corTitulo(p.ativo),
                        fontSize: 20.0),
                  ),
                  Text(
                    "Código: ${p.codigo}",
                    style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w500,
                        color: cores.corSecundaria(p.ativo)),
                  ),
                  Text(
                    p.ativo ? "Ativo" : "Inativo",
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
        ProdutoController _prodController = ProdutoController();
        await _prodController.obterCategoria(p.id);
        p.categoria = _prodController.categoria;
        Navigator.of(contexto).push(MaterialPageRoute(
            builder: (contexto) =>
                TelaCRUDProduto(produto: p, snapshot: snapshot)));
      },
    );
  }
}
