import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tcc_3/Relatorios/Relatorio_Itens_Cliente.dart';
import 'package:tcc_3/controller/EmpresaController.dart';
import 'package:tcc_3/controller/RelatorioItensClienteController.dart';
import 'package:tcc_3/model/Empresa.dart';

class TelaFiltroItens_Cliente extends StatefulWidget {
  @override
  _TelaFiltroItens_ClienteState createState() =>
      _TelaFiltroItens_ClienteState();
}

class _TelaFiltroItens_ClienteState extends State<TelaFiltroItens_Cliente> {
  String _dropdownValueCliente;
  final _scaffold = GlobalKey<ScaffoldState>();
  final _controllerDataInicial = TextEditingController();
  final _controllerDataFinal = TextEditingController();
  RelatorioItensClienteController _controllerRelatorio =
      RelatorioItensClienteController();
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
          _criarDropDownCliente(),
          _criarCampoData(context, "Data Inicial", _controllerDataInicial),
          _criarCampoData(context, "Data Final", _controllerDataFinal),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.arrow_forward),
        backgroundColor: Theme.of(context).primaryColor,
        onPressed: () async {
          if (_dropdownValueCliente == null ||
              _controllerDataInicial.text.isEmpty ||
              _controllerDataFinal.text.isEmpty) {
            _scaffold.currentState.showSnackBar(SnackBar(
              content: Text("Informe todos os filtros!"),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 5),
            ));
          } else {
            await _controllerEmpresa
                .obterEmpresaPorDescricao(_dropdownValueCliente);
            empresa = _controllerEmpresa.emp;
            if (dataInicial.isAfter(dataFinal) ||
                dataFinal.isBefore(dataInicial)) {
              _scaffold.currentState.showSnackBar(SnackBar(
                content: Text("Data inicial maior que data final!"),
                backgroundColor: Colors.red,
                duration: Duration(seconds: 5),
              ));
            } else {
              _controllerRelatorio.lista.add(['Item', 'Quantidade']);
              _controllerRelatorio
                  .obterPedidosRelatorio(empresa, dataInicial, dataFinal)
                  .whenComplete(() => obterItens());
            }
          }
        },
      ),
    );
  }

  void obterItens() {
    _controllerRelatorio
        .itensRelatorio(_controllerRelatorio.pedidos)
        .whenComplete(() => removerDuplicados());
  }

  void removerDuplicados() {
    _controllerRelatorio
        .removerDuplicados(_controllerRelatorio.itensPedidoVenda);
    obterLista();
  }

  void obterLista() {
    if (_controllerRelatorio.itensPedidoVenda.length != 0) {
      _controllerRelatorio
          .criarListaTabelaList(_controllerRelatorio.itensPedidoVendaAux);
      reportView_Itens_Cliente(context, _dropdownValueCliente, dataInicial,
          dataFinal, _controllerRelatorio.lista);
    }
    _controllerRelatorio.lista.clear();
    _controllerRelatorio.itensPedidoVenda.clear();
    _controllerRelatorio.itensPedidoVendaAux.clear();
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
