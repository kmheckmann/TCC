import 'package:flutter/material.dart';
import 'package:tcc_3/screens/TelaFiltroItensVendidos.dart';
import 'package:tcc_3/screens/TelaFiltroCustoPedidos.dart';
import 'package:tcc_3/screens/TelaFiltroValorItensVendidos.dart';

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
        ),
        InkWell(
          child: _linhaNomeRelatorio("Custo pedidos de bonificação"),
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => TelaFiltroCustoPedidos("Bonificação")));
          },
        ),
        InkWell(
          child: _linhaNomeRelatorio("Custo pedidos de troca"),
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => TelaFiltroCustoPedidos("Troca")));
          },
        ),
        InkWell(
          child: _linhaNomeRelatorio("Valor obtido no período por item"),
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => TelaFiltroValorItensVendidos()));
          },
        ),
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
