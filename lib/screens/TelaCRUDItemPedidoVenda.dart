import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tcc_3/acessorios/Auxiliares.dart';
import 'package:tcc_3/acessorios/Campos.dart';
import 'package:tcc_3/acessorios/Cores.dart';
import 'package:tcc_3/controller/CategoriaController.dart';
import 'package:tcc_3/controller/EstoqueProdutoController.dart';
import 'package:tcc_3/controller/ItemPedidoVendaController.dart';
import 'package:tcc_3/controller/ObterProxIDController.dart';
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
  final int qtdeExistente;

  TelaCRUDItemPedidoVenda(
      {this.pedidoVenda, this.itemPedido, this.snapshot, this.qtdeExistente});
  @override
  _TelaCRUDItemPedidoVendaState createState() => _TelaCRUDItemPedidoVendaState(
      snapshot: snapshot, pedidoVenda: pedidoVenda, itemPedido: itemPedido, qtdeExistente: qtdeExistente);
}

class _TelaCRUDItemPedidoVendaState extends State<TelaCRUDItemPedidoVenda> {
  final DocumentSnapshot snapshot;
  final int qtdeExistente;
  PedidoVenda pedidoVenda;
  ItemPedidoVenda itemPedido;
  Auxiliares aux = Auxiliares();
  Cores cor = Cores();
  Campos campos = Campos();
  //mascara usada para impedir que sejam usados espaços, virgulas ou hifens no campo preço
  final maskPreco =
      FilteringTextInputFormatter.deny(new RegExp('[\\-|\\ |\\,]'));
  //mascara usada para impedir que sejam usados espaços, virgulas, hifens ou pontos no campo quantidade
  final maskQtde =
      FilteringTextInputFormatter.deny(new RegExp('[\\-|\\ |\\,|\\.]'));

  _TelaCRUDItemPedidoVendaState(
      {this.snapshot, this.pedidoVenda, this.itemPedido, this.qtdeExistente});

  String _dropdownValueProduto;
  double vlItemAntigo;
  final _controllerPreco = TextEditingController();
  final _controllerQtde = TextEditingController();
  final _controllerProd = TextEditingController();
  final _controllerProdQtdeExistente = TextEditingController();
  final _controllerProdCat = TextEditingController();

  bool _novocadastro;
  String _nomeTela;
  Produto produto = Produto();

  final _validadorCampos = GlobalKey<FormState>();
  final _scaffold = GlobalKey<ScaffoldState>();

