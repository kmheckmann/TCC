import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tcc_3/model/Cidade.dart';
import 'package:tcc_3/model/Empresa.dart';
import 'package:cpfcnpj/cpfcnpj.dart';

class EmpresaController {
  EmpresaController();
  Empresa empresa = Empresa();
  Cidade cidade = Cidade();
  bool existeCadastroCNPJ = true;
  bool existeCadastroIE = true;
  Empresa emp;

  Map<String, dynamic> dadosEmpresa = Map();
  Map<String, dynamic> dadosCidade = Map();

  Map<String, dynamic> converterParaMapa(Empresa e) {
    return {
      "razaoSocial": e.razaoSocial,
      "nomeFantasia": e.nomeFantasia,
      "cnpj": e.cnpj,
      "inscEstadual": e.inscEstadual,
      "cep": e.cep,
      "bairro": e.bairro,
      "logradouro": e.logradouro,
      "numero": e.numero,
      "telefone": e.telefone,
      "email": e.email,
      "ativo": e.ativo,
      "ehFornecedor": e.ehFornecedor
    };
  }

  Future<Null> salvarEmpresa(Map<String, dynamic> dadosEmpresa,
      Map<String, dynamic> dadosCidade) async {
    this.dadosEmpresa = dadosEmpresa;
    this.dadosCidade = dadosCidade;
    await FirebaseFirestore.instance
        .collection("empresas")
        .doc(dadosEmpresa["cnpj"])
        .set(dadosEmpresa);

    await FirebaseFirestore.instance
        .collection("empresas")
        .doc(dadosEmpresa["cnpj"])
        .collection("cidade")
        .doc("IDcidade")
        .set(dadosCidade);
  }

  Future<Null> editarEmpresa(Map<String, dynamic> dadosEmpresa,
      Map<String, dynamic> dadosCidade, String idFirebase) async {
    this.dadosEmpresa = dadosEmpresa;
    this.dadosCidade = dadosCidade;
    await FirebaseFirestore.instance
        .collection("empresas")
        .doc(idFirebase)
        .set(dadosEmpresa);

    await FirebaseFirestore.instance
        .collection("empresas")
        .doc(idFirebase)
        .collection("cidade")
        .doc("IDcidade")
        .set(dadosCidade);
  }

  //Método para buscar os valores da cidade na subcoleção dentro da empresa
  Future<Null> obterCidadeEmpresa(String idEmpresa) async {
    Cidade c = Cidade();
    CollectionReference ref = FirebaseFirestore.instance
        .collection('empresas')
        .doc(idEmpresa)
        .collection('cidade');
    QuerySnapshot obterCidadeDaEmpresa = await ref.get();

    CollectionReference refCidade =
        FirebaseFirestore.instance.collection('cidades');
    QuerySnapshot obterDadosCidade = await refCidade.get();

    obterCidadeDaEmpresa.docs.forEach((document) {
      c.setID = document.data()["id"];

      obterDadosCidade.docs.forEach((document1) {
        if (c.getID == document1.id) {
          c = Cidade.buscarFirebase(document1);
        }
      });
    });
    this.cidade = c;
  }

  Future<Null> verificarExistenciaEmpresa(Empresa e, bool novoCadastro) async {
    Empresa emp;
    //Duas listas criadas para indicar corretamente ao usuario se já existe uma empresa com só com o mesmo CNPJ
    //Se existe uma empresa só com a mesma Inscrição Estadual ou ambos
    List<Empresa> empresasMesmoCNPJ = List<Empresa>();
    List<Empresa> empresasMesmaInscEstadual = List<Empresa>();
    //Busca todas as empresas cadastradas
    CollectionReference ref = FirebaseFirestore.instance.collection("empresas");
    QuerySnapshot eventsQuery = await ref.get();

    eventsQuery.docs.forEach((document) {
      //Para cada empresa retornada verificar se o CNPJ ou inscrição estadual
      //são iguais ao que está tentando ser atribuído ao novo cadastro
      //Se for, adiciona na lista correspondente
      if (document.data()["cnpj"] == e.cnpj) {
        emp = Empresa.buscarFirebase(document);
        emp.id = document.id;
        empresasMesmoCNPJ.add(emp);
      }

      if (document.data()["inscEstadual"] == e.inscEstadual) {
        emp = Empresa.buscarFirebase(document);
        emp.id = document.id;
        empresasMesmaInscEstadual.add(emp);
      }
    });

    if (novoCadastro) {
      //Quando for um novo cadastro não pode existir nenhuma outra empresa com o mesmo cnpj e inscrição estadual
      //entao o tamanho da lista da empresa deve ser 0 para permitir adicionar o registro
      if (empresasMesmoCNPJ.length == 0 || empresasMesmoCNPJ.isEmpty)
        existeCadastroCNPJ = false;
      if (empresasMesmaInscEstadual.length == 0 ||
          empresasMesmaInscEstadual.isEmpty) existeCadastroIE = false;
    } else {
      //Se não for um novo cadastro, já existe 1 registro,
      //Existe a possibilidade do usuario alterar o valor e depois tentar voltar ao original
      //Para tratar isso será comparado o ID do cadastro existente com o que esta sendo alterado
      //Se forem diferentes, será informado que o cadastro já existe e não será possível salvar
      //Se forem iguais, permite salvar
      if (empresasMesmaInscEstadual.length == 1 &&
          empresasMesmaInscEstadual[0].id == e.id) existeCadastroIE = false;
      if (empresasMesmoCNPJ.length == 1 && empresasMesmoCNPJ[0].id == e.id)
        existeCadastroCNPJ = false;
    }
  }

  //Método utilizado pela tela te pedidos
  //seleciona-se a empresa no comboBox e pelo nome fantasia busca os outros dados da empresa
  Future<Empresa> obterEmpresaPorDescricao(String nomeEmpresa) async {
    CollectionReference ref = FirebaseFirestore.instance.collection('empresas');
    QuerySnapshot eventsQuery =
        await ref.where("razaoSocial", isEqualTo: nomeEmpresa).get();

    eventsQuery.docs.forEach((document) {
      emp = Empresa.buscarFirebase(document);
      emp.id = document.id;
    });
    return Future.value(emp);
  }

  bool validarCNPJ(String cnpj) {
    bool cnpjValido;
    CNPJ.format(cnpj);
    if (CNPJ.isValid(cnpj)) {
      cnpjValido = true;
    } else {
      cnpjValido = false;
    }
    return cnpjValido;
  }
}
