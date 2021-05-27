import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tcc_3/acessorios/Auxiliares.dart';
import 'package:tcc_3/controller/EstoqueProdutoController.dart';
import 'package:tcc_3/controller/ProdutoController.dart';
import 'package:tcc_3/model/EstoqueProduto.dart';
import 'package:tcc_3/model/Produto.dart';
import 'package:tcc_3/screens/TelaEstoque.dart';

class TelaFiltroEstoque extends StatefulWidget {
  final List<EstoqueProduto> estoques = [];
  @override
  _TelaFiltroEstoqueState createState() =>
      _TelaFiltroEstoqueState(this.estoques);
}

class _TelaFiltroEstoqueState extends State<TelaFiltroEstoque> {
  EstoqueProdutoController _controllerEstoque = EstoqueProdutoController();
  ProdutoController _controllerProduto = ProdutoController();
  final _scaffold = GlobalKey<ScaffoldState>();
  Auxiliares aux = Auxiliares();
  Produto p = Produto();
  List<EstoqueProduto> estoques;
  String _dropdownValueProduto;

  _TelaFiltroEstoqueState(this.estoques);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffold,
      //Botão para consultar
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.arrow_forward),
          backgroundColor: Theme.of(context).primaryColor,
          //Ao clicar no botao para consultar
          //Se não tiver selecionado o produto uma mensagem sera apresentada
          //e a consulta nao sera realizada
          onPressed: () async {
            if (_dropdownValueProduto == null) {
              aux.exibirBarraMensagem(
                  "Informe o filtro", Colors.red, _scaffold);
            } else {
              //Se tiver informado o filtro
              //O as informações do produto selecionado são buscados
              await _controllerProduto.obterProdutoPorID(
                  id: _dropdownValueProduto,
                  terminou: whenCompleteObterproduto);

              //Apos obter as infos do produto
              //Obtem o estoque  
              await _controllerEstoque.obterEstoqueProduto(
                  p: p, terminou: whenCompleteObterEstoqueprod);

              //Direciona o user para a tela de listagem de estoque 
              //Com a lista contendo os lotes de estoque
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => TelaEstoque(
                        estoques: estoques,
                      )));
            }
          }),
      body: Padding(
        padding: EdgeInsets.fromLTRB(10.0, 0, 0, 3.0),
        child: _criarDropDownProduto(),
      ),
    );
  }

  Widget _criarDropDownProduto() {
    return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("produtos")
            .where("ativo", isEqualTo: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return Center(
              child: CircularProgressIndicator(),
            );
          else {
            var length = snapshot.data.docs.length;
            DocumentSnapshot ds = snapshot.data.docs[length - 1];
            return Container(
              padding: EdgeInsets.fromLTRB(0.0, 8.0, 8.0, 0.0),
              child: Row(
                children: <Widget>[
                  Container(
                    width: 336.0,
                    child: DropdownButton(
                      value: _dropdownValueProduto,
                      hint: Text("Selecionar produto"),
                      onChanged: (String newValue) {
                        setState(() {
                          _dropdownValueProduto = newValue;
                        });
                      },
                      items:
                          snapshot.data.docs.map((DocumentSnapshot document) {
                        return DropdownMenuItem<String>(
                            value: document.id +
                                " - " +
                                document.data()['descricao'],
                            child: Container(
                              child: Text(
                                  document.id +
                                      " - " +
                                      document.data()['descricao'],
                                  style: TextStyle(color: Colors.black)),
                            ));
                      }).toList(),
                    ),
                  ),
                ],
              ),
            );
          }
        });
  }

  void whenCompleteObterproduto() {
    p = _controllerProduto.produto;
  }

  void whenCompleteObterEstoqueprod() {
    this.estoques = _controllerEstoque.getEstoques;
  }
}
