import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tcc_3/controller/EstoqueProdutoController.dart';
import 'package:tcc_3/controller/ItemPedidoVendaController.dart';
import 'package:tcc_3/controller/PedidoVendaController.dart';
import 'package:tcc_3/controller/ProdutoController.dart';
import 'package:tcc_3/model/ItemPedido.dart';
import 'package:tcc_3/model/ItemPedidoVenda.dart';
import 'package:tcc_3/model/PedidoVenda.dart';
import 'package:tcc_3/model/Produto.dart';
import 'package:tcc_3/screens/TelaItensPedidoVenda.dart';

class TelaCRUDItemPedidoVenda extends StatefulWidget {
  final PedidoVenda pedidoVenda;
  final ItemPedido itemPedido;
  final DocumentSnapshot snapshot;

  TelaCRUDItemPedidoVenda({this.pedidoVenda, this.itemPedido, this.snapshot});
  @override
  _TelaCRUDItemPedidoVendaState createState() => _TelaCRUDItemPedidoVendaState(
      snapshot: snapshot, pedidoVenda: pedidoVenda, itemPedido: itemPedido);
}

class _TelaCRUDItemPedidoVendaState extends State<TelaCRUDItemPedidoVenda> {
  final DocumentSnapshot snapshot;
  PedidoVenda pedidoVenda;
  ItemPedidoVenda itemPedido;

  _TelaCRUDItemPedidoVendaState(
      {this.snapshot, this.pedidoVenda, this.itemPedido});

  String _dropdownValueProduto;
  double vlItemAntigo;
  final _controllerPreco = TextEditingController();
  final _controllerQtde = TextEditingController();
  final _controllerProd = TextEditingController();
  final _controllerProdQtde = TextEditingController();
  bool _novocadastro;
  bool _temEstoque = false;
  String _nomeTela;
  Produto produto = Produto();

  final _validadorCampos = GlobalKey<FormState>();
  final _scaffold = GlobalKey<ScaffoldState>();

  ProdutoController _controllerProduto = ProdutoController();
  ItemPedidoVendaController _controllerItemPedido = ItemPedidoVendaController();
  PedidoVendaController _controllerPedido = PedidoVendaController();
  EstoqueProdutoController _controllerEstoque = EstoqueProdutoController();
  @override
  void initState() {
    super.initState();
    if (itemPedido != null) {
      _controllerEstoque.obterEstoqueProduto(produto);
      _nomeTela = "Editar Produto";
      vlItemAntigo = itemPedido.preco;
      _dropdownValueProduto = itemPedido.produto.descricao;
      _controllerPreco.text = itemPedido.preco.toString();
      _controllerQtde.text = itemPedido.quantidade.toString();
      _controllerProdQtde.text = _controllerEstoque.qtdeExistente.toString();
      _novocadastro = false;
    } else {
      _nomeTela = "Novo Produto";
      itemPedido = ItemPedidoVenda(pedidoVenda);
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
          visible: pedidoVenda.pedidoFinalizado ? false : true,
          child: FloatingActionButton(
              child: Icon(Icons.save),
              backgroundColor: Colors.blue,
              onPressed: () async {
                if (_validadorCampos.currentState.validate()) {
                  if (_dropdownValueProduto != null) {
                    _codigoPersistir();
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
              _criarCampoQtdeExistente(),
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
                    height: 88.0,
                    child: DropdownButtonFormField(
                      decoration: InputDecoration(
                          labelText: "Produto",
                          labelStyle: TextStyle(color: Colors.blueGrey)),
                      value: _dropdownValueProduto,
                      onChanged: (String newValue) async {
                        //Ao selecionar o valor no dropdown busca o item correspondente
                        await _controllerProduto
                            .obterProdutoPorDescricao(newValue);
                        produto = _controllerProduto.produto;
                        //Faz o calculo do preco de venda e seta o valor no campo
                        await _controllerEstoque.obterPrecoVenda(produto);
                        _controllerPreco.text =
                            _controllerEstoque.precoVenda.toString();
                        setState(() {
                          _dropdownValueProduto = newValue;
                          _controllerProdQtde.text = _controllerEstoque
                              .retornarQtdeExistente(produto)
                              .toString();
                          itemPedido.labelListaProdutos = _dropdownValueProduto;
                        });
                      },
                      items: snapshot.data.documents
                          .map((DocumentSnapshot document) {
                        return DropdownMenuItem<String>(
                            value: document.data()['descricao'],
                            child: Container(
                              child: Text(
                                  document.documentID +
                                      ' - ' +
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

  TextStyle _style() {
    if (pedidoVenda.pedidoFinalizado) {
      return TextStyle(color: Colors.grey, fontSize: 17.0);
    } else {
      return TextStyle(color: Colors.black, fontSize: 17.0);
    }
  }

  Widget _criarCampoTexto(
      TextEditingController _controller, String titulo, TextInputType tipo) {
    return TextFormField(
      controller: _controller,
      enabled: pedidoVenda.pedidoFinalizado ? false : true,
      keyboardType: tipo,
      decoration: InputDecoration(
          hintText: titulo,
          labelText: titulo,
          labelStyle:
              TextStyle(color: Colors.blueGrey, fontWeight: FontWeight.w400)),
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

  Widget _criarCampoQtdeExistente() {
    return TextFormField(
      controller: _controllerProdQtde,
      enabled: false,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
          hintText: "Quantidade Existente",
          labelText: "Quantidade Existente",
          labelStyle:
              TextStyle(color: Colors.blueGrey, fontWeight: FontWeight.w400)),
      style: TextStyle(color: Colors.grey, fontSize: 17.0),
    );
  }

  Widget _campoProduto() {
    _controllerProd.text = _dropdownValueProduto;
    //se o pedido estiver finalizado sera criado um TextField com o valor
    //se não estiver, sera criado o dropDown
    if (pedidoVenda.pedidoFinalizado) {
      return _criarCampoTexto(_controllerProd, "Produto", TextInputType.text);
    } else {
      return _criarDropDownProduto();
    }
  }

  void _codigoPersistir() async {
    itemPedido.preco = double.parse(_controllerPreco.text);
    if (_novocadastro) {
      await _controllerItemPedido.obterProxID(pedidoVenda.id);
      itemPedido.id = _controllerItemPedido.proxID;
      _controllerPedido.somarPrecoNoVlTotal(pedidoVenda, itemPedido);
      pedidoVenda.valorTotal = _controllerPedido.pedidoVenda.valorTotal;
      pedidoVenda.valorComDesconto =
          _controllerPedido.pedidoVenda.valorComDesconto;
      _controllerItemPedido.persistirItem(itemPedido, pedidoVenda.id,
          produto.id, _controllerPedido.converterParaMapaPedidoVenda(pedidoVenda));
    } else {
      _controllerPedido.atualizarPrecoNoVlTotal(
          vlItemAntigo, pedidoVenda, itemPedido);
      pedidoVenda.valorTotal = _controllerPedido.pedidoVenda.valorTotal;
      pedidoVenda.valorComDesconto =
          _controllerPedido.pedidoVenda.valorComDesconto;
      _controllerItemPedido.persistirItem(itemPedido, pedidoVenda.id,
          produto.id, _controllerPedido.converterParaMapaPedidoVenda(pedidoVenda));
    }
    Navigator.of(context).pop(MaterialPageRoute(
        builder: (contexto) => TelaItensPedidovenda(pedidoVenda: pedidoVenda)));
  }
}
