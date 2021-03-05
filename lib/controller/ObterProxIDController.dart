import 'package:cloud_firestore/cloud_firestore.dart';

class ObterProxIDController {
  String proxID;

  ObterProxIDController();

  Future<Null> obterProxID(String collection) async {
    int idTemp = 0;
    int docID;
    CollectionReference ref = FirebaseFirestore.instance.collection(collection);
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
}
