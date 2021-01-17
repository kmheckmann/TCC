import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tcc_3/model/EstoqueProduto.dart';
import 'package:tcc_3/screens/HomeScreen.dart';

class TelaEstoque extends StatefulWidget {
  final List<EstoqueProduto> estoques;
  @override
  TelaEstoque({this.estoques});
  _TelaEstoqueState createState() => _TelaEstoqueState(estoques: estoques);
}

class _TelaEstoqueState extends State<TelaEstoque> {
  List<EstoqueProduto> estoques = List<EstoqueProduto>();
  _TelaEstoqueState({this.estoques});

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => HomeScreen(
                    )));
              },
            );
          },
        ),
        title: Text("Consulta de Estoque"),
        centerTitle: true,
      ),
      //Botão para retornar a tela de filtro
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.filter_list),
          backgroundColor: Theme.of(context).primaryColor,
          onPressed: () {
            estoques.clear();
            Navigator.of(context).pop(estoques);
          }),
      body: ListView.builder(
          itemCount: estoques == null ? 0 : estoques.length,
          itemBuilder: ((context, index) {
            return _construirListaEstoque(estoques, index);
          })),
    );
  }

//Coloca em cards todos os lotes de produtos com as informações de cada lote
  Widget _construirListaEstoque(estoques, index) {
    EstoqueProduto e = estoques[index];
    return InkWell(
      //InkWell eh pra dar uma animacao quando clicar no produto
      child: Card(
        child: Row(
          children: <Widget>[
            //Flexible eh para quebrar a linha caso a descricao do produto seja maior que a largura da tela
            Flexible(
                //padding: EdgeInsets.all(8.0),
                child: Padding(
              padding: EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "Lote: ${e.id}",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 0, 120, 189),
                        fontSize: 20.0),
                  ),
                  Text(
                    "Qtde: ${e.quantidade.toString()}",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontSize: 17.0),
                  ),
                  Text(
                    "Dt Aquisição: ${_formatarData(e)}",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontSize: 17.0),
                  ),
                  Text(
                    "Preço Compra: ${e.precoCompra.toString()}",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontSize: 17.0),
                  ),
                ],
              ),
            ))
          ],
        ),
      ),
      onTap: () {},
    );
  }

  String _formatarData(EstoqueProduto e) {
    return (e.dataAquisicao.day.toString() +
        "/" +
        e.dataAquisicao.month.toString() +
        "/" +
        e.dataAquisicao.year.toString() +
        " " +
        (new DateFormat.Hms().format(e.dataAquisicao)));
  }
}
