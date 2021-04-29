import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tcc_3/controller/EmpresaController.dart';
import 'package:tcc_3/controller/EstoqueProdutoController.dart';
import 'package:tcc_3/controller/PedidoCompraController.dart';
import 'package:tcc_3/controller/UsuarioController.dart';
import 'package:tcc_3/model/Empresa.dart';
import 'package:tcc_3/model/EstoqueProduto.dart';
import 'package:tcc_3/model/PedidoCompra.dart';
import 'package:tcc_3/model/Usuario.dart';
import 'package:tcc_3/screens/TelaItensPedidoCompra.dart';
import 'package:intl/intl.dart';

class TelaCRUDPedidoCompra extends StatefulWidget {
  final PedidoCompra pedidoCompra;
  final DocumentSnapshot snapshot;
  final Usuario vendedor;

  TelaCRUDPedidoCompra({this.pedidoCompra, this.snapshot, this.vendedor});

  @override
  _TelaCRUDPedidoCompraState createState() => _TelaCRUDPedidoCompraState(
      this.pedidoCompra, this.snapshot, this.vendedor);
}

class _TelaCRUDPedidoCompraState extends State<TelaCRUDPedidoCompra> {
  final DocumentSnapshot snapshot;
  PedidoCompra pedidoCompra;
  Usuario vendedor;
  EstoqueProduto estoque;

  _TelaCRUDPedidoCompraState(this.pedidoCompra, this.snapshot, this.vendedor);

  final _validadorCampos = GlobalKey<FormState>();
  final _scaffold = GlobalKey<ScaffoldState>();
  String _dropdownValueTipoPgto;
  String _dropdownValueFornecedor;
  final _controllerVlTotal = TextEditingController();
  final _controllerVlTotalDesc = TextEditingController();
  final _controllerData = TextEditingController();
  final _controllerDataFinal = TextEditingController();
  final _controllerIdPedido = TextEditingController();
  final _controllerPercentDesc = TextEditingController();
  final _controllerVendedor = TextEditingController();
  final _controllerFormaPgto = TextEditingController();
  final _controllerFornecedor = TextEditingController();
  bool _novocadastro;
  bool _permiteEditar = true;
  bool _vlCheckBox;
  String _nomeTela;
  Empresa empresa = Empresa();
  PedidoCompraController _controllerPedido = PedidoCompraController();
  EmpresaController _controllerEmpresa = EmpresaController();
  UsuarioController _controllerUsuario = UsuarioController();
  EstoqueProdutoController _controllerEstoque = EstoqueProdutoController();

