import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tcc_3/controller/ItemPedidoCompraController.dart';
import 'package:tcc_3/controller/PedidoCompraController.dart';
import 'package:tcc_3/controller/ProdutoController.dart';
import 'package:tcc_3/model/ItemPedido.dart';
import 'package:tcc_3/model/ItemPedidoCompra.dart';
import 'package:tcc_3/model/PedidoCompra.dart';
import 'package:tcc_3/model/Produto.dart';
import 'package:tcc_3/screens/TelaItensPedidoCompra.dart';

class TelaCRUDItemPedidoCompra extends StatefulWidget {
  final PedidoCompra pedidoCompra;
  final ItemPedido itemPedido;
  final DocumentSnapshot snapshot;

  TelaCRUDItemPedidoCompra({this.pedidoCompra, this.itemPedido, this.snapshot});

  @override
  _TelaCRUDItemPedidoCompraState createState() =>
      _TelaCRUDItemPedidoCompraState(
          snapshot: snapshot,
          pedidoCompra: pedidoCompra,
          itemPedido: itemPedido);
}

class _TelaCRUDItemPedidoCompraState extends State<TelaCRUDItemPedidoCompra> {
  final DocumentSnapshot snapshot;
  PedidoCompra pedidoCompra;
  ItemPedidoCompra itemPedido;

  _TelaCRUDItemPedidoCompraState(
      {this.snapshot, this.pedidoCompra, this.itemPedido});

  String _dropdownValueProduto;
  double vlItemAntigo;
  final _controllerPreco = TextEditingController();
  final _controllerQtde = TextEditingController();
  final _controllerProd = TextEditingController();
  bool _novocadastro;
  String _nomeTela;
  Produto produto = Produto();

  final _validadorCampos = GlobalKey<FormState>();
  final _scaffold = GlobalKey<ScaffoldState>();

  ProdutoController _controllerProduto = ProdutoController();
  ItemPedidoCompraController _controllerItemPedido =
      ItemPedidoCompraController();
  PedidoCompraController _controllerPedido = PedidoCompraController();

  @override
  void initState() {
    super.initState();
    if (itemPedido != null) {
      _nomeTela = "Editar Produto";
      vlItemAntigo = itemPedido.preco;
      _dropdownValueProduto = itemPedido.produto.getDescricao;
      _controllerPreco.text = itemPedido.preco.toString();
      _controllerQtde.text = itemPedido.quantidade.toString();
      _novocadastro = false;
    } else {
      _nomeTela = "Novo Produto";
      itemPedido = ItemPedidoCompra(pedidoCompra);
      _novocadastro = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffold,
      appBar: AppBar(
        title: Text(_nomeTela),
        centerTitle: true,
      ),
      floatingActionButton: Visibility(
          visible: pedidoCompra.pedidoFinalizado ? false : true,
          child: FloatingActionButton(
              child: Icon(Icons.save),
              backgroundColor: Colors.blue,
              onPressed: () async {
                await _controllerProduto
                    .obterProdutoPorDescricao(_dropdownValueProduto);
                produto = _controllerProduto.produto;

                if (_validadorCampos.currentState.validate()) {
                  if (_dropdownValueProduto != null) {
                    if (_novocadastro) {
                      await _controllerItemPedido.obterProxID(pedidoCompra.id);
                      itemPedido.id = _controllerItemPedido.proxID;
                      _controllerPedido.somarPrecoNoVlTotal(
                          pedidoCompra, itemPedido);
                      pedidoCompra.valorTotal =
                          _controllerPedido.pedidoCompra.valorTotal;
                      pedidoCompra.valorComDesconto =
                          _controllerPedido.pedidoCompra.valorComDesconto;
                      _controllerItemPedido.persistirItem(
                          itemPedido,
                          pedidoCompra.id,
                          produto.getID,
                          _controllerPedido.converterParaMapa(pedidoCompra));
                    } else {
                      _controllerPedido.atualizarPrecoNoVlTotal(
                          vlItemAntigo, pedidoCompra, itemPedido);
                      pedidoCompra.valorTotal =
                          _controllerPedido.pedidoCompra.valorTotal;
                      pedidoCompra.valorComDesconto =
                          _controllerPedido.pedidoCompra.valorComDesconto;
                      _controllerItemPedido.persistirItem(
                          itemPedido,
                          pedidoCompra.id,
                          produto.getID,
                          _controllerPedido.converterParaMapa(pedidoCompra));
                    }
                    Navigator.of(context).pop(MaterialPageRoute(
                        builder: (contexto) =>
                            TelaItensPedidoCompra(pedidoCompra: pedidoCompra)));
                  } else {
                    _scaffold.currentState.showSnackBar(SnackBar(
                      content: Text("É necessário selecionar um produto!"),
                      backgroundColor: Colors.red,
                      duration: Duration(seconds: 5),
                    ));
                  }
                }
              })),
      body: Form(
          key: _validadorCampos,
          child: ListView(
            padding: EdgeInsets.all(8.0),
            children: <Widget>[
              _campoProduto(),
              _criarCampoTexto(_controllerPreco, "Preço", TextInputType.number),
              _criarCampoTexto(
                  _controllerQtde, "Quantidade", TextInputType.number),
            ],
          )),
    );
  }

  Widget _criarDropDownProduto() {
    return StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance
            .collection("produtos")
            .where("ativo", isEqualTo: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else {
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
                          itemPedido.labelListaProdutos = _dropdownValueProduto;
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

  TextStyle _style() {
    if (pedidoCompra.pedidoFinalizado) {
      return TextStyle(color: Colors.grey, fontSize: 17.0);
    } else {
      return TextStyle(color: Colors.black, fontSize: 17.0);
    }
  }

  Widget _criarCampoTexto(
      TextEditingController _controller, String titulo, TextInputType tipo) {
    return TextFormField(
      controller: _controller,
      enabled: pedidoCompra.pedidoFinalizado ? false : true,
      keyboardType: tipo,
      decoration: InputDecoration(hintText: titulo),
      style: _style(),
      validator: (text) {
        if (_controller.text.isEmpty)
          return "É necessário preencher este campo!";
      },
      onChanged: (texto) {
        if (titulo == "Preço") itemPedido.preco = double.parse(texto);
        if (titulo == "Quantidade") itemPedido.quantidade = int.parse(texto);
      },
    );
  }

  Widget _campoProduto() {
    _controllerProd.text = _dropdownValueProduto;
    //se o pedido estiver finalizado sera criado um TextField com o valor
    //se não estiver, sera criado o dropDown
    if (pedidoCompra.pedidoFinalizado) {
      return _criarCampoTexto(_controllerProd, "Produto", TextInputType.text);
    } else {
      return _criarDropDownProduto();
    }
  }
}
