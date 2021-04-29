import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:tcc_3/controller/EmpresaController.dart';
import 'package:tcc_3/controller/EstoqueProdutoController.dart';
import 'package:tcc_3/controller/PedidoVendaController.dart';
import 'package:tcc_3/controller/UsuarioController.dart';
import 'package:tcc_3/model/Empresa.dart';
import 'package:tcc_3/model/PedidoVenda.dart';
import 'package:tcc_3/model/Produto.dart';
import 'package:tcc_3/model/Usuario.dart';
import 'package:tcc_3/screens/TelaItensPedidoVenda.dart';

class TelaCRUDPedidoVenda extends StatefulWidget {
  final PedidoVenda pedidoVenda;
  final DocumentSnapshot snapshot;
  final Usuario vendedor;

  TelaCRUDPedidoVenda({this.pedidoVenda, this.snapshot, this.vendedor});

  @override
  _TelaCRUDPedidoVendaState createState() =>
      _TelaCRUDPedidoVendaState(this.pedidoVenda, this.snapshot, this.vendedor);
}

class _TelaCRUDPedidoVendaState extends State<TelaCRUDPedidoVenda> {
  final DocumentSnapshot snapshot;
  PedidoVenda pedidoVenda;
  Usuario vendedor;

  _TelaCRUDPedidoVendaState(this.pedidoVenda, this.snapshot, this.vendedor);

  final _validadorCampos = GlobalKey<FormState>();
  final _scaffold = GlobalKey<ScaffoldState>();
  String _dropdownValueTipoPgto;
  String _dropdownValueTipoPedido;
  String _dropdownValueFornecedor;
  final _controllerVlTotal = TextEditingController();
  final _controllerVlTotalDesc = TextEditingController();
  final _controllerData = TextEditingController();
  final _controllerDataFinal = TextEditingController();
  final _controllerIdPedido = TextEditingController();
  final _controllerPercentDesc = TextEditingController();
  final _controllerVendedor = TextEditingController();
  final _controllerFormaPgto = TextEditingController();
  final _controllerCliente = TextEditingController();
  final _controllerTipoPedido = TextEditingController();
  bool _novocadastro;
  bool _permiteEditar = true;
  bool _vlCheckBox;
  String _nomeTela;
  Empresa empresa = Empresa();
  PedidoVendaController _controllerPedido = PedidoVendaController();
  EmpresaController _controllerEmpresa = EmpresaController();
  UsuarioController _controllerUsuario = UsuarioController();
  EstoqueProdutoController _controllerEstoque = EstoqueProdutoController();
  List<Produto> produtos = List<Produto>();

