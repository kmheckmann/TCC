import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tcc_3/controller/CidadeController.dart';
import 'package:tcc_3/controller/EmpresaController.dart';
import 'package:tcc_3/model/Cidade.dart';
import 'package:tcc_3/model/Empresa.dart';

class TelaCRUDEmpresa extends StatefulWidget {
  final Empresa empresa;
  final DocumentSnapshot snapshot;

  TelaCRUDEmpresa({this.empresa, this.snapshot});

  @override
  _TelaCRUDEmpresaState createState() =>
      _TelaCRUDEmpresaState(empresa, snapshot);
}

class _TelaCRUDEmpresaState extends State<TelaCRUDEmpresa> {
  Empresa empresa;
  final DocumentSnapshot snapshot;
  bool _novocadastro;
  bool _cnpjValido;

  _TelaCRUDEmpresaState(this.empresa, this.snapshot);

  String _nomeTela;
  Cidade cidade = Cidade();
  EmpresaController _controllerEmpresa = EmpresaController();
  CidadeController _controllerCidade = CidadeController();
  String _dropdownValue;
  bool _existeCadastroIE;
  bool _existeCadastroCNPJ;

  //Usa-se controladores de textos para colocar texto nos componentes e obter o que está no componente
  final _scaffold = GlobalKey<ScaffoldState>();
  final _validadorCampos = GlobalKey<FormState>();
  final _controllerRazaoSocial = TextEditingController();
  final _controllerNomeFantasia = TextEditingController();
  final _controllerCnpj = TextEditingController();
  final _controllerinscEstadual = TextEditingController();
  final _controllerCep = TextEditingController();
  final _controllerBairro = TextEditingController();
  final _controllerlogradouro = TextEditingController();
  final _controllerNumero = TextEditingController();
  final _controllerTelefone = TextEditingController();
  final _controllerEmail = TextEditingController();

  @override
  //Ao chamar esta classe popula-se alguns campos da tela
  void initState() {
    super.initState();
    _existeCadastroIE = false;
    _existeCadastroCNPJ = false;
    if (empresa != null) {
      _nomeTela = "Editar Empresa";
      _controllerRazaoSocial.text = empresa.razaoSocial;
      _controllerNomeFantasia.text = empresa.nomeFantasia;
      _controllerCnpj.text = empresa.cnpj;
      _controllerinscEstadual.text = empresa.inscEstadual;
      _controllerCep.text = empresa.cep;
      _controllerBairro.text = empresa.bairro;
      _controllerlogradouro.text = empresa.logradouro;
      _controllerNumero.text = empresa.numero.toString();
      _controllerTelefone.text = empresa.telefone;
      _controllerEmail.text = empresa.email;
      _dropdownValue = (empresa.cidade.nome + ' - ' + empresa.cidade.estado);
      _novocadastro = false;
    } else {
      _nomeTela = "Cadastrar Empresa";
      empresa = Empresa();
      empresa.ativo = true;
      empresa.ehFornecedor = true;
      _novocadastro = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffold,
        appBar: AppBar(
          title: Text(_nomeTela),
          centerTitle: true,
        ),
        //Botão para salvar
        floatingActionButton: FloatingActionButton(
            child: Icon(Icons.save),
            backgroundColor: Colors.blue,
            onPressed: () async {
              if (_controllerCnpj.text.isNotEmpty) {
                _cnpjValido = _controllerEmpresa.validarCNPJ(empresa.cnpj);
              }
              //Ao clicar pra salvar realiza a verificação de CNPJ e Inscrição Estadual
              await _controllerEmpresa.verificarExistenciaEmpresa(
                  empresa, _novocadastro);

              //Roda o validator de cada campo e verifica se os conteúdos estão de acordo com esperado
              if (_validadorCampos.currentState.validate()) {
                //Verifica se o dropdown da cidade tem valor
                if (_dropdownValue != null) {
                  //Obtém todas as informações da cidade do dropdown
                  await _controllerCidade.obterCidadePorNomeEstado(_dropdownValue);
                  empresa.cidade = _controllerCidade.cidade;

                  //Transforma as informações da empresa e da cidade para mapa para salvar no firebase
                  Map<String, dynamic> mapaCidade = Map();
                  mapaCidade["id"] = empresa.cidade.id;
                  Map<String, dynamic> mapa =
                      _controllerEmpresa.converterParaMapa(empresa);

                  //Verifica qual método para persistir as alterações deve-se chamar
                  if (_novocadastro) {
                    _controllerEmpresa.salvarEmpresa(mapa, mapaCidade);
                  } else {
                    _controllerEmpresa.editarEmpresa(
                        mapa, mapaCidade, empresa.id);
                  }
                  //Fecha a tela atual e volta para a anterior
                  Navigator.of(context).pop();
                } else {
                  //Se a cidade não for selecionada apresenta uma mensagem e não salva as alterações
                  if (_dropdownValue == null) {
                    _scaffold.currentState.showSnackBar(SnackBar(
                      content: Text("É necessário selecionar uma cidade!"),
                      backgroundColor: Colors.red,
                      duration: Duration(seconds: 5),
                    ));
                  }
                }
              }
            }),
        body: Form(
            key: _validadorCampos,
            child: ListView(
              padding: EdgeInsets.all(8.0),
              children: <Widget>[
                //Faz as chamadas de todos os componentes necessários para criar a tela
                _criarCampo(_controllerRazaoSocial, TextInputType.text, 200,
                    "Razão Social"),
                _criarCampo(_controllerNomeFantasia, TextInputType.text, 200,
                    "Nome Fantasia"),
                _criarCampoIE(),
                _criarCampoCNPJ(),
                _criarCampo(_controllerCep, TextInputType.number, 8, "CEP"),
                _criarDropDownCidade(),
                _criarCampoBairro(),
                _criarCampo(_controllerlogradouro, TextInputType.text, 100,
                    "Logradouro"),
                _criarCampoNumero(),
                _criarCampoTelefone(),
                _criarCampoEmail(),
                _criarCampoCheckBox(),
                _criarCampoCheckBoxFornecedor(),
              ],
            )));
  }

//A propriedade validator dentro de cada campo faz algumas verificações e se o conteúdo não estiver como esperado
//Irá retornar uma mensagem em vermelho logo abaixo do campo
  Widget _criarCampoEmail() {
    return Container(
        padding: EdgeInsets.all(6.0),
        child: TextFormField(
          controller: _controllerEmail,
          keyboardType: TextInputType.emailAddress,
          maxLength: 50,
          decoration: InputDecoration(
            hintText: "E-mail",
          ),
          style: TextStyle(color: Colors.black, fontSize: 17.0),
          validator: (text) {
            if (text.isEmpty) return "É necessário informar este campo!";
            if (text.isNotEmpty && !text.contains("@") ||
                !text.contains(".com")) return "E-mail inválido!";
          },
          onChanged: (texto) {
            empresa.email = texto.toLowerCase();
          },
        ));
  }

