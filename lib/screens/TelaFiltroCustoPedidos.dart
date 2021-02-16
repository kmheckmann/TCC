import 'package:flutter/material.dart';
import 'package:tcc_3/controller/RelatorioCustoPedidosController.dart';
import 'package:tcc_3/Relatorios/Relatorio_Custo_Pedidos.dart';

class TelaFiltroCustoPedidos extends StatefulWidget {
  final String tipoPedido;
  TelaFiltroCustoPedidos(this.tipoPedido);

  @override
  _TelaFiltroCustoPedidosState createState() =>
      _TelaFiltroCustoPedidosState(this.tipoPedido);
}

class _TelaFiltroCustoPedidosState
    extends State<TelaFiltroCustoPedidos> {
  final String tipoPedido;

  _TelaFiltroCustoPedidosState(this.tipoPedido);
  final _scaffold = GlobalKey<ScaffoldState>();
  final _controllerDataInicial = TextEditingController();
  final _controllerDataFinal = TextEditingController();
  RelatorioCustoPedidosController _controllerPedidos =
      RelatorioCustoPedidosController();
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
              _controllerPedidos.lista
                  .add(['Pedido', 'Cliente', 'Valor Total (R\$)']);
              _controllerPedidos
                  .obterPedidosBonificacao(dataInicial, dataFinal, tipoPedido)
                  .whenComplete(() => obterLista());
            }
          }
        },
      ),
    );
  }

  void obterLista() {
    if (_controllerPedidos.lista.length != 0) {
      reportView_Custo_Pedidos(
          context, dataInicial, dataFinal, _controllerPedidos.lista, tipoPedido);
      _controllerPedidos.lista.clear();
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