  ProdutoController _controllerProduto = ProdutoController();
  CategoriaController _catController = CategoriaController();
  ItemPedidoVendaController _controllerItemPedido = ItemPedidoVendaController();
  PedidoVendaController _controllerPedido = PedidoVendaController();
  EstoqueProdutoController _controllerEstoque = EstoqueProdutoController();
  ObterProxIDController proxIDController = ObterProxIDController();

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
      _controllerProdCat.text = itemPedido.produto.getCategoria.getDescricao;
      _controllerProdQtdeExistente.text = this.qtdeExistente.toString();
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
          visible: pedidoVenda.getPedidoFinalizado ? false : true,
          child: FloatingActionButton(
              child: Icon(Icons.save),
              backgroundColor: Colors.blue,
              onPressed: () async {
                if (_validadorCampos.currentState.validate()) {
                  if (_dropdownValueProduto != null) {
                    if (int.parse(_controllerQtde.text) <=
                        int.parse(_controllerProdQtdeExistente.text)) {
                      _codigoPersistir();
                    } else {
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return aux.alerta(
                                "Produto sem estoque!",
                                "A quantidade desejada é maior que a quantidade em estoque do produto, verifique!",
                                context);
                          });
                    }
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
              _criarCampoTexto(_controllerPreco, "Preço",
                  TextInputType.numberWithOptions(decimal: true), maskPreco),
              _criarCampoTexto(_controllerQtde, "Quantidade",
                  TextInputType.number, maskQtde),
              campos.campoTextoDesabilitado(
                  _controllerProdCat, "Categoria do produto", false),
              campos.campoTextoDesabilitado(
                  _controllerProdQtdeExistente, "Qtde Existente", false)
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
              padding: EdgeInsets.fromLTRB(5.0, 5.0, 0.0, 0.0),
              child: Row(
                children: <Widget>[
                  Container(
                    width: 336.0,
                    height: 88.0,
                    child: DropdownButtonFormField(
                      decoration: InputDecoration(
                          labelText: "Produto",
                          labelStyle: TextStyle(color: cor.corLabel())),
                      value: _dropdownValueProduto,
                      onChanged: (String newValue) async {
                        await _controllerProduto.obterProdutoPorID(
                            terminou: whenCompleteObterProduto, id: newValue);
                        await _controllerProduto.obterCategoria(produto.getID);
                        await _catController
                            .obterCategoria(
                                _controllerProduto.getIdCategoriaProduto)
                            .whenComplete(() => produto.setCategoria =
                                _catController.getCategoria);
                        await _controllerEstoque.obterPrecoVenda(
                            produto, whenCompleteObterPrecoVenda);
                        _controllerEstoque.retornarQtdeExistente(
                            id: produto.getID, terminou:  whenCompleteObterQtdeExistente);
                        setState(() {
                          _dropdownValueProduto = newValue;
                          _controllerProdCat.text =
                              produto.getCategoria.getDescricao;
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
    return Container(
      padding: EdgeInsets.fromLTRB(5.0, 5.0, 0, 0),
      child: TextFormField(
        controller: _controller,
        inputFormatters: [mask],
        enabled: pedidoVenda.getPedidoFinalizado ? false : true,
        keyboardType: tipo,
        decoration: InputDecoration(
            hintText: titulo,
            labelText: titulo,
            labelStyle:
                TextStyle(color: cor.corLabel(), fontWeight: FontWeight.w400)),
        style: TextStyle(color: cor.corCampo(true), fontSize: 17.0),
        validator: (text) {
          if (_controller.text.isEmpty)
            return "É necessário preencher este campo!";
        },
        onChanged: (texto) {
          if (texto.isNotEmpty) {
            if (titulo == "Preço") itemPedido.preco = double.parse(texto);
            if (titulo == "Quantidade")
              itemPedido.quantidade = int.parse(texto);
          }
        },
      ),
    );
  }

  Widget _campoProduto() {
    _controllerProd.text = _dropdownValueProduto;
    //se o pedido estiver finalizado sera criado um TextField com o valor
    //se não estiver, sera criado o dropDown
    if (pedidoVenda.getPedidoFinalizado) {
      return campos.campoTextoDesabilitado(_controllerProd, "Produto", false);
    } else {
      return _criarDropDownProduto();
    }
  }

  void _codigoPersistir() async {
    itemPedido.preco = double.parse(_controllerPreco.text);
    if (_novocadastro) {
      await proxIDController.obterProxID(FirebaseFirestore.instance
          .collection("pedidos")
          .doc(pedidoVenda.getID)
          .collection("itens"));
      itemPedido.id = proxIDController.proxID;
      _controllerPedido.somarPrecoNoVlTotal(pedidoVenda, itemPedido);
      pedidoVenda.setValorTotal =
          _controllerPedido.getPedidoVenda.getValorTotal;
      pedidoVenda.setValorDesconto =
          _controllerPedido.getPedidoVenda.getValorDesconto;
      _controllerItemPedido.persistirItem(
          itemPedido,
          pedidoVenda.getID,
          produto.getID,
          _controllerPedido.converterParaMapaPedidoVenda(pedidoVenda));
    } else {
      _controllerPedido.atualizarPrecoNoVlTotal(
          vlItemAntigo, pedidoVenda, itemPedido);
      pedidoVenda.setValorTotal =
          _controllerPedido.getPedidoVenda.getValorTotal;
      pedidoVenda.setValorDesconto =
          _controllerPedido.getPedidoVenda.getValorDesconto;
      _controllerItemPedido.persistirItem(
          itemPedido,
          pedidoVenda.getID,
          produto.getID,
          _controllerPedido.converterParaMapaPedidoVenda(pedidoVenda));
    }
    Navigator.of(context).pop(MaterialPageRoute(
        builder: (contexto) => TelaItensPedidovenda(pedidoVenda: pedidoVenda)));
  }

  void whenCompleteObterProduto() async {
    produto = _controllerProduto.produto;
    itemPedido.labelListaProdutos = produto.getDescricao;
  }

  void whenCompleteObterPrecoVenda() {
    _controllerPreco.text = _controllerEstoque.getPrecoVenda.toString();
  }

  void whenCompleteObterQtdeExistente() {
    _controllerProdQtdeExistente.text =
        _controllerEstoque.getQtdeExistente.toString();
  }
}
