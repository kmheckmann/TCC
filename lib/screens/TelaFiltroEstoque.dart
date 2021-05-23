import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tcc_3/controller/EstoqueProdutoController.dart';
import 'package:tcc_3/controller/ProdutoController.dart';
import 'package:tcc_3/model/EstoqueProduto.dart';
import 'package:tcc_3/model/Produto.dart';
import 'package:tcc_3/screens/TelaEstoque.dart';

class TelaFiltroEstoque extends StatefulWidget {
  final List<EstoqueProduto> estoques = List();
  @override
  _TelaFiltroEstoqueState createState() =>
      _TelaFiltroEstoqueState(this.estoques);
}

class _TelaFiltroEstoqueState extends State<TelaFiltroEstoque> {
  EstoqueProdutoController _controllerEstoque = EstoqueProdutoController();
  ProdutoController _controllerProduto = ProdutoController();
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
      //Botão para consultar
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.arrow_forward),
          backgroundColor: Theme.of(context).primaryColor,
          onPressed: () async {
            //Ao clicar no botão para consultar, se houver algo selecionado vai buscar as informações do produto
            //E direcionar para a tela que apresenta os resultados com o produto filtrado
            await _controllerProduto
                .obterProdutoPorID(id: _dropdownValueProduto);
            p = _controllerProduto.produto;
            await _controllerEstoque.obterEstoqueProduto(p);
            this.estoques = _controllerEstoque.estoques;
            //Se nenhum produto for selecionado, vai apresentar na tela todos os produtos existentes
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => TelaEstoque(
                      estoques: estoques,
                    )));
          }),
      body: Padding(
        padding: EdgeInsets.fromLTRB(10.0, 0, 0, 3.0),
        child: _criarDropDownProduto(),
      ),
    );
  }

  Widget _criarDropDownProduto() {
    return StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance
            .collection("produtos")
            .where("ativo", isEqualTo: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return Center(
              child: CircularProgressIndicator(),
            );
          else {
            var length = snapshot.data.documents.length;
            DocumentSnapshot ds = snapshot.data.documents[length - 1];
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
                      items: snapshot.data.documents
                          .map((DocumentSnapshot document) {
                        return DropdownMenuItem<String>(
                            value: document.data()['descricao'],
                            child: Container(
                              child: Text(document.data()['descricao'],
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
}
