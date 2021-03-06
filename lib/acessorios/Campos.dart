import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tcc_3/acessorios/Cores.dart';

class Campos {
  String texto;

  Campos();

  Cores cores = Cores();

  Widget campoTextoDesabilitado(
      TextEditingController controller, String titulo, bool habilitado) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
          hintText: titulo,
          labelText: titulo,
          labelStyle: TextStyle(
              color: cores.corTextoCampoDesabilitado(habilitado),
              fontWeight: FontWeight.w400)),
      style: TextStyle(color: cores.corCampo(habilitado), fontSize: 17.0),
      enabled: habilitado,
    );
  }
}
