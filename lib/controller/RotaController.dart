import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tcc_3/model/Empresa.dart';
import 'package:tcc_3/model/Rota.dart';
import 'package:tcc_3/model/Usuario.dart';

class RotaController {
  Map<String, dynamic> dadosRota = Map();
  Map<String, dynamic> dadosVendedor = Map();
  Map<String, dynamic> dadosCliente = Map();
  Usuario vendedor = Usuario();
  bool existeRota;

  RotaController();

  Future<String> obterProxID() async {
    int idTemp = 0;
    int docID;
    String proxID;
    CollectionReference ref = Firestore.instance.collection("rotas");
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
    return Future.value(proxID);
  }

  //Converte para mapa pasa salvar no firebase
  Map<String, dynamic> converterParaMapa(Rota r) {
    return {
      "diaSemana": r.getDiaSemana,
      "frequencia": r.getFrequencia,
      "ativa": r.getAtiva,
      "tituloRota": r.getTituloRota,
      "idv": r.getIDV
    };
  }

//Persiste a roda criada no banco
  Future<Null> persistirRota(
      Map<String, dynamic> dadosRota,
      Map<String, dynamic> dadosCliente,
      Map<String, dynamic> dadosVendedor,
      String id) async {
    this.dadosRota = dadosRota;
    this.dadosCliente = dadosCliente;
    this.dadosVendedor = dadosVendedor;
    await Firestore.instance
        .collection("rotas")
        .document(id)
        .setData(dadosRota);

//Cria na collection Rota uma collection onde será salvo o ID do cliente da rota
    await Firestore.instance
        .collection("rotas")
        .document(id)
        .collection("cliente")
        .document("IDcliente")
        .setData(dadosCliente);

//Cria na collection Rota uma collection onde será salvo o ID do vendedor da rota
    await Firestore.instance
        .collection("rotas")
        .document(id)
        .collection("vendedor")
        .document("IDvendedor")
        .setData(dadosVendedor);
  }

//Obtem através do ID do cliente salvo dentro da colletion ROta, as informações do cliente
  Future<Empresa> obterCliente(String idRota) async {
    Empresa cliente = Empresa();
    CollectionReference ref = Firestore.instance
        .collection('rotas')
        .document(idRota)
        .collection('cliente');
    QuerySnapshot obterClienteRota = await ref.getDocuments();

    for (var document in obterClienteRota.documents) {
      cliente.setId = document.data()["id"];

      CollectionReference refCliente =
          Firestore.instance.collection('empresas');
      QuerySnapshot obterDadosEmpresa = await refCliente.getDocuments();

      for (var document in obterDadosEmpresa.documents) {
        if (cliente.getId == document.documentID) {
          cliente = Empresa.buscarFirebase(document);
          return Future.value(cliente);
        }
      }
    }
  }

//Obtem através do ID do vendedor salvo dentro da colletion ROta, as informações do vendedor
  Future<Usuario> obterVendedor(String idRota) async {
    CollectionReference ref = Firestore.instance
        .collection('rotas')
        .document(idRota)
        .collection('vendedor');
    QuerySnapshot obterVendedorRota = await ref.getDocuments();

    for (var document in obterVendedorRota.documents) {
      vendedor.setID = document.data()["id"];
      CollectionReference refCliente =
          Firestore.instance.collection('usuarios');
      QuerySnapshot obterDadosVendedor = await refCliente.getDocuments();      

      for (var document in obterDadosVendedor.documents) {
        if (vendedor.getID == document.documentID) {
          vendedor = Usuario.buscarFirebase(document);
          return Future.value(vendedor);
        }
      }
    }
  }

  Future<Null> verificarExistenciaRota(String idCLiente, Rota r) async {
    existeRota = false;
    //Busca todas as rotas cadastradas
    CollectionReference ref = Firestore.instance.collection("rotas");
    QuerySnapshot eventsQuery1 = await ref.getDocuments();

    for (var document in eventsQuery1.documents) {
      CollectionReference ref2 = Firestore.instance
          .collection('rotas')
          .document(document.documentID)
          .collection('cliente');
          String idAtualLista = document.documentID;
      QuerySnapshot eventsQuery2 = await ref2.getDocuments();
      eventsQuery2.documents.forEach((document) {
        if (idCLiente == document.data()["id"] && r.getIdFirebase != idAtualLista) {
          existeRota = true;
        }
      });
    }
  }
}