  Widget _criarCampoNumero() {
    return Container(
        padding: EdgeInsets.all(6.0),
        child: TextFormField(
          controller: _controllerNumero,
          keyboardType: TextInputType.number,
          maxLength: 10,
          decoration: InputDecoration(
            hintText: "Número",
          ),
          style: TextStyle(color: Colors.black, fontSize: 17.0),
          validator: (text) {
            if (text.isEmpty) return "É necessário informar este campo!";
          },
          onChanged: (texto) {
            empresa.numero = int.parse(texto.toUpperCase());
          },
        ));
  }

  Widget _criarCampoTelefone() {
    return Container(
        padding: EdgeInsets.all(6.0),
        child: TextFormField(
          controller: _controllerTelefone,
          keyboardType: TextInputType.number,
          maxLength: 11,
          decoration: InputDecoration(
            hintText: "Telefone",
          ),
          style: TextStyle(color: Colors.black, fontSize: 17.0),
          validator: (text) {
            if (text.isEmpty) return "É necessário informar este campo!";
          },
          onChanged: (texto) {
            empresa.telefone = texto.toUpperCase();
          },
        ));
  }

  Widget _criarCampoBairro() {
    return Container(
        padding: EdgeInsets.all(6.0),
        child: TextFormField(
          controller: _controllerBairro,
          keyboardType: TextInputType.text,
          maxLength: 100,
          decoration: InputDecoration(
            hintText: "Bairro",
          ),
          style: TextStyle(color: Colors.black, fontSize: 17.0),
          validator: (text) {
            if (text.isEmpty) return "É necessário informar este campo!";
          },
          onChanged: (texto) {
            empresa.bairro = texto.toUpperCase();
          },
        ));
  }

  Widget _criarCampo(TextEditingController _controller, TextInputType tipo,
      int tamanho, String nome) {
    return Container(
        padding: EdgeInsets.all(6.0),
        child: TextFormField(
          controller: _controller,
          keyboardType: tipo,
          maxLength: tamanho,
          decoration: InputDecoration(
            hintText: nome,
          ),
          style: TextStyle(color: Colors.black, fontSize: 17.0),
          validator: (text) {
            if (text.isEmpty) return "É necessário informar este campo!";
            if (nome == "CEP" && text.length < 8)
              return "Valor inválido, verifique!";
          },
          onChanged: (texto) {
            switch (nome) {
              case "Logradouro":
                {
                  empresa.logradouro = texto.toUpperCase();
                }
                break;

              case "Razão Social":
                {
                  empresa.razaoSocial = texto.toUpperCase();
                }
                break;

              case "Nome Fantasia":
                {
                  empresa.nomeFantasia = texto.toUpperCase();
                }
                break;

              case "CEP":
                {
                  empresa.cep = texto.toUpperCase();
                }
                break;
            }
          },
        ));
  }

