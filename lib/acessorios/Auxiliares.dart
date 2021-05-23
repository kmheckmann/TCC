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
