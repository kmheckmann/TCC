import 'package:flutter/material.dart';

class Cores {
  Cores();

  Color corTitulo(bool situacao) {
    if (situacao == true) {
      return Color.fromARGB(255, 0, 120, 189);
    } else {
      return Color.fromARGB(255, 144, 144, 144);
    }
  }

  Color corSecundaria(bool situacao) {
    if (situacao == true) {
      return Color.fromARGB(255, 0, 0, 0);
    } else {
      return Color.fromARGB(255, 144, 144, 144);
    }
  }

  Color corCampo(bool situacao){
    if (situacao == true) {
      return Color.fromARGB(255, 0, 0, 0);
    } else {
      return Color.fromARGB(255, 160, 160, 160);
    }
  }
}
