import 'package:flutter/material.dart';
import 'package:tcc_3/Relatorios/Relatorio_Valor_Itens_Vendidos.dart';
import 'package:tcc_3/controller/RelatorioValorItensVendidosController.dart';

class TelaFiltroValorItensVendidos extends StatefulWidget {
  TelaFiltroValorItensVendidos();

  @override
  _TelaFiltroValorItensVendidosState createState() =>
      _TelaFiltroValorItensVendidosState();
}

class _TelaFiltroValorItensVendidosState
    extends State<TelaFiltroValorItensVendidos> {
  final _scaffold = GlobalKey<ScaffoldState>();
  final _controllerDataInicial = TextEditingController();
  final _controllerDataFinal = TextEditingController();
  RelatorioValorItensVendidosController _controllerRelatorio =
      RelatorioValorItensVendidosController();
  DateTime dataInicial;
  DateTime dataFinal;
  DateTime currentDate = DateTime.now();

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
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.arrow_forward),
        backgroundColor: Theme.of(context).primaryColor,
        onPressed: () async {
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
              _controllerRelatorio.lista.add(['Item', 'Valor (R\$)']);
              _controllerRelatorio
                  .obterPedidosRelatorio(dataInicial, dataFinal)
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
      reportView_Valor_Itens_Vendidos(
          context, dataInicial, dataFinal, _controllerRelatorio.lista);
      _controllerRelatorio.lista.clear();
      _controllerRelatorio.pedidos.clear();
      _controllerRelatorio.itensPedidoVenda.clear();
      _controllerRelatorio.itensPedidoVendaAux.clear();
    }
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
