import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tcc_3/acessorios/Campos.dart';
import 'package:tcc_3/acessorios/Cores.dart';
import 'package:tcc_3/acessorios/Auxiliares.dart';
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
  final _controllerEstado = TextEditingController();

  Cores cores = Cores();
  Campos campos = Campos();
  Auxiliares aux = Auxiliares();
  Cidade cidade = Cidade();
  EmpresaController _controllerEmpresa = EmpresaController();
  CidadeController _controllerCidade = CidadeController();
  String _dropdownValue;
  String _nomeTela;
  bool _existeCadastroIE;
  bool _existeCadastroCNPJ;
  bool _existeCadastroRazaoSocial;

  @override
  //Ao chamar esta classe popula-se alguns campos da tela
  void initState() {
    super.initState();
    _existeCadastroIE = true;
    _existeCadastroCNPJ = true;
    _existeCadastroRazaoSocial = true;
    if (empresa != null) {
      _nomeTela = "Editar Empresa";
      _controllerRazaoSocial.text = empresa.getRazaoSocial;
      _controllerNomeFantasia.text = empresa.getNomeFantasia;
      _controllerCnpj.text = empresa.getCnpj;
      _controllerinscEstadual.text = empresa.getInscEstadual;
      _controllerCep.text = empresa.getCep;
      _controllerBairro.text = empresa.getBairro;
      _controllerlogradouro.text = empresa.getLogradouro;
      _controllerNumero.text = empresa.getNumero.toString();
      _controllerTelefone.text = empresa.getTelefone;
      _controllerEmail.text = empresa.getEmail;
      _controllerEstado.text = empresa.getCidade.getEstado;
      _dropdownValue =
          (empresa.getCidade.getID + ' - ' + empresa.getCidade.getNome);
      _novocadastro = false;
    } else {
      _nomeTela = "Cadastrar Empresa";
      empresa = Empresa();
      empresa.setAtivo = true;
      empresa.setEhFornecedor = true;
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
            if (_novocadastro) {
              if (_controllerCnpj.text.isNotEmpty) {
                _cnpjValido = _controllerEmpresa.validarCNPJ(empresa.getCnpj);
                if (_cnpjValido) {
                  await _controllerEmpresa.verificarExistenciaCNPJ(
                      empresa.getCnpj, whenCompleteCNPJ);
                }
              }

              if (_controllerinscEstadual.text.isNotEmpty) {
                await _controllerEmpresa.verificarExistenciaInscEstadual(
                    empresa.getInscEstadual, whenCompleteIE);
              }

              if (_controllerRazaoSocial.text.isNotEmpty) {
                await _controllerEmpresa.verificarExistenciaRazaoSocial(
                    empresa.getRazaoSocial, whenCompleteRazaoSocial);
              }
            }
            //Roda o validator de cada campo e verifica se os conteúdos estão de acordo com esperado
            if (_validadorCampos.currentState.validate()) {
              //Verifica se o dropdown da cidade tem valor
              if (_dropdownValue != null) {
                //Transforma as informações da empresa e da cidade para mapa para salvar no firebase
                Map<String, dynamic> mapaCidade = Map();
                mapaCidade["id"] = empresa.getCidade.getID;
                Map<String, dynamic> mapa =
                    _controllerEmpresa.converterParaMapa(empresa);

                //Verifica qual método para persistir as alterações deve-se chamar
                if (_novocadastro) {
                  _controllerEmpresa.persistirEmpresa(mapa, mapaCidade);
                } else {
                  _controllerEmpresa.persistirEmpresa(mapa, mapaCidade);
                }
                //Fecha a tela atual e volta para a anterior
                Navigator.of(context).pop();
              } else {
                //Se a cidade não for selecionada apresenta uma mensagem e não salva as alterações
                if (_dropdownValue == null) {
                  aux.exibirBarraMensagem("É necessário selecionar uma cidade!",
                      Colors.red, _scaffold);
                }
              }
            }
          }),
      body: SingleChildScrollView(
          child: Form(
              key: _validadorCampos,
              child: Column(
                children: [
                  campos.campoTextoDesabilitado(
                      _controllerCnpj, "Código", false),
                  _novocadastro
                      ? _criarCampoRazaoSocial()
                      : campos.campoTextoDesabilitado(
                          _controllerRazaoSocial, "Razão Social", false),
                  _criarCampo(_controllerNomeFantasia, TextInputType.text, 200,
                      "Nome Fantasia"),
                  _novocadastro
                      ? _criarCampoIE()
                      : campos.campoTextoDesabilitado(
                          _controllerinscEstadual, "Inscrição Estadual", false),
                  _novocadastro
                      ? _criarCampoCNPJ()
                      : campos.campoTextoDesabilitado(
                          _controllerCnpj, "CNPJ", false),
                  _criarCampo(_controllerCep, TextInputType.number, 8, "CEP"),
                  campos.campoTextoDesabilitado(
                      _controllerEstado, "Estado", false),
                  _criarDropDownCidade(),
                  _criarCampo(
                      _controllerBairro, TextInputType.text, 100, "Bairro"),
                  _criarCampo(_controllerlogradouro, TextInputType.text, 100,
                      "Logradouro"),
                  _criarCampo(
                      _controllerNumero, TextInputType.number, 10, "Número"),
                  _criarCampo(_controllerTelefone, TextInputType.number, 11,
                      "Telefone"),
                  _criarCampo(_controllerEmail, TextInputType.emailAddress, 30,
                      "E-mail"),
                  _criarCampoCheckBox(),
                  _criarCampoCheckBoxFornecedor(),
                ],
              ))),
    );
  }

  //A propriedade validator dentro de cada campo faz algumas verificações e se o conteúdo não estiver como esperado
