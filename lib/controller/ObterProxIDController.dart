import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tcc_3/model/Pedido.dart';

class ObterProxIDController {
  String proxID;

  ObterProxIDController();

  Future<Null> obterProxID(CollectionReference collection) async {
    int idTemp = 0;
    int docID;
    CollectionReference ref = collection;
    QuerySnapshot eventsQuery = await ref.get();

    eventsQuery.docs.forEach((document) {
      docID = int.parse(document.id);
      if (eventsQuery.docs.length == 0) {
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

  String proxIDEstoque(Pedido p, String idItem, DateTime data) {
    //obtem o id pedido, id item e a hora, minutos e segundos atuais pra formar o id do estoque do item
    return p.getID +
        "-" +
        idItem +
        "-" +
        data.day.toString() +
        data.month.toString() +
        data.year.toString() +
        data.hour.toString() +
        data.minute.toString() +
        data.second.toString();
  }
}