  Widget _criarCampoCNPJ() {
    return Container(
        padding: EdgeInsets.all(6.0),
        child: TextFormField(
          controller: _controllerCnpj,
          keyboardType: TextInputType.number,
          maxLength: 14,
          //Se não for um novo cadastro o campo fica desabilitado
          enabled: _novocadastro,
          decoration: InputDecoration(
            hintText: "CNPJ",
          ),
          style: _style(),
          validator: (text) {
            if (text.isEmpty || text.length < 14)
              return "É necessário informar corretamente este campo!";
            if (_existeCadastroCNPJ)
              return "Já existe empresa com esse CNPJ, verifique!";
            if (text.isNotEmpty && _cnpjValido == false)
              return "CNPJ inválido!";
          },
          onChanged: (texto) {
            empresa.cnpj = texto.toUpperCase();
          },
        ));
  }

  Widget _criarCampoIE() {
    return Container(
        padding: EdgeInsets.all(6.0),
        child: TextFormField(
          controller: _controllerinscEstadual,
          keyboardType: TextInputType.number,
          maxLength: 9,
          decoration: InputDecoration(
            hintText: "Inscrição Estadual",
          ),
          style: TextStyle(color: Colors.black, fontSize: 17.0),
          validator: (text) {
            if (text.isEmpty || text.length < 9)
              return "É necessário informar corretamente este campo!";
            if (_existeCadastroIE)
              return "Já existe empresa com essa IE, verifique!";
          },
          onChanged: (texto) {
            empresa.inscEstadual = texto.toUpperCase();
          },
        ));
  }

  Widget _criarCampoCheckBox() {
    return Container(
      padding: EdgeInsets.only(top: 10.0),
      child: Row(
        children: <Widget>[
          Checkbox(
            value: empresa.ativo == true,
            onChanged: (bool novoValor) {
              setState(() {
                if (novoValor) {
                  empresa.ativo = true;
                } else {
                  empresa.ativo = false;
                }
              });
            },
          ),
          Text(
            "Ativa?",
            style: TextStyle(fontSize: 18.0),
          ),
        ],
      ),
    );
  }

  Widget _criarCampoCheckBoxFornecedor() {
    return Container(
      padding: EdgeInsets.only(top: 10.0),
      child: Row(
        children: <Widget>[
          Checkbox(
            value: empresa.ehFornecedor == true,
            onChanged: (bool novoValor) {
              setState(() {
                if (novoValor) {
                  empresa.ehFornecedor = true;
                } else {
                  empresa.ehFornecedor = false;
                }
              });
            },
          ),
          Text(
            "Fornecedor?",
            style: TextStyle(fontSize: 18.0),
          ),
        ],
      ),
    );
  }

  Widget _criarDropDownCidade() {
    return StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance
            .collection('cidades')
            .where('ativa', isEqualTo: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else {
            var length = snapshot.data.documents.length;
            DocumentSnapshot ds = snapshot.data.documents[length - 1];
            return Container(
              padding: EdgeInsets.all(8.0),
              child: Row(
                children: <Widget>[
                  Container(
                    width: 300.0,
                    child: DropdownButton(
                      value: _dropdownValue,
                      hint: Text("Selecionar cidade"),
                      onChanged: (String newValue) {
                        setState(() {
                          _dropdownValue = newValue;
                        });
                      },
                      items: snapshot.data.documents
                          .map((DocumentSnapshot document) {
                        return DropdownMenuItem<String>(
                            value: document.data()['nome'] +
                                ' - ' +
                                document.data()['estado'],
                            child: Container(
                              child: Text(
                                  document.data()['nome'] +
                                      ' - ' +
                                      document.data()['estado'],
                                  style: TextStyle(color: Colors.black)),
                            ));
                      }).toList(),
                    ),
                  ),
                ],
              ),
            );
          }
        });
  }

  //Define a cor da fonte de campos que serão desabilitados ao se tratar de uma edição
  TextStyle _style() {
    if (_novocadastro) {
      return TextStyle(color: Colors.black, fontSize: 17.0);
    } else {
      return TextStyle(color: Colors.grey, fontSize: 17.0);
    }
  }
}