//Irá retornar uma mensagem em vermelho logo abaixo do campo

  Widget _criarCampo(TextEditingController _controller, TextInputType tipo,
      int tamanho, String nome) {
    return Container(
        padding: EdgeInsets.fromLTRB(5.0, 5.0, 0, 0),
        child: TextFormField(
          controller: _controller,
          keyboardType: tipo,
          maxLength: tamanho,
          decoration: InputDecoration(
              hintText: nome,
              labelText: nome,
              labelStyle: TextStyle(
                  color: cores.corLabel(), fontWeight: FontWeight.w400)),
          style: TextStyle(color: cores.corCampo(true), fontSize: 17.0),
          validator: (_controller) {
            if (_controller.isNotEmpty) {
              if (nome == "E-mail" && !_controller.contains("@")) {
                return "E-mail inválido!";
              }
              if (nome == "E-mail" && !_controller.contains(".com")) {
                return "E-mail inválido!";
              }
              if (nome == "CEP" && _controller.length < 8) {
                return "Valor inválido, verifique!";
              }
            } else {
              return "É necessário informar este campo!";
            }
            return null;
          },
          onChanged: (texto) {
            switch (nome) {
              case "Logradouro":
                {
                  empresa.setLogradouro = texto.toUpperCase();
                }
                break;

              case "Telefone":
                {
                  empresa.setTelefone = texto.toUpperCase();
                }
                break;

              case "Bairro":
                {
                  empresa.setBairro = texto.toUpperCase();
                }
                break;

              case "Número":
                {
                  empresa.setNumero = int.parse(texto.toUpperCase());
                }
                break;

              case "Nome Fantasia":
                {
                  empresa.setNomeFantasia = texto.toUpperCase();
                }
                break;

              case "E-mail":
                {
                  empresa.setEmail = texto.toLowerCase();
                }
                break;

              case "CEP":
                {
                  empresa.setCep = texto.toUpperCase();
                }
                break;
            }
          },
        ));
  }

  Widget _criarCampoCNPJ() {
    return Container(
        padding: EdgeInsets.fromLTRB(5.0, 5.0, 0, 0),
        child: TextFormField(
            controller: _controllerCnpj,
            keyboardType: TextInputType.text,
            maxLength: 14,
            decoration: InputDecoration(
                hintText: "CNPJ",
                labelText: "CNPJ",
                labelStyle: TextStyle(
                    color: cores.corLabel(), fontWeight: FontWeight.w400)),
            style: TextStyle(color: cores.corCampo(true), fontSize: 17.0),
            validator: (_controllerCnpj) {
              if (_controllerCnpj.isNotEmpty) {
                if (_controllerCnpj.isNotEmpty && _cnpjValido == false) {
                  return "CNPJ inválido!";
                }

                if (_controllerCnpj.isNotEmpty && _controllerCnpj.length < 14) {
                  return "Número de dígitos incorretos!";
                }
                if (_existeCadastroCNPJ) {
                  return "Já existe empresa com esse CNPJ, verifique!";
                }
              } else {
                return "É necessário informar este campo!";
              }
              return null;
            },
            onChanged: (texto) {
              empresa.setCnpj = texto.toUpperCase();
            }));
  }

  Widget _criarCampoRazaoSocial() {
    return Container(
        padding: EdgeInsets.fromLTRB(5.0, 5.0, 0, 0),
        child: TextFormField(
            controller: _controllerRazaoSocial,
            keyboardType: TextInputType.text,
            maxLength: 200,
            decoration: InputDecoration(
                hintText: "Razão Social",
                labelText: "Razão Social",
                labelStyle: TextStyle(
                    color: cores.corLabel(), fontWeight: FontWeight.w400)),
            style: TextStyle(color: cores.corCampo(true), fontSize: 17.0),
            validator: (_controllerRazaoSocial) {
              if (_controllerRazaoSocial.isNotEmpty) {
                if (_existeCadastroRazaoSocial) {
                  return "Razão Social já existe, verifique!";
                }
              } else {
                return "É necessário informar este campo!";
              }
              return null;
            },
            onChanged: (texto) {
              empresa.setRazaoSocial = texto.toUpperCase();
            }));
  }

  Widget _criarCampoIE() {
    return Container(
        padding: EdgeInsets.fromLTRB(5.0, 5.0, 0, 0),
        child: TextFormField(
            controller: _controllerinscEstadual,
            keyboardType: TextInputType.text,
            maxLength: 9,
            decoration: InputDecoration(
                hintText: "Inscrição Estadual",
                labelText: "Inscrição Estadual",
                labelStyle: TextStyle(
                    color: cores.corLabel(), fontWeight: FontWeight.w400)),
            style: TextStyle(color: cores.corCampo(true), fontSize: 17.0),
            validator: (_controllerinscEstadual) {
              if (_controllerinscEstadual.isNotEmpty) {
                if (_controllerinscEstadual.length < 9) {
                  return "Número de dígitos incorretos!";
                }
                if (_existeCadastroIE) {
                  return "Já existe empresa com essa IE, verifique!";
                }
              } else {
                return "É necessário informar este campo!";
              }
              return null;
            },
            onChanged: (texto) {
              empresa.setInscEstadual = texto.toUpperCase();
            }));
  }

  Widget _criarCampoCheckBox() {
    return Container(
      padding: EdgeInsets.only(top: 10.0),
      child: Row(
        children: <Widget>[
          Checkbox(
            value: empresa.getAtivo == true,
            onChanged: (bool novoValor) {
              setState(() {
                if (novoValor) {
                  empresa.setAtivo = true;
                } else {
                  empresa.setAtivo = false;
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
            value: empresa.getEhFornecedor == true,
            onChanged: (bool novoValor) {
              setState(() {
                if (novoValor) {
                  empresa.setEhFornecedor = true;
                } else {
                  empresa.setEhFornecedor = false;
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
        stream: FirebaseFirestore.instance
            .collection('cidades')
            .where('ativa', isEqualTo: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else {
            var length = snapshot.data.docs.length;
            DocumentSnapshot ds = snapshot.data.docs[length - 1];
            return Container(
              padding: EdgeInsets.fromLTRB(5.0, 5.0, 0, 0),
              child: Row(
                children: <Widget>[
                  Container(
                    width: 300.0,
                    child: DropdownButton(
                      value: _dropdownValue,
                      hint: Text("Selecionar cidade"),
                      onChanged: (String newValue) async {
                        await _controllerCidade.obterCidade(newValue);
                        setState(() {
                          _dropdownValue = newValue;
                          empresa.setCidade = _controllerCidade.getCidade;
                          _controllerEstado.text = empresa.getCidade.getEstado;
                        });
                      },
                      items:
                          snapshot.data.docs.map((DocumentSnapshot document) {
                        return DropdownMenuItem<String>(
                            value:
                                document.id + ' - ' + document.data()['nome'],
                            child: Container(
                              child: Text(
                                  document.id + ' - ' + document.data()['nome'],
                                  style: TextStyle(
                                      color: cores.corCampo(true),
                                      fontSize: 17.0)),
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

  void whenCompleteCNPJ() {
    _existeCadastroCNPJ = _controllerEmpresa.getExisteCadastroCNPJ;
  }

  void whenCompleteIE() {
    _existeCadastroIE = _controllerEmpresa.getExisteCadastroIE;
  }

  void whenCompleteRazaoSocial() {
    _existeCadastroRazaoSocial =
        _controllerEmpresa.getExisteCadastroRazaoSocial;
  }
}
