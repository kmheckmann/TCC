import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tcc_3/acessorios/Auxiliares.dart';
import 'package:tcc_3/acessorios/Campos.dart';
import 'package:tcc_3/acessorios/Cores.dart';
import 'package:tcc_3/controller/ItemPedidoCompraController.dart';
import 'package:tcc_3/controller/ObterProxIDController.dart';
import 'package:tcc_3/controller/PedidoCompraController.dart';
import 'package:tcc_3/controller/ProdutoController.dart';
import 'package:tcc_3/model/ItemPedido.dart';
import 'package:tcc_3/model/ItemPedidoCompra.dart';
import 'package:tcc_3/model/PedidoCompra.dart';
import 'package:tcc_3/model/Produto.dart';
import 'package:tcc_3/screens/TelaItensPedidoCompra.dart';
import 'package:flutter/services.dart';

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

  final _controllerPreco = TextEditingController();
  final _controllerQtde = TextEditingController();
  final _controllerProd = TextEditingController();
  final _validadorCampos = GlobalKey<FormState>();
  final _scaffold = GlobalKey<ScaffoldState>();
  //mascara usada para impedir que sejam usados espaços, virgulas ou hifens no campo preço
  final maskPreco =
      FilteringTextInputFormatter.deny(new RegExp('[\\-|\\ |\\,]'));
  //mascara usada para impedir que sejam usados espaços, virgulas, hifens ou pontos no campo quantidade
  final maskQtde =
      FilteringTextInputFormatter.deny(new RegExp('[\\-|\\ |\\,|\\.]'));
  String _dropdownValueProduto;
  double vlItemAntigo;
  bool _novocadastro;
  String _nomeTela;
  Produto produto = Produto();

  ProdutoController _controllerProduto = ProdutoController();
  ItemPedidoCompraController _controllerItemPedido =
      ItemPedidoCompraController();
  PedidoCompraController _controllerPedido = PedidoCompraController();
  ObterProxIDController proxIDController = ObterProxIDController();
  Auxiliares aux = Auxiliares();
  Cores cor = Cores();
  Campos campos = Campos();

  @override
  void initState() {
    super.initState();
    if (itemPedido != null) {
      _nomeTela = "Editar Produto";
      vlItemAntigo = itemPedido.preco;
      _dropdownValueProduto =
          itemPedido.produto.getID + ' - ' + itemPedido.produto.getDescricao;
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
          visible: pedidoCompra.getPedidoFinalizado ? false : true,
          child: FloatingActionButton(
              child: Icon(Icons.save),
              backgroundColor: Colors.blue,
              onPressed: () async {
                if (_dropdownValueProduto != null) {
                  await _controllerProduto.obterProdutoPorID(
                      terminou: whenCompleteObterProduto,
                      id: _dropdownValueProduto);
                }

                if (_validadorCampos.currentState.validate()) {
                  if (_dropdownValueProduto != null) {
                    if (_novocadastro) {
                      await proxIDController.obterProxID(FirebaseFirestore
                          .instance
                          .collection("pedidos")
                          .doc(pedidoCompra.getID)
                          .collection("itens"));
                      itemPedido.id = proxIDController.proxID;
                      _controllerPedido.somarPrecoNoVlTotal(
                          pedidoCompra, itemPedido);
                      pedidoCompra.setValorTotal =
                          _controllerPedido.pedidoCompra.getValorTotal;
                      pedidoCompra.setValorDesconto =
                          _controllerPedido.pedidoCompra.getValorDesconto;
                      _controllerItemPedido.persistirItem(
                          itemPedido,
                          pedidoCompra.getID,
                          produto.getID,
                          _controllerPedido.converterParaMapa(pedidoCompra));
                    } else {
                      _controllerPedido.atualizarPrecoNoVlTotal(
                          vlItemAntigo, pedidoCompra, itemPedido);
                      pedidoCompra.setValorTotal =
                          _controllerPedido.pedidoCompra.getValorTotal;
                      pedidoCompra.setValorDesconto =
                          _controllerPedido.pedidoCompra.getValorDesconto;
                      _controllerItemPedido.persistirItem(
                          itemPedido,
                          pedidoCompra.getID,
                          produto.getID,
                          _controllerPedido.converterParaMapa(pedidoCompra));
                    }
                    Navigator.of(context).pop(MaterialPageRoute(
                        builder: (contexto) =>
                            TelaItensPedidoCompra(pedidoCompra: pedidoCompra)));
                  } else {
                    aux.exibirBarraMensagem(
                        "É necessário selecionar um produto!",
                        Colors.red,
                        _scaffold);
                  }
                }
              })),
      body: Form(
          key: _validadorCampos,
          child: ListView(
            padding: EdgeInsets.all(8.0),
            children: <Widget>[
              _campoProduto(),
              !pedidoCompra.getPedidoFinalizado
                  ? _criarCampoTexto(_controllerPreco, "Preço",
                      TextInputType.number, maskPreco)
                  : campos.campoTextoDesabilitado(
                      _controllerPreco, "Preço", false),
              !pedidoCompra.getPedidoFinalizado
                  ? _criarCampoTexto(_controllerQtde, "Quantidade",
                      TextInputType.number, maskQtde)
                  : campos.campoTextoDesabilitado(
                      _controllerQtde, "Quantidade", false),
            ],
          )),
    );
  }

  Widget _criarDropDownProduto() {
    return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("produtos")
            .where("ativo", isEqualTo: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else {
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
                                ' - ' +
                                document.data()['descricao'],
                            child: Container(
                              child: Text(
                                  document.id +
                                      ' - ' +
                                      document.data()['descricao'],
                                  style: TextStyle(
                                      color: cor.corCampo(true),
                                      fontSize: 17.0)),
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

  Widget _criarCampoTexto(TextEditingController _controller, String titulo,
      TextInputType tipo, FilteringTextInputFormatter mask) {
    return TextFormField(
      controller: _controller,
      inputFormatters: [mask],
      enabled: pedidoCompra.getPedidoFinalizado ? false : true,
      keyboardType: tipo,
      decoration: InputDecoration(hintText: titulo),
      style: TextStyle(color: cor.corCampo(true), fontSize: 17.0),
      validator: (text) {
        if (_controller.text.isEmpty)
          return "É necessário preencher este campo!";
      },
      onChanged: (texto) {
        if (texto.isNotEmpty) {
          if (titulo == "Preço") itemPedido.preco = double.parse(texto);
          if (titulo == "Quantidade") itemPedido.quantidade = int.parse(texto);
        }
      },
    );
  }

  Widget _campoProduto() {
    _controllerProd.text = _dropdownValueProduto;
    //se o pedido estiver finalizado sera criado um TextField com o valor
    //se não estiver, sera criado o dropDown
    if (pedidoCompra.getPedidoFinalizado) {
      return campos.campoTextoDesabilitado(_controllerProd, "Produto", false);
    } else {
      return _criarDropDownProduto();
    }
  }

  void whenCompleteObterProduto() {
    produto = _controllerProduto.produto;
    itemPedido.labelListaProdutos = produto.getDescricao;
  }
}
