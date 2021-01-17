import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tcc_3/model/ItemPedido.dart';
import 'package:tcc_3/model/Produto.dart';

abstract class ItemPedidoController {
  String proxID;
  Produto produto = Produto();
  Map<String, dynamic> dadosPedido = Map();

  Future<Null> obterProxID(String idPedido) async {
    int idTemp = 0;
    int docID;
    CollectionReference ref = Firestore.instance
        .collection("pedidos")
        .document(idPedido)
        .collection("itens");
    QuerySnapshot eventsQuery = await ref.getDocuments();

    eventsQuery.documents.forEach((document) {
      docID = int.parse(document.documentID);
      if (eventsQuery.documents.length == 0) {
        idTemp = 1;
        proxID = idTemp.toString();
      } else {
        if (docID > idTemp) {
          idTemp = docID;
        }
      }
    });

    idTemp = idTemp + 1;
    proxID = idTemp.toString();
  }

  void persistirItem(ItemPedido item, String idPedido, String idProduto,
      Map<String, dynamic> dadosPedido);

  void removerItem(ItemPedido item, String idItem, String idPedido,
      Map<String, dynamic> dadosPedido);

//Método utilizado para pegar as demais informações do produto selecionado na tela de cadastro do item do pedido
  Future<Null> obterProduto(String idPedido) async {
    Produto prod = Produto();
    //Busca a categoria vinculada ao produto (dentro do produto está salvo somente o ID da categoria)
    CollectionReference ref = Firestore.instance
        .collection('pedidos')
        .document(idPedido)
        .collection('itens');
    QuerySnapshot obterProduto = await ref.getDocuments();

    //Busca todas as categorias cadastradas
    CollectionReference refCliente = Firestore.instance.collection('produtos');
    QuerySnapshot obterDadosProduto = await refCliente.getDocuments();

    //Pega o ID do produto do pedido e compara com os IDs dos produtos cadastrados
    //Se o ID do produto do pedido for igual ao ID de um dos produtos cadastradao, atribui as informações
    obterProduto.documents.forEach((document) {
      prod.id = document.data()["id"];
      obterDadosProduto.documents.forEach((document1) {
        if (prod.id == document1.documentID) {
          prod = Produto.buscarFirebase(document1);
        }
      });
    });
    this.produto = prod;
  }
}
