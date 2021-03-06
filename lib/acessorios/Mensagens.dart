import 'package:flutter/material.dart';

class Mensagens {
  Mensagens();

  void exibirBarraMensagem(
      String texto, Color cor, GlobalKey<ScaffoldState> scaffold) {
    scaffold.currentState.showSnackBar(SnackBar(
      content: Text(texto),
      backgroundColor: cor,
      duration: Duration(seconds: 5),
    ));
  }
}
