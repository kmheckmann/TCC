import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tcc_3/model/Cidade.dart';

class CidadeController {
  String proxID;
  Cidade cidade = Cidade();
  bool existeCadastro;

  CidadeController();

  Map<String, dynamic> dadosCidade = Map();

  Map<String, dynamic> converterParaMapa(Cidade c) {
    return {
      "nome": c.nome,
      "estado": c.estado,
      "ativa": c.ativa,
    };
  }

  Future<Null> salvarCidade(Map<String, dynamic> dadosCidade, String id) async {
    this.dadosCidade = dadosCidade;
    await Firestore.instance
        .collection("cidades")
        .document(id)
        .setData(dadosCidade);
  }

  Future<Null> editarCidade(
      Map<String, dynamic> dadosCidade, String idFirebase) async {
    this.dadosCidade = dadosCidade;
    await Firestore.instance
        .collection("cidades")
        .document(idFirebase)
        .setData(dadosCidade);
  }

  Future<Null> obterProxID() async {
    int idTemp = 0;
    int docID;
    CollectionReference ref = Firestore.instance.collection("cidades");
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

  Future<Null> obterCidadePorNome(String nomeEestado) async {
    //Utilizado pelo cadastro de empresas, para saber qual o codigo da cidade selecionada no comboBox do cadastroF
    var array = nomeEestado.split(" - ");
    String nome = array[0];
    String estado = array[1];
    CollectionReference ref = Firestore.instance.collection("cidades");
    QuerySnapshot eventsQuery =
        await ref.where("nome", isEqualTo: nome).getDocuments();

    eventsQuery.documents.forEach((document) {
      if (document.data()['estado'] == estado) {
        Cidade c = Cidade.buscarFirebase(document);
        c.id = document.documentID;
        cidade = c;
      }
    });
  }

  Future<Null> verificarExistenciaCidade(Cidade cid, bool novoCad) async {
    existeCadastro = true;
    Cidade c = Cidade();
    List<Cidade> cidades = List<Cidade>();

    //Busca todas as cidades cadastradas
    CollectionReference ref = Firestore.instance.collection("cidades");
    //Pega todas as cidades com o mesmo nome
    QuerySnapshot eventsQuery2 =
        await ref.where("nome", isEqualTo: cid.nome).getDocuments();

    //Para todas cidades com o mesmo nome encontradas verifica se possuem o mesmo estado
    //Se sim, adiciona numa lista
    eventsQuery2.documents.forEach((document) {
      if (document.data()["estado"] == cid.estado) {
        c.nome = document.data()["nome"];
        c.estado = document.data()["estado"];
        c.id = document.documentID;
        cidades.add(c);
      }
    });
    if (novoCad) {
      //Quando for um novo cadastro não pode existir nenhuma outra cidade com o mesmo nome e stado
      //entao o tamanho da lista da cidade deve ser 0 para permitir adicionar o registro
      if (cidades.length == 0 || cidades.isEmpty) existeCadastro = false;
    } else {
      //Se não for um novo cadastro, já existe 1 registro,
      //Existe a possibilidade do usuario alterar o texto e depois tentar voltar ao original
      //Para tratar isso será comparado o ID do cadastro existente com o que esta sendo alterado
      //Se forem diferentes, será informado que o cadastro já existe e não será possível salvar
      //Se forem iguais, permite salvar
      if (cidades.length == 1 && cidades[0].id == cid.id)
        existeCadastro = false;
    }
  }
}
