import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tcc_3/acessorios/Cores.dart';
import 'package:tcc_3/controller/CidadeController.dart';
import 'package:tcc_3/controller/EmpresaController.dart';
import 'package:tcc_3/model/Empresa.dart';
import 'package:tcc_3/screens/TelaCRUDEmpresa.dart';

class TelaEmpresas extends StatefulWidget {
  @override
  _TelaEmpresasState createState() => _TelaEmpresasState();
}

class _TelaEmpresasState extends State<TelaEmpresas> {
  Cores cores = Cores();
  EmpresaController _empresaController = EmpresaController();
  CidadeController _cidadeController = CidadeController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //Cria botão para adicionar registro
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          backgroundColor: Theme.of(context).primaryColor,
          onPressed: () {
            //Ao pressionar o botão encaminha para a tela de cadastro/edição
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => TelaCRUDEmpresa()),
            ).then((value) => setState(() {}));
          }),
      body: FutureBuilder<QuerySnapshot>(
          //O sistema ira acessar o documento "empresas"
          future: FirebaseFirestore.instance
              .collection("empresas")
              .orderBy("ativo", descending: true)
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
                  itemCount: snapshot.data.documents.length,
                  //Ira pegar cada cidade no firebase e retornar na ela dentro de um card
                  itemBuilder: (context, index) {
                    Empresa empresa =
                        Empresa.buscarFirebase(snapshot.data.documents[index]);
                    return _construirListaEmpresas(
                        context, empresa, snapshot.data.documents[index]);
                  });
          }),
    );
  }

  Widget _construirListaEmpresas(
      contexto, Empresa e, DocumentSnapshot snapshot) {
    return InkWell(
      //InkWell eh pra dar uma animacao quando clicar na empresa
      child: Card(
        child: Row(
          children: <Widget>[
            //Flexible eh para quebrar a linha caso a descricao da empresa seja maior que a largura da tela
            Flexible(
                //padding: EdgeInsets.all(8.0),
                child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Column(
                //Lista as informações da empresa dentro de um card
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    e.getRazaoSocial,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: cores.corTitulo(e.getAtivo),
                        fontSize: 20.0),
                  ),
                  Text(
                    e.getAtivo ? "Ativa" : "Inativa",
                    style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w500,
                        color: cores.corSecundaria(e.getAtivo)),
                  ),
                ],
              ),
            ))
          ],
        ),
      ),
      onTap: () async {
        //Ao clicar no card encaminha para a tela de edição
        //Busca algumas informações necessárias da empresa antes de ir para a tela de edição
        await _empresaController.obterIDCidadeEmpresa(e.getId);
        await _cidadeController
            .obterCidade(_empresaController.getCidadeEmpresa);
        e.setCidade = _cidadeController.getCidade;
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  TelaCRUDEmpresa(empresa: e, snapshot: snapshot)),
        ).then((value) => setState(() {}));
      },
    );
  }
}