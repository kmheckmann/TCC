import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:tcc_3/acessorios/Cores.dart';
import 'package:tcc_3/controller/PedidoVendaController.dart';
import 'package:tcc_3/controller/UsuarioController.dart';
import 'package:tcc_3/model/PedidoVenda.dart';
import 'package:tcc_3/model/Usuario.dart';
import 'package:tcc_3/screens/TelaCRUDPedidoVenda.dart';

class TelaPedidosVenda extends StatefulWidget {
  @override
  _TelaPedidosVendaState createState() => _TelaPedidosVendaState();
}

class _TelaPedidosVendaState extends State<TelaPedidosVenda> {
  Usuario u = Usuario();
  DateFormat format = DateFormat();
  Cores cores = Cores();
  UsuarioController _usuarioController = UsuarioController();

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<UsuarioController>(
        builder: (context, child, model) {
      u.setID = model.dadosUsuarioAtual["id"];
      u.setPrimeiroLogin = model.dadosUsuarioAtual[["primeiroLogin"]];
      u.setNome = model.dadosUsuarioAtual["nome"];
      u.setEmail = model.dadosUsuarioAtual["email"];
      u.setCPF = model.dadosUsuarioAtual["cpf"];
      u.setEhAdm = model.dadosUsuarioAtual["ehAdm"];
      u.setAtivo = model.dadosUsuarioAtual["ativo"];

      return ScopedModel<PedidoVenda>(
        model: PedidoVenda(),
        child: Scaffold(
          floatingActionButton: FloatingActionButton(
              child: Icon(Icons.add),
              backgroundColor: Theme.of(context).primaryColor,
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => TelaCRUDPedidoVenda(vendedor: u)));
                setState(() {});
              }),
          body: FutureBuilder<QuerySnapshot>(
              //O sistema ira acessar o documento "pedidos" e buscar todos os pedidos marcados como pedidos de venda
              future: FirebaseFirestore.instance
                  .collection("pedidos")
                  .where("ehPedidoVenda", isEqualTo: true)
                  .orderBy("pedidoFinalizado", descending: true)
                  .get(),
              builder: (context, snapshot) {
                //Como os dados serao buscados do firebase, pode ser que demore para obter
                //entao, enquanto os dados nao sao obtidos sera apresentado um circulo na tela
                //indicando que esta carregando
                if (!snapshot.hasData)
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                else
                  return ListView.builder(
                      padding: EdgeInsets.all(4.0),
                      //Pega a quantidade de cidades
                      itemCount: snapshot.data.docs.length,
                      //Ira pegar cada cidade no firebase e retornar
                      itemBuilder: (context, index) {
                        PedidoVenda pedidoVenda = PedidoVenda.buscarFirebase(
                            snapshot.data.docs[index]);
                        return _construirListaPedidos(
                            context, pedidoVenda, snapshot.data.docs[index], u);
                      });
              }),
        ),
      );
    });
  }

  Widget _construirListaPedidos(
      contexto, PedidoVenda p, DocumentSnapshot snapshot, Usuario u) {
    return InkWell(
      //InkWell eh pra dar uma animacao quando clicar no produto
      child: Card(
        child: Row(
          children: <Widget>[
            //Flexible eh para quebrar a linha caso a descricao do produto seja maior que a largura da tela
            Flexible(
                //padding: EdgeInsets.all(8.0),
                child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    p.getID,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: cores.corTitulo(!p.getPedidoFinalizado),
                        fontSize: 20.0),
                  ),
                  Text(
                    "Fornecedor: ${p.getLabel}",
                    style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w500,
                        color: cores.corSecundaria(!p.getPedidoFinalizado)),
                  ),
                  Text(
                    "Data: ${p.getDataPedido.day}/${p.getDataPedido.month}/${p.getDataPedido.year} ${new DateFormat.Hms().format(p.getDataPedido)}",
                    style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w500,
                        color: cores.corSecundaria(!p.getPedidoFinalizado)),
                  ),
                  Text(
                    p.getPedidoFinalizado
                        ? "Finalizado: Sim"
                        : "Finalizado: Não",
                    style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w500,
                        color: cores.corSecundaria(!p.getPedidoFinalizado)),
                  )
                ],
              ),
            ))
          ],
        ),
      ),
      onTap: () async {
        PedidoVendaController _controller = PedidoVendaController();
        /*await _controller.obterEmpresadoPedido(p.getID);
        p.setEmpresa = _controller.empresa;
        await _controller.obterUsuariodoPedido(p.getID);
        p.setUser = _controller.usuario;*/
        Navigator.of(contexto).push(MaterialPageRoute(
            builder: (contexto) => TelaCRUDPedidoVenda(
                pedidoVenda: p, snapshot: snapshot, vendedor: u)));
      },
    );
  }
}
