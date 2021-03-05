import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tcc_3/model/Cidade.dart';

class CidadeController {
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

  Future<Null> persistirCidade(
      Map<String, dynamic> dadosCidade, String id) async {
    this.dadosCidade = dadosCidade;
    await FirebaseFirestore.instance
        .collection("cidades")
        .doc(id)
        .set(dadosCidade);
  }

  Future<Null> obterCidadePorNomeEstado(String nomeEestado) async {
    //Utilizado pelo cadastro de empresas,
    //para saber qual os dados da cidade selecionada no comboBox

    //A string recebida trás o nome e o estado separados por hifen
    //A string é quebrada e o estado é atribuido a uma variavel e o nome a outra
    var array = nomeEestado.split(" - ");
    String nome = array[0];
    String estado = array[1];

    //obtem-se as cidades com o mesmo nome
    CollectionReference ref = FirebaseFirestore.instance.collection("cidades");
    QuerySnapshot eventsQuery = await ref.where("nome", isEqualTo: nome).get();

    eventsQuery.docs.forEach((document) {
      //Depois, obtem-se a cidade a onde o estado seja igual ao passado por parametro
      if (document.data()['estado'] == estado) {
        Cidade c = Cidade.buscarFirebase(document);
        c.id = document.id;
        cidade = c;
      }
    });
  }

  Future<Null> verificarExistenciaCidade(Cidade cid, bool novoCad) async {
    existeCadastro = true;
    Cidade c = Cidade();
    List<Cidade> cidades = List<Cidade>();

    //Busca todas as cidades cadastradas
    CollectionReference ref = FirebaseFirestore.instance.collection("cidades");
    //Pega todas as cidades com o mesmo nome
    QuerySnapshot eventsQuery2 =
        await ref.where("nome", isEqualTo: cid.nome).get();

    //Para todas cidades com o mesmo nome encontradas verifica se possuem o mesmo estado
    //Se sim, adiciona numa lista
    eventsQuery2.docs.forEach((document) {
      if (document.data()["estado"] == cid.estado) {
        c.nome = document.data()["nome"];
        c.estado = document.data()["estado"];
        c.id = document.id;
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
      if (cidades.length == 1 && cidades[0].id == cid.id) {
        existeCadastro = false;
      } else {
        //Se não for novo cadastro, ou seja, é edição, e a lista nao tiver registros
        //Nao
        if (cidades.length == 0) {
          existeCadastro = false;
        }
      }
    }
  }
}