  @override
  void initState() {
    super.initState();
    if (pedidoCompra != null) {
      _nomeTela = "Editar Pedido";
      _controllerVlTotal.text = pedidoCompra.valorTotal.toString();
      _controllerIdPedido.text = pedidoCompra.id;
      _controllerPercentDesc.text = pedidoCompra.percentualDesconto.toString();
      _controllerVendedor.text = pedidoCompra.user.getNome;
      _dropdownValueTipoPgto = pedidoCompra.tipoPagamento;
      _dropdownValueFornecedor = pedidoCompra.empresa.getNomeFantasia;
      _controllerVlTotalDesc.text = pedidoCompra.valorComDesconto.toString();
      _novocadastro = false;
      _vlCheckBox = pedidoCompra.pedidoFinalizado;
      _controllerData.text = _formatarData(pedidoCompra.dataPedido);
      if (pedidoCompra.dataFinalPedido != null)
        _controllerDataFinal.text = _formatarData(pedidoCompra.dataFinalPedido);
      if (pedidoCompra.pedidoFinalizado == true) _permiteEditar = false;
    } else {
      _nomeTela = "Novo Pedido";
      pedidoCompra = PedidoCompra();
      pedidoCompra.dataPedido = DateTime.now();
      pedidoCompra.ehPedidoVenda = false;
      pedidoCompra.valorTotal = 0.0;
      pedidoCompra.percentualDesconto = 0.0;
      //formatar data
      _controllerData.text = _formatarData(pedidoCompra.dataPedido);
      _novocadastro = true;
      _vlCheckBox = false;
      pedidoCompra.pedidoFinalizado = false;
      _controllerVendedor.text = vendedor.getNome;
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
                await _controllerPedido.atualizarCapaPedido(pedidoCompra.id);
                _controllerVlTotal.text = pedidoCompra.valorTotal.toString();
                _controllerVlTotalDesc.text =
                    pedidoCompra.valorComDesconto.toString();
                _controllerPercentDesc.text =
                    pedidoCompra.percentualDesconto.toString();
                _controllerFornecedor.text = _dropdownValueFornecedor;
                _controllerFormaPgto.text = pedidoCompra.tipoPagamento;
              })
        ],
      ),
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.apps),
          backgroundColor: Colors.blue,
          onPressed: () async {
            await _controllerEmpresa
                .obterEmpresaPorDescricao(_dropdownValueFornecedor);
            empresa = _controllerEmpresa.getEmpresa;
            await _controllerUsuario.obterUsuarioPorCPF(vendedor.getCPF);
            vendedor = _controllerUsuario.usuario;
            pedidoCompra.pedidoFinalizado = _vlCheckBox;

            if (pedidoCompra.pedidoFinalizado == true &&
                pedidoCompra.dataFinalPedido == null) {
              await _controllerPedido.verificarSePedidoTemItens(pedidoCompra);

              if (_controllerPedido.podeFinalizar == true) {
                _controllerEstoque.gerarEstoque(pedidoCompra);
                pedidoCompra.dataFinalPedido = DateTime.now();
                _controllerDataFinal.text =
                    _formatarData(pedidoCompra.dataFinalPedido);
                _codigoBotaoSalvar();
              } else {
                _scaffold.currentState.showSnackBar(SnackBar(
                  content: Text(
                      "O pedido não pode ser finalizado pois não contém itens!"),
                  backgroundColor: Colors.red,
                  duration: Duration(seconds: 5),
                ));
              }
            } else {
              _codigoBotaoSalvar();
            }
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
              _campoFornecedor(),
              _campoTipoPgto(),
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
                  pedidoCompra.percentualDesconto = double.parse(texto);
                  setState(() {
                    _controllerPedido.calcularDesconto(pedidoCompra);
                    pedidoCompra.valorComDesconto =
                        _controllerPedido.pedidoCompra.valorComDesconto;
                    _controllerVlTotalDesc.text =
                        pedidoCompra.valorComDesconto.toString();
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

  Widget _criarDropDownTipoPgto() {
    return Container(
      padding: EdgeInsets.fromLTRB(0.0, 8.0, 8.0, 0.0),
      child: Row(
        children: <Widget>[
          Container(
            width: 336.0,
            child: DropdownButton<String>(
              value: _dropdownValueTipoPgto,
              style: TextStyle(color: Colors.black),
              hint: Text("Selecionar Tipo Pagamento"),
              onChanged: (String newValue) {
                setState(() {
                  _dropdownValueTipoPgto = newValue;
                  pedidoCompra.tipoPagamento = _dropdownValueTipoPgto;
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

  Widget _criarDropDownFornecedor() {
    return StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance
            .collection('empresas')
            .where('ehFornecedor', isEqualTo: true)
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
                      value: _dropdownValueFornecedor,
                      style: TextStyle(color: Colors.black),
                      hint: Text("Selecionar fornecedor"),
                      onChanged: (String newValue) {
                        setState(() {
                          _dropdownValueFornecedor = newValue;
                          pedidoCompra.labelTelaPedidos =
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
            onChanged: pedidoCompra.pedidoFinalizado
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

  void _codigoBotaoSalvar() async {
    // método criado para não precisar repetir duas vezes o mesmo codigo na hora que clica no salvar
    if (_dropdownValueTipoPgto != null && _dropdownValueFornecedor != null) {
      Map<String, dynamic> mapa =
          _controllerPedido.converterParaMapa(pedidoCompra);
      Map<String, dynamic> mapaVendedor = Map();
      mapaVendedor["id"] = vendedor.getID;
      Map<String, dynamic> mapaEmpresa = Map();
      mapaEmpresa["id"] = empresa.getId;
      pedidoCompra.pedidoFinalizado = _vlCheckBox;

      if (_novocadastro) {
        _novocadastro = false;
        await _controllerPedido.obterProxID();
        pedidoCompra.id = _controllerPedido.proxID;
        _controllerPedido.persistirAlteracoesPedido(
            mapa, mapaEmpresa, mapaVendedor, pedidoCompra.id);
      } else {
        _controllerPedido.persistirAlteracoesPedido(
            mapa, mapaEmpresa, mapaVendedor, pedidoCompra.id);
      }
      Navigator.of(context).push(MaterialPageRoute(
          builder: (contexto) => TelaItensPedidoCompra(
                pedidoCompra: pedidoCompra,
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
    if (pedidoCompra.pedidoFinalizado) {
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

  Widget _campoTipoPgto() {
    _controllerFormaPgto.text = pedidoCompra.tipoPagamento;
    //se o pedido estiver finalizado sera criado um TextField com o valor
    //se não estiver, sera criado o dropDown
    if (pedidoCompra.pedidoFinalizado) {
      return _criarCampoTexto(
          "Tipo Pagamento", _controllerFormaPgto, TextInputType.text);
    } else {
      return _criarDropDownTipoPgto();
    }
  }

  Widget _campoFornecedor() {
    _controllerFornecedor.text = pedidoCompra.empresa.getNomeFantasia;
    //se o pedido estiver finalizado sera criado um TextField com o valor
    //se não estiver, sera criado o dropDown
    if (pedidoCompra.pedidoFinalizado) {
      return _criarCampoTexto(
          "Fornecedor", _controllerFornecedor, TextInputType.text);
    } else {
      return _criarDropDownFornecedor();
    }
  }
}