  @override
  void initState() {
    super.initState();
    if (pedidoVenda != null) {
      _nomeTela = "Editar Pedido";
      _controllerVlTotal.text = pedidoVenda.valorTotal.toString();
      _controllerIdPedido.text = pedidoVenda.id;
      _controllerPercentDesc.text = pedidoVenda.percentualDesconto.toString();
      _controllerVendedor.text = pedidoVenda.user.getNome;
      _dropdownValueTipoPgto = pedidoVenda.tipoPagamento;
      _dropdownValueTipoPedido = pedidoVenda.tipoPedido;
      _dropdownValueFornecedor = pedidoVenda.empresa.getRazaoSocial;
      _controllerVlTotalDesc.text = pedidoVenda.valorComDesconto.toString();
      _novocadastro = false;
      _vlCheckBox = pedidoVenda.pedidoFinalizado;
      _controllerData.text = _formatarData(pedidoVenda.dataPedido);
      if (pedidoVenda.dataFinalPedido != null)
        _controllerDataFinal.text = _formatarData(pedidoVenda.dataFinalPedido);
      if (pedidoVenda.pedidoFinalizado == true) _permiteEditar = false;
    } else {
      _nomeTela = "Novo Pedido";
      pedidoVenda = PedidoVenda();
      pedidoVenda.dataPedido = DateTime.now();
      pedidoVenda.ehPedidoVenda = true;
      pedidoVenda.valorTotal = 0.0;
      pedidoVenda.valorComDesconto = 0.0;
      pedidoVenda.percentualDesconto = 0.0;
      //formatar data
      _controllerData.text = _formatarData(pedidoVenda.dataPedido);
      _novocadastro = true;
      _vlCheckBox = false;
      pedidoVenda.pedidoFinalizado = false;
      _controllerVendedor.text = vendedor.getNome;
      _controllerVlTotalDesc.text = pedidoVenda.valorComDesconto.toString();
      _controllerVlTotal.text = pedidoVenda.valorTotal.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffold,
      appBar: AppBar(
        title: Text(_nomeTela),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.loop),
              onPressed: () async {
                await _controllerPedido.atualizarCapaPedido(pedidoVenda.id);
                _controllerVlTotal.text = pedidoVenda.valorTotal.toString();
                _controllerVlTotalDesc.text =
                    pedidoVenda.valorComDesconto.toString();
                _controllerPercentDesc.text =
                    pedidoVenda.percentualDesconto.toString();
                _controllerCliente.text = _dropdownValueFornecedor;
                _controllerFormaPgto.text = pedidoVenda.tipoPagamento;
                _controllerTipoPedido.text = pedidoVenda.tipoPedido;
              })
        ],
      ),
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.apps),
          backgroundColor: Colors.blue,
          onPressed: () async {
            await _controllerEmpresa
                .obterEmpresaPorDescricao(_dropdownValueFornecedor)
                .whenComplete(() => _validacoes());
          }),
      body: Form(
          key: _validadorCampos,
          child: ListView(
            padding: EdgeInsets.all(8.0),
            children: <Widget>[
              _criarCampoTexto(
                  "Código Pedido", _controllerIdPedido, TextInputType.number),
              _criarCampoTexto(
                  "Vendedor", _controllerVendedor, TextInputType.text),
              _criarCampoTexto(
                  "Data Pedido", _controllerData, TextInputType.text),
              _criarCampoTexto(
                  "Data Finalização", _controllerDataFinal, TextInputType.text),
              _campoCliente(),
              _campoTipoPgto(),
              _campoTipoPedido(),
              _criarCampoTexto(
                  "Valor Total", _controllerVlTotal, TextInputType.number),
              _criarCampoTexto("Valor Total Com Desconto",
                  _controllerVlTotalDesc, TextInputType.number),
              TextFormField(
                enabled: _permiteEditar,
                controller: _controllerPercentDesc,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(hintText: "% Desconto"),
                style: _style(),
                onChanged: (texto) {
                  pedidoVenda.percentualDesconto = double.parse(texto);
                  setState(() {
                    _controllerPedido.calcularDesconto(pedidoVenda);
                    pedidoVenda.valorComDesconto =
                        _controllerPedido.pedidoVenda.valorComDesconto;
                    _controllerVlTotalDesc.text =
                        pedidoVenda.valorComDesconto.toString();
                  });
                },
              ),
              _criarCampoCheckBox(),
            ],
          )),
    );
  }

  Widget _criarCampoTexto(
      String nome, TextEditingController controller, TextInputType tipo) {
    return TextFormField(
      controller: controller,
      keyboardType: tipo,
      decoration: InputDecoration(
          hintText: nome,
          labelText: nome,
          labelStyle:
              TextStyle(color: Colors.blueGrey, fontWeight: FontWeight.w400)),
      style: TextStyle(color: Colors.grey, fontSize: 17.0),
      enabled: false,
    );
  }

  Widget _criarDropDownTipoPedido() {
    return Container(
      padding: EdgeInsets.fromLTRB(0.0, 8.0, 8.0, 0.0),
      child: Row(
        children: <Widget>[
          Container(
            width: 336.0,
            child: DropdownButtonFormField<String>(
              decoration: InputDecoration(
                  labelText: "Tipo Pedido",
                  labelStyle: TextStyle(color: Colors.blueGrey)),
              value: _dropdownValueTipoPedido,
              style: TextStyle(color: Colors.black),
              onChanged: (String newValue) {
                setState(() {
                  _dropdownValueTipoPedido = newValue;
                  pedidoVenda.tipoPedido = _dropdownValueTipoPedido;
                });
              },
              items: <String>['Normal', 'Troca', 'Bonificação']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          )
        ],
      ),
    );
  }

  Widget _criarDropDownCliente() {
    return StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance.collection('empresas').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else {
            var length = snapshot.data.documents.length;
            DocumentSnapshot ds = snapshot.data.documents[length - 1];
            return Container(
              child: Row(
                children: <Widget>[
                  Container(
                    width: 336.0,
                    height: 88.0,
                    child: DropdownButtonFormField(
                      decoration: InputDecoration(
                          labelText: "Cliente",
                          labelStyle: TextStyle(color: Colors.blueGrey)),
                      value: _dropdownValueFornecedor,
                      style: TextStyle(color: Colors.black),
                      onChanged: (String newValue) {
                        setState(() {
                          _dropdownValueFornecedor = newValue;
                          pedidoVenda.labelTelaPedidos =
                              _dropdownValueFornecedor;
                        });
                      },
                      items: snapshot.data.documents
                          .map((DocumentSnapshot document) {
                        return DropdownMenuItem<String>(
                            value: document.data()['razaoSocial'],
                            child: Container(
                              child: Text(document.data()['razaoSocial'],
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

  Widget _criarCampoCheckBox() {
    return Container(
      padding: EdgeInsets.only(top: 10.0),
      child: Row(
        children: <Widget>[
          Checkbox(
            value: _vlCheckBox == true,
            onChanged: pedidoVenda.pedidoFinalizado
                ? null
                : (bool novoValor) {
                    setState(() {
                      if (novoValor) {
                        _vlCheckBox = true;
                      } else {
                        _vlCheckBox = false;
                      }
                    });
                  },
          ),
          Text(
            "Finalizado?",
            style: _style(),
          ),
        ],
      ),
    );
  }

  void _validacoes() async {
    pedidoVenda.pedidoFinalizado = _vlCheckBox;
    if (pedidoVenda.pedidoFinalizado == true &&
        pedidoVenda.dataFinalPedido == null) {
      await _controllerPedido.verificarSePedidoTemItens(pedidoVenda);

      if (_controllerPedido.podeFinalizar == true) {
        await _controllerEstoque.verificarEstoqueTodosItensPedido(pedidoVenda);
        if (_controllerEstoque.permitirFinalizarPedidoVenda == true) {
          _controllerEstoque.descontarEstoqueProduto(pedidoVenda);
          pedidoVenda.dataFinalPedido = DateTime.now();
          _controllerDataFinal.text =
              _formatarData(pedidoVenda.dataFinalPedido);
          _codigoBotaoSalvar();
        } else {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return _alertaEstoque();
              });
        }
      } else {
        _scaffold.currentState.showSnackBar(SnackBar(
          content:
              Text("O pedido não pode ser finalizado pois não contém itens!"),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 5),
        ));
      }
    } else {
      _codigoBotaoSalvar();
    }
  }

  void _codigoBotaoSalvar() async {
    empresa = _controllerEmpresa.getEmp;
    // método criado para não precisar repetir duas vezes o mesmo codigo na hora que clica no salvar
    if (_dropdownValueTipoPgto != null &&
        _dropdownValueFornecedor != null &&
        _dropdownValueTipoPedido != null) {
      Map<String, dynamic> mapa = _controllerPedido.converterParaMapaPedidoVenda(pedidoVenda);
      Map<String, dynamic> mapaVendedor = Map();
      mapaVendedor["id"] = vendedor.getID;
      Map<String, dynamic> mapaEmpresa = Map();
      mapaEmpresa["id"] = empresa.getId;
      pedidoVenda.pedidoFinalizado = _vlCheckBox;

      if (_novocadastro) {
        _novocadastro = false;
        await _controllerPedido.obterProxID();
        pedidoVenda.id = _controllerPedido.proxID;
        _controllerPedido.persistirAlteracoesPedido(
            mapa, mapaEmpresa, mapaVendedor, pedidoVenda.id);
      } else {
        _controllerPedido.persistirAlteracoesPedido(
            mapa, mapaEmpresa, mapaVendedor, pedidoVenda.id);
      }
      Navigator.of(context).push(MaterialPageRoute(
          builder: (contexto) => TelaItensPedidovenda(
                pedidoVenda: pedidoVenda,
                snapshot: snapshot,
              )));
    } else {
      _scaffold.currentState.showSnackBar(SnackBar(
        content: Text("Todos os campos da tela devem ser informados!"),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 5),
      ));
    }
  }

  TextStyle _style() {
    if (pedidoVenda.pedidoFinalizado) {
      return TextStyle(color: Colors.grey, fontSize: 17.0);
    } else {
      return TextStyle(color: Colors.black, fontSize: 17.0);
    }
  }

  String _formatarData(DateTime data) {
    return (data.day.toString() +
        "/" +
        data.month.toString() +
        "/" +
        data.year.toString() +
        " " +
        (new DateFormat.Hms().format(data)));
  }

  Widget _criarDropDownTipoPgto() {
    return Container(
      padding: EdgeInsets.fromLTRB(0.0, 8.0, 8.0, 0.0),
      child: Row(
        children: <Widget>[
          Container(
            width: 336.0,
            height: 88.0,
            child: DropdownButtonFormField<String>(
              decoration: InputDecoration(
                  labelText: "Tipo Pagamento",
                  labelStyle: TextStyle(color: Colors.blueGrey)),
              value: _dropdownValueTipoPgto,
              style: TextStyle(color: Colors.black),
              onChanged: (String newValue) {
                setState(() {
                  _dropdownValueTipoPgto = newValue;
                  pedidoVenda.tipoPagamento = _dropdownValueTipoPgto;
                });
              },
              items: <String>['À Vista', 'Cheque', 'Boleto', 'Duplicata']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          )
        ],
      ),
    );
  }

  Widget _campoTipoPgto() {
    _controllerFormaPgto.text = pedidoVenda.tipoPagamento;
    //se o pedido estiver finalizado sera criado um TextField com o valor
    //se não estiver, sera criado o dropDown
    if (pedidoVenda.pedidoFinalizado) {
      return _criarCampoTexto(
          "Tipo Pagamento", _controllerFormaPgto, TextInputType.text);
    } else {
      return _criarDropDownTipoPgto();
    }
  }

  Widget _campoTipoPedido() {
    _controllerTipoPedido.text = pedidoVenda.tipoPedido;
    //se o pedido estiver finalizado sera criado um TextField com o valor
    //se não estiver, sera criado o dropDown
    if (pedidoVenda.pedidoFinalizado) {
      return _criarCampoTexto(
          "Tipo Pedido", _controllerTipoPedido, TextInputType.text);
    } else {
      return _criarDropDownTipoPedido();
    }
  }

  Widget _campoCliente() {
    _controllerCliente.text = pedidoVenda.empresa.getNomeFantasia;
    //se o pedido estiver finalizado sera criado um TextField com o valor
    //se não estiver, sera criado o dropDown
    if (pedidoVenda.pedidoFinalizado) {
      return _criarCampoTexto(
          "Cliente", _controllerCliente, TextInputType.text);
    } else {
      return _criarDropDownCliente();
    }
  }

  Widget _alertaEstoque() {
    return AlertDialog(
      title: Text('Produtos sem estoque suficiente'),
      titleTextStyle: TextStyle(fontWeight: FontWeight.bold),
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            Text(
                'O pedido possui itens sem estoque suficiente para atender a quantidade solicitada'),
          ],
        ),
      ),
      actions: <Widget>[
        FlatButton(
          child: Text('OK'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        )
      ],
    );
  }
}
