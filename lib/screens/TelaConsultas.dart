import 'package:flutter/material.dart';
import 'package:tcc_3/screens/TelaFiltroItens_Cliente.dart';

class TelaConsultas extends StatefulWidget {
  @override
  _TelaConsultasState createState() => _TelaConsultasState();
}

class _TelaConsultasState extends State<TelaConsultas> {
  final _scaffold = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    return Container(
        child: InkWell(
      child: Row(
        children: [
          Flexible(
            child: Padding(
                padding: EdgeInsets.fromLTRB(0.0, 15.0, 8.0, 2.0),
                child: Column(
                  children: [
                    Text(
                      "Itens mais vendidos por cliente",
                      style: TextStyle(fontSize: 20.0),
                    ),
                    Divider(color: Colors.black)
                  ],
                )),
          )
        ],
      ),
      onTap: () {
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => TelaFiltroItens_Cliente()));
      },
    ));
  }
}
