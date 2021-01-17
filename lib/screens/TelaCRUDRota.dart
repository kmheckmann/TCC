import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tcc_3/controller/EmpresaController.dart';
import 'package:tcc_3/controller/RotaController.dart';
import 'package:tcc_3/controller/UsuarioController.dart';
import 'package:tcc_3/model/Rota.dart';
import 'package:tcc_3/model/Empresa.dart';
import 'package:tcc_3/model/Usuario.dart';

class TelaCRUDRota extends StatefulWidget {
  final Rota rota;
  final Usuario user;
  final DocumentSnapshot snapshot;

  TelaCRUDRota({this.rota, this.snapshot, this.user});

  @override
  _TelaCRUDRotaState createState() => _TelaCRUDRotaState(rota, snapshot, user);
}

//enumerado das opções de frequencia
enum SingingCharacter { semanal, quinzenal, mensal }

class _TelaCRUDRotaState extends State<TelaCRUDRota> {
  final DocumentSnapshot snapshot;
  final _validadorCampos = GlobalKey<FormState>();
  final _scaffold = GlobalKey<ScaffoldState>();
  final Usuario user;
  RotaController _controllerRota = RotaController();
  EmpresaController _controllerEmpresa = EmpresaController();
  UsuarioController _controllerUsuario = UsuarioController();
  final _controllerCliente = TextEditingController();
  final _controllerVendedor = TextEditingController();
  final _controllerDiaSemana = TextEditingController();
  bool _clienteComRota;
  String _dropdownValueVendedor;
  String _dropdownValueCliente;
  String _dropdownValueDiaSemana;

  Rota rota;
  bool _novocadastro;
  String _nomeTela;
  Empresa cliente = Empresa();
  Usuario vendedor = Usuario();

  SingingCharacter _character = SingingCharacter.semanal;
  _TelaCRUDRotaState(this.rota, this.snapshot, this.user);
  @override
  void initState() {
    super.initState();
    //busca do firebase todas as empresas e usuarios para popular os campos cliente e vendedor, respectivamente
    _clienteComRota = false;
    if (rota != null) {
      //Se foi passado o objeto rota por parâmetro ao direcionar para esta tela
      //atribui as informações do objeto aos campos
      _nomeTela = "Editar Rota";
      _dropdownValueDiaSemana = rota.getDiaSemana;
      _dropdownValueVendedor =
          rota.getVendedor.getNome + " - " + rota.getVendedor.getCPF;
      _dropdownValueCliente = rota.getCliente.razaoSocial;
      _atribuirValorFrquencia(rota.getFrequencia);
      _novocadastro = false;
    } else {
      //se não for passado por parametro um objeto tipo rota assume que é um novo cadastro
      _nomeTela = "Cadastrar Rota";
      rota = Rota();
      rota.setAtiva = true;
      _novocadastro = true;
      rota.setFrequencia = "Semanal";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffold,
      appBar: AppBar(
        //cria a barra no topo com o nome da tela
        title: Text(_nomeTela),
        centerTitle: true,
      ),
      floatingActionButton: Visibility(
          //Se o user for administrador apresenta o botão para salvar
          visible: user.getEhAdm,
          child: FloatingActionButton(
            //cria o icone para salcar
            child: Icon(Icons.save),
            backgroundColor: Colors.blue,
            onPressed: () async {
              //ao salvar verifica se os campos não estão vazios
              if (_dropdownValueCliente != null &&
                  _dropdownValueVendedor != null &&
                  _dropdownValueDiaSemana != null) {
                cliente = await _controllerEmpresa
                    .obterEmpresaPorDescricao(_dropdownValueCliente);
                vendedor = await _controllerUsuario
                    .obterUsuarioPorCPF(_dropdownValueVendedor);
                await _controllerRota.verificarExistenciaRota(cliente.id, rota);
                _clienteComRota = _controllerRota.existeRota;
                //depois dos campos verifica se outro vendedor não realiza a rota para o cliente selecionado
                if (_clienteComRota == false) {
                  _fazerPersistencia();
                  //Fecha a tela atual e volta para a anterior
                  Navigator.of(context).pop();
                } else {
                  //se outro vendedor já possui rota para o cliente selecionado exibe mensagem e não salva
                  _scaffold.currentState.showSnackBar(SnackBar(
                    content:
                        Text("Cliente é utilizado em outra rota. Verifique!"),
                    backgroundColor: Colors.red,
                    duration: Duration(seconds: 5),
                  ));
                }
              } else {
                //se não forem informados todos os campos exibe mensagem e não salva
                _scaffold.currentState.showSnackBar(SnackBar(
                  content: Text(
                      "Todos os campos da tela devem ter um valor selecionado!"),
                  backgroundColor: Colors.red,
                  duration: Duration(seconds: 5),
                ));
              }
            },
          )),
      body: Form(
          //Form cria o corpo da tela
          key: _validadorCampos,
          child: ListView(
            padding: EdgeInsets.all(8.0),
            children: <Widget>[
              //onde seta-se os campos que serão apresentados
              //Dentro de cada método será verificado se o usuário é administrador
              //Se for, apresenta os campos habilitados para edição
              //Caso contrário não será permitido editar
              _campoVendedor(),
              _campoCliente(),
              _campoDiaSemana(),
              _criarRadioButton(),
              _criarCampoCheckBox(),
            ],
          )),
    );
  }

