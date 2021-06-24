import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tcc_3/acessorios/Cores.dart';
import 'package:tcc_3/controller/CategoriaController.dart';
import 'package:tcc_3/controller/ItemPedidoCompraController.dart';
import 'package:tcc_3/controller/PedidoCompraController.dart';
import 'package:tcc_3/controller/ProdutoController.dart';
import 'package:tcc_3/model/ItemPedido.dart';
import 'package:tcc_3/model/ItemPedidoCompra.dart';
import 'package:tcc_3/model/PedidoCompra.dart';
import 'package:tcc_3/screens/TelaCRUDItemPedidoCompra.dart';

class TelaItensPedidoCompra extends StatefulWidget {
  final PedidoCompra pedidoCompra;
  final ItemPedido itemPedido;
  final DocumentSnapshot snapshot;

  TelaItensPedidoCompra({this.pedidoCompra, this.itemPedido, this.snapshot});

  @override
  _TelaItensPedidoCompraState createState() =>
      _TelaItensPedidoCompraState(snapshot, pedidoCompra, itemPedido);
}

class _TelaItensPedidoCompraState extends State<TelaItensPedidoCompra> {
  final DocumentSnapshot snapshot;
  ItemPedido itemPedido;
  PedidoCompra pedidoCompra;
  ItemPedido itemRemovido;
  ItemPedidoCompraController _controller = ItemPedidoCompraController();
  ProdutoController _controllerproduto = ProdutoController();
  PedidoCompraController _controllerPedido = PedidoCompraController();
  CategoriaController _controllerCategoria = CategoriaController();
  Cores cor = Cores();

  _TelaItensPedidoCompraState(
      this.snapshot, this.pedidoCompra, this.itemPedido);
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
          visible: pedidoCompra.getPedidoFinalizado ? false : true,
          child: FloatingActionButton(
              child: Icon(Icons.add),
              backgroundColor: Theme.of(context).primaryColor,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => TelaCRUDItemPedidoCompra(
                            pedidoCompra: pedidoCompra,
                          )),
                ).then((value) => setState(() {}));
              })),
      body: FutureBuilder<QuerySnapshot>(
          //O sistema ira acessar o documento "pedidos" e depois a coleção de itens dos pedidos
          future: FirebaseFirestore.instance
              .collection("pedidos")
              .doc(pedidoCompra.getID)
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
                  //Pega a quantidade de itens
                  itemCount: snapshot.data.docs.length,
                  //Ira pegar cada item no firebase e retornar
                  itemBuilder: (context, index) {
                    ItemPedido itemPedido = ItemPedidoCompra.buscarFirebase(
                        snapshot.data.docs[index]);
                    _controllerproduto
                        .obterProdutoPorID(id: itemPedido.id)
                        .whenComplete(() =>
                            itemPedido.produto = _controllerproduto.produto);
                    return _construirListaPedidos(context, itemPedido,
                        snapshot.data.docs[index], pedidoCompra);
                  });
          }),
    );
  }

  Widget _construirListaPedidos(
      contexto, ItemPedido p, DocumentSnapshot snapshot, PedidoCompra pedido) {
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
          pedido.setValorTotal = _controllerPedido.pedidoCompra.getValorTotal;
          pedido.setValorDesconto =
              _controllerPedido.pedidoCompra.getValorDesconto;
          _controller.removerItem(p, snapshot.id, pedido.getID,
              _controllerPedido.converterParaMapa(pedido));
        },
      );
    }
  }

  Widget _codigoLista(
      contexto, ItemPedido p, DocumentSnapshot snapshot, PedidoCompra pedido) {
    return InkWell(
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
                        color: cor.corTitulo(!pedido.getPedidoFinalizado),
                        fontSize: 20.0),
                  ),
                  Text(
                    "Qtde: ${snapshot.data()["quantidade"]}",
                    style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w500,
                        color: cor.corSecundaria(!pedido.getPedidoFinalizado)),
                  ),
                  Text(
                    "Preço unitário: ${snapshot.data()["preco"]}",
                    style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w500,
                        color: cor.corSecundaria(!pedido.getPedidoFinalizado)),
                  ),
                  Text(
                    "Preço total: ${(snapshot.data()["preco"] * snapshot.data()["quantidade"]).toStringAsFixed(2)}",
                    style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w500,
                        color: cor.corSecundaria(!pedido.getPedidoFinalizado)),
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
        await _controllerproduto.obterCategoria(p.produto.getID);
        await _controllerCategoria
            .obterCategoria(_controllerproduto.getIdCategoriaProduto)
            .whenComplete(() =>
                p.produto.setCategoria = _controllerCategoria.getCategoria);
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => TelaCRUDItemPedidoCompra(
                    pedidoCompra: pedido,
                    itemPedido: p,
                    snapshot: snapshot,
                  )),
        ).then((value) => setState(() {}));
      },
    );
  }
}
