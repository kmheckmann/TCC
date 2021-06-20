import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tcc_3/controller/CategoriaController.dart';
import 'package:tcc_3/controller/EstoqueProdutoController.dart';
import 'package:tcc_3/controller/ItemPedidoVendaController.dart';
import 'package:tcc_3/controller/PedidoVendaController.dart';
import 'package:tcc_3/controller/ProdutoController.dart';
import 'package:tcc_3/model/ItemPedido.dart';
import 'package:tcc_3/model/ItemPedidoVenda.dart';
import 'package:tcc_3/model/PedidoVenda.dart';
import 'package:tcc_3/screens/TelaCRUDItemPedidoVenda.dart';

class TelaItensPedidovenda extends StatefulWidget {
  final PedidoVenda pedidoVenda;
  final ItemPedido itemPedido;
  final DocumentSnapshot snapshot;

  TelaItensPedidovenda({this.pedidoVenda, this.itemPedido, this.snapshot});

  @override
  _TelaItensPedidovendaState createState() =>
      _TelaItensPedidovendaState(snapshot, pedidoVenda, itemPedido);
}

class _TelaItensPedidovendaState extends State<TelaItensPedidovenda> {
  final DocumentSnapshot snapshot;
  int qtdeTotalItem = 0;
  ItemPedido itemPedido;
  PedidoVenda pedidoVenda;
  ItemPedido itemRemovido;
  ItemPedidoVendaController _controller = ItemPedidoVendaController();
  EstoqueProdutoController _controllerEstoque = EstoqueProdutoController();
  PedidoVendaController _controllerPedido = PedidoVendaController();
  ProdutoController _controllerproduto = ProdutoController();
  CategoriaController _controllerCategoria = CategoriaController();

  _TelaItensPedidovendaState(this.snapshot, this.pedidoVenda, this.itemPedido);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Itens do Pedido"),
        centerTitle: true,
      ),
      floatingActionButton: Visibility(
          //O Visibility foi adicionado para poder definir quando o botao é apresentado
          //se o pedido estiver finalizado, o botão nao é apresentado
          visible: pedidoVenda.getPedidoFinalizado ? false : true,
          child: FloatingActionButton(
              child: Icon(Icons.add),
              backgroundColor: Theme.of(context).primaryColor,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => TelaCRUDItemPedidoVenda(
                            pedidoVenda: pedidoVenda,
                          )),
                ).then((value) => setState(() {}));
              })),
      body: FutureBuilder<QuerySnapshot>(
          //O sistema ira acessar o documento "pedidos" e depois a coleção de itens dos pedidos
          future: FirebaseFirestore.instance
              .collection("pedidos")
              .doc(pedidoVenda.getID)
              .collection("itens")
              .get(),
          builder: (context, snapshot) {
            //Como os dados serao buscados do firebase, pode ser que demore para obter
            //entao, enquanto os dados nao sao obtidos sera apresentado um circulo na tela
            //indicando que esta carregando
            if (!snapshot.hasData)
              return Center(
                child: CircularProgressIndicator(),
              );
            else
              return ListView.builder(
                  padding: EdgeInsets.all(4.0),
                  //Pega a quantidade de cidades
                  itemCount: snapshot.data.docs.length,
                  //Ira pegar cada cidade no firebase e retornar
                  itemBuilder: (context, index) {
                    _controller.obterProduto(pedidoVenda.getID);
                    ItemPedidoVenda itemPedido = ItemPedidoVenda.buscarFirebase(
                        snapshot.data.docs[index]);
                    itemPedido.produto = _controller.getProduto;
                    return _construirListaPedidos(context, itemPedido,
                        snapshot.data.docs[index], pedidoVenda);
                  });
          }),
    );
  }

  Widget _construirListaPedidos(
      contexto, ItemPedido p, DocumentSnapshot snapshot, PedidoVenda pedido) {
    if (pedido.getPedidoFinalizado) {
      return _codigoLista(contexto, p, snapshot, pedido);
    } else {
      return Dismissible(
        //A key é o que widget dismiss usa pra saber qual item está sendo arrastado
        //Usei os milisegundos pq cada key precisa ser diferente
        key: Key(DateTime.now().millisecondsSinceEpoch.toString()),
        background: Container(
          color: Colors.red,
          child: Align(
            alignment: Alignment(-0.9, 0.0),
            child: Icon(Icons.delete, color: Colors.white),
          ),
        ),
        direction: DismissDirection.startToEnd,
        child: _codigoLista(contexto, p, snapshot, pedido),
        //o atributo inDismissed obriga que seja informado a direcao como parametro
        //no atributo direction rentringi para que o card fosse arrastado somente da esquerda para direita
        //assim a direcao passada sempre sera a mesma, por isso, a direcao nao sera utilizada
        onDismissed: (direction) {
          itemRemovido = p;
          _controllerPedido.subtrairPrecoVlTotal(pedido, itemRemovido);
          pedido.setValorTotal = _controllerPedido.getPedidoVenda.getValorTotal;
          pedido.setValorDesconto =
              _controllerPedido.getPedidoVenda.getValorDesconto;
          _controller.removerItem(p, snapshot.id, pedido.getID,
              _controllerPedido.converterParaMapa(pedido));
        },
      );
    }
  }

  Widget _codigoLista(
      contexto, ItemPedido p, DocumentSnapshot snapshot, PedidoVenda pedido) {
    return InkWell(
      //InkWell eh pra dar uma animacao quando clicar no produto
      child: Card(
        child: Row(
          children: <Widget>[
            //Flexible eh para quebrar a linha caso a descricao do produto seja maior que a largura da tela
            Flexible(
                //padding: EdgeInsets.all(8.0),
                child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    snapshot.data()["label"],
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 0, 120, 189),
                        fontSize: 20.0),
                  ),
                  Text(
                    "Qtde: ${snapshot.data()["quantidade"]}",
                    style:
                        TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500),
                  ),
                  Text(
                    "Preço unitário: ${snapshot.data()["preco"]}",
                    style:
                        TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500),
                  ),
                  Text(
                    "Preço total: ${snapshot.data()["preco"] * snapshot.data()["quantidade"]}",
                    style:
                        TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ))
          ],
        ),
      ),
      onTap: () async {
        await _controllerproduto
            .obterProdutoPorID(id: snapshot.data()["id"])
            .whenComplete(() => p.produto = _controllerproduto.produto);
        await _controllerproduto.obterCategoria(snapshot.data()["id"]);
       _controllerEstoque
            .retornarQtdeExistente(id: snapshot.data()["id"], terminou: whenCompleteObterQtdeExistente);
        await _controllerCategoria
            .obterCategoria(_controllerproduto.getIdCategoriaProduto)
            .whenComplete(() =>
                p.produto.setCategoria = _controllerCategoria.getCategoria);
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => TelaCRUDItemPedidoVenda(
                    pedidoVenda: pedido,
                    itemPedido: p,
                    snapshot: snapshot,
                    qtdeExistente: qtdeTotalItem,
                  )),
        ).then((value) => setState(() {}));
      },
    );
  }

  void whenCompleteObterQtdeExistente() {
    qtdeTotalItem =
        _controllerEstoque.getQtdeExistente;
  }
}
