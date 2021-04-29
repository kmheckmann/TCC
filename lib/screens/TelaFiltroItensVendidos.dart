import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tcc_3/Relatorios/Relatorio_Itens_Cliente.dart';
import 'package:tcc_3/controller/EmpresaController.dart';
import 'package:tcc_3/controller/RelatorioItensClienteController.dart';
import 'package:tcc_3/controller/RelatorioItensVendidosController.dart';
import 'package:tcc_3/model/Empresa.dart';

class TelaFiltroItensVendidos extends StatefulWidget {
  final bool filtraCliente;
  TelaFiltroItensVendidos(this.filtraCliente);
  @override
  _TelaFiltroItensVendidosState createState() =>
      _TelaFiltroItensVendidosState(this.filtraCliente);
}

class _TelaFiltroItensVendidosState extends State<TelaFiltroItensVendidos> {
  final bool filtraCliente;
  _TelaFiltroItensVendidosState(this.filtraCliente);
  String _dropdownValueCliente;
  final _scaffold = GlobalKey<ScaffoldState>();
  final _controllerDataInicial = TextEditingController();
  final _controllerDataFinal = TextEditingController();
  RelatorioItensClienteController _controllerRelatorioFiltraCliente =
      RelatorioItensClienteController();
  RelatorioItensVendidosController _controllerRelatorioItensVendidos =
      RelatorioItensVendidosController();
  EmpresaController _controllerEmpresa = EmpresaController();
  DateTime dataInicial;
  DateTime dataFinal;
  DateTime currentDate = DateTime.now();
  Empresa empresa;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffold,
      appBar: AppBar(
        title: Text("Filtros"),
        centerTitle: true,
      ),
      body: ListView(
        children: <Widget>[
          _criarCampoData(context, "Data Inicial", _controllerDataInicial),
          _criarCampoData(context, "Data Final", _controllerDataFinal),
          filtraCliente ? _criarDropDownCliente() : Container(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.arrow_forward),
        backgroundColor: Theme.of(context).primaryColor,
        onPressed: () async {
          if (_dropdownValueCliente == null && filtraCliente) {
            _scaffold.currentState.showSnackBar(SnackBar(
              content: Text("Informe o cliente!"),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 5),
            ));
          } else {
            if (_controllerDataInicial.text.isEmpty ||
                _controllerDataFinal.text.isEmpty) {
              _scaffold.currentState.showSnackBar(SnackBar(
                content: Text("Informe todas as datas!"),
                backgroundColor: Colors.red,
                duration: Duration(seconds: 5),
              ));
            } else {
              if (dataInicial.isAfter(dataFinal) ||
                  dataFinal.isBefore(dataInicial)) {
                _scaffold.currentState.showSnackBar(SnackBar(
                  content: Text("Data inicial maior que data final!"),
                  backgroundColor: Colors.red,
                  duration: Duration(seconds: 5),
                ));
              } else {
                if (filtraCliente) {
                  _filtraPorCliente();
                } else {
                  _itensVendidos();
                }
              }
            }
          }
        },
      ),
    );
  }

  void _filtraPorCliente() async {
    await _controllerEmpresa.obterEmpresaPorDescricao(_dropdownValueCliente);
    empresa = _controllerEmpresa.getEmp;
    _controllerRelatorioFiltraCliente.lista.add(['Item', 'Quantidade']);
    _controllerRelatorioFiltraCliente
        .obterPedidosRelatorioPorCliente(empresa, dataInicial, dataFinal)
        .whenComplete(() => obterItens());
  }

  void _itensVendidos() async {
    _controllerRelatorioItensVendidos.lista.add(['Item', 'Quantidade']);
    _controllerRelatorioItensVendidos
        .obterPedidosRelatorio(dataInicial, dataFinal)
        .whenComplete(() => obterItens());
  }

  void obterItens() {
    if (filtraCliente) {
      _controllerRelatorioFiltraCliente
          .itensRelatorio(_controllerRelatorioFiltraCliente.pedidos)
          .whenComplete(() => removerDuplicados());
    } else {
      _controllerRelatorioItensVendidos
          .itensRelatorio(_controllerRelatorioItensVendidos.pedidos)
          .whenComplete(() => removerDuplicados());
    }
  }

  void removerDuplicados() {
    if (filtraCliente) {
      _controllerRelatorioFiltraCliente.removerDuplicados(
          _controllerRelatorioFiltraCliente.itensPedidoVenda);
      obterLista();
    } else {
      _controllerRelatorioItensVendidos.removerDuplicados(
          _controllerRelatorioItensVendidos.itensPedidoVenda);
      obterLista();
    }
  }

  void obterLista() {
    if (filtraCliente) {
      if (_controllerRelatorioFiltraCliente.itensPedidoVenda.length != 0) {
        _controllerRelatorioFiltraCliente.criarListaTabelaList();
        reportView_Itens_Cliente(
            context,
            _dropdownValueCliente,
            dataInicial,
            dataFinal,
            _controllerRelatorioFiltraCliente.lista,
            "Relatório itens mais vendidos por cliente",
            filtraCliente);
      }
      _controllerRelatorioFiltraCliente.lista.clear();
      _controllerRelatorioFiltraCliente.itensPedidoVenda.clear();
      _controllerRelatorioFiltraCliente.limparLinkedHashMap();
      _controllerRelatorioFiltraCliente.itensPedidoVendaAux.clear();
    } else {
      if (_controllerRelatorioItensVendidos.itensPedidoVenda.length != 0) {
        _controllerRelatorioItensVendidos.criarListaTabelaList();
        reportView_Itens_Cliente(
            context,
            _dropdownValueCliente,
            dataInicial,
            dataFinal,
            _controllerRelatorioItensVendidos.lista,
            "Relatório itens mais vendidos",
            filtraCliente);
      }
      _controllerRelatorioItensVendidos.lista.clear();
      _controllerRelatorioItensVendidos.itensPedidoVenda.clear();
      _controllerRelatorioItensVendidos.limparLinkedHashMap();
      _controllerRelatorioItensVendidos.itensPedidoVendaAux.clear();
    }
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
              padding: EdgeInsets.all(8.0),
              child: Row(
                children: <Widget>[
                  Container(
                    width: 336.0,
                    height: 88.0,
                    child: DropdownButtonFormField(
                      decoration: InputDecoration(
                          labelText: "Cliente",
                          labelStyle: TextStyle(color: Colors.blueGrey)),
                      value: _dropdownValueCliente,
                      style: TextStyle(color: Colors.black),
                      onChanged: (String newValue) {
                        setState(() {
                          _dropdownValueCliente = newValue;
                        });
                      },
                      items:
                          snapshot.data.docs.map((DocumentSnapshot document) {
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

  Future<void> _selectDate(BuildContext context, String label) async {
    final DateTime pickedDate = await showDatePicker(
        context: context,
        initialDate: currentDate,
        firstDate: DateTime(2015),
        lastDate: DateTime(2050));
    if (pickedDate != null && pickedDate != currentDate)
      setState(() {
        if (label == "Data Inicial") {
          dataInicial = pickedDate;
          _controllerDataInicial.text =
              "${dataInicial.day}/${dataInicial.month}/${dataInicial.year}";
        } else {
          dataFinal = pickedDate;
          _controllerDataFinal.text =
              "${dataFinal.day}/${dataFinal.month}/${dataFinal.year}";
        }
      });
  }

  Widget _criarCampoData(
      context, String label, TextEditingController controller) {
    return SizedBox(
      width: 300.0,
      child: Row(
        children: [
          Container(
              width: 170.0,
              padding: EdgeInsets.fromLTRB(8.0, 0.0, 0.0, 0.0),
              child: TextFormField(
                controller: controller,
                keyboardType: TextInputType.number,
                maxLength: 10,
                enabled: false,
                decoration: InputDecoration(
                  labelText: label,
                  labelStyle: TextStyle(color: Colors.blueGrey),
                ),
                style: TextStyle(color: Colors.black, fontSize: 17.0),
              )),
          IconButton(
              icon: Icon(Icons.calendar_today),
              color: Theme.of(context).primaryColor,
              onPressed: () {
                _selectDate(context, label);
              })
        ],
      ),
    );
  }
}
