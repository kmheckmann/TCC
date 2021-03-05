import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tcc_3/acessorios/Cores.dart';
import 'package:tcc_3/screens/TelaCRUDCategoria.dart';
import 'package:tcc_3/model/Categoria.dart';

class TelaCategorias extends StatefulWidget {
  @override
  _TelaCategoriasState createState() => _TelaCategoriasState();
}

class _TelaCategoriasState extends State<TelaCategorias> {
  Cores cores = Cores();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //Botao para ir para a tela para adicionar novos registros
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          backgroundColor: Theme.of(context).primaryColor,
          onPressed: () {
            //Direciona para a tela para adicionar novos registros
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => TelaCRUDCategoria()),
            ).then((value) => setState(() {}));
          }),
      body: FutureBuilder<QuerySnapshot>(
          //O sistema ira acessar o documento "categorias"
          future: FirebaseFirestore.instance
              .collection("categorias")
              .orderBy("ativa", descending: true)
              .get(),
          builder: (context, snapshot) {
            //Como os dados serao buscados do firebase, pode ser que demore para obter
            //entao, enquanto os dados nao sao obtidos sera apresentado um circulo na tela
            //indicando que esta carregando
            if (!snapshot.hasData)
              return Center(
                child: CircularProgressIndicator(),
              );
            else
              return ListView.builder(
                  padding: EdgeInsets.all(4.0),
                  //Pega a quantidade de cidades
                  itemCount: snapshot.data.docs.length,
                  //Ira pegar cada cidade no firebase e retornar
                  itemBuilder: (context, index) {
                    Categoria categoria = Categoria.buscarFirebase(
                        snapshot.data.docs[index]);
                    return _construirListaCidades(
                        context, categoria, snapshot.data.docs[index]);
                  });
          }),
    );
  }

  Widget _construirListaCidades(
      contexto, Categoria c, DocumentSnapshot snapshot) {
    //Para cada categoria existente adicionar um card com a descricao e com o status da categoria
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
                    c.descricao,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: cores.corTitulo(c.ativa),
                        fontSize: 20.0),
                  ),
                  Text(
                    c.ativa ? "Ativa" : "Inativa",
                    style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w500,
                        color: cores.corSecundaria(c.ativa)),
                  ),
                ],
              ),
            ))
          ],
        ),
      ),
      onTap: () {
        //Ao clicar sobre o card direciona para a tela de edição
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  TelaCRUDCategoria(categoria: c, snapshot: snapshot)),
        ).then((value) => setState(() {}));
      },
    );
  }
}
