import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tcc_3/controller/RelatorioItensVendidosController.dart';
import 'package:tcc_3/model/Empresa.dart';
import 'package:tcc_3/model/PedidoVenda.dart';

class RelatorioItensClienteController extends RelatorioItensVendidosController {
  
  Future<Null> obterPedidosRelatorioPorCliente(
       Empresa c, DateTime data1, DateTime data2) async {
    //Esse método busca os pedidos de venda para o cliente selecionado no filtro
    pedidos.clear();
    CollectionReference ref = FirebaseFirestore.instance.collection('pedidos');
    QuerySnapshot obterPedidos =
        await ref.where("label", isEqualTo: c.getRazaoSocial).get();

    obterPedidos.docs.forEach((document) {
      if (document.data()["ehPedidoVenda"] == true) {
        dataPedidoTimeStamp = document.data()["dataPedido"];
        dataPedido = dataPedidoTimeStamp.toDate();

        if (dataPedido.isAfter(data1) && dataPedido.isBefore(data2)) {
          pedido = PedidoVenda.buscarFirebase(document);
          pedidos.add(pedido);
        }
      }
    });
    print(pedidos.length);
  }
}
