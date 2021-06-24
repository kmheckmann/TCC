import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:tcc_3/acessorios/Auxiliares.dart';
import 'package:tcc_3/acessorios/Campos.dart';
import 'package:tcc_3/acessorios/Cores.dart';
import 'package:tcc_3/controller/EmpresaController.dart';
import 'package:tcc_3/controller/EstoqueProdutoController.dart';
import 'package:tcc_3/controller/ObterProxIDController.dart';
import 'package:tcc_3/controller/PedidoVendaController.dart';
import 'package:tcc_3/model/Empresa.dart';
import 'package:tcc_3/model/PedidoVenda.dart';
import 'package:tcc_3/model/Produto.dart';
import 'package:tcc_3/model/Usuario.dart';
import 'package:tcc_3/screens/TelaItensPedidoVenda.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:tcc_3/screens/TelaPedidosVenda.dart';

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
  bool _temItens;
  String _nomeTela;
  Empresa empresa = Empresa();
  PedidoVendaController _controllerPedido = PedidoVendaController();
  EmpresaController _controllerEmpresa = EmpresaController();
  Campos campos = Campos();
  Cores cores = Cores();
  Auxiliares aux = Auxiliares();
  EstoqueProdutoController _controllerEstoque = EstoqueProdutoController();
  ObterProxIDController _controllerObterProxID = ObterProxIDController();
  List<Produto> produtos = [];
  final maskDesconto = MaskTextInputFormatter(mask: "##.##");

  @override
  void initState() {
    super.initState();
    if (pedidoVenda != null) {
      _nomeTela = "Editar Pedido";
      _controllerVlTotal.text = pedidoVenda.getValorTotal.toString();
      _controllerIdPedido.text = pedidoVenda.getID;
      _controllerPercentDesc.text = pedidoVenda.getPercentDesconto.toString();
      _controllerVendedor.text = pedidoVenda.getUser.getNome;
      _dropdownValueTipoPgto = pedidoVenda.getTipoPgto;
      _dropdownValueTipoPedido = pedidoVenda.tipoPedido;
      _dropdownValueFornecedor = pedidoVenda.getEmpresa.getId +
          " - " +
          pedidoVenda.getEmpresa.getRazaoSocial;
      _controllerVlTotalDesc.text = pedidoVenda.getValorDesconto.toString();
      _novocadastro = false;
      _controllerData.text = aux.formatarData(pedidoVenda.getDataPedido);
      if (pedidoVenda.getDataFinal != null)
        _controllerDataFinal.text = aux.formatarData(pedidoVenda.getDataFinal);
    } else {
      _nomeTela = "Novo Pedido";
      pedidoVenda = PedidoVenda();
      pedidoVenda.setDataPedido = DateTime.now();
      pedidoVenda.setEhPedidoVenda = true;
      pedidoVenda.setValorTotal = 0.0;
      pedidoVenda.setValorDesconto = 0.0;
      pedidoVenda.setPercentDesconto = 0.0;
      //formatar data
      _controllerData.text = aux.formatarData(pedidoVenda.getDataPedido);
      _novocadastro = true;
      pedidoVenda.setPedidoFinalizado = false;
      _controllerVendedor.text = vendedor.getNome;
      _controllerVlTotalDesc.text = pedidoVenda.getValorDesconto.toString();
      _controllerVlTotal.text = pedidoVenda.getValorTotal.toString();
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
                await _controllerPedido.atualizarCapaPedido(
                    pedidoVenda.getID, terminouAtualizarCapaPedido);
              })
        ],
      ),
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.apps),
          backgroundColor: Colors.blue,
          onPressed: () async {
            //verifica se algum fornecedor foi selecionado
            if (_dropdownValueFornecedor != null) {
              //obtem os dados da empresa e atribui ao fornecedor
              await _controllerEmpresa.obterEmpresa(
                  id: _dropdownValueFornecedor, terminou: whenCompleteEmpresa);
            }

            if (_dropdownValueTipoPgto != null &&
                _dropdownValueFornecedor != null &&
                _dropdownValueTipoPedido != null) {
              //A variavel pedidoFinalizado é atualizado conforme o checkbox Finalizado é alterado
              //Se essa variavel estiver como true e a data final do pedido esta nula
              //faz a verificacao necessaria para permitir ou nao finalizar o pedido
              if (pedidoVenda.getPedidoFinalizado == true &&
                  pedidoVenda.getDataFinal == null) {
                await _controllerPedido.verificarSePedidoTemItens(
                    pedidoVenda, whenCompleteVerificaSePedidoTemItens);

                if (_temItens == true) {
                  await _controllerEstoque
                      .verificarEstoqueTodosItensPedido(pedidoVenda);
                  if (_controllerEstoque.getPermitirFinalizarPedidoVenda ==
                      true) {
                    _controllerEstoque.descontarEstoqueProduto(pedidoVenda);
                    pedidoVenda.setDataFinal = DateTime.now();
                    _controllerDataFinal.text =
                        aux.formatarData(pedidoVenda.getDataFinal);
                    _codigoBotaoSalvar();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => TelaPedidosVenda()),
                    ).then((value) => setState(() {}));
                  } else {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return aux.alerta(
                              "Itens sem estoque",
                              "O pedido possui itens sem estoque suficiente para atender a quantidade solicitada",
                              context);
                        });
                  }
                } else {
                  //Se não puder finalizar a variavel PedidoFinalizado volta a ser false
                  pedidoVenda.setPedidoFinalizado = false;
                  //o setState é para atualizar a tela de novo
                  //e fazer com que os campos sejam editaveis novamente
                  setState(() {});
                  //uma mensagem é exibida e as alterações não são persistidas
                  aux.exibirBarraMensagem(
                      "O pedido não pode ser finalizado pois não contém itens!",
                      Colors.red,
                      _scaffold);
                }
              } else {
                //Se não foi marcado o finalizar pedido
                //só persiste as alterações
                _codigoBotaoSalvar();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => TelaItensPedidovenda(
                            pedidoVenda: pedidoVenda,
                            snapshot: snapshot,
                          )),
                ).then((value) => setState(() {}));
              }
            } else {
              aux.exibirBarraMensagem(
                  "Todos os campos da tela devem ser informados!",
                  Colors.red,
                  _scaffold);
            }
          }),
      body: SingleChildScrollView(
          padding: EdgeInsets.only(left: 5.0),
          child: Form(
              key: _validadorCampos,
              child: Column(
                children: [
                  campos.campoTextoDesabilitado(
                      _controllerIdPedido, "Código Pedido", false),
                  campos.campoTextoDesabilitado(
                      _controllerVendedor, "Vendedor", false),
                  campos.campoTextoDesabilitado(
                      _controllerData, "Data Pedido", false),
                  campos.campoTextoDesabilitado(
                      _controllerDataFinal, "Data Finalização", false),
                  _campoCliente(),
                  _campoTipoPgto(),
                  _campoTipoPedido(),
                  campos.campoTextoDesabilitado(
                      _controllerVlTotal, "Valor Total", false),
                  campos.campoTextoDesabilitado(_controllerVlTotalDesc,
                      "Valor Total Com Desconto", false),
                  _criarCampoDesconto(),
                  _criarCampoCheckBox(),
                ],
              ))),
    );
  }

  Widget _criarCampoDesconto() {
    return Container(
      padding: EdgeInsets.fromLTRB(5.0, 5.0, 0, 0),
      child: TextFormField(
        enabled: !pedidoVenda.getPedidoFinalizado,
        controller: _controllerPercentDesc,
        keyboardType: TextInputType.number,
        inputFormatters: [maskDesconto],
        decoration: InputDecoration(
            hintText: "% Desconto",
            labelText: "% Desconto",
            labelStyle: TextStyle(
                color: cores.corLabel(), fontWeight: FontWeight.w400)),
        style: TextStyle(
            color: cores.corCampo(!pedidoVenda.getPedidoFinalizado),
            fontSize: 17.0),
        onChanged: (texto) {
          if (texto.isNotEmpty) {
            pedidoVenda.setPercentDesconto = double.parse(texto);
          }
          setState(() {
            _controllerPedido.calcularDesconto(pedidoVenda);
            pedidoVenda.setValorDesconto =
                _controllerPedido.getPedidoVenda.getValorDesconto;
            _controllerVlTotalDesc.text =
                pedidoVenda.getValorDesconto.toString();
          });
        },
      ),
    );
  }

  Widget _criarDropDownTipoPedido() {
    return Container(
      padding: EdgeInsets.fromLTRB(5.0, 5.0, 0, 0),
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
        stream: FirebaseFirestore.instance.collection('empresas').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else {
            var length = snapshot.data.docs.length;
            DocumentSnapshot ds = snapshot.data.docs[length - 1];
            return Container(
              child: Row(
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.fromLTRB(5.0, 5.0, 0, 0),
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
                          pedidoVenda.setLabel = _dropdownValueFornecedor;
                        });
                      },
                      items:
                          snapshot.data.docs.map((DocumentSnapshot document) {
                        return DropdownMenuItem<String>(
                            value: document.id +
                                " - " +
                                document.data()['razaoSocial'],
                            child: Container(
                              child: Text(
                                  document.id +
                                      " - " +
                                      document.data()['razaoSocial'],
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
            value: pedidoVenda.getPedidoFinalizado == true,
            onChanged: pedidoVenda.getPedidoFinalizado
                ? null
                : (bool novoValor) {
                    setState(() {
                      if (novoValor) {
                        pedidoVenda.setPedidoFinalizado = true;
                      } else {
                        pedidoVenda.setPedidoFinalizado = false;
                      }
                    });
                  },
          ),
          Text(
            "Finalizado?",
            style: TextStyle(
                color: cores.corCampo(!pedidoVenda.getPedidoFinalizado),
                fontSize: 17.0),
          ),
        ],
      ),
    );
  }

  void _codigoBotaoSalvar() async {
    empresa = _controllerEmpresa.getEmpresa;
    // método criado para não precisar repetir duas vezes o mesmo codigo na hora que clica no salvar
    Map<String, dynamic> mapa =
        _controllerPedido.converterParaMapaPedidoVenda(pedidoVenda);
    Map<String, dynamic> mapaVendedor = Map();
    mapaVendedor["id"] = vendedor.getID;
    Map<String, dynamic> mapaEmpresa = Map();
    mapaEmpresa["id"] = empresa.getId;

    if (_novocadastro) {
      _novocadastro = false;
      await _controllerObterProxID
          .obterProxID(FirebaseFirestore.instance.collection("pedidos"));
      pedidoVenda.setID = _controllerObterProxID.proxID;
      _controllerPedido.persistirAlteracoesPedido(
          mapa, mapaEmpresa, mapaVendedor, pedidoVenda.getID);
      _controllerIdPedido.text = pedidoVenda.getID;
    } else {
      _controllerPedido.persistirAlteracoesPedido(
          mapa, mapaEmpresa, mapaVendedor, pedidoVenda.getID);
    }
  }

  Widget _criarDropDownTipoPgto() {
    return Container(
      padding: EdgeInsets.fromLTRB(5.0, 5.0, 0, 0),
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
                  pedidoVenda.setTipoPgto = _dropdownValueTipoPgto;
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
    _controllerFormaPgto.text = pedidoVenda.getTipoPgto;
    //se o pedido estiver finalizado sera criado um TextField com o valor
    //se não estiver, sera criado o dropDown
    if (pedidoVenda.getPedidoFinalizado) {
      return campos.campoTextoDesabilitado(
          _controllerFormaPgto, "Tipo Pagamento", false);
    } else {
      return _criarDropDownTipoPgto();
    }
  }

  Widget _campoTipoPedido() {
    _controllerTipoPedido.text = pedidoVenda.tipoPedido;
    //se o pedido estiver finalizado sera criado um TextField com o valor
    //se não estiver, sera criado o dropDown
    if (pedidoVenda.getPedidoFinalizado) {
      return campos.campoTextoDesabilitado(
          _controllerTipoPedido, "Tipo Pedido", false);
    } else {
      return _criarDropDownTipoPedido();
    }
  }

  Widget _campoCliente() {
    _controllerCliente.text = pedidoVenda.getEmpresa.getNomeFantasia;
    //se o pedido estiver finalizado sera criado um TextField com o valor
    //se não estiver, sera criado o dropDown
    if (pedidoVenda.getPedidoFinalizado) {
      return campos.campoTextoDesabilitado(
          _controllerCliente, "Cliente", false);
    } else {
      return _criarDropDownCliente();
    }
  }

  void terminouAtualizarCapaPedido() {
    _controllerVlTotal.text = pedidoVenda.getValorTotal.toString();
    _controllerVlTotalDesc.text = pedidoVenda.getValorDesconto.toString();
    _controllerPercentDesc.text = pedidoVenda.getPercentDesconto.toString();
    _controllerCliente.text = _dropdownValueFornecedor;
    _controllerFormaPgto.text = pedidoVenda.getTipoPgto;
    _controllerTipoPedido.text = pedidoVenda.tipoPedido;
    _controllerIdPedido.text = pedidoVenda.getID;
  }

  void whenCompleteEmpresa() {
    empresa = _controllerEmpresa.getEmpresa;
    pedidoVenda.setLabel = empresa.getRazaoSocial;
  }

  void whenCompleteVerificaSePedidoTemItens() {
    _temItens = _controllerPedido.getPodeFinalizar;
  }
}
