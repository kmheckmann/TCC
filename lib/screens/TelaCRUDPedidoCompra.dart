import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:tcc_3/acessorios/Campos.dart';
import 'package:tcc_3/acessorios/Cores.dart';
import 'package:tcc_3/controller/EmpresaController.dart';
import 'package:tcc_3/acessorios/Auxiliares.dart';
import 'package:tcc_3/controller/EstoqueProdutoController.dart';
import 'package:tcc_3/controller/ObterProxIDController.dart';
import 'package:tcc_3/controller/PedidoCompraController.dart';
import 'package:tcc_3/model/Empresa.dart';
import 'package:tcc_3/model/EstoqueProduto.dart';
import 'package:tcc_3/model/PedidoCompra.dart';
import 'package:tcc_3/model/Usuario.dart';
import 'package:tcc_3/screens/TelaItensPedidoCompra.dart';

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
  final _controllerVlTotal = TextEditingController();
  final _controllerVlTotalDesc = TextEditingController();
  final _controllerData = TextEditingController();
  final _controllerDataFinal = TextEditingController();
  final _controllerIdPedido = TextEditingController();
  final _controllerPercentDesc = TextEditingController();
  final _controllerVendedor = TextEditingController();
  final _controllerFormaPgto = TextEditingController();
  final _controllerFornecedor = TextEditingController();
  final maskDesconto = MaskTextInputFormatter(mask: "##.##");

  String _dropdownValueTipoPgto;
  String _dropdownValueFornecedor;
  String _nomeTela;
  bool _novocadastro;

  Campos campos = Campos();
  Cores cores = Cores();
  Empresa empresa = Empresa();
  Auxiliares aux = Auxiliares();
  PedidoCompraController _controllerPedido = PedidoCompraController();
  EmpresaController _controllerEmpresa = EmpresaController();
  EstoqueProdutoController _controllerEstoque = EstoqueProdutoController();
  ObterProxIDController _controllerObterPoxID = ObterProxIDController();

  @override
  void initState() {
    super.initState();
    if (pedidoCompra != null) {
      _nomeTela = "Editar Pedido";
      _controllerVlTotal.text = pedidoCompra.getValorTotal.toString();
      _controllerIdPedido.text = pedidoCompra.getID;
      _controllerPercentDesc.text = pedidoCompra.getPercentDesconto.toString();
      _controllerVendedor.text = pedidoCompra.getUser.getNome;
      _dropdownValueTipoPgto = pedidoCompra.getTipoPgto;
      _dropdownValueFornecedor = pedidoCompra.getEmpresa.getId +
          " - " +
          pedidoCompra.getEmpresa.getRazaoSocial;
      _controllerVlTotalDesc.text = pedidoCompra.getValorDesconto.toString();
      _novocadastro = false;
      _controllerData.text = aux.formatarData(pedidoCompra.getDataPedido);
      if (pedidoCompra.getDataFinal != null)
        _controllerDataFinal.text = aux.formatarData(pedidoCompra.getDataFinal);
    } else {
      _nomeTela = "Novo Pedido";
      pedidoCompra = PedidoCompra();
      pedidoCompra.setDataPedido = DateTime.now();
      pedidoCompra.setEhPedidoVenda = false;
      pedidoCompra.setValorTotal = 0.0;
      pedidoCompra.setPercentDesconto = 0.0;
      pedidoCompra.setValorDesconto = 0.0;
      _controllerData.text = aux.formatarData(pedidoCompra.getDataPedido);
      _novocadastro = true;
      pedidoCompra.setPedidoFinalizado = false;
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
                  await _controllerPedido.atualizarCapaPedido(
                      pedidoCompra.getID, whenCompleteAtualizarCapaPedido);
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
                    id: _dropdownValueFornecedor,
                    terminou: whenCompleteEmpresa);
              }

              //A variavel pedidoFinalizado é atualizado conforme o checkbox Finalizado é alterado
              //Se essa variavel estiver como true e a data final do pedido esta nula
              //faz a verificacao necessaria para permitir ou nao finalizar o pedido
              if (pedidoCompra.getPedidoFinalizado == true &&
                  pedidoCompra.getDataFinal == null) {
                await _controllerPedido.verificarSePedidoTemItens(pedidoCompra);

                //Verifica o valor da variavel para identificar se pode ou nao finalizar o pedido
                if (_controllerPedido.getPodeFinalizar == true) {
                  //se puder, adiciona o estoque nos itens e seta a data final no pedido
                  //E depois persiste as alterações
                  _controllerEstoque.gerarEstoque(pedidoCompra);
                  pedidoCompra.setDataFinal = DateTime.now();
                  _controllerDataFinal.text =
                      aux.formatarData(pedidoCompra.getDataFinal);
                  _codigoBotaoSalvar();
                } else {
                  //Se não puder finalizar a variavel PedidoFinalizado volta a ser false
                  pedidoCompra.setPedidoFinalizado = false;
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
                  _campoFornecedor(),
                  _campoTipoPgto(),
                  campos.campoTextoDesabilitado(
                      _controllerVlTotal, "Valor Total", false),
                  campos.campoTextoDesabilitado(_controllerVlTotalDesc,
                      "Valor Total Com Desconto", false),
                  _campoPercentDesconto(),
                  _criarCampoCheckBox(),
                ],
              )),
        ));
  }

  Widget _criarDropDownTipoPgto() {
    return Container(
      padding: EdgeInsets.fromLTRB(5.0, 5.0, 0, 0),
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
                  pedidoCompra.setTipoPgto = _dropdownValueTipoPgto;
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
        stream: FirebaseFirestore.instance
            .collection('empresas')
            .where('ehFornecedor', isEqualTo: true)
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
              padding: EdgeInsets.fromLTRB(5.0, 5.0, 0, 0),
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
            value: pedidoCompra.getPedidoFinalizado == true,
            onChanged: pedidoCompra.getPedidoFinalizado
                ? null
                : (bool novoValor) {
                    setState(() {
                      if (novoValor) {
                        pedidoCompra.setPedidoFinalizado = true;
                      } else {
                        pedidoCompra.setPedidoFinalizado = false;
                      }
                    });
                  },
          ),
          Text(
            "Finalizado?",
            style: TextStyle(
                color: cores.corCampo(!pedidoCompra.getPedidoFinalizado),
                fontSize: 17.0),
          ),
        ],
      ),
    );
  }

  void _codigoBotaoSalvar() async {
    if (_dropdownValueTipoPgto != null && _dropdownValueFornecedor != null) {
      //Se o tipo de pgto e fornecedor terem sido selecionados, segue o processo para persistir
      Map<String, dynamic> mapa =
          _controllerPedido.converterParaMapa(pedidoCompra);
      Map<String, dynamic> mapaVendedor = Map();
      mapaVendedor["id"] = vendedor.getID;
      Map<String, dynamic> mapaEmpresa = Map();
      mapaEmpresa["id"] = empresa.getId;

      if (_novocadastro) {
        //Se for um novo cadastro, gera ID para o pedido e persiste
        _novocadastro = false;
        await _controllerObterPoxID.obterProxID(FirebaseFirestore.instance.collection("pedidos"));
        pedidoCompra.setID = _controllerObterPoxID.proxID;
        _controllerPedido.persistirAlteracoesPedido(
            mapa, mapaEmpresa, mapaVendedor, pedidoCompra.getID);
      } else {
        //se nao for novo cadastro, só persiste pois já tem ID
        _controllerPedido.persistirAlteracoesPedido(
            mapa, mapaEmpresa, mapaVendedor, pedidoCompra.getID);
      }
      //Ao salvar, direciona o user para a proxima tela (de itens do pedido)
      Navigator.of(context).push(MaterialPageRoute(
          builder: (contexto) => TelaItensPedidoCompra(
                pedidoCompra: pedidoCompra,
                snapshot: snapshot,
              )));
    } else {
      //Exibe mensagem caso tipo de pgto e fornecedor nao tenham sido informados
      if (_dropdownValueTipoPgto == null) {
        aux.exibirBarraMensagem(
            "O tipo de pagamento deve ser selecionado!", Colors.red, _scaffold);
      }

      if (_dropdownValueFornecedor == null) {
        aux.exibirBarraMensagem(
            "O fornecedor deve ser selecionado!", Colors.red, _scaffold);
      }
    }
  }

  Widget _campoTipoPgto() {
    _controllerFormaPgto.text = pedidoCompra.getTipoPgto;
    //se o pedido estiver finalizado sera criado um TextField com o valor
    //se não estiver, sera criado o dropDown
    if (pedidoCompra.getPedidoFinalizado) {
      return campos.campoTextoDesabilitado(
          _controllerFormaPgto, "Tipo Pagamento", false);
    } else {
      return _criarDropDownTipoPgto();
    }
  }

  Widget _campoPercentDesconto() {
    return Container(
      padding: EdgeInsets.fromLTRB(5.0, 5.0, 0, 0),
      child: TextFormField(
        enabled: !pedidoCompra.getPedidoFinalizado,
        controller: _controllerPercentDesc,
        inputFormatters: [maskDesconto],
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
            hintText: "% Desconto",
            labelText: "% Desconto",
            labelStyle: TextStyle(
                color: cores.corLabel(), fontWeight: FontWeight.w400)),
        style: TextStyle(
            color: cores.corCampo(!pedidoCompra.getPedidoFinalizado),
            fontSize: 17.0),
        onChanged: (texto) {
          if (texto.isNotEmpty) {
            pedidoCompra.setPercentDesconto = double.parse(texto);
          }
          setState(() {
            _controllerPedido.calcularDesconto(pedidoCompra);
            pedidoCompra.setValorDesconto =
                _controllerPedido.pedidoCompra.getValorDesconto;
            _controllerVlTotalDesc.text =
                pedidoCompra.getValorDesconto.toString();
          });
        },
      ),
    );
  }

  Widget _campoFornecedor() {
    _controllerFornecedor.text = pedidoCompra.getEmpresa.getNomeFantasia;
    //se o pedido estiver finalizado sera criado um TextField com o valor
    //se não estiver, sera criado o dropDown
    if (pedidoCompra.getPedidoFinalizado) {
      return campos.campoTextoDesabilitado(
          _controllerFornecedor, "Fornecedor", false);
    } else {
      return _criarDropDownFornecedor();
    }
  }

  void whenCompleteEmpresa() {
    empresa = _controllerEmpresa.getEmpresa;
    pedidoCompra.setLabel = empresa.getRazaoSocial;
  }

  void whenCompleteAtualizarCapaPedido() {
    _controllerVlTotal.text = pedidoCompra.getValorTotal.toString();
    _controllerVlTotalDesc.text = pedidoCompra.getValorDesconto.toString();
    _controllerPercentDesc.text = pedidoCompra.getPercentDesconto.toString();
    _controllerFornecedor.text = _dropdownValueFornecedor;
    _controllerFormaPgto.text = pedidoCompra.getTipoPgto;
  }
}
