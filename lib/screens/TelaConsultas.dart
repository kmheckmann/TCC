import 'package:flutter/material.dart';
import 'package:tcc_3/screens/TelaFiltroItensVendidos.dart';

class TelaConsultas extends StatefulWidget {
  @override
  _TelaConsultasState createState() => _TelaConsultasState();
}

class _TelaConsultasState extends State<TelaConsultas> {
  final _scaffold = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(
      children: [
        InkWell(
          child: _linhaNomeRelatorio("Itens mais vendidos por cliente"),
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => TelaFiltroItensVendidos(true)));
          },
        ),
        InkWell(
          child: _linhaNomeRelatorio("Itens mais vendidos"),
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => TelaFiltroItensVendidos(false)));
          },
        )
      ],
    ));
  }

  Widget _linhaNomeRelatorio(String nome) {
    return Row(
      children: [
        Flexible(
          child: Padding(
              padding: EdgeInsets.fromLTRB(0.0, 15.0, 8.0, 2.0),
              child: Column(
                children: [
                  Text(
                    nome,
                    style: TextStyle(fontSize: 20.0),
                  ),
                  Divider(color: Colors.black)
                ],
              )),
        )
      ],
    );
  }
}
