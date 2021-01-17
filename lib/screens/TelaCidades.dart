import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tcc_3/acessorios/Cores.dart';
import 'package:tcc_3/model/Cidade.dart';
import 'package:tcc_3/screens/TelaCRUDCidade.dart';

class TelaCidades extends StatefulWidget {
  @override
  _TelaCidadesState createState() => _TelaCidadesState();
}

class _TelaCidadesState extends State<TelaCidades> {
  Cores cores = Cores();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //Botao para adicionar registros
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          backgroundColor: Theme.of(context).primaryColor,
          onPressed: () {
            //Direciona para a tela de cadastro
            Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => TelaCRUDCidade()));
            setState(() {});
          }),
      body: FutureBuilder<QuerySnapshot>(
          //O sistema ira acessar o documento "cidades"
          future: Firestore.instance.collection("cidades").orderBy("ativa",descending: true).getDocuments(),
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
                  itemCount: snapshot.data.documents.length,
                  //Ira pegar cada cidade no firebase e retornar
                  itemBuilder: (context, index) {
                    Cidade cidade =
                        Cidade.buscarFirebase(snapshot.data.documents[index]);
                    return _construirListaCidades(
                        context, cidade, snapshot.data.documents[index]);
                  });
          }),
    );
  }

  Widget _construirListaCidades(contexto, Cidade c, DocumentSnapshot snapshot) {
    //Pega cada cidade existe e monta um card com o nome e status da cidade
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
                    c.nome,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: cores.corTitulo(c.ativa),
                        fontSize: 20.0),
                  ),
                  Text(
                    c.estado,
                    style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w500,
                        color: cores.corSecundaria(c.ativa)),
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
        //ao clicar sobre o card direciona para a página de edição
        Navigator.of(contexto).push(MaterialPageRoute(
            builder: (contexto) =>
                TelaCRUDCidade(cidade: c, snapshot: snapshot)));
        setState(() {});
      },
    );
  }
}
