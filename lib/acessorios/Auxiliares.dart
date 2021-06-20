import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Auxiliares {
  Auxiliares();

  void exibirBarraMensagem(
      String texto, Color cor, GlobalKey<ScaffoldState> scaffold) {
    scaffold.currentState.showSnackBar(SnackBar(
      content: Text(texto),
      backgroundColor: cor,
      duration: Duration(seconds: 5),
    ));
  }

  Widget alerta(String texto1, String texto2, BuildContext context) {
    return AlertDialog(
      title: Text(texto1),
      titleTextStyle: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 22.0),
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            Text(texto2),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: Text('OK'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        )
      ],
    );
  }

  String formatarData(DateTime data) {
    return (data.day.toString() +
        "/" +
        data.month.toString() +
        "/" +
        data.year.toString() +
        " " +
        (new DateFormat.Hms().format(data)));
  }
}