  Widget _criarDropDownCliente() {
    return StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance.collection('empresas').where("ativo", isEqualTo: true).snapshots(),
        builder: (context, snapshot) {
          var length = snapshot.data.documents.length;
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else {
            DocumentSnapshot ds = snapshot.data.documents[length - 1];
            return Container(
              padding: EdgeInsets.all(8.0),
              child: Row(
                children: <Widget>[
                  Container(
                    width: 300.0,
                    child: DropdownButtonFormField(
                      decoration: InputDecoration(
                          labelText: "Cliente",
                          labelStyle: TextStyle(color: Colors.blueGrey)),
                      value: _dropdownValueCliente,
                      onChanged: (String newValue) {
                        setState(() {
                          _dropdownValueCliente = newValue;
                        });
                      },
                      items: snapshot.data.documents
                          .map((DocumentSnapshot document) {
                        return DropdownMenuItem<String>(
                            value: document.data()['razaoSocial'],
                            child: Container(
                              child: Text(document.data()['razaoSocial'],
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

  Widget _criarDropDownVendedor() {
    return StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance.collection('usuarios').where("ativo", isEqualTo: true).snapshots(),
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
                    child: DropdownButtonFormField(
                      decoration: InputDecoration(
                          labelText: "Vendedor",
                          labelStyle: TextStyle(color: Colors.blueGrey)),
                      value: _dropdownValueVendedor,
                      onChanged: (String newValue) {
                        setState(() {
                          _dropdownValueVendedor = newValue;
                        });
                      },
                      items: snapshot.data.documents
                          .map((DocumentSnapshot document) {
                        return DropdownMenuItem<String>(
                            value: document.data()['nome'] +
                                " - " +
                                document.data()['cpf'],
                            child: Container(
                              child: Text(
                                  document.data()['nome'] +
                                      " - " +
                                      document.data()['cpf'],
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

  Widget _criarOpcoesDiaSemana() {
    return Container(
      width: 300.0,
      padding: EdgeInsets.all(8.0),
      child: Row(
        children: <Widget>[
          Container(
            width: 300.0,
            child: DropdownButtonFormField<String>(
              decoration: InputDecoration(
                  labelText: "Dia da Semana",
                  labelStyle: TextStyle(color: Colors.blueGrey)),
              value: _dropdownValueDiaSemana,
              style: TextStyle(color: Colors.black),
              onChanged: (String newValue) {
                setState(() {
                  _dropdownValueDiaSemana = newValue;
                  rota.setDiaSemana = _dropdownValueDiaSemana;
                });
              },
              items: <String>[
                'Domingo',
                'Segunda-feira',
                'Terça-feita',
                'Quarta-feira',
                'Quinta-feira',
                'Sexta-feira',
                'Sábado'
              ].map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value, style: TextStyle(color: Colors.black)),
                );
              }).toList(),
            ),
          )
        ],
      ),
    );
  }

  Widget _criarRadioButton() {
    return Column(
      children: <Widget>[
        RadioListTile<SingingCharacter>(
          title: const Text('Semanal'),
          value: SingingCharacter.semanal,
          groupValue: _character,
          onChanged: user.getEhAdm
              ? (SingingCharacter value) {
                  setState(() {
                    _character = value;
                    rota.setFrequencia = "Semanal";
                  });
                }
              : null,
        ),
        RadioListTile<SingingCharacter>(
          title: const Text('Quinzenal'),
          value: SingingCharacter.quinzenal,
          groupValue: _character,
          onChanged: user.getEhAdm
              ? (SingingCharacter value) {
                  setState(() {
                    _character = value;
                    rota.setFrequencia = "Quinzenal";
                  });
                }
              : null,
        ),
        RadioListTile<SingingCharacter>(
          title: const Text('Mensal'),
          value: SingingCharacter.mensal,
          groupValue: _character,
          onChanged: user.getEhAdm
              ? (SingingCharacter value) {
                  setState(() {
                    _character = value;
                    rota.setFrequencia = "Mensal";
                  });
                }
              : null,
        )
      ],
    );
  }

  Widget _criarCampoCheckBox() {
    return Container(
      padding: EdgeInsets.only(top: 10.0),
      child: Row(
        children: <Widget>[
          Checkbox(
            value: rota.getAtiva == true,
            onChanged: user.getEhAdm
                ? (bool novoValor) {
                    setState(() {
                      if (novoValor) {
                        rota.setAtiva = true;
                      } else {
                        rota.setAtiva = false;
                      }
                    });
                  }
                : null,
          ),
          Text(
            "Ativa?",
            style: TextStyle(fontSize: 18.0),
          ),
        ],
      ),
    );
  }

  void _atribuirValorFrquencia(String frequencia) {
    if (frequencia == "Semanal") {
      _character = SingingCharacter.semanal;
    }
    if (frequencia == "Quinzenal") {
      _character = SingingCharacter.quinzenal;
    }
    if (frequencia == "Mensal") {
      _character = SingingCharacter.mensal;
    }
  }

  void _fazerPersistencia() async {
    //faz as atribuições necessárias para ter todos os dados que serão salvos no firebase
    rota.setTituloRota = vendedor.getNome + " - " + cliente.razaoSocial;
    rota.setIDV = vendedor.getID;
    Map<String, dynamic> mapa = _controllerRota.converterParaMapa(rota);
    Map<String, dynamic> mapaVendedor = Map();
    mapaVendedor["id"] = vendedor.getID;
    Map<String, dynamic> mapaCliente = Map();
    mapaCliente["id"] = cliente.id;
    if (_novocadastro) {
      //se for um novo cadastro gera novo id
      rota.setIdFirebase = await _controllerRota.obterProxID();
    }
    _controllerRota.persistirRota(
        mapa, mapaCliente, mapaVendedor, rota.getIdFirebase);
  }

  Widget _campoVendedor() {
    if(!_novocadastro){
      _controllerVendedor.text =
        rota.getVendedor.getNome + " - " + rota.getVendedor.getCPF;
    }
    
    if (user.getEhAdm) {
      return _criarDropDownVendedor();
    } else {
      return _criarCampoTexto("Vendedor", _controllerVendedor);
    }
  }

  Widget _campoCliente() {
    if(!_novocadastro){
      _controllerCliente.text = rota.getCliente.razaoSocial;
    }
    
    if (user.getEhAdm) {
      return _criarDropDownCliente();
    } else {
      return _criarCampoTexto("Cliente", _controllerCliente);
    }
  }

  Widget _campoDiaSemana() {
    if(!_novocadastro){
      _controllerDiaSemana.text = rota.getDiaSemana;
    }
    if (user.getEhAdm) {
      return _criarOpcoesDiaSemana();
    } else {
      return _criarCampoTexto("Dia da Semana", _controllerDiaSemana);
    }
  }

  Widget _criarCampoTexto(String nome, TextEditingController controller) {
    return Container(
      padding: EdgeInsets.all(8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
            hintText: nome,
            labelText: nome,
            labelStyle:
                TextStyle(color: Colors.blueGrey, fontWeight: FontWeight.w400)),
        style: TextStyle(color: Colors.grey, fontSize: 17.0),
        enabled: false,
      ),
    );
  }
}
