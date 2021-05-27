import 'package:flutter/material.dart';
import 'package:tcc_3/acessorios/Auxiliares.dart';
import 'package:tcc_3/acessorios/Cores.dart';
import 'package:tcc_3/model/EstoqueProduto.dart';
import 'package:tcc_3/screens/HomeScreen.dart';

class TelaEstoque extends StatefulWidget {
  final List<EstoqueProduto> estoques;
  @override
  TelaEstoque({this.estoques});
  _TelaEstoqueState createState() => _TelaEstoqueState(estoques: estoques);
}

class _TelaEstoqueState extends State<TelaEstoque> {
  List<EstoqueProduto> estoques = [];
  _TelaEstoqueState({this.estoques});
  Auxiliares aux = Auxiliares();
  Cores cores = Cores();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //Na barra no topo da tela cria um icone de uma seta
        //Ao clicar nesse icone retorna para a tela inicial
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
      //Para retornar a tela de filtro
      //Deve-se clicar no botao na parte inferior direita da tela
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
                        color: cores.corTitulo(true),
                        fontSize: 20.0),
                  ),
                  Text(
                    "Qtde: ${e.quantidade.toString()}",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: cores.corSecundaria(true),
                        fontSize: 17.0),
                  ),
                  Text(
                    "Dt Aquisição: ${aux.formatarData(e.dataAquisicao)}",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: cores.corSecundaria(true),
                        fontSize: 17.0),
                  ),
                  Text(
                    "Preço Compra: ${e.precoCompra.toString()}",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: cores.corSecundaria(true),
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
}
