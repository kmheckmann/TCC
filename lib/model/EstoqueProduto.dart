import 'package:cloud_firestore/cloud_firestore.dart';

class EstoqueProduto {
  String id;
  DateTime dataAquisicao;
  double precoCompra;
  int quantidade;

  EstoqueProduto();

//Snapshot é como se fosse uma foto da coleção existente no banco
//Esse construtor usa o snapshot para obter o ID do documento e demais informações
//Isso é usado quando há um componente do tipo builder que vai consultar alguma colletion
//E para cada item nessa colletion terá um snapshot e será possível atribuir isso a um objeto
  EstoqueProduto.buscarFirebase(DocumentSnapshot snapshot) {
    //DocumentSnapshot contém as informações obtidas do firebase
    id = snapshot.documentID;
    dataAquisicao = snapshot.data()["dtAquisicao"].toDate();
    quantidade = snapshot.data()["quantidade"];
    precoCompra = snapshot.data()["precoCompra"] + 0.0;
  }
}
