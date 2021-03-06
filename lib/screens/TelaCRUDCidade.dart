import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tcc_3/acessorios/Campos.dart';
import 'package:tcc_3/acessorios/Cores.dart';
import 'package:tcc_3/acessorios/Mensagens.dart';
import 'package:tcc_3/controller/CidadeController.dart';
import 'package:tcc_3/controller/ObterProxIDController.dart';
import 'package:tcc_3/model/Cidade.dart';

class TelaCRUDCidade extends StatefulWidget {
  final Cidade cidade;
  final DocumentSnapshot snapshot;

  TelaCRUDCidade({this.cidade, this.snapshot});

  @override
  _TelaCRUDCidadeState createState() => _TelaCRUDCidadeState(cidade, snapshot);
}

class _TelaCRUDCidadeState extends State<TelaCRUDCidade> {
  final DocumentSnapshot snapshot;
  _TelaCRUDCidadeState(this.cidade, this.snapshot);

  ObterProxIDController obterProxID = ObterProxIDController();
  CidadeController _controllerCidade = CidadeController();
  Cores cores = Cores();
  Campos campos = Campos();
  Mensagens msg = Mensagens();

  //Usado para inserir texto no campo ou obter
  final _controllerNome = TextEditingController();
  final _controllerID = TextEditingController();
  final _validadorCampos = GlobalKey<FormState>();
  final _scaffold = GlobalKey<ScaffoldState>();

  Cidade cidade;
  bool _novocadastro;
  bool _existeCadastro;
  String _nomeTela;
  String _dropdownValue;

  @override
  void initState() {
    super.initState();
    _existeCadastro = false;
    if (cidade != null) {
      _nomeTela = "Editar Cidade";
      _controllerNome.text = cidade.getNome;
      _controllerID.text = cidade.getID;
      _dropdownValue = cidade.getEstado;
      _novocadastro = false;
    } else {
      _nomeTela = "Cadastrar Cidade";
      cidade = Cidade();
      cidade.setAtiva = true;
      _novocadastro = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffold,
        //barra com o titulo da tela
        appBar: AppBar(
          title: Text(_nomeTela),
          centerTitle: true,
        ),
        //botao para salvar
        floatingActionButton: FloatingActionButton(
            child: Icon(Icons.save),
            backgroundColor: Colors.blue,
            onPressed: () {
              _codigoBotaoSalvar();
            }),
        body: Form(
            key: _validadorCampos,
            child: ListView(
              padding: EdgeInsets.all(8.0),
              //ListView para adicionar scroll quando abrir o teclado em vez de ocultar os campos
              children: <Widget>[
                campos.campoTextoDesabilitado(_controllerID, "Código", false),
                _criarDropDownEstado(),
                _criarCampoNome(),
                _criarCampoCheckBox()
              ],
            )));
  }

  void _codigoBotaoSalvar() async {
    //Se os campos possuirem valores informados
    //verifica se a já existe uma cidade com as mesma informações
    if (_dropdownValue != null && _controllerNome.text.isNotEmpty) {
      await _controllerCidade.verificarExistenciaCidade(cidade, _novocadastro);
      _existeCadastro = _controllerCidade.existeCadastro;
    }

    //Faz a validação do form (propriedade validador do FormTextField)
    if (_validadorCampos.currentState.validate()) {
      if (_dropdownValue != null) {
        //Se o estado nao for informado, não será permitido salvar o cadastro
        //Caso exista uma cidade com mesmo nome o cadastro não é realizado e é apresentada a mensagem
        if (!_existeCadastro) {
          //Se estiver tudo certo converte para mapa para salvar no banco
          Map<String, dynamic> mapa =
              _controllerCidade.converterParaMapa(cidade);

          if (_novocadastro) {
            await obterProxID.obterProxID("cidades");
            cidade.setID = obterProxID.proxID;
            _controllerCidade.persistirCidade(mapa, cidade.getID);
          } else {
            _controllerCidade.persistirCidade(mapa, cidade.getID);
          }
          //retorna para a listagem das cidades
          Navigator.of(context).pop();
        } else {
          msg.exibirBarraMensagem(
              "Essa cidade já está cadastrada!", Colors.red, _scaffold);
        }
      } else {
        if (_dropdownValue == null) {
          msg.exibirBarraMensagem(
              "É necessário selecionar um Estado!", Colors.red, _scaffold);
        }
      }
    }
  }

  Widget _criarCampoNome() {
    return TextFormField(
      controller: _controllerNome,
      decoration: InputDecoration(hintText: "Nome Cidade"),
      style: TextStyle(color: cores.corCampo(true), fontSize: 17.0),
      keyboardType: TextInputType.text,
      //Onde é realizada a validação do form
      validator: (text) {
        //no validator consiste se a cidade informada já existe
        //se existir retorna a mensagem
        if (text.isEmpty) return "Informe o nome da cidade!";
      },
      onChanged: (texto) {
        cidade.setNome = texto.toUpperCase();
      },
    );
  }

  Widget _criarCampoCheckBox() {
    return Container(
      padding: EdgeInsets.only(top: 10.0),
      child: Row(
        children: <Widget>[
          Checkbox(
            value: cidade.getAtiva == true,
            onChanged: (bool novoValor) {
              setState(() {
                if (novoValor) {
                  cidade.setAtiva = true;
                } else {
                  cidade.setAtiva = false;
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

  Widget _criarDropDownEstado() {
    return Container(
      padding: EdgeInsets.fromLTRB(0.0, 8.0, 8.0, 0.0),
      child: Row(
        children: <Widget>[
          DropdownButton<String>(
            value: _dropdownValue,
            style: TextStyle(color: Colors.black),
            underline: Container(
              height: 1,
              color: Colors.grey,
            ),
            hint: Text("Selecionar Estado"),
            onChanged: (String newValue) {
              setState(() {
                cidade.setEstado = null;
                _dropdownValue = newValue;
                cidade.setEstado = _dropdownValue;
              });
            },
            items: <String>[
              'Acre',
              'Alogoas',
              'Amapá',
              'Amazonas',
              'Bahia',
              'Ceará',
              'Distrito Federal',
              'Espírito Santo',
              'Goiás',
              'Maranhão',
              'Mato Grosso',
              'Mato Grosso do Sul',
              'Minas Gerais',
              'Pará',
              'Paraíba',
              'Paraná',
              'Pernambuco',
              'Piauí',
              'Rio de Janeiro',
              'Rio Grande do Norte',
              'Rio Grande do Sul',
              'Rondônia',
              'Roraima',
              'Santa Catarina',
              'São Paulo',
              'Sergipe',
              'Tocantins'
            ].map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          )
        ],
      ),
    );
  }
}